import '../../../data/mixer_repository.dart';
import '../../../data/models/mixer_transaction.dart';
import '../../../data/models/predicted_pair.dart';
import '../../../debug.dart';
import '../graph_service.dart';
import '../pair_analysis_service.dart';

class PairAnalysisServiceImpl implements PairAnalysisService {
  final GraphService _graphService;
  final MixerRepository _mixerRepository;

  const PairAnalysisServiceImpl(this._graphService, this._mixerRepository);

  @override
  Future<List<PredictedPair>> generatePairs({
    required String mixer,
    required List<MixerTransaction> deposits,
    required List<MixerTransaction> withdrawals,
    required int maxDepth,
  }) async {
    final pairs = <PredictedPair>[];
    final detectedTransactions = <String>{};
    final popularTransitiveAddresses = <String, int>{};
    var index = 0;

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

        if (!_isPotentialPair(dep, wit)) {
          continue;
        }

        // Skip if transaction already used in another pair
        if (detectedTransactions.contains(dep.txHash) ||
            detectedTransactions.contains(wit.txHash)) {
          continue;
        }

        if (_graphService.isConnected(
          dep.account,
          wit.account,
          maxDepth: maxDepth,
        )) {
          final possiblePair = PredictedPair(
            index: index,
            depHash: dep.txHash,
            witHash: wit.txHash,
            sender: dep.account,
            receiver: wit.account,
          );

          if (isDebug) {
            try {
              final path = _graphService.findPath(
                dep.account,
                wit.account,
                maxDepth: maxDepth,
              );
              if (path == null) {
                // No path found within max depth
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

    return pairs;
  }

  bool _isPotentialPair(MixerTransaction dep, MixerTransaction wit) {
    // Skip if same account
    if (dep.account == wit.account) {
      return false;
    }

    // Skip if withdrawal is not chronologically after deposit
    if (wit.timeStamp <= dep.timeStamp) {
      return false;
    }

    return true;
  }
}
