import 'dart:async';

import '../models/transaction_record.dart';

abstract interface class BlockchainApi {
  FutureOr<List<TransactionRecord>> getTransactionsByAddress(String address);

  FutureOr<List<TransactionRecord>> getTokenTransfersByAddress(String address);

  FutureOr<bool> isContract(String address);
}
