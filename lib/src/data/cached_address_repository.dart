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
    String address,
  ) async {
    final cacheKey = '$_transactionsCacheKeyPrefix$address';

    // Try to get data from cache first
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

    // If not in cache, fetch from API
    final transactions = await _api.getTransactionsByAddress(address);

    // Cache the result
    await _cacheService.set(
      cacheKey,
      transactions.map((tx) => tx.toJson()).toList(),
    );

    return transactions;
  }

  /// Gets token transfers for an address with caching
  @override
  Future<List<TransactionRecord>> getTokenTransfersForAddress(
    String address,
  ) async {
    final cacheKey = '$_tokenTransfersCacheKeyPrefix$address';

    // Try to get data from cache first
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

    // If not in cache, fetch from API
    final tokenTransfers = await _api.getTokenTransfersByAddress(address);

    // Cache the result
    await _cacheService.set(
      cacheKey,
      tokenTransfers.map((tx) => tx.toJson()).toList(),
    );

    return tokenTransfers;
  }

  /// Clears the cache for a specific address
  Future<void> clearCacheForAddress(String address) async {
    await _cacheService.remove('$_transactionsCacheKeyPrefix$address');
    await _cacheService.remove('$_tokenTransfersCacheKeyPrefix$address');
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
    const tornadoContracts = {
      '0x12D66f87A04A9E220743712cE6d9bB1B5616B8Fc',
      '0x47CE0C6eD5B0Ce3d3A51fdb1C52DC66a7c3c2936',
      '0x910Cbd523D972eb0a6f4cAe4618aD62622b39DbF',
      '0xA160cdAB225685dA1d56aa342Ad8841c3b53f291',
    };

    if (tornadoContracts.contains(address)) {
      return true;
    }

    final cacheKey = '$_isContractCacheKeyPrefix$address';

    // Try to get data from cache first
    if (await _cacheService.has(cacheKey)) {
      final cachedData = await _cacheService.get<bool>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }
    }

    // If not in cache, fetch from API
    final isContract = await _api.isContract(address);

    // Cache the result - contract status doesn't change, so we can cache it indefinitely
    await _cacheService.set(cacheKey, isContract);

    return isContract;
  }
}
