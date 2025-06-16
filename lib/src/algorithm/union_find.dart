// ignore analyzer for names in comments
// ignore_for_file: comment_references

import 'graph_algorithm.dart';

/// A generic Union-Find (Disjoint-Set) data structure for arbitrary
/// node types T.
///
/// Note: T must correctly implement equality (`==`) and `hashCode` (which is
/// the case for all built-in immutable types like String, int, etc., or any
/// class that overrides them properly).
final class UnionFind<T> implements GraphAlgorithm<T> {
  /// parent[x] = the parent of x, or x itself if x is a root.
  final Map<T, T> _parent = {};

  /// rank[x] = an upper bound on the height of x's tree
  /// (used for union by rank).
  final Map<T, int> _rank = {};

  /// Stores all direct connections between nodes
  final Map<T, Set<T>> _connections = {};

  /// If x is not seen yet, create a new singleton set { x }.
  void _makeSet(T x) {
    if (!_parent.containsKey(x)) {
      _parent[x] = x;
      _rank[x] = 0;
    }
  }

  /// Find the root of x, applying path compression.
  T find(T x) {
    _makeSet(x);
    if (_parent[x] != x) {
      // Ensure _parent[x] is not null
      // ignore: null_check_on_nullable_type_parameter
      _parent[x] = find(_parent[x]!);
    }
    return _parent[x]!;
  }

  /// Adds an edge between two nodes in the graph.
  ///
  /// This is an alias for union() to conform to the GraphAlgorithm interface.
  @override
  void addEdge(T x, T y) {
    union(x, y);
  }

  /// Union the sets containing x and y (by rank).
  void union(T x, T y) {
    final rootX = find(x);
    final rootY = find(y);
    if (rootX == rootY) return;

    final rankX = _rank[rootX]!;
    final rankY = _rank[rootY]!;

    _connections.putIfAbsent(x, () => {}).add(y);
    _connections.putIfAbsent(y, () => {}).add(x);

    if (rankX < rankY) {
      _parent[rootX] = rootY;
    } else if (rankX > rankY) {
      _parent[rootY] = rootX;
    } else {
      _parent[rootY] = rootX;
      _rank[rootX] = rankX + 1;
    }
  }

  /// Returns true if x and y are in the same connected component.
  ///
  /// [maxDepth] is not applied for Union-Find
  @override
  bool connected(T x, T y, {int? maxDepth}) {
    if (!_parent.containsKey(x) || !_parent.containsKey(y)) {
      return false;
    }

    return find(x) == find(y);
  }

  /// Finds the path between two connected nodes using BFS
  ///
  /// Returns an empty list if the nodes are not connected
  /// Finds the path between two connected nodes using BFS
  ///
  /// Returns an empty list if the nodes are not connected
  /// If [maxDepth] is provided and the path length exceeds this value,
  /// the search will stop and return null
  @override
  List<T>? findPath(T start, T end, {int? maxDepth}) {
    if (start == end) return [start];

    if (!_parent.containsKey(start) ||
        !_parent.containsKey(end) ||
        find(start) != find(end)) {
      return [];
    }

    final queue = <(T, List<T>)>[
      (start, [start]),
    ];
    final visited = <T>{start};

    while (queue.isNotEmpty) {
      final (current, path) = queue.removeAt(0);

      if (maxDepth != null && path.length > maxDepth) {
        return null;
      }

      final neighbors = _connections[current] ?? {};
      for (final neighbor in neighbors) {
        if (neighbor == end) {
          return [...path, end];
        }

        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add((neighbor, [...path, neighbor]));
        }
      }
    }

    return [];
  }
}
