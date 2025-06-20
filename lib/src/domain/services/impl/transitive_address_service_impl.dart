import '../../../data/address_repository.dart';
import '../../../data/mixer_repository.dart';
import '../../../debug.dart';
import '../transitive_address_service.dart';

class TransitiveAddressServiceImpl implements TransitiveAddressService {
  final AddressRepository _addressRepository;
  final MixerRepository _mixerRepository;

  const TransitiveAddressServiceImpl(
    this._addressRepository,
    this._mixerRepository,
  );

  @override
  Future<void> processTopTransitiveAddresses() async {
    print('Processing top transitive addresses');
    for (final contract in _mixerRepository.mixers) {
      print('Processing top transitive addresses for contract $contract');
      final topTransitiveAddresses = await _mixerRepository
          .loadTopTransitiveAddresses(
            filePath: 'assets/result/top_transitive_addresses_$contract.csv',
          );
      if (isDebug) {
        print('''
Processing ${topTransitiveAddresses.length} top transitive addresses for contract $contract
''');
      }
      for (final (address, _) in topTransitiveAddresses) {
        final tag = await _addressRepository.getAddressNametag(address);
        if (isDebug) {
          if (tag != null && tag.isNotEmpty) {
            print('Found tag for address: $address - tag: $tag');
          }
        }
      }
    }
  }

  @override
  Map<String, int> identifyPopularTransitiveAddresses(
    List<List<String>> paths,
  ) {
    final transitiveAddresses = <String, int>{};

    for (final path in paths) {
      if (path.length > 2) {
        // Skip first and last elements (source and destination)
        for (var i = 1; i < path.length - 1; i++) {
          final address = path[i];
          transitiveAddresses[address] =
              (transitiveAddresses[address] ?? 0) + 1;
        }
      }
    }

    return transitiveAddresses;
  }
}
