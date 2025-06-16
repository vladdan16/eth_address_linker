import 'dart:io';

import 'mixer_repository.dart';
import 'models/mixer_transaction.dart';
import 'models/predicted_pair.dart';

final class TornadoRepository implements MixerRepository {
  final _depositsByMixer = <String, List<MixerTransaction>>{};

  final _withdrawalsByMixer = <String, List<MixerTransaction>>{};

  final _txByHash = <String, MixerTransaction>{};

  @override
  final List<String> mixers = [
    'Mixer_0.1ETH',
    'Mixer_1ETH',
    'Mixer_10ETH',
    'Mixer_100ETH',
  ];

  @override
  MixerTransaction? getTransactionByHash(String hash) => _txByHash[hash];

  @override
  List<MixerTransaction>? depositsByMixer(String mixer) =>
      _depositsByMixer[mixer];

  @override
  List<MixerTransaction>? withdrawalsByMixer(String mixer) =>
      _withdrawalsByMixer[mixer];

  /// Loads tornado transactions from a CSV file
  @override
  Future<List<MixerTransaction>> loadMixerTransactions(String mixer) async {
    final filePath = 'assets/data/tornadoFullHistory$mixer.csv';
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      return [];
    }

    final transactions = <MixerTransaction>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      final parts = line.split(',');
      if (parts.length < 7) continue;

      final transaction = MixerTransaction(
        index: int.parse(parts[0]),
        timeStamp: int.parse(parts[1]),
        txHash: parts[2],
        action: parts[3],
        account: parts[4],
        amount: double.parse(parts[5]),
        gasPrice: int.parse(parts[6]),
      );

      transactions.add(transaction);
      _txByHash[transaction.txHash] = transaction;

      if (transaction.isDeposit) {
        _depositsByMixer.putIfAbsent(mixer, () => []);
        _depositsByMixer[mixer]?.add(transaction);
      } else if (transaction.isWithdrawal) {
        _withdrawalsByMixer.putIfAbsent(mixer, () => []);
        _withdrawalsByMixer[mixer]?.add(transaction);
      }
    }

    return transactions;
  }

  /// Loads all tornado transactions from all files
  @override
  Future<List<MixerTransaction>> loadAllMixersTransactions() async {
    final transactions = <MixerTransaction>[];

    for (final mixer in mixers) {
      try {
        final txs = await loadMixerTransactions(mixer);
        transactions.addAll(txs);
      } on Object catch (e) {
        print('Error loading transaction from mixer $mixer: $e');
      }
    }

    return transactions;
  }

  /// Saves address pairs to a CSV file
  ///
  /// Each pair represents a potential link between a deposit address
  /// and a withdrawal address.
  @override
  Future<void> savePairsToCSV(
    Set<(String, String)> pairs, {
    String filename = 'pairs.csv',
  }) async {
    final filePath = 'assets/result/$filename';
    final file = File(filePath);

    final directory = file.parent;
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final buffer = StringBuffer()
      ..writeln('deposit_address,withdrawal_address');

    for (final (deposit, withdrawal) in pairs) {
      buffer.writeln('$deposit,$withdrawal');
    }

    await file.writeAsString(buffer.toString());

    print('Saved ${pairs.length} address pairs to $filePath');
  }

  /// Saves predicted transactions to a CSV file
  @override
  Future<void> savePredictionToCSV(
    List<PredictedPair> pairs, {
    String filename = 'predicted_pairs.csv',
  }) async {
    final filePath = 'assets/result/$filename';
    final file = File(filePath);

    final directory = file.parent;
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final buffer = StringBuffer()
      ..writeln('index,depHash,witHash,sender,receiver');

    for (final p in pairs) {
      buffer.writeln(
        '${p.index},${p.depHash},${p.witHash},${p.sender},${p.receiver}',
      );
    }

    await file.writeAsString(buffer.toString());

    print('Saved ${pairs.length}');
  }

  @override
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
