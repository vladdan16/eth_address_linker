import 'dart:async';

import '../models/transaction_record.dart';
import 'api.dart';
import 'etherscan_api.dart';
import 'moralis_api.dart';

/// A wrapper around multiple blockchain API implementations
/// that routes calls to the appropriate API based on the operation
class BlockchainApiWrapper implements BlockchainApi {
  final EtherscanApi _etherscanApi;
  final MoralisApi _moralisApi;

  BlockchainApiWrapper(this._etherscanApi, this._moralisApi);

  /// Gets the nametag for an address from the blockchain explorer
  ///
  /// This method routes the call to Moralis API which is specialized for this operation
  /// Returns null if no nametag is found
  @override
  Future<String?> getAddressNametag(String address) async {
    return _moralisApi.getAddressNametag(address);
  }

  /// Gets transactions for an address
  ///
  /// This method routes the call to Etherscan API
  /// If [startTimestamp] and [endTimestamp] are provided, only transactions
  /// within that time range will be returned.
  @override
  Future<List<TransactionRecord>> getTransactionsByAddress(
    String address, {
    int? startTimestamp,
    int? endTimestamp,
  }) async {
    return _etherscanApi.getTransactionsByAddress(
      address,
      startTimestamp: startTimestamp,
      endTimestamp: endTimestamp,
    );
  }

  /// Gets token transfers for an address
  ///
  /// This method routes the call to Etherscan API
  @override
  Future<List<TransactionRecord>> getTokenTransfersByAddress(
    String address,
  ) async {
    return _etherscanApi.getTokenTransfersByAddress(address);
  }

  /// Checks if an address is a contract
  ///
  /// This method routes the call to Etherscan API
  @override
  Future<bool> isContract(String address) async {
    return _etherscanApi.isContract(address);
  }
}
