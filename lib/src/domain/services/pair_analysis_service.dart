import '../../data/models/mixer_transaction.dart';
import '../../data/models/predicted_pair.dart';

/// Service for pair analysis
abstract interface class PairAnalysisService {
  /// Generates pairs of likely connected deposit and withdrawal addresses
  Future<List<PredictedPair>> generatePairs({
    required String mixer,
    required List<MixerTransaction> deposits,
    required List<MixerTransaction> withdrawals,
    required int maxDepth,
  });
}
