import 'dart:io';

import 'models/predicted_pair.dart';
import 'models/tornado_transaction.dart';

class TornadoRepository {
  final _depositsByContract = <String, List<TornadoTransaction>>{};

  final _withdrawalsByContract = <String, List<TornadoTransaction>>{};

  List<String> get contracts => _depositsByContract.keys.toList();

  List<TornadoTransaction>? depositsByContract(String contract) =>
      _depositsByContract[contract];

  List<TornadoTransaction>? withdrawalsByContract(String contract) =>
      _withdrawalsByContract[contract];

  Future<List<TornadoTransaction>> loadTornadoTransactions(
    String filePath,
  ) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      return [];
    }

    final transactions = <TornadoTransaction>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      final parts = line.split(',');
      if (parts.length < 7) continue;

      final transaction = TornadoTransaction(
        index: int.parse(parts[0]),
        timeStamp: int.parse(parts[1]),
        txHash: parts[2],
        action: parts[3],
        account: parts[4],
        amount: double.parse(parts[5]),
        gasPrice: int.parse(parts[6]),
      );

      transactions.add(transaction);
      // _tornadoTransactions[transaction.txHash] = transaction;

      if (transaction.isDeposit) {
        _depositsByContract.putIfAbsent(filePath, () => []);
        _depositsByContract[filePath]?.add(transaction);
      } else if (transaction.isWithdrawal) {
        _withdrawalsByContract.putIfAbsent(filePath, () => []);
        _withdrawalsByContract[filePath]?.add(transaction);
      }
    }

    return transactions;
  }

  Future<List<TornadoTransaction>> loadAlltornadoTransactions() async {
    final transactions = <TornadoTransaction>[];

    const files = [
      'assets/data/tornadoFullHistoryMixer_0.1ETH.csv',
      'assets/data/tornadoFullHistoryMixer_1ETH.csv',
      'assets/data/tornadoFullHistoryMixer_10ETH.csv',
      'assets/data/tornadoFullHistoryMixer_100ETH.csv',
    ];

    for (final file in files) {
      try {
        final txs = await loadTornadoTransactions(file);
        transactions.addAll(txs);
      } on Object catch (e) {
        print('Error loading $file: $e');
      }
    }

    return transactions;
  }

  /// Saves address pairs to a CSV file
  ///
  /// Each pair represents a potential link between a deposit address
  /// and a withdrawal address.
  Future<void> savePairsToCSV(
    Set<(String, String)> pairs, {
    String filePath = 'assets/data/address_pairs.csv',
  }) async {
    final file = File(filePath);

    // Create directory if it doesn't exist
    final directory = file.parent;
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    // Create CSV content with header
    final buffer = StringBuffer()
      ..writeln('deposit_address,withdrawal_address');

    // Add each pair to the CSV
    for (final (deposit, withdrawal) in pairs) {
      buffer.writeln('$deposit,$withdrawal');
    }

    // Write to file
    await file.writeAsString(buffer.toString());

    print('Saved ${pairs.length} address pairs to $filePath');
  }

  Future<void> savePredictionToCSV(
    List<PredictedPair> pairs, {
    String filePath = 'assets/data/predicted_pairs.csv',
  }) async {
    final file = File(filePath);

    // Create directory if it doesn't exist
    final directory = file.parent;
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    // Create CSV content with header
    final buffer = StringBuffer()
      ..writeln('index,depHash,witHash,sender,receiver');

    // Add each pair to the CSV
    for (final pair in pairs) {
      buffer.writeln(
        '${pair.index},${pair.depHash},${pair.witHash},${pair.sender},${pair.receiver}',
      );
    }

    // Write to file
    await file.writeAsString(buffer.toString());

    print('Saved ${pairs.length}');
  }

  Future<List<(String, int)>> loadTopTransitiveAddresses({
    String filePath = 'top_transitive_addresses.csv',
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      return [];
    }

    final topAddresses = <(String, int)>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      final parts = line.split(',');
      if (parts.length < 2) continue;

      topAddresses.add((parts[0], int.parse(parts[1])));
    }

    return topAddresses;
  }
}
