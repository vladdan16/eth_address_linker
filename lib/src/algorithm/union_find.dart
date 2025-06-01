/// A generic Union-Find (Disjoint-Set) data structure for arbitrary
/// node types T.
///
/// Note: T must correctly implement equality (`==`) and `hashCode` (which is
/// the case for all built-in immutable types like String, int, etc., or any
/// class that overrides them properly).
class UnionFind<T> {
  /// parent[x] = the parent of x, or x itself if x is a root.
  final Map<T, T> _parent = {};

  /// rank[x] = an upper bound on the height of x’s tree
  /// (used for union by rank).
  final Map<T, int> _rank = {};

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
  bool connected(T x, T y) {
    if (!_parent.containsKey(x) || !_parent.containsKey(y)) {
      // If we’ve never seen one of them, they can’t be connected.
      return false;
    }
    return find(x) == find(y);
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
