import 'dart:async';

import 'package:dio/dio.dart';

import '../models/transaction_record.dart';
import 'api.dart';

/// Exception thrown when Etherscan API rate limit is reached
class RateLimitException implements Exception {
  const RateLimitException(this.message, this.retryAfter);

  final String message;
  final Duration retryAfter;

  @override
  String toString() => 'RateLimitException: $message. Retry after $retryAfter';
}

/// Implementation of the Etherscan API client
final class EtherscanApi implements BlockchainApi {
  EtherscanApi(this._dio);

  final Dio _dio;

  /// Maximum number of items per page in Etherscan API
  static const int _maxItemsPerPage = 10000;

  /// Default delay between API calls to avoid rate limiting
  static const Duration _defaultRateLimitDelay = Duration(milliseconds: 200);

  /// Current rate limit delay, may be adjusted based on API responses
  Duration _currentRateLimitDelay = _defaultRateLimitDelay;

  /// Last API call timestamp for rate limiting
  DateTime? _lastApiCallTime;

  /// Handles rate limiting by delaying API calls if needed
  Future<void> _handleRateLimit() async {
    if (_lastApiCallTime != null) {
      final timeSinceLastCall = DateTime.now().difference(_lastApiCallTime!);
      if (timeSinceLastCall < _currentRateLimitDelay) {
        final waitTime = _currentRateLimitDelay - timeSinceLastCall;
        await Future<void>.delayed(waitTime);
      }
    }
    _lastApiCallTime = DateTime.now();
  }

  /// Makes a rate-limited API call to Etherscan
  Future<Response<T>> _makeApiCall<T>(
    String module,
    String action,
    Map<String, Object?> params,
  ) async {
    await _handleRateLimit();

    try {
      final response = await _dio.get<T>(
        '/api',
        queryParameters: {'module': module, 'action': action, ...params},
      );

      // Check if we need to adjust rate limiting based on response
      final headers = response.headers;
      if (headers.map.containsKey('x-ratelimit-remaining')) {
        final remaining = int.tryParse(
          headers.value('x-ratelimit-remaining') ?? '',
        );
        if (remaining != null && remaining < 5) {
          // Increase delay when approaching rate limit
          _currentRateLimitDelay = Duration(
            milliseconds: _currentRateLimitDelay.inMilliseconds * 2,
          );
        } else if (remaining != null && remaining > 20) {
          // Decrease delay when far from rate limit, but not below default
          final newDelay = Duration(
            milliseconds: _currentRateLimitDelay.inMilliseconds ~/ 1.5,
          );
          if (newDelay >= _defaultRateLimitDelay) {
            _currentRateLimitDelay = newDelay;
          }
        }
      }

      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        // Handle rate limiting
        final retryAfter = Duration(
          seconds:
              int.tryParse(e.response?.headers.value('retry-after') ?? '5') ??
              5,
        );
        _currentRateLimitDelay = retryAfter;
        throw RateLimitException('Rate limit exceeded', retryAfter);
      }
      rethrow;
    }
  }

  /// Handles pagination for Etherscan API calls
  Future<List<TransactionRecord>> _getPaginatedResults(
    String module,
    String action,
    String address, {
    int startBlock = 0,
    int endBlock = 99999999,
    String? contractAddress,
  }) async {
    final List<TransactionRecord> allTransactions = [];
    int page = 1;
    bool hasMoreData = true;

    while (hasMoreData) {
      final params = <String, Object?>{
        'address': address,
        'startblock': startBlock.toString(),
        'endblock': endBlock.toString(),
        'page': page.toString(),
        'offset': (_maxItemsPerPage ~/ page).toString(),
      };

      if (contractAddress != null) {
        params['contractaddress'] = contractAddress;
      }

      try {
        final response = await _makeApiCall<Map<String, Object?>>(
          module,
          action,
          params,
        );

        final data = response.data;
        if (data == null || data['status'] != '1') {
          final message = data?['message'] as String? ?? 'Unknown error';
          if (message.toLowerCase().contains('no transactions found')) {
            // No error, just no more transactions
            break;
          }
          throw Exception('Etherscan API error: $message');
        }

        final result = data['result']! as List<Object?>;
        if (result.isEmpty) {
          hasMoreData = false;
          break;
        }

        final transactions = result
            .map(
              (tx) => TransactionRecord.fromJson(
                Map<String, Object?>.from(tx! as Map<String, Object?>),
              ),
            )
            .toList();

        allTransactions.addAll(transactions);

        // If we got less than the maximum items per page, we've reached the end
        if (transactions.length < _maxItemsPerPage) {
          hasMoreData = false;
        } else {
          page++;
        }
      } on RateLimitException catch (e) {
        // Wait and retry on rate limit
        await Future<void>.delayed(e.retryAfter);
      }
    }

    return allTransactions;
  }

  @override
  Future<List<TransactionRecord>> getTransactionsByAddress(
    String address,
  ) async {
    return _getPaginatedResults('account', 'txlist', address);
  }

  @override
  Future<List<TransactionRecord>> getTokenTransfersByAddress(
    String address,
  ) async {
    return _getPaginatedResults('account', 'tokentx', address);
  }

  /// Gets ERC20 token transfers for a specific token contract and address
  Future<List<TransactionRecord>> getErc20TransfersByContract(
    String address,
    String contractAddress,
  ) async {
    return _getPaginatedResults(
      'account',
      'tokentx',
      address,
      contractAddress: contractAddress,
    );
  }

  /// Gets internal transactions for an address
  Future<List<TransactionRecord>> getInternalTransactionsByAddress(
    String address,
  ) async {
    return _getPaginatedResults('account', 'txlistinternal', address);
  }

  @override
  Future<bool> isContract(String address) async {
    try {
      final response = await _makeApiCall<Map<String, Object?>>(
        'proxy',
        'eth_getCode',
        {'address': address, 'tag': 'latest'},
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Etherscan API error: No data returned');
      }

      final result = data['result'] as String?;
      if (result == null) {
        throw Exception('Etherscan API error: No result returned');
      }

      // If the address has code (result is not '0x' or '0x0'), it's a contract
      // '0x' or '0x0' means there's no code at this address
      // (it's an EOA - Externally Owned Account)
      return result != '0x' && result != '0x0';
    } on Object catch (e) {
      // If there's an error, assume it's not a contract
      print('Error checking if address $address is a contract: $e');
      return false;
    }
  }
}
