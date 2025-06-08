import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:yx_scope/yx_scope.dart';

/// Interface for cache service operations
abstract interface class CacheService implements AsyncLifecycle {
  /// Get data from cache by key
  Future<T?> get<T>(String key);

  /// Save data to cache with key
  Future<void> set<T>(String key, T data);

  /// Check if key exists in cache
  Future<bool> has(String key);

  /// Remove data from cache by key
  Future<void> remove(String key);

  /// Clear all cache data
  Future<void> clear();
}

/// Implementation of cache service using Hive
class HiveCacheService implements CacheService {
  static const String _boxName = 'blockchain_data_cache';
  late Box<String> _box;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    // Create a directory for the cache in the current directory
    final cacheDir = Directory('cache');
    if (!cacheDir.existsSync()) {
      await cacheDir.create();
    }

    Hive.init(cacheDir.path);
    _box = await Hive.openBox<String>(_boxName);
    _isInitialized = true;
  }

  @override
  Future<void> dispose() => Hive.close();

  @override
  Future<T?> get<T>(String key) async {
    _ensureInitialized();

    final jsonString = _box.get(key);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString);
      return json as T;
    } on Object catch (e) {
      print('Error decoding JSON: $jsonString, error: $e');
      rethrow;
    }
  }

  @override
  Future<void> set<T>(String key, T data) async {
    _ensureInitialized();

    final jsonString = jsonEncode(data);
    await _box.put(key, jsonString);
  }

  @override
  Future<bool> has(String key) async {
    _ensureInitialized();
    return _box.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    _ensureInitialized();
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    _ensureInitialized();
    await _box.clear();
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('HiveCacheService must be initialized before use');
    }
  }
}
