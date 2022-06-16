import 'dart:async';
import 'package:dio/dio.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:gigaturnip_api/gigaturnip_api.dart' hide Campaign, Task, Chain, TaskStage;
import 'package:gigaturnip_repository/gigaturnip_repository.dart';

enum CampaignsActions { listUserCampaigns, listSelectableCampaigns }

enum TasksActions { listOpenTasks, listClosedTasks }

class GigaTurnipRepository {
  late final GigaTurnipApiClient _gigaTurnipApiClient;

  List<Campaign> _userCampaigns = [];
  List<Campaign> _selectableCampaigns = [];
  List<Task> _openedTasks = [];
  List<Task> _closedTasks = [];
  List<TaskStage> _userRelevantTaskStages = [];

  final Duration _cacheValidDuration = const Duration(minutes: 30);
  DateTime _campaignLastFetchTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _tasksLastFetchTime = DateTime.fromMicrosecondsSinceEpoch(0);
  DateTime _userRelevantTaskStagesLastFetchTime = DateTime.fromMicrosecondsSinceEpoch(0);

  GigaTurnipRepository({
    AuthenticationRepository? authenticationRepository,
  }) {
    _gigaTurnipApiClient = GigaTurnipApiClient(
      httpClient: Dio(BaseOptions(baseUrl: GigaTurnipApiClient.baseUrl))
        ..interceptors.add(
          ApiInterceptors(authenticationRepository ?? AuthenticationRepository()),
        ),
    );
  }

  bool _shouldRefreshFromApi(DateTime lastFetchTime, bool forceRefresh) {
    return lastFetchTime.isBefore(DateTime.now().subtract(_cacheValidDuration)) || forceRefresh;
  }

  Future<void> refreshAllCampaigns() async {
    final userCampaignsData = await _gigaTurnipApiClient.getUserCampaigns();
    final userCampaigns = userCampaignsData.map((apiCampaign) {
      return Campaign.fromApiModel(apiCampaign);
    }).toList();

    final selectableCampaignsData = await _gigaTurnipApiClient.getSelectableCampaigns();
    final selectableCampaigns = selectableCampaignsData.map((apiCampaign) {
      return Campaign.fromApiModel(apiCampaign);
    }).toList();

    _campaignLastFetchTime = DateTime.now();
    _userCampaigns = userCampaigns;
    _selectableCampaigns = selectableCampaigns;
  }

  Future<List<Campaign>> getCampaigns({
    required CampaignsActions action,
    bool forceRefresh = false,
  }) async {
    bool shouldRefreshFromApi =
        _shouldRefreshFromApi(_campaignLastFetchTime, forceRefresh) || _userCampaigns.isEmpty;

    if (shouldRefreshFromApi) {
      await refreshAllCampaigns();
    }
    if (action == CampaignsActions.listUserCampaigns) {
      return _userCampaigns;
    } else {
      return _selectableCampaigns;
    }
  }

  Future<void> refreshUserRelevantTaskStages(Campaign selectedCampaign) async {
    final userRelevantTaskStageData = await _gigaTurnipApiClient.getUserRelevantTaskStages(
      query: {
        'chain__campaign': selectedCampaign.id,
      },
    );
    final userRelevantTaskStages = userRelevantTaskStageData.map((apiTaskStage) {
      return TaskStage.fromApiModel(apiTaskStage);
    }).toList();

    _userRelevantTaskStagesLastFetchTime = DateTime.now();
    _userRelevantTaskStages = userRelevantTaskStages;
  }

  Future<List<TaskStage>> getUserRelevantTaskStages({
    required Campaign selectedCampaign,
    bool forceRefresh = false,
  }) async {
    bool shouldRefreshFromApi =
        _shouldRefreshFromApi(_userRelevantTaskStagesLastFetchTime, forceRefresh) ||
            _userRelevantTaskStages.isEmpty;

    if (shouldRefreshFromApi) {
      await refreshUserRelevantTaskStages(selectedCampaign);
    }
    return _userRelevantTaskStages;
  }

  Future<void> refreshAllTasks(Campaign selectedCampaign) async {
    final openedTasksData = await _gigaTurnipApiClient.getUserRelevantTasks(
      query: {
        'complete': false,
        'stage__chain__campaign': selectedCampaign.id,
      },
    );
    final openedTasks = openedTasksData.map((apiTask) {
      return Task.fromApiModel(apiTask);
    }).toList();

    final closedTasksData = await _gigaTurnipApiClient.getUserRelevantTasks(
      query: {
        'complete': true,
        'stage__chain__campaign': selectedCampaign.id,
      },
    );
    final closedTasks = closedTasksData.map((apiTask) {
      return Task.fromApiModel(apiTask);
    }).toList();

    // TODO: Add available tasks action

    _tasksLastFetchTime = DateTime.now();
    _openedTasks = openedTasks;
    _closedTasks = closedTasks;
  }

  Future<List<Task>> getTasks({
    required TasksActions action,
    required Campaign selectedCampaign,
    bool forceRefresh = false,
  }) async {
    bool shouldRefreshFromApi =
        _shouldRefreshFromApi(_tasksLastFetchTime, forceRefresh) || _openedTasks.isEmpty;

    if (shouldRefreshFromApi) {
      await refreshAllTasks(selectedCampaign);
    }

    // TODO: Add available tasks action
    switch (action) {
      case TasksActions.listOpenTasks:
        return _openedTasks;
      case TasksActions.listClosedTasks:
        return _closedTasks;
    }
  }
}

class ApiInterceptors extends Interceptor {
  final AuthenticationRepository _authenticationRepository;

  ApiInterceptors(this._authenticationRepository);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    var accessToken = await _authenticationRepository.token;

    options.headers['Authorization'] = 'JWT $accessToken';

    return handler.next(options);
  }
}
