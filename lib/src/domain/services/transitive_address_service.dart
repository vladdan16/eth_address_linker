/// Service for transitive address processing
abstract interface class TransitiveAddressService {
  /// Processes top transitive addresses
  Future<void> processTopTransitiveAddresses();

  /// Identifies popular transitive addresses from paths
  Map<String, int> identifyPopularTransitiveAddresses(List<List<String>> paths);
}
