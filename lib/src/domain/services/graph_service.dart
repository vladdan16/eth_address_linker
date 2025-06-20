/// Service for graph operations
abstract interface class GraphService {
  /// Builds a transaction graph from address data
  Future<void> buildTransactionGraph({
    required Set<String> addresses,
    required int startTimestamp,
    required int endTimestamp,
    required int maxTxHistory,
  });

  /// Checks if two addresses are connected in the graph
  bool isConnected(String address1, String address2, {int? maxDepth});

  /// Finds a path between two addresses in the graph
  List<String>? findPath(String address1, String address2, {int? maxDepth});
}
