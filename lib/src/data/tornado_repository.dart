import 'dart:io';

import 'models/predicted_pair.dart';
import 'models/tornado_transaction.dart';

class TornadoRepository {
  final _depositsByContract = <String, List<TornadoTransaction>>{};

  final _withdrawalsByContract = <String, List<TornadoTransaction>>{};

  /// Returns a list of all contracts
  late final List<String> contracts = [
    'Mixer_0.1ETH',
    'Mixer_1ETH',
    'Mixer_10ETH',
    'Mixer_100ETH',
  ];

  /// Retrieve all deposit transactions for a given contract
  List<TornadoTransaction>? depositsByContract(String contract) =>
      _depositsByContract[contract];

  /// Retrieve all withdrawal transactions for a given contract
  List<TornadoTransaction>? withdrawalsByContract(String contract) =>
      _withdrawalsByContract[contract];

  /// Loads tornado transactions from a CSV file
  Future<List<TornadoTransaction>> loadTornadoTransactions(
    String contract,
  ) async {
    final filePath = 'assets/data/tornadoFullHistory$contract.csv';
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

      if (transaction.isDeposit) {
        _depositsByContract.putIfAbsent(contract, () => []);
        _depositsByContract[contract]?.add(transaction);
      } else if (transaction.isWithdrawal) {
        _withdrawalsByContract.putIfAbsent(contract, () => []);
        _withdrawalsByContract[contract]?.add(transaction);
      }
    }

    return transactions;
  }

  /// Loads all tornado transactions from all files
  Future<List<TornadoTransaction>> loadAlltornadoTransactions() async {
    final transactions = <TornadoTransaction>[];

    for (final contract in contracts) {
      try {
        final txs = await loadTornadoTransactions(contract);
        transactions.addAll(txs);
      } on Object catch (e) {
        print('Error loading transaction from contract $contract: $e');
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
    String filename = 'pairs.csv',
  }) async {
    final filePath = 'assets/result/$filename';
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

  /// Saves predicted transactions to a CSV file
  Future<void> savePredictionToCSV(
    List<PredictedPair> pairs, {
    String filename = 'predicted_pairs.csv',
  }) async {
    final filePath = 'assets/result/$filename';
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
    for (final p in pairs) {
      buffer.writeln(
        '${p.index},${p.depHash},${p.witHash},${p.sender},${p.receiver}',
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
