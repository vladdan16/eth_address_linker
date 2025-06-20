/// Service for address information
abstract interface class AddressInfoService {
  /// Gets the nametag for an address
  Future<String?> getAddressNametag(String address);

  /// Checks if an address is a contract
  Future<bool> isContract(String address);

  /// Checks if an address is a common/labeled address
  bool isCommonAddress(String address);
}
