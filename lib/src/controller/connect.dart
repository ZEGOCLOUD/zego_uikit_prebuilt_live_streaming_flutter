part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerConnect {
  final _connectController = ZegoLiveStreamingConnectController();

  ZegoLiveStreamingConnectController get connect => _connectController;
}

typedef ZegoLiveStreamingConnectEvent = void Function(ZegoUIKitUser audience);

/// Here are the APIs related to connect.
class ZegoLiveStreamingConnectController {
  /// for audience: current audience connection state, audience or co-host(connected)
  ValueNotifier<ZegoLiveStreamingAudienceConnectState>
      get audienceLocalConnectStateNotifier =>
          _audienceLocalConnectStateNotifier;

  /// for host: current requesting co-host's audiences
  ValueNotifier<List<ZegoUIKitUser>> get requestCoHostUsersNotifier =>
      _requestCoHostUsersNotifier;

  ValueNotifier<ZegoUIKitUser?> get hostNotifier {
    _initByCoreManager();
    return _hostNotifier;
  }

  /// audience requests to become a co-host by sending a request to the host.
  /// if you want audience be co-host without request to the host, use [startCoHost]
  ///
  /// If [withToast] is set to true, a toast message will be displayed after the request succeeds or fails.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> audienceSendCoHostRequest({
    bool withToast = false,
  }) async {
    ZegoLoggerService.logInfo(
      'audience request to be co-host',
      tag: 'live streaming',
      subTag: 'controller.connect',
    );

    if (null == _hostManager ||
        null == _connectManager ||
        null == _prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not request, '
        'hostManager:$_hostManager, '
        'connectManager:$_connectManager, '
        'prebuiltConfig:$_prebuiltConfig, ',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (!_hostExist) {
      if (withToast) {
        showError(_prebuiltConfig!.innerText.requestCoHostFailedToast);
      }
      return false;
    }

    if (!_isLiving) {
      if (withToast) {
        showError(_prebuiltConfig!.innerText.requestCoHostFailedToast);
      }
      return false;
    }

    if (ZegoLiveStreamingAudienceConnectState.connecting ==
        audienceLocalConnectStateNotifier.value) {
      ZegoLoggerService.logInfo(
        'audience connect state is in requesting, not need request more',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );
      return false;
    }

    final result = await ZegoUIKit()
        .getSignalingPlugin()
        .sendInvitation(
          inviterID: ZegoUIKit().getLocalUser().id,
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: [_hostManager!.notifier.value?.id ?? ''],
          timeout: 60,
          type: ZegoInvitationType.requestCoHost.value,
          data: '',
        )
        .then((result) {
      ZegoLoggerService.logInfo(
        'audience request to be co-host, result:$result',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      if (withToast) {
        if (result.error?.code.isNotEmpty ?? false) {
          showError('${_prebuiltConfig!.innerText.requestCoHostFailedToast}, '
              '${result.error?.code} ${result.error?.message}');
        } else {
          showSuccess(_prebuiltConfig!.innerText.sendRequestCoHostToast);
        }
      }

      return result.error == null;
    });

    if (result) {
      _events?.audienceEvents.onCoHostRequestSent?.call();

      _connectManager!.updateAudienceConnectState(
          ZegoLiveStreamingAudienceConnectState.connecting);
    }

    return result;
  }

  /// audience cancels the co-host request to the host.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> audienceCancelCoHostRequest() async {
    ZegoLoggerService.logInfo(
      'audience cancel be co-host request',
      tag: 'live streaming',
      subTag: 'controller.connect',
    );

    if (null == _hostManager ||
        null == _connectManager ||
        null == _prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not request, '
        'hostManager:$_hostManager, '
        'connectManager:$_connectManager, '
        'prebuiltConfig:$_prebuiltConfig, ',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (ZegoLiveStreamingAudienceConnectState.connecting !=
        audienceLocalConnectStateNotifier.value) {
      ZegoLoggerService.logInfo(
        'audience connect state is not in requesting, not need cancel',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );
      return false;
    }

    final result = await ZegoUIKit().getSignalingPlugin().cancelInvitation(
      invitees: [_hostManager!.notifier.value?.id ?? ''],
      data: '',
    );
    ZegoLoggerService.logInfo(
      'audience cancel be co-host request, result:$result',
      tag: 'live streaming',
      subTag: 'controller.connect',
    );

    _events?.audienceEvents.onActionCancelCoHostRequest?.call();

    _connectManager!
        .updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);

    return result.error == null;
  }

  /// audience switch to be an co-host directly, without request to host
  /// if you want audience be co-host with request to the host, use [audienceSendCoHostRequest]
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> startCoHost() async {
    ZegoLoggerService.logInfo(
      'audience switch to co-host',
      tag: 'live streaming',
      subTag: 'controller.connect',
    );

    if (null == _hostManager ||
        null == _connectManager ||
        null == _prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not request, '
        'hostManager:$_hostManager, '
        'connectManager:$_connectManager, '
        'prebuiltConfig:$_prebuiltConfig, ',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (!_hostExist) {
      ZegoLoggerService.logInfo(
        'host is not exist, ignore current co-host switch',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (!_isLiving) {
      ZegoLoggerService.logInfo(
        'is not in living, ignore current co-host switch',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (_connectManager!.isCoHost(ZegoUIKit().getLocalUser())) {
      ZegoLoggerService.logInfo(
        'audience is co-host now',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );
      return false;
    }

    if (_connectManager!.isMaxCoHostReached) {
      _prebuiltConfig!.onMaxCoHostReached?.call(
        _prebuiltConfig!.maxCoHostCount,
      );

      ZegoLoggerService.logInfo(
        'co-host max count had reached, ignore current co-host switch',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    final permissions = _connectManager!.getCoHostPermissions();
    await permissions
        .request()
        .then((Map<Permission, PermissionStatus> statuses) {
      if (permissions.contains(Permission.camera) &&
          statuses[Permission.camera] != PermissionStatus.granted) {
        ZegoLoggerService.logInfo(
          'camera not granted when audience switch to co-host',
          tag: 'live streaming',
          subTag: 'controller.connect',
        );
      }
      if (permissions.contains(Permission.microphone) &&
          statuses[Permission.microphone] != PermissionStatus.granted) {
        ZegoLoggerService.logInfo(
          'camera not granted when audience switch to co-host',
          tag: 'live streaming',
          subTag: 'controller.connect',
        );
      }

      _connectManager!.updateAudienceConnectState(
          ZegoLiveStreamingAudienceConnectState.connected);
    });

    return true;
  }

  /// co-host ends the connection and switches to the audience role voluntarily.
  ///
  /// If [showRequestDialog] is true, a confirmation dialog will be displayed to prevent accidental clicks.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> stopCoHost({
    bool showRequestDialog = true,
  }) async {
    ZegoLoggerService.logInfo(
      'co-host switch to audience',
      tag: 'live streaming',
      subTag: 'controller.connect',
    );

    if (null == _hostManager ||
        null == _connectManager ||
        null == _prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not request, '
        'hostManager:$_hostManager, '
        'connectManager:$_connectManager, '
        'prebuiltConfig:$_prebuiltConfig, ',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (showRequestDialog) {
      return _connectManager!.coHostRequestToEnd();
    }

    return _connectManager!.coHostEndConnect();
  }

  /// host approve the co-host request made by [audience].
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> hostAgreeCoHostRequest(ZegoUIKitUser audience) async {
    ZegoLoggerService.logInfo(
      'agree the co-host request from ${audience.id}',
      tag: 'live streaming',
      subTag: 'controller.connect',
    );

    if (null == _hostManager ||
        null == _connectManager ||
        null == _prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not agree, '
        'hostManager:$_hostManager, '
        'connectManager:$_connectManager, '
        'prebuiltConfig:$_prebuiltConfig, ',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (!_isLocalHost) {
      ZegoLoggerService.logInfo(
        'local is not a host, can not agree',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (_connectManager!.coHostCount.value + _agreeRequestingUserIDs.length >=
        _connectManager!.maxCoHostCount) {
      _prebuiltConfig!.onMaxCoHostReached
          ?.call(_prebuiltConfig!.maxCoHostCount);

      ZegoLoggerService.logInfo(
        'co-host max count had reached, can not agree',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    _agreeRequestingUserIDs.add(audience.id);
    ZegoLoggerService.logInfo(
      'agree requesting count:${_agreeRequestingUserIDs.length}',
      tag: 'live streaming',
      subTag: 'controller.connect',
    );

    return ZegoUIKit()
        .getSignalingPlugin()
        .acceptInvitation(inviterID: audience.id, data: '')
        .then((result) {
      ZegoLoggerService.logInfo(
        'agree the co-host request from ${audience.id}, result:$result',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      if (result.error == null) {
        _events?.hostEvents.onActionAcceptCoHostRequest?.call();

        _connectManager!.removeRequestCoHostUsers(audience);
      } else {
        showDebugToast('error:${result.error}');
      }

      return result.error == null;
    });
  }

  /// host reject the co-host request made by [audience].
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> hostRejectCoHostRequest(ZegoUIKitUser audience) async {
    ZegoLoggerService.logInfo(
      'reject the co-host request from ${audience.id}',
      tag: 'live streaming',
      subTag: 'controller.connect',
    );

    if (null == _hostManager ||
        null == _connectManager ||
        null == _prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not reject, '
        'hostManager:$_hostManager, '
        'connectManager:$_connectManager, '
        'prebuiltConfig:$_prebuiltConfig, ',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (!_isLocalHost) {
      ZegoLoggerService.logInfo(
        'local is not a host',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .refuseInvitation(inviterID: audience.id, data: '')
        .then((result) {
      ZegoLoggerService.logInfo(
        'refuse audience ${audience.name} co-host request, $result',
        tag: 'live streaming',
        subTag: 'member list',
      );

      if (result.error == null) {
        _events?.hostEvents.onActionRefuseCoHostRequest?.call();

        _connectManager!.removeRequestCoHostUsers(audience);
      } else {
        showDebugToast('error:${result.error}');
      }

      return result.error == null;
    });
  }

  /// host remove the co-host, make [coHost] to be a audience
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> removeCoHost(ZegoUIKitUser coHost) async {
    ZegoLoggerService.logInfo(
      'remove co-host:${coHost.id}',
      tag: 'live streaming',
      subTag: 'controller.connect',
    );

    if (null == _hostManager ||
        null == _connectManager ||
        null == _prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not remove, '
        'hostManager:$_hostManager, '
        'connectManager:$_connectManager, '
        'prebuiltConfig:$_prebuiltConfig, ',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (!_isLocalHost) {
      ZegoLoggerService.logInfo(
        'local is not a host',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    return _connectManager!.kickCoHost(coHost);
  }

  /// DO NOT CALL
  /// Call Inside By Prebuilt
  void init({ZegoUIKitPrebuiltLiveStreamingEvents? events}) {
    _events = events;

    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }
    _subscriptions.add(
      ZegoUIKit().getAudioVideoListStream().listen(_onAudioVideoListUpdated),
    );

    _connectManager?.audienceLocalConnectStateNotifier
        .removeListener(_onAudienceLocalConnectStateUpdated);
    _connectManager?.audienceLocalConnectStateNotifier
        .addListener(_onAudienceLocalConnectStateUpdated);

    _connectManager?.requestCoHostUsersNotifier
        .removeListener(_onRequestCoHostUsersUpdated);
    _connectManager?.requestCoHostUsersNotifier
        .addListener(_onRequestCoHostUsersUpdated);
  }

  /// DO NOT CALL
  /// Call Inside By Prebuilt
  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'controller.room',
    );

    _events = null;

    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }

    _connectManager?.audienceLocalConnectStateNotifier
        .removeListener(_onAudienceLocalConnectStateUpdated);
    _connectManager?.requestCoHostUsersNotifier
        .removeListener(_onRequestCoHostUsersUpdated);

    _agreeRequestingUserIDs.clear();
  }

  void _onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    _agreeRequestingUserIDs.removeWhere(
      (userID) => -1 != users.indexWhere((user) => user.id == userID),
    );
  }

  void _onAudienceLocalConnectStateUpdated() {
    _audienceLocalConnectStateNotifier.value =
        _connectManager!.audienceLocalConnectStateNotifier.value;
  }

  void _onRequestCoHostUsersUpdated() {
    _requestCoHostUsersNotifier.value =
        _connectManager!.requestCoHostUsersNotifier.value;
  }

  void _initByCoreManager() {
    if (_alreadyInitByCoreManager) {
      return;
    }

    _alreadyInitByCoreManager = true;

    ZegoLiveStreamingManagers()
        .initializedNotifier
        .addListener(_onCoreManagerInitFinished);
    _onCoreManagerInitFinished();
  }

  void _onCoreManagerInitFinished() {
    if (ZegoLiveStreamingManagers().initializedNotifier.value) {
      ZegoLiveStreamingManagers()
          .hostManager
          ?.notifier
          .addListener(_onHostUpdated);
    } else {
      ZegoLiveStreamingManagers()
          .hostManager
          ?.notifier
          .removeListener(_onHostUpdated);
    }
  }

  void _onHostUpdated() {
    _hostNotifier.value =
        ZegoLiveStreamingManagers().hostManager?.notifier.value;
  }

  ZegoUIKitPrebuiltLiveStreamingConfig? get _prebuiltConfig =>
      ZegoLiveStreamingManagers().hostManager?.config;

  ZegoLiveHostManager? get _hostManager =>
      ZegoLiveStreamingManagers().hostManager;

  ZegoLiveConnectManager? get _connectManager =>
      ZegoLiveStreamingManagers().connectManager;

  bool get _isLocalHost => _hostManager?.isLocalHost ?? false;

  bool get _hostExist => _hostManager?.notifier.value?.id.isNotEmpty ?? false;

  bool get _isLiving =>
      _connectManager?.liveStatusNotifier.value == LiveStatus.living;

  /// for host: Notification that an audience has requested to become a co-host to the host.
  @Deprecated(
      'Since 2.17.0， use [ZegoUIKitPrebuiltLiveStreamingEvents.hostEvents.onCoHostRequest]')
  set onRequestCoHostEvent(ZegoLiveStreamingConnectEvent? event) =>
      _events?.hostEvents.onCoHostRequestReceived = event;

  ZegoLiveStreamingConnectEvent? get onRequestCoHostEvent =>
      _events?.hostEvents.onCoHostRequestReceived;

  /// for host: Notification that an audience has cancelled their co-host request.
  @Deprecated(
      'Since 2.17.0， use [ZegoUIKitPrebuiltLiveStreamingEvents.hostEvents.onCoHostRequestCanceled]')
  set onCancelCoHostEvent(ZegoLiveStreamingConnectEvent? event) =>
      _events?.hostEvents.onCoHostRequestCanceled = event;

  ZegoLiveStreamingConnectEvent? get onCancelCoHostEvent =>
      _events?.hostEvents.onCoHostRequestCanceled;

  /// for host: Notification that an audience co-host request has timed out.
  @Deprecated(
      'Since 2.17.0， use [ZegoUIKitPrebuiltLiveStreamingEvents.hostEvents.onCoHostRequestTimeout]')
  set onRequestCoHostTimeoutEvent(ZegoLiveStreamingConnectEvent? event) =>
      _events?.hostEvents.onCoHostRequestTimeout = event;

  ZegoLiveStreamingConnectEvent? get onRequestCoHostTimeoutEvent =>
      _events?.hostEvents.onCoHostRequestTimeout;

  final List<StreamSubscription<dynamic>?> _subscriptions = [];
  final List<String> _agreeRequestingUserIDs = [];

  /// audience: current audience connection state, audience or co-host
  final _audienceLocalConnectStateNotifier =
      ValueNotifier<ZegoLiveStreamingAudienceConnectState>(
          ZegoLiveStreamingAudienceConnectState.idle);

  /// for host: current requesting co-host's users
  final _requestCoHostUsersNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);

  var _hostNotifier = ValueNotifier<ZegoUIKitUser?>(null);
  bool _alreadyInitByCoreManager = false;

  ZegoUIKitPrebuiltLiveStreamingEvents? _events;
}
