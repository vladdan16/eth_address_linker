import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';
import 'package:yx_scope/yx_scope.dart';

import 'algorithm/algorithm.dart';
import 'algorithm/bfs.dart';
import 'algorithm/graph_algorithm.dart';
import 'algorithm/union_find.dart';
import 'data/api/api.dart';
import 'data/api/blockchain_api_wrapper.dart';
import 'data/api/etherscan_api.dart';
import 'data/api/moralis_api.dart';
import 'data/cache/cache_service.dart';
import 'data/cached_address_repository.dart';
import 'data/labeled_addresses_repository.dart';
import 'data/tornado_repository.dart';
import 'domain/interactor.dart';
import 'domain/services/services.dart';

/// Container for dependency injection
class AppScopeContainer extends DataScopeContainer<Algorithm> {
  AppScopeContainer({required super.data});

  @override
  List<Set<AsyncDep<Object>>> get initializeQueue => [
    {_cacheServiceDep, _labeledAddressesRepositoryDep},
  ];

  late final _etherscanApiKey = dep<String?>(
    () => _dotenvDep.get['ETHERSCAN_API_KEY'],
  );

  late final _moralisApiKey = dep<String?>(
    () => _dotenvDep.get['MORALIS_API_KEY'],
  );

  late final _dotenvDep = dep<DotEnv>(
    () => DotEnv(includePlatformEnvironment: true)..load(),
  );

  /// Dio HTTP client dependency for Etherscan API
  late final _etherscanDioDep = dep<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://api.etherscan.io',
        queryParameters: {'apikey': _etherscanApiKey.get, 'sort': 'asc'},
      ),
    ),
  );

  /// Dio HTTP client dependency for Moralis API
  late final _moralisDioDep = dep<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://deep-index.moralis.io/api/v2.2',
        queryParameters: {'chain': 'eth'},
        headers: {
          'X-API-Key': _moralisApiKey.get,
          'Accept': 'application/json',
        },
      ),
    ),
  );

  /// Etherscan API client dependency
  late final _etherscanApiDep = dep<EtherscanApi>(
    () => EtherscanApi(_etherscanDioDep.get),
  );

  /// Moralis API client dependency
  late final _moralisApiDep = dep<MoralisApi>(
    () => MoralisApi(_moralisDioDep.get),
  );

  /// BlockchainApi wrapper dependency
  late final _blockchainApiWrapperDep = dep<BlockchainApiWrapper>(
    () => BlockchainApiWrapper(_etherscanApiDep.get, _moralisApiDep.get),
  );

  /// BlockchainApi interface dependency
  late final _blockchainApiDep = dep<BlockchainApi>(
    () => _blockchainApiWrapperDep.get,
  );

  /// Cache service dependency
  late final _cacheServiceDep = asyncDep<CacheService>(HiveCacheService.new);

  /// Cached address repository dependency
  late final _cachedAddressRepositoryDep = dep<CachedAddressRepository>(
    () => CachedAddressRepository(_blockchainApiDep.get, _cacheServiceDep.get),
  );

  late final _tornadoRepositoryDep = dep<TornadoRepository>(
    TornadoRepository.new,
  );

  late final _graphAlgorithmDep = dep<GraphAlgorithm<String>>(
    () => switch (data) {
      Algorithm.unionFind => UnionFind<String>(),
      Algorithm.bfs => BFS<String>(),
    },
  );

  late final _labeledAddressesRepositoryDep =
      asyncDep<LabeledAddressesRepository>(LabeledAddressesRepository.new);

  late final _addressInfoServiceDep = dep<AddressInfoService>(
    () => AddressInfoServiceImpl(
      _cachedAddressRepositoryDep.get,
      _labeledAddressesRepositoryDep.get,
    ),
  );

  late final _graphServiceDep = dep<GraphService>(
    () => GraphServiceImpl(
      _cachedAddressRepositoryDep.get,
      _graphAlgorithmDep.get,
      _addressInfoServiceDep.get,
    ),
  );

  late final _pairAnalysisServiceDep = dep<PairAnalysisService>(
    () => PairAnalysisServiceImpl(
      _graphServiceDep.get,
      _tornadoRepositoryDep.get,
    ),
  );

  late final _transitiveAddressServiceDep = dep<TransitiveAddressService>(
    () => TransitiveAddressServiceImpl(
      _cachedAddressRepositoryDep.get,
      _tornadoRepositoryDep.get,
    ),
  );

  late final _interactorDep = dep<Interactor>(
    () => Interactor(
      _graphServiceDep.get,
      _pairAnalysisServiceDep.get,
      _addressInfoServiceDep.get,
      _transitiveAddressServiceDep.get,
      _tornadoRepositoryDep.get,
    ),
  );

  /// Interactor dependency
  Interactor get interactor => _interactorDep.get;
}

class AppScopeHolder extends DataScopeHolder<AppScopeContainer, Algorithm> {
  AppScopeHolder();

  @override
  AppScopeContainer createContainer(Algorithm data) =>
      AppScopeContainer(data: data);
}
