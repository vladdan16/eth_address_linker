import '../../../data/address_repository.dart';
import '../../../data/labeled_addresses_repository.dart';
import '../address_info_service.dart';

class AddressInfoServiceImpl implements AddressInfoService {
  final AddressRepository _addressRepository;
  final LabeledAddressesRepository _labeledAddressesRepository;

  const AddressInfoServiceImpl(
    this._addressRepository,
    this._labeledAddressesRepository,
  );

  @override
  Future<String?> getAddressNametag(String address) async {
    return _addressRepository.getAddressNametag(address);
  }

  @override
  Future<bool> isContract(String address) async {
    return _addressRepository.isContract(address);
  }

  @override
  bool isCommonAddress(String address) {
    return _labeledAddressesRepository.isCommon(address);
  }
}
