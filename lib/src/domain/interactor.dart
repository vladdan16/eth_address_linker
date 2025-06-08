import '../algorithm/union_find.dart';
import '../data/address_repository.dart';
import '../data/labeled_addresses_repository.dart';
import '../data/tornado_repository.dart';

class Interactor {
  final AddressRepository _addressRepository;
  final TornadoRepository _tornadoRepository;
  final LabeledAddressesRepository _labeledAddressesRepository;
  final UnionFind<String> _unionFind;

  const Interactor(
    this._addressRepository,
    this._tornadoRepository,
    this._labeledAddressesRepository,
    this._unionFind,
  );

  Future<void> createTxGraph() async {
    final allTransactions = await _tornadoRepository
        .loadAlltornadoTransactions();

    final addresses = allTransactions
        .map((transaction) => transaction.account)
        .where(
          (address) =>
              address.isNotEmpty &&
              !_labeledAddressesRepository.isLabeled(address),
        )
        .toSet();

    // TODO(vladdan16): implement more depth
    for (final address in addresses) {
      final txHistory = await _addressRepository.getTransactionsForAddress(
        address,
      );

      for (final tx in txHistory) {
        final (from, to) = (tx.from, tx.to);
        if (from.isEmpty || to.isEmpty) {
          continue;
        }
        _unionFind.union(from, to);
      }
    }
  }

  Future<void> generatePairs() async {
    final pairs = <(String, String)>{};

    final deposits = _tornadoRepository.depositAddresses;
    final withdrawals = _tornadoRepository.withdrawalAddresses;

    for (var i = 0; i < deposits.length; i++) {
      for (var j = 0; j < withdrawals.length; j++) {
        final dep = deposits[i];
        final wit = withdrawals[j];
        if (dep == wit) {
          continue;
        }
        if (_unionFind.connected(dep, wit)) {
          pairs.add((dep, wit));
        }
      }
    }
    // TODO: save pairs to csv file
  }
}
