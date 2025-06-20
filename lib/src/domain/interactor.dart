import '../data/mixer_repository.dart';
import 'services/services.dart';

class Interactor {
  final GraphService _graphService;
  final PairAnalysisService _pairAnalysisService;
  final AddressInfoService _addressInfoService;
  final TransitiveAddressService _transitiveAddressService;
  final MixerRepository _mixerRepository;

  const Interactor(
    this._graphService,
    this._pairAnalysisService,
    this._addressInfoService,
    this._transitiveAddressService,
    this._mixerRepository,
  );

  // Default timestamp values if not provided via CLI
  static const defaultStartTimestamp = 1546354022; // Jan 1, 2019
  static const defaultEndTimestamp = 1659970022; // Aug 8, 2022

  Future<void> createTxGraph({
    int? startTimestamp,
    int? endTimestamp,
    int maxTxHistory = 1000,
  }) async {
    final effectiveStartTimestamp = startTimestamp ?? defaultStartTimestamp;
    final effectiveEndTimestamp = endTimestamp ?? defaultEndTimestamp;

    print('''
Using time range: ${DateTime.fromMillisecondsSinceEpoch(effectiveStartTimestamp * 1000)} to ${DateTime.fromMillisecondsSinceEpoch(effectiveEndTimestamp * 1000)}
''');

    final allTransactions = await _mixerRepository.loadAllMixersTransactions();

    final addresses = allTransactions
        .map((transaction) => transaction.account)
        .where(
          (address) =>
              address.isNotEmpty &&
              !_addressInfoService.isCommonAddress(address),
        )
        .toSet();

    await _graphService.buildTransactionGraph(
      addresses: addresses,
      startTimestamp: effectiveStartTimestamp,
      endTimestamp: effectiveEndTimestamp,
      maxTxHistory: maxTxHistory,
    );

    print('Created transaction graph');
  }

  Future<void> generatePairs({int maxDepth = 4}) async {
    final mixers = _mixerRepository.mixers;

    for (final mixer in mixers) {
      print('\nGenerating pairs for mixer $mixer');

      final deposits = _mixerRepository.depositsByMixer(mixer)!;
      final withdrawals = _mixerRepository.withdrawalsByMixer(mixer)!;

      final pairs = await _pairAnalysisService.generatePairs(
        mixer: mixer,
        deposits: deposits,
        withdrawals: withdrawals,
        maxDepth: maxDepth,
      );

      print('Found ${pairs.length} address pairs for contract $mixer');

      await _mixerRepository.savePredictionToCSV(
        pairs,
        filename: 'heuristic4$mixer.csv',
      );

      print('Saved ${pairs.length} address pairs to CSV file');
    }
  }

  Future<String?> getAddressNametag(String address) async {
    return _addressInfoService.getAddressNametag(address);
  }

  Future<void> processTopTransitiveAddresses() async {
    await _transitiveAddressService.processTopTransitiveAddresses();
  }
}
