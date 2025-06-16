/// Interface for graph algorithms that can determine connectivity and
/// find paths between nodes in a graph.
abstract interface class GraphAlgorithm<T> {
  /// Adds an edge between two nodes in the graph.
  ///
  /// This creates a connection between [x] and [y].
  void addEdge(T x, T y);

  /// Checks if two nodes are connected in the graph.
  ///
  /// Returns true if there is a path from [x] to [y], false otherwise.
  /// If [maxDepth] is provided, the search will be limited to that depth.
  bool connected(T x, T y, {int? maxDepth});

  /// Finds a path between two nodes in the graph.
  ///
  /// Returns a list of nodes representing the path from [start] to [end],
  /// including both [start] and [end].
  /// Returns an empty list if no path exists.
  /// Returns null if [maxDepth] is provided and the path length exceeds
  /// this value.
  List<T>? findPath(T start, T end, {int? maxDepth});
}
