
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

    var index = 1;
    // TODO(vladdan16): implement more depth
    for (final address in addresses) {
      print('Processing address $address ($index/${addresses.length})');
      index++;
      final txHistory = await _addressRepository.getTransactionsForAddress(
        address,
      );

      for (final tx in txHistory) {
        final (from, to) = (tx.from, tx.to);
        if (from.isEmpty || to.isEmpty) {
          continue;
        }
        // Skip labeled addresses
        if (_labeledAddressesRepository.isLabeled(from) ||
            _labeledAddressesRepository.isLabeled(to)) {
          continue;
        }
        if (await _addressRepository.isContract(to)) {
          // print('Skipping contract $to');
          continue;
        }
        _unionFind.union(from, to);
      }
    }

    print('Created transaction graph');
  }

  Future<void> generatePairs() async {
    final pairs = <(String, String)>{};

    final deposits = _tornadoRepository.depositAddresses;
    final withdrawals = _tornadoRepository.withdrawalAddresses;

    print(
      'Checking connections between ${deposits.length} deposits and ${withdrawals.length} withdrawals...',
    );

    final total = deposits.length * withdrawals.length;
    print('Total number of connections to check: $total');
    var current = 1;

    for (var i = 0; i < deposits.length; i++) {
      for (var j = 0; j < withdrawals.length; j++) {
        if (current % 1000 == 0) {
          print('Checked $current connections');
        }
        current++;
        final dep = deposits[i];
        final wit = withdrawals[j];
        if (dep == wit) {
          continue;
        }
        if (_unionFind.connected(dep, wit)) {
          pairs.add((dep, wit));

          if (_unionFind.debug) {
            try {
              print('Finding path between $dep and $wit');
              final path = _unionFind.findPath(dep, wit);
              if (path.isNotEmpty) {
                print('Connection path: ${path.join(' -> ')}');
              }
            } on Object catch (e) {
              print('Error finding path between $dep and $wit: $e');
            }
          }
        }
      }
    }
    print('Found ${pairs.length} address pairs');

    // save pairs to csv file
    await _tornadoRepository.savePairsToCSV(pairs);

    print('Saved ${pairs.length} address pairs to CSV file');
  }
}
