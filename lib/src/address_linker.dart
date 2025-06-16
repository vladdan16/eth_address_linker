import 'algorithm/algorithm.dart';
import 'di.dart';

class AddressLinker {
  late final AppScopeHolder _scopeHolder;

  Future<void> init({String? algorithm}) async {
    _scopeHolder = AppScopeHolder();

    final alg = algorithm ?? 'unionfind';
    print('Initializing AddressLinker with algorithm: $alg');
    await _scopeHolder.create(Algorithm.fromName(alg));
  }

  /// Runs the AddressLinker
  ///
  /// [startTimestamp] and [endTimestamp] - start and end for transaction
  /// to be analyzed
  ///
  /// [maxDepth] - maximum depth between addresses to be treat as connected
  ///
  /// [maxTxHistory] - maximum number of transactions, if the number
  /// of transactions exceeds this value, address will not be added to the graph
  Future<void> run({
    int? startTimestamp,
    int? endTimestamp,
    int? maxDepth,
    int? maxTxHistory,
  }) async {
    final interactor =
        _scopeHolder.scope?.interactor ??
        (throw Exception('You should call init() first'));

    print('Running AddressLinker...');
    await interactor.createTxGraph(
      startTimestamp: startTimestamp,
      endTimestamp: endTimestamp,
      maxTxHistory: maxTxHistory ?? 1000,
    );

    print('Generating pairs...');
    final depth = maxDepth ?? 4;
    print('Max depth chosen: $depth');
    await interactor.generatePairs(maxDepth: depth);

    print('Done.');
  }

  /// Gets the nametag for an Ethereum address
  ///
  /// Returns null if no nametag is found
  Future<String?> getAddressNametag(String address) async {
    final interactor =
        _scopeHolder.scope?.interactor ??
        (throw Exception('You should call init() first'));

    return interactor.getAddressNametag(address);
  }

  /// Processes the top transitive addresses
  Future<void> processTopTransitiveAddresses() async {
    final interactor =
        _scopeHolder.scope?.interactor ??
        (throw Exception('You should call init() first'));

    await interactor.processTopTransitiveAddresses();
  }

  Future<void> dispose() => _scopeHolder.drop();
}
