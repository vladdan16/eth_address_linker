import 'dart:async';

import 'package:dio/dio.dart';

import '../models/transaction_record.dart';
import 'api.dart';

/// Exception thrown when Moralis API rate limit is reached
class MoralisRateLimitException implements Exception {
  const MoralisRateLimitException(this.message, this.retryAfter);

  final String message;
  final Duration retryAfter;

  @override
  String toString() =>
      'MoralisRateLimitException: $message. Retry after $retryAfter';
}

/// Implementation of the Moralis API client
class MoralisApi implements BlockchainApi {
  MoralisApi(this._dio);

  final Dio _dio;

  /// Default delay between API calls to avoid rate limiting
  static const Duration _defaultRateLimitDelay = Duration(milliseconds: 300);

  /// Current rate limit delay, may be adjusted based on API responses
  Duration _currentRateLimitDelay = _defaultRateLimitDelay;

  /// Last API call timestamp for rate limiting
  DateTime? _lastApiCallTime;

  bool _isQuotaExceeded = false;

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

  /// Makes a rate-limited API call to Moralis
  Future<Response<T>> _makeApiCall<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await _handleRateLimit();

    try {
      final response = await _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
      );

      // Check if we need to adjust rate limiting based on response
      final headers = response.headers;
      if (headers.map.containsKey('x-rate-limit-remaining')) {
        final remaining = int.tryParse(
          headers.value('x-rate-limit-remaining') ?? '',
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
        throw MoralisRateLimitException('Rate limit exceeded', retryAfter);
      }
      rethrow;
    }
  }

  /// Gets the nametag for an address from Moralis API
  ///
  /// This method fetches transaction history from Moralis API and extracts
  /// address labels from the transactions.
  @override
  Future<String?> getAddressNametag(String address) async {
    if (_isQuotaExceeded) {
      return null;
    }

    try {
      final normalizedAddress = address.toLowerCase();

      final response = await _makeApiCall<Map<String, Object?>>(
        '/$normalizedAddress',
      );

      final data = response.data;
      if (data == null) {
        return null;
      }

      final result = data['result'] as List<Object?>?;
      if (result == null || result.isEmpty) {
        return null;
      }

      final transaction = result[0]! as Map<String, Object?>;
      if (transaction['to_address']?.toString().toLowerCase() ==
              normalizedAddress &&
          transaction['to_address_label'] != null &&
          transaction['to_address_label'].toString().isNotEmpty) {
        return transaction['to_address_label'].toString();
      }

      if (transaction['from_address']?.toString().toLowerCase() ==
              normalizedAddress &&
          transaction['from_address_label'] != null &&
          transaction['from_address_label'].toString().isNotEmpty) {
        return transaction['from_address_label'].toString();
      }

      return '';
    } on MoralisRateLimitException catch (e) {
      print(
        'Rate limit exceeded when getting nametag for $address: ${e.message}',
      );

      await Future<void>.delayed(e.retryAfter);
      return getAddressNametag(address);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('Quota limit exceeded for Moralis API or token is invalid');
        print(e);
        print('Skipping all subsequent requests for address to API');
        _isQuotaExceeded = true;
        return null;
      }

      print(
        'Error getting nametag from Moralis for address $address: ${e.message}',
      );
      return null;
    } on Object catch (e) {
      print('Error getting nametag from Moralis for address $address: $e');
      return null;
    }
  }

  @override
  FutureOr<List<TransactionRecord>> getTokenTransfersByAddress(String address) {
    // We don't implement it for now. It is enough to utilize Etherscan Api
    throw UnimplementedError();
  }

  @override
  FutureOr<List<TransactionRecord>> getTransactionsByAddress(
    String address, {
    int? startTimestamp,
    int? endTimestamp,
  }) {
    // We don't implement it for now. It is enough to utilize Etherscan Api
    throw UnimplementedError();
  }

  @override
  FutureOr<bool> isContract(String address) {
    // We don't implement it for now. It is enough to utilize Etherscan Api
    throw UnimplementedError();
  }
}
