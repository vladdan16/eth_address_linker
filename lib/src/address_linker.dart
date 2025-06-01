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

    await interactor.createTxGraph();

    await interactor.generatePairs();
  }

  Future<void> dispose() => _scopeHolder.drop();
}
