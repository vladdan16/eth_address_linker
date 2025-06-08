import 'dart:io';

import 'models/tornado_transaction.dart';

class TornadoRepository {
  /// Map of transaction hash to Tornado transaction
  final Map<String, TornadoTransaction> _tornadoTransactions = {};

  /// Map of deposit transactions by account
  final Map<String, List<TornadoTransaction>> _depositsByAccount = {};

  /// Map of withdrawal transactions by account
  final Map<String, List<TornadoTransaction>> _withdrawalsByAccount = {};

  List<String> get depositAddresses => _depositsByAccount.keys.toList();

  List<String> get withdrawalAddresses => _withdrawalsByAccount.keys.toList();

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
      _tornadoTransactions[transaction.txHash] = transaction;

      if (transaction.isDeposit) {
        _depositsByAccount
            .putIfAbsent(transaction.account, () => [])
            .add(transaction);
      } else if (transaction.isWithdrawal) {
        _withdrawalsByAccount
            .putIfAbsent(transaction.account, () => [])
            .add(transaction);
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
}
