import 'dart:convert';
import 'dart:io';

import 'package:yx_scope/yx_scope.dart';

import '../debug.dart';

/// Service that tells whether address is related to some common service
final class LabeledAddressesRepository implements AsyncLifecycle {
  static const _labeledAddresses = 'assets/data/labeledAddresses.json';

  /// Addresses related to common services like exchange
  ///
  /// Note: it would be better to implement this feature through Etherscan API,
  /// but it costs about 900$ per month
  static const _commonAddressesFile = 'assets/data/common_addresses.txt';

  /// Those are addresses not marked by some common tag, but they have too much
  /// transactions in common with most of users in our dataset
  static const _suspiciousAddressesFile = 'assets/data/suspicious_addresses.txt';

  late final Set<String> _commonAddresses;

  @override
  Future<void> init() async {
    _commonAddresses = {};
    await _loadLabeledAddresses();
    await _loadCommonAddresses();
    await _loadSuspiciousAddresses();
    print('Loaded ${_commonAddresses.length} common addresses');
  }

  Future<void> _loadLabeledAddresses() async {
    final file = File(_labeledAddresses);
    final labeledAddresses = <String>{};

    final data = await file.readAsString();
    final map = jsonDecode(data) as Map<String, Object?>;
    for (final cluster in map.values) {
      if (cluster is! List<Object?>) {
        throw Exception('Groups must be a list');
      }
      for (final group in cluster) {
        if (group is! List<Object?>) {
          throw Exception('Group must be a list');
        }

        labeledAddresses.add(group.first! as String);
      }
    }
    if (isDebug) {
      print('Loaded ${labeledAddresses.length} labeled addresses');
      print('Labeled addresses: $labeledAddresses');
    }
    _commonAddresses.addAll(labeledAddresses);
  }

  Future<void> _loadCommonAddresses() async {
    final file = File(_commonAddressesFile);

    final commonAddresses = await file.readAsLines();

    if (isDebug) {
      print('Loaded ${commonAddresses.length} common addresses');
      print('Common addresses:');
      print(commonAddresses);
    }

    _commonAddresses.addAll(commonAddresses);
  }

  Future<void> _loadSuspiciousAddresses() async {
    final file = File(_suspiciousAddressesFile);

    final suspiciousAddresses = await file.readAsLines();

    if (isDebug) {
      print('Loaded ${suspiciousAddresses.length} suspicious addresses');
      print('Suspicious addresses:');
      print(suspiciousAddresses);
    }

    _commonAddresses.addAll(suspiciousAddresses);
  }

  /// Returns true if address is related to some common service
  bool isCommon(String address) => _commonAddresses.contains(address);

  @override
  Future<void> dispose() async {
    // no-op
  }
}
