import 'dart:convert';

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
}
