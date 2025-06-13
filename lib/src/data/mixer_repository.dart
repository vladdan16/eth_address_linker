import 'dart:async';

import 'models/mixer_transaction.dart';
import 'models/predicted_pair.dart';

/// Interface that represents mixer
abstract interface class MixerRepository {
  /// List of all mixers with specific type
  List<String> get mixers;

  /// Retrieve a mixer transaction by its hash
  MixerTransaction? getTransactionByHash(String hash);

  /// Retrieve all deposit transactions for a given contract
  List<MixerTransaction>? depositsByContract(String contract);

  /// Retrieve all withdrawal transactions for a given contract
  List<MixerTransaction>? withdrawalsByContract(String contract);

  /// Loads mixer transactions from a CSV file
  FutureOr<List<MixerTransaction>> loadMixerTransactions(String contract);

  /// Loads all mixer transactions from all files
  FutureOr<List<MixerTransaction>> loadAllMixersTransactions();

  /// Saves address pairs to a CSV file
  FutureOr<void> savePairsToCSV(Set<(String, String)> pairs, {String filename});

  /// Saves predicted transactions to a CSV file
  FutureOr<void> savePredictionToCSV(
    List<PredictedPair> pairs, {
    String filename,
  });

  /// Loads top transitive addresses from a CSV file
  FutureOr<List<(String, int)>> loadTopTransitiveAddresses({String filePath});
}
