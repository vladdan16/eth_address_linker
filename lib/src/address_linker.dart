import 'di.dart';

class AddressLinker {
  late final AppScopeHolder _scopeHolder;

  Future<void> init() async {
    _scopeHolder = AppScopeHolder();
    await _scopeHolder.create();

    // Initialize cache service
    await _scopeHolder.scope?.initialize();
  }

  Future<void> run() async {
    final interactor =
        _scopeHolder.scope?.interactor ??
        (throw Exception('You should call init() first'));

    print('Running AddressLinker...');
    await interactor.createTxGraph();

    print('Generating pairs...');
    await interactor.generatePairs();

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

  Future<void> dispose() => _scopeHolder.drop();
}
