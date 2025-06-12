import '../algorithm/union_find.dart';
import '../data/address_repository.dart';
import '../data/labeled_addresses_repository.dart';
import '../data/tornado_repository.dart';
import '../debug.dart';

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

  static const _startTimestamp = 1576526361;
  static const _endTimestamp = 1586497829;

  Future<void> createTxGraph() async {
    final allTransactions = await _tornadoRepository
        .loadAlltornadoTransactions();

    final addresses = allTransactions
        .map((transaction) => transaction.account)
        .where(
          (address) =>
              address.isNotEmpty &&
              !_labeledAddressesRepository.isCommon(address),
        )
        .toSet();

    var index = 1;
    // TODO(vladdan16): implement more depth
    for (final address in addresses) {
      print('Processing address $address ($index/${addresses.length})');
      index++;
      final txHistory = await _addressRepository.getTransactionsForAddress(
        address,
        startTimestamp: _startTimestamp,
        endTimestamp: _endTimestamp,
      );

      for (final tx in txHistory) {
        final (from, to) = (tx.from, tx.to);
        if (from.isEmpty || to.isEmpty) {
          continue;
        }
        // Skip contract addresses
        if (await _addressRepository.isContract(to)) {
          if (isDebug) {
            print('Skipping contract address $to');
          }
          continue;
        }
        // Skip labeled addresses
        // TODO(vladdan16): maybe we don't need this check
        if (_labeledAddressesRepository.isCommon(to)) {
          if (isDebug) {
            print('Skipping labeled address $to');
          }
          continue;
        }
        // Skip tagged addresses
        final fromTag = await _addressRepository.getAddressNametag(tx.from);
        final toTag = await _addressRepository.getAddressNametag(tx.to);
        if (fromTag != null && fromTag.isNotEmpty) {
          if (isDebug) {
            print('Skipping from tagged address $from, tag: $fromTag');
          }
          continue;
        }
        if (toTag != null && toTag.isNotEmpty) {
          if (isDebug) {
            print('Skipping to tagged address $to, tag: $toTag');
          }
          continue;
        }
        _unionFind.union(from, to);
      }
    }

    print('Created transaction graph');
  }

  Future<void> generatePairs() async {
    final pairs = <(String, String)>{};
    final popularTransitiveAddresses = <String, int>{};

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
          // pairs.add((dep, wit));
          final possiblePair = (dep, wit);

          if (isDebug) {
            try {
              // print('Finding path between $dep and $wit');
              final path = _unionFind.findPath(dep, wit, maxDepth: 4);
              if (path == null) {
                // print('Path between $dep and $wit exceeds maximum depth');
              } else if (path.isNotEmpty) {
                // print('Connection path: ${path.join(' -> ')}');
                path.sublist(1, path.length - 1).forEach((address) {
                  popularTransitiveAddresses[address] =
                      (popularTransitiveAddresses[address] ?? 0) + 1;
                });
                pairs.add(possiblePair);
              }
            } on Object catch (e) {
              // print('Error finding path between $dep and $wit: $e');
            }
          } else {
            pairs.add(possiblePair);
          }
        }
      }
    }
    print('Found ${pairs.length} address pairs');

    // save pairs to csv file
    await _tornadoRepository.savePairsToCSV(pairs);

    print('Saved ${pairs.length} address pairs to CSV file');

    if (isDebug) {
      final sortedEntries = popularTransitiveAddresses.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      print('Top 20 popular transitive addresses:');
      sortedEntries
          .take(20)
          .forEach((entry) => print('${entry.key}: ${entry.value}'));
    }
  }

  /// Gets the nametag for an Ethereum address
  ///
  /// Returns null if no nametag is found
  Future<String?> getAddressNametag(String address) async {
    return _addressRepository.getAddressNametag(address);
  }
}
