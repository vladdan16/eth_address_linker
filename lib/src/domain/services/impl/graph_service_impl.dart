import '../../../algorithm/graph_algorithm.dart';
import '../../../data/address_repository.dart';
import '../../../debug.dart';
import '../address_info_service.dart';
import '../graph_service.dart';

class GraphServiceImpl implements GraphService {
  final AddressRepository _addressRepository;
  final GraphAlgorithm<String> _graphAlgorithm;
  final AddressInfoService _addressInfoService;

  const GraphServiceImpl(
    this._addressRepository,
    this._graphAlgorithm,
    this._addressInfoService,
  );

  @override
  Future<void> buildTransactionGraph({
    required Set<String> addresses,
    required int startTimestamp,
    required int endTimestamp,
    required int maxTxHistory,
  }) async {
    var index = 1;
    for (final address in addresses) {
      print('Processing address $address ($index/${addresses.length})');
      index++;

      await _processAddress(
        address,
        startTimestamp,
        endTimestamp,
        maxTxHistory,
      );
    }
  }

  Future<void> _processAddress(
    String address,
    int startTimestamp,
    int endTimestamp,
    int maxTxHistory,
  ) async {
    final txHistory = await _addressRepository.getTransactionsForAddress(
      address,
      startTimestamp: startTimestamp,
      endTimestamp: endTimestamp,
    );

    for (final tx in txHistory) {
      final (from, to) = (tx.from, tx.to);
      if (from.isEmpty || to.isEmpty) {
        continue;
      }

      if (await _shouldSkipTransaction(from, to)) {
        continue;
      }

      // Skip addresses with too big tx history
      final addressToCheck = address == to ? from : to;
      if (await _hasTooManyTransactions(
        addressToCheck,
        startTimestamp,
        endTimestamp,
        maxTxHistory,
      )) {
        continue;
      }

      _graphAlgorithm.addEdge(from, to);
    }
  }

  Future<bool> _shouldSkipTransaction(String from, String to) async {
    // Skip contract addresses
    if (await _addressInfoService.isContract(to)) {
      if (isDebug) {
        print('Skipping contract address $to');
      }
      return true;
    }

    // Skip common addresses
    if (_addressInfoService.isCommonAddress(to) ||
        _addressInfoService.isCommonAddress(from)) {
      if (isDebug) {
        print('Skipping labeled address $to');
      }
      return true;
    }

    // Skip tagged addresses
    final fromTag = await _addressRepository.getAddressNametag(from);
    final toTag = await _addressRepository.getAddressNametag(to);
    if (fromTag != null && fromTag.isNotEmpty) {
      if (isDebug) {
        print('Skipping from tagged address $from, tag: $fromTag');
      }
      return true;
    }
    if (toTag != null && toTag.isNotEmpty) {
      if (isDebug) {
        print('Skipping to tagged address $to, tag: $toTag');
      }
      return true;
    }

    return false;
  }

  Future<bool> _hasTooManyTransactions(
    String address,
    int startTimestamp,
    int endTimestamp,
    int maxTxHistory,
  ) async {
    final txs = await _addressRepository.getTransactionsForAddress(
      address,
      startTimestamp: startTimestamp,
      endTimestamp: endTimestamp,
      limit: maxTxHistory + 1, // Get one more to check if limit exceeded
    );

    if (txs.length > maxTxHistory) {
      if (isDebug) {
        print('''
Skipping address $address with too big tx history (${txs.length} > $maxTxHistory)
''');
      }
      return true;
    }

    return false;
  }

  @override
  bool isConnected(String address1, String address2, {int? maxDepth}) {
    return _graphAlgorithm.connected(address1, address2, maxDepth: maxDepth);
  }

  @override
  List<String>? findPath(String address1, String address2, {int? maxDepth}) {
    return _graphAlgorithm.findPath(address1, address2, maxDepth: maxDepth);
  }
}
