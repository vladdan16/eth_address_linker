import '../algorithm/union_find.dart';
import '../data/address_repository.dart';
import '../data/labeled_addresses_repository.dart';
import '../data/models/predicted_pair.dart';
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
        // Skip common addresses
        if (_labeledAddressesRepository.isCommon(to) ||
            _labeledAddressesRepository.isCommon(from)) {
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

  /// Generate predicted pairs for each contract
  Future<void> generatePairs() async {
    final contracts = _tornadoRepository.contracts;

    for (final contract in contracts) {
      final pairs = <PredictedPair>[];
      // Transaction hashes that have already beed added to predicted pairs
      final detectedTransactions = <String>{};
      final popularTransitiveAddresses = <String, int>{};
      var index = 0;

      final deposits = _tornadoRepository.depositsByContract(contract)!;
      final withdrawals = _tornadoRepository.withdrawalsByContract(contract)!;

      print('''
Checking connections between ${deposits.length} deposits and ${withdrawals.length} withdrawals...
''');

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
          if (dep.account == wit.account) {
            continue;
          }
          if (detectedTransactions.contains(dep.txHash) ||
              detectedTransactions.contains(wit.txHash)) {
            continue;
          }
          if (_unionFind.connected(dep.account, wit.account)) {
            final possiblePair = PredictedPair(
              index: index,
              depHash: dep.txHash,
              witHash: wit.txHash,
              sender: dep.account,
              receiver: wit.account,
            );

            if (isDebug) {
              try {
                final path = _unionFind.findPath(dep.account, wit.account);
                if (path == null) {
                } else if (path.isNotEmpty) {
                  print('Connection path: ${path.join(' -> ')}');
                  path.sublist(1, path.length - 1).forEach((address) {
                    popularTransitiveAddresses[address] =
                        (popularTransitiveAddresses[address] ?? 0) + 1;
                  });
                  pairs.add(possiblePair);
                  detectedTransactions
                    ..add(dep.txHash)
                    ..add(wit.txHash);
                  index++;
                }
              } on Object catch (e) {
                print('Error finding path between $dep and $wit: $e');
              }
            } else {
              pairs.add(possiblePair);
              detectedTransactions
                ..add(dep.txHash)
                ..add(wit.txHash);
              index++;
            }
          }
        }
      }
      print('Found ${pairs.length} address pairs for contract $contract');

      await _tornadoRepository.savePredictionToCSV(
        pairs,
        filename: 'heuristic4$contract.csv',
      );

      print('Saved ${pairs.length} address pairs to CSV file');

      if (isDebug) {
        final sortedEntries = popularTransitiveAddresses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final top = sortedEntries
            .where((entry) => entry.value > 1)
            .map((entry) => (entry.key, entry.value.toString()))
            .toSet();
        await _tornadoRepository.savePairsToCSV(
          top,
          filename: 'top_transitive_addresses_$contract.csv',
        );
      }
    }
  }

  /// Gets the nametag for an Ethereum address
  ///
  /// Returns null if no nametag is found
  Future<String?> getAddressNametag(String address) async {
    return _addressRepository.getAddressNametag(address);
  }

  /// Retrieve tags for top transitive addresses
  Future<void> processTopTransitiveAddresses() async {
    final topTransitiveAddresses = await _tornadoRepository
        .loadTopTransitiveAddresses();
    if (isDebug) {
      print(
        'Processing ${topTransitiveAddresses.length} top transitive addresses',
      );
    }
    for (final (address, _) in topTransitiveAddresses) {
      final tag = await _addressRepository.getAddressNametag(address);
      if (isDebug) {
        if (tag != null && tag.isNotEmpty) {
          print('Found tag for address: $address - tag: $tag');
        }
      }
    }
  }
}
