/// A generic Union-Find (Disjoint-Set) data structure for arbitrary
/// node types T.
///
/// Note: T must correctly implement equality (`==`) and `hashCode` (which is
/// the case for all built-in immutable types like String, int, etc., or any
/// class that overrides them properly).
class UnionFind<T> {
  /// parent[x] = the parent of x, or x itself if x is a root.
  final Map<T, T> _parent = {};

  /// rank[x] = an upper bound on the height of x's tree
  /// (used for union by rank).
  final Map<T, int> _rank = {};

  /// Stores all direct connections between nodes
  final Map<T, Set<T>> _connections = {};

  /// Debug flag to enable path logging
  final bool debug;

  /// Creates a new UnionFind data structure
  ///
  /// If [debug] is true, the [connected] method will log the path
  /// between connected nodes
  UnionFind({this.debug = false});

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

  /// Union the sets containing x and y (by rank).
  void union(T x, T y) {
    final rootX = find(x);
    final rootY = find(y);
    if (rootX == rootY) return;

    final rankX = _rank[rootX]!;
    final rankY = _rank[rootY]!;

    // Store the direct connection for path finding
    _connections.putIfAbsent(x, () => {}).add(y);
    _connections.putIfAbsent(y, () => {}).add(x);

    // Attach the smaller rank tree under the larger one
    if (rankX < rankY) {
      _parent[rootX] = rootY;
    } else if (rankX > rankY) {
      _parent[rootY] = rootX;
    } else {
      // If ranks are equal, pick one root and bump its rank
      _parent[rootY] = rootX;
      _rank[rootX] = rankX + 1;
    }
  }

  /// Returns true if x and y are in the same connected component.
  ///
  /// If [debug] is true, it will also log the path between x and y
  /// if they are connected.
  bool connected(T x, T y) {
    if (!_parent.containsKey(x) || !_parent.containsKey(y)) {
      // If we've never seen one of them, they can't be connected.
      return false;
    }

    // Check if nodes are connected by comparing their roots
    final isConnected = find(x) == find(y);

    // Only try to find the path if they are actually connected and debug is enabled
    // This avoids unnecessary path finding for unconnected nodes
    if (isConnected && debug) {
      try {
        // We don't call findPath here anymore to avoid potential recursion
        // The caller should explicitly call findPath if needed
      } on Object catch (e) {
        print('Error finding path: $e');
      }
    }

    return isConnected;
  }

  /// Finds the path between two connected nodes using BFS
  ///
  /// Returns an empty list if the nodes are not connected
  List<T> findPath(T start, T end) {
    if (start == end) return [start];

    // Check if nodes are connected by comparing their roots
    // This avoids the recursive call to connected()
    if (!_parent.containsKey(start) ||
        !_parent.containsKey(end) ||
        find(start) != find(end)) {
      return [];
    }

    // Use BFS to find the shortest path
    final queue = <(T, List<T>)>[
      (start, [start]),
    ];
    final visited = <T>{start};

    while (queue.isNotEmpty) {
      final (current, path) = queue.removeAt(0);

      // Check direct connections from the current node
      final neighbors = _connections[current] ?? {};
      for (final neighbor in neighbors) {
        if (neighbor == end) {
          // Found the end node, return the path
          return [...path, end];
        }

        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add((neighbor, [...path, neighbor]));
        }
      }
    }

    // If we get here, there's no path (should not happen if connected returned true)
    return [];
  }
}

// void main() {
//   // Suppose our undirected graph has edges among String‐nodes:
//   //   "Alice"–"Bob", "Bob"–"Charlie", "David"–"Eva", "X"–"Y".
//   final edges = <(String, String)>[
//     ('Alice', 'Bob'),
//     ('Bob', 'Charlie'),
//     ('David', 'Eva'),
//     ('X', 'Y'),
//   ];
//
//   final uf = UnionFind<String>();
//
//   // 1) Union all edges
//   for (final edge in edges) {
//     uf.union(edge.$1, edge.$2);
//   }
//
//   // 2) Query cluster membership
//   print(uf.connected('Alice', 'Charlie')); // true  (Alice–Bob–Charlie)
//   print(uf.connected('Alice', 'Eva')); // false (different components)
//   print(uf.connected('David', 'Eva')); // true  (David–Eva)
//   print(uf.connected('X', 'Z')); // false (Z not seen at all)
//   print(uf.connected('X', 'Y')); // true  (X–Y)
// }
