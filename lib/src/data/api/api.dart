import 'dart:async';

import '../models/transaction_record.dart';

abstract interface class BlockchainApi {
  /// Gets transactions for an address
  ///
  /// If [startTimestamp] and [endTimestamp] are provided, only transactions
  /// within that time range will be returned.
  FutureOr<List<TransactionRecord>> getTransactionsByAddress(
    String address, {
    int? startTimestamp,
    int? endTimestamp,
  });

  /// Gets token transfers for an address
  FutureOr<List<TransactionRecord>> getTokenTransfersByAddress(String address);

  /// Checks if an address is a contract
  FutureOr<bool> isContract(String address);
}
