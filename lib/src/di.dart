import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';
import 'package:yx_scope/yx_scope.dart';

import 'algorithm/union_find.dart';
import 'data/address_repository.dart';
import 'data/api/api.dart';
import 'data/api/etherscan_api.dart';
import 'data/cache/cache_service.dart';
import 'data/cached_address_repository.dart';
import 'data/tornado_repository.dart';
import 'domain/interactor.dart';

/// Container for dependency injection
class AppScopeContainer extends ScopeContainer {
  @override
  List<Set<AsyncDep<Object>>> get initializeQueue => [
    {_cacheServiceDep},
  ];

  late final _etherscanApiKey = dep<String?>(
    () => _dotenvDep.get['ETHERSCAN_API_KEY'],
  );

  late final _dotenvDep = dep<DotEnv>(
    () => DotEnv(includePlatformEnvironment: true)..load(),
  );

  /// Dio HTTP client dependency
  late final _dioDep = dep<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://api.etherscan.io',
        queryParameters: {'apikey': _etherscanApiKey.get, 'sort': 'asc'},
      ),
    ),
  );

  /// Etherscan API client dependency
  late final _etherscanApiDep = dep<EtherscanApi>(
    () => EtherscanApi(_dioDep.get),
  );

  /// BlockchainApi interface dependency
  late final _blockchainApiDep = dep<BlockchainApi>(() => _etherscanApiDep.get);

  /// Cache service dependency
  late final _cacheServiceDep = asyncDep<CacheService>(HiveCacheService.new);

  /// Address repository dependency (without caching)
  late final _addressRepositoryDep = dep<AddressRepository>(
    () => AddressRepository(_blockchainApiDep.get),
  );

  /// Cached address repository dependency
  late final _cachedAddressRepositoryDep = dep<CachedAddressRepository>(
    () => CachedAddressRepository(_blockchainApiDep.get, _cacheServiceDep.get),
  );

  late final _tornadoRepositoryDep = dep<TornadoRepository>(
    TornadoRepository.new,
  );

  late final _unionFindAlgDep = dep<UnionFind<String>>(UnionFind<String>.new);

  late final _interactorDep = dep<Interactor>(
    () => Interactor(
      _cachedAddressRepositoryDep.get,
      _tornadoRepositoryDep.get,
      _unionFindAlgDep.get,
    ),
  );

  Interactor get interactor => _interactorDep.get;

  /// Initialize all required services
  Future<void> initialize() async {
    // Initialize cache service
    await _cacheServiceDep.get.init();
  }
}

class AppScopeHolder extends ScopeHolder<AppScopeContainer> {
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}
