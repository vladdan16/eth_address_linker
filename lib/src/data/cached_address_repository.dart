import 'address_repository.dart';
import 'api/api.dart';
import 'cache/cache_service.dart';
import 'models/transaction_record.dart';

/// Repository for Ethereum address analysis and clustering with caching
class CachedAddressRepository implements AddressRepository {
  final BlockchainApi _api;
  final CacheService _cacheService;

  const CachedAddressRepository(this._api, this._cacheService);

  /// Cache key prefix for transactions
  static const String _transactionsCacheKeyPrefix = 'transactions_';

  /// Cache key prefix for token transfers
  static const String _tokenTransfersCacheKeyPrefix = 'token_transfers_';

  /// Gets transactions for an address with caching
  @override
  Future<List<TransactionRecord>> getTransactionsForAddress(
    String address, {
    int? startTimestamp,
    int? endTimestamp,
    int? limit,
  }) async {
    final cacheKey = '$_transactionsCacheKeyPrefix$address';

    if (await _cacheService.has(cacheKey)) {
      final cachedData = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedData != null) {
        return cachedData
            .map(
              (item) => TransactionRecord.fromJson(
                Map<String, Object?>.from(item as Map<String, dynamic>),
              ),
            )
            .where(
              (tx) => _filterTransactionByTime(
                tx,
                start: startTimestamp,
                end: endTimestamp,
              ),
            )
            .toList();
      }
    }

    try {
      final transactions = await _api.getTransactionsByAddress(
        address,
        startTimestamp: startTimestamp,
        endTimestamp: endTimestamp,
        limit: limit,
      );

      await _cacheService.set(
        cacheKey,
        transactions.map((tx) => tx.toJson()).toList(),
      );

      return transactions;
    } on Object catch (e) {
      print('Error getting transactions for address $address: $e');
      return [];
    }
  }

  /// Gets token transfers for an address with caching
  @override
  Future<List<TransactionRecord>> getTokenTransfersForAddress(
    String address,
  ) async {
    final cacheKey = '$_tokenTransfersCacheKeyPrefix$address';

    if (await _cacheService.has(cacheKey)) {
      final cachedData = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedData != null) {
        return cachedData
            .map(
              (item) => TransactionRecord.fromJson(
                Map<String, Object?>.from(item as Map<String, dynamic>),
              ),
            )
            .toList();
      }
    }

    final tokenTransfers = await _api.getTokenTransfersByAddress(address);

    await _cacheService.set(
      cacheKey,
      tokenTransfers.map((tx) => tx.toJson()).toList(),
    );

    return tokenTransfers;
  }

  /// Cache key prefix for address nametags
  static const String _nametagCacheKeyPrefix = 'nametag_';

  /// Gets the nametag for an address with caching
  @override
  Future<String?> getAddressNametag(String address) async {
    final cacheKey = '$_nametagCacheKeyPrefix$address';

    if (await _cacheService.has(cacheKey)) {
      final cachedData = await _cacheService.get<String?>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }
    }

    final nametag = await _api.getAddressNametag(address);

    await _cacheService.set(cacheKey, nametag);

    return nametag;
  }

  /// Clears the cache for a specific address
  Future<void> clearCacheForAddress(String address) async {
    await _cacheService.remove('$_transactionsCacheKeyPrefix$address');
    await _cacheService.remove('$_tokenTransfersCacheKeyPrefix$address');
    await _cacheService.remove('$_nametagCacheKeyPrefix$address');
  }

  /// Clears all cached data
  Future<void> clearAllCache() async {
    await _cacheService.clear();
  }

  /// Cache key prefix for contract checks
  static const String _isContractCacheKeyPrefix = 'is_contract_';

  /// Checks if an address is a contract with caching
  @override
  Future<bool> isContract(String address) async {
    final cacheKey = '$_isContractCacheKeyPrefix$address';

    if (await _cacheService.has(cacheKey)) {
      final cachedData = await _cacheService.get<bool>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }
    }

    final isContract = await _api.isContract(address);

    await _cacheService.set(cacheKey, isContract);

    return isContract;
  }

  bool _filterTransactionByTime(
    TransactionRecord transaction, {
    int? start,
    int? end,
  }) {
    if (start == null && end == null) {
      return true;
    }

    final timestamp = int.parse(transaction.timeStamp);

    if (start != null && timestamp < start) {
      return false;
    }

    if (end != null && timestamp > end) {
      return false;
    }

    return true;
  }
}
