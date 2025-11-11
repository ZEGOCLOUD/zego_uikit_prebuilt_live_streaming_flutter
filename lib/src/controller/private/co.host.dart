part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerCoHostPrivate {
  final _impl = ZegoLiveStreamingControllerCoHostPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerCoHostPrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerCoHostPrivateImpl {
  final List<StreamSubscription<dynamic>?> _subscriptions = [];
  final List<String> agreeRequestingUserIDs = [];

  /// audience: current audience connection state, audience or co-host
  final audienceLocalConnectStateNotifier =
      ValueNotifier<ZegoLiveStreamingAudienceConnectState>(
          ZegoLiveStreamingAudienceConnectState.idle);

  /// for host: current requesting co-host's users
  final requestCoHostUsersNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);

  ///
  final hostNotifier = ValueNotifier<ZegoUIKitUser?>(null);

  bool _alreadyInitByCoreManager = false;

  ZegoUIKitPrebuiltLiveStreamingConfig? configs;
  ZegoUIKitPrebuiltLiveStreamingEvents? events;

  ZegoLiveStreamingHostManager get hostManager =>
      ZegoLiveStreamingPageLifeCycle().currentManagers.hostManager;

  ZegoLiveStreamingConnectManager get connectManager =>
      ZegoLiveStreamingPageLifeCycle().currentManagers.connectManager;

  bool get isLocalHost => hostManager.isLocalHost;

  bool get hostExist => hostManager.notifier.value?.id.isNotEmpty ?? false;

  bool get isLiving =>
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .liveStatusManager
          .notifier
          .value ==
      LiveStatus.living;

  Function(ZegoLiveStreamingCoHostHostEventRequestReceivedData)?
      get onRequestCoHostEvent => events?.coHost.host.onRequestReceived;

  Function(ZegoLiveStreamingCoHostHostEventRequestCanceledData)?
      get onCancelCoHostEvent => events?.coHost.host.onRequestCanceled;

  Function(ZegoLiveStreamingCoHostHostEventRequestTimeoutData)?
      get onRequestCoHostTimeoutEvent => events?.coHost.host.onRequestTimeout;

  void _onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    agreeRequestingUserIDs.removeWhere(
      (userID) => -1 != users.indexWhere((user) => user.id == userID),
    );
  }

  void _onAudienceLocalConnectStateUpdated() {
    audienceLocalConnectStateNotifier.value =
        connectManager.audienceLocalConnectStateNotifier.value;
  }

  void _onRequestCoHostUsersUpdated() {
    requestCoHostUsersNotifier.value =
        connectManager.requestCoHostUsersNotifier.value;
  }

  void initByCoreManager() {
    if (_alreadyInitByCoreManager) {
      return;
    }

    _alreadyInitByCoreManager = true;

    ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .initializedNotifier
        .addListener(_onCoreManagerInitFinished);
    _onCoreManagerInitFinished();
  }

  void _onCoreManagerInitFinished() {
    if (ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .initializedNotifier
        .value) {
      hostNotifier.value = ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .hostManager
          .notifier
          .value;
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .hostManager
          .notifier
          .addListener(_onHostUpdated);
    } else {
      hostNotifier.value = null;
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .hostManager
          .notifier
          .removeListener(_onHostUpdated);
    }
  }

  void _onHostUpdated() {
    hostNotifier.value = ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .notifier
        .value;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL
  /// Call Inside By Prebuilt
  void initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? configs,
    required ZegoUIKitPrebuiltLiveStreamingEvents? events,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.connect.invite.p',
    );

    this.configs = configs;
    this.events = events;

    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }
    _subscriptions.add(
      ZegoUIKit()
          .getAudioVideoListStream(
            targetRoomID:
                ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
          )
          .listen(_onAudioVideoListUpdated),
    );

    connectManager.audienceLocalConnectStateNotifier
        .removeListener(_onAudienceLocalConnectStateUpdated);
    connectManager.audienceLocalConnectStateNotifier
        .addListener(_onAudienceLocalConnectStateUpdated);

    connectManager.requestCoHostUsersNotifier
        .removeListener(_onRequestCoHostUsersUpdated);
    connectManager.requestCoHostUsersNotifier
        .addListener(_onRequestCoHostUsersUpdated);
  }

  /// DO NOT CALL
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.connect.invite.p',
    );

    events = null;
    configs = null;

    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }

    connectManager.audienceLocalConnectStateNotifier
        .removeListener(_onAudienceLocalConnectStateUpdated);
    connectManager.requestCoHostUsersNotifier
        .removeListener(_onRequestCoHostUsersUpdated);

    agreeRequestingUserIDs.clear();
  }
}
