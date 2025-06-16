import 'graph_algorithm.dart';

/// A Breadth-First Search implementation of the GraphAlgorithm interface.
///
/// This class uses BFS to find connections and paths in a graph.
/// Unlike UnionFind, the connected method respects the maxDepth parameter
/// and will return false if the path length exceeds the specified limit.
final class BFS<T> implements GraphAlgorithm<T> {
  /// Adjacency list representation of the graph
  final Map<T, Set<T>> _graph = {};

  /// Adds an edge between two nodes in the graph.
  ///
  /// This creates a bidirectional connection between [x] and [y].
  @override
  void addEdge(T x, T y) {
    _graph.putIfAbsent(x, () => {}).add(y);
    _graph.putIfAbsent(y, () => {}).add(x);
  }

  @override
  bool connected(T x, T y, {int? maxDepth}) {
    if (!_graph.containsKey(x) || !_graph.containsKey(y)) {
      return false;
    }

    if (x == y) {
      return true;
    }

    final queue = <(T, int)>[(x, 0)];
    final visited = <T>{x};

    while (queue.isNotEmpty) {
      final (current, depth) = queue.removeAt(0);

      if (maxDepth != null && depth >= maxDepth) {
        return false;
      }

      for (final neighbor in (_graph[current] ?? {}).cast<T>()) {
        if (neighbor == y) {
          return true;
        }

        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add((neighbor, depth + 1));
        }
      }
    }

    return false;
  }

  @override
  List<T>? findPath(T start, T end, {int? maxDepth}) {
    if (!_graph.containsKey(start) || !_graph.containsKey(end)) {
      return [];
    }

    if (start == end) {
      return [start];
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

      for (final neighbor in (_graph[current] ?? {}).cast<T>()) {
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

  /// Clears all edges from the graph.
  void clear() {
    _graph.clear();
  }
}
