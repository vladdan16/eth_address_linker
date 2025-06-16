import '../algorithm/graph_algorithm.dart';
import '../data/address_repository.dart';
import '../data/labeled_addresses_repository.dart';
import '../data/mixer_repository.dart';
import '../data/models/predicted_pair.dart';
import '../debug.dart';

class Interactor {
  final AddressRepository _addressRepository;
  final MixerRepository _mixerRepository;
  final LabeledAddressesRepository _labeledAddressesRepository;
  final GraphAlgorithm<String> _graphAlgorithm;

  const Interactor(
    this._addressRepository,
    this._mixerRepository,
    this._labeledAddressesRepository,
    this._graphAlgorithm,
  );

  // Default timestamp values if not provided via CLI
  static const defaultStartTimestamp = 1546354022; // Jan 1, 2019
  static const defaultEndTimestamp = 1659970022; // Aug 8, 2022

  Future<void> createTxGraph({int? startTimestamp, int? endTimestamp}) async {
    final effectiveStartTimestamp = startTimestamp ?? defaultStartTimestamp;
    final effectiveEndTimestamp = endTimestamp ?? defaultEndTimestamp;

    print('''
Using time range: ${DateTime.fromMillisecondsSinceEpoch(effectiveStartTimestamp * 1000)} to ${DateTime.fromMillisecondsSinceEpoch(effectiveEndTimestamp * 1000)}
''');
    final allTransactions = await _mixerRepository.loadAllMixersTransactions();

    final addresses = allTransactions
        .map((transaction) => transaction.account)
        .where(
          (address) =>
              address.isNotEmpty &&
              !_labeledAddressesRepository.isCommon(address),
        )
        .toSet();

    var index = 1;
    for (final address in addresses) {
      print('Processing address $address ($index/${addresses.length})');
      index++;
      final txHistory = await _addressRepository.getTransactionsForAddress(
        address,
        startTimestamp: effectiveStartTimestamp,
        endTimestamp: effectiveEndTimestamp,
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

        // Skip addresses with too big tx history
        final addressToCheck = address == to ? from : to;
        final txs = await _addressRepository.getTransactionsForAddress(
          addressToCheck,
          startTimestamp: effectiveStartTimestamp,
          endTimestamp: effectiveEndTimestamp,
          limit: 20000,
        );
        if (txs.length > 1000) {
          if (isDebug) {
            print('Skipping address $addressToCheck with too big tx history');
          }
          continue;
        }

        _graphAlgorithm.addEdge(from, to);
      }
    }

    print('Created transaction graph');
  }

  /// Generate predicted pairs for each mixer
  Future<void> generatePairs() async {
    final mixers = _mixerRepository.mixers;

    for (final mixer in mixers) {
      print('\nGenerating pairs for mixer $mixer');

      final pairs = <PredictedPair>[];
      // Transaction hashes that have already beed added to predicted pairs
      final detectedTransactions = <String>{};
      final popularTransitiveAddresses = <String, int>{};
      var index = 0;

      final deposits = _mixerRepository.depositsByMixer(mixer)!;
      final withdrawals = _mixerRepository.withdrawalsByMixer(mixer)!;

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

          // Skip if same account
          if (dep.account == wit.account) {
            continue;
          }

          // Skip if transaction already used in another pair
          if (detectedTransactions.contains(dep.txHash) ||
              detectedTransactions.contains(wit.txHash)) {
            continue;
          }

          // Skip if withdrawal is not chronologically after deposit
          if (wit.timeStamp <= dep.timeStamp) {
            continue;
          }

          if (_graphAlgorithm.connected(dep.account, wit.account)) {
            final possiblePair = PredictedPair(
              index: index,
              depHash: dep.txHash,
              witHash: wit.txHash,
              sender: dep.account,
              receiver: wit.account,
            );

            if (isDebug) {
              try {
                final path = _graphAlgorithm.findPath(
                  dep.account,
                  wit.account,
                  maxDepth: 4,
                );
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
      print('Found ${pairs.length} address pairs for contract $mixer');

      await _mixerRepository.savePredictionToCSV(
        pairs,
        filename: 'heuristic4$mixer.csv',
      );

      print('Saved ${pairs.length} address pairs to CSV file');

      if (isDebug) {
        final sortedEntries = popularTransitiveAddresses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final top = sortedEntries
            .where((entry) => entry.value > 1)
            .map((entry) => (entry.key, entry.value.toString()))
            .toSet();
        await _mixerRepository.savePairsToCSV(
          top,
          filename: 'top_transitive_addresses_$mixer.csv',
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
    print('Processing top transitive addresses');
    for (final contract in _mixerRepository.mixers) {
      print('Processing top transitive addresses for contract $contract');
      final topTransitiveAddresses = await _mixerRepository
          .loadTopTransitiveAddresses(
            filePath: 'assets/result/top_transitive_addresses_$contract.csv',
          );
      if (isDebug) {
        print('''
Processing ${topTransitiveAddresses.length} top transitive addresses for contract $contract
''');
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
}
