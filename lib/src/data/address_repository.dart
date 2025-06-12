import 'api/api.dart';
import 'models/transaction_record.dart';

/// Repository for Ethereum address analysis and clustering
class AddressRepository {
  final BlockchainApi _api;

  AddressRepository(this._api);

  /// Gets transactions for an address
  ///
  /// If [startTimestamp] and [endTimestamp] are provided, only transactions
  /// within that time range will be returned.
  Future<List<TransactionRecord>> getTransactionsForAddress(
    String address, {
    int? startTimestamp,
    int? endTimestamp,
  }) async {
    return _api.getTransactionsByAddress(
      address,
      startTimestamp: startTimestamp,
      endTimestamp: endTimestamp,
    );
  }

  /// Gets token transfers for an address
  Future<List<TransactionRecord>> getTokenTransfersForAddress(
    String address,
  ) async {
    return _api.getTokenTransfersByAddress(address);
  }

  /// Checks if an address is a contract
  Future<bool> isContract(String address) async {
    return _api.isContract(address);
  }
}
