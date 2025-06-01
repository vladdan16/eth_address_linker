import 'api/api.dart';
import 'models/transaction_record.dart';

/// Repository for Ethereum address analysis and clustering
class AddressRepository {
  final BlockchainApi _api;

  AddressRepository(this._api);

  /// Gets transactions for an address
  Future<List<TransactionRecord>> getTransactionsForAddress(
    String address,
  ) async {
    return _api.getTransactionsByAddress(address);
  }

  /// Gets token transfers for an address
  Future<List<TransactionRecord>> getTokenTransfersForAddress(
    String address,
  ) async {
    return _api.getTokenTransfersByAddress(address);
  }
}
