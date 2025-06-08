import 'dart:convert';
import 'dart:io';

import 'package:yx_scope/yx_scope.dart';

/// Service that tells whether address is related to some common service
final class LabeledAddressesRepository implements AsyncLifecycle {
  static const _labeledAddresses = 'assets/data/labeledAddresses.json';

  late final Set<String> _commonAddresses;

  @override
  Future<void> init() async {
    final file = File(_labeledAddresses);

    final data = await file.readAsString();
    final map = jsonDecode(data) as Map<String, Object?>;
    _commonAddresses = {};
    for (final cluster in map.values) {
      if (cluster is! List<Object?>) {
        throw Exception('Groups must be a list');
      }
      for (final group in cluster) {
        if (group is! List<Object?>) {
          throw Exception('Group must be a list');
        }

        _commonAddresses.add(group.first! as String);
      }
    }
    print('Loaded ${_commonAddresses.length} common addresses');
  }

  /// Returns true if address is related to some common service
  bool isLabeled(String address) => _commonAddresses.contains(address);

  @override
  Future<void> dispose() async {
    // no-op
  }
}
