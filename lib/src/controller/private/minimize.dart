part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerMinimizingPrivate {
  final _private = ZegoLiveStreamingControllerMinimizingPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerMinimizingPrivateImpl get private => _private;
}

/// @nodoc
/// Here are the APIs related to invitation.
class ZegoLiveStreamingControllerMinimizingPrivateImpl {
  ZegoLiveStreamingMinimizeData? get minimizeData => _minimizeData;
  bool get isLiving =>
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .liveStatusManager
          .notifier
          .value ==
      LiveStatus.living;

  ZegoLiveStreamingMinimizeData? _minimizeData;
  ZegoUIKitPrebuiltLiveStreamingConfig? config;
  final activeUser = ZegoLiveStreamingControllerMinimizePrivateActiveUser();

  final isMinimizingNotifier = ValueNotifier<bool>(false);

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void initByPrebuilt({
    required ZegoLiveStreamingMinimizeData minimizeData,
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.minimize.p',
    );

    _minimizeData = minimizeData;
    this.config = config;
    activeUser.setConfig(config: config);

    isMinimizingNotifier.value =
        ZegoLiveStreamingMiniOverlayMachine().isMinimizing;
    ZegoLiveStreamingMiniOverlayMachine()
        .registerStateChanged(onMiniOverlayMachineStateChanged);
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.minimize.p',
    );

    _minimizeData = null;
    config = null;
    activeUser.setConfig(config: null);

    ZegoLiveStreamingMiniOverlayMachine()
        .unregisterStateChanged(onMiniOverlayMachineStateChanged);
  }

  void onMiniOverlayMachineStateChanged(
    ZegoLiveStreamingMiniOverlayPageState state,
  ) {
    isMinimizingNotifier.value =
        ZegoLiveStreamingMiniOverlayPageState.minimizing == state;
  }
}

class ZegoLiveStreamingControllerMinimizePrivateActiveUser {
  bool isStarted = false;
  ZegoUIKitPrebuiltLiveStreamingConfig? config;
  bool showLocalUserView = false;

  final activeUserIDNotifier = ValueNotifier<String?>(null);
  StreamSubscription<dynamic>? audioVideoListSubscription;
  List<StreamSubscription<dynamic>?> soundLevelSubscriptions = [];
  Timer? activeUserTimer;
  final Map<String, List<double>> rangeSoundLevels = {};

  bool get ignoreLocalUser {
    /// Under ios pip, only remote pull-based streaming can be rendered, so filtering is required
    bool ignore = false;
    if (Platform.isIOS) {
      if ((ZegoUIKitPrebuiltLiveStreamingController().pip.private.pipImpl()
              as ZegoLiveStreamingControllerIOSPIP)
          .isSupportInConfig) {
        ignore = true;
      }
    }

    return ignore ? ignore : !showLocalUserView;
  }

  void setConfig({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) {
    this.config = config;
  }

  void start({
    bool showLocalUserView = false,
  }) {
    if (isStarted) {
      ZegoLoggerService.logInfo(
        'start, but already start',
        tag: 'call',
        subTag: 'controller.minimize.active_user',
      );

      return;
    }
    isStarted = true;

    ZegoLoggerService.logInfo(
      'start',
      tag: 'call',
      subTag: 'controller.minimize.active_user',
    );

    listenAudioVideoList();
    activeUserTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateActiveUserByTimer();
    });
  }

  void stop() {
    if (!isStarted) {
      ZegoLoggerService.logInfo(
        'stop, but not start',
        tag: 'call',
        subTag: 'controller.minimize.active_user',
      );

      return;
    }
    isStarted = false;

    ZegoLoggerService.logInfo(
      'stop',
      tag: 'call',
      subTag: 'controller.minimize.active_user',
    );

    audioVideoListSubscription?.cancel();
    activeUserTimer?.cancel();
    activeUserTimer = null;
  }

  void listenAudioVideoList() {
    audioVideoListSubscription = ZegoUIKit()
        .getAudioVideoListStream(
          targetRoomID:
              ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        )
        .listen(onAudioVideoListUpdated);

    final audioVideoList = ZegoUIKit().getAudioVideoList(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
    );
    if (ignoreLocalUser) {
      audioVideoList
          .removeWhere((user) => user.id == ZegoUIKit().getLocalUser().id);
    }
    onAudioVideoListUpdated(audioVideoList);

    if (audioVideoList.isEmpty) {
      if (!ignoreLocalUser) {
        activeUserIDNotifier.value = ZegoUIKit().getLocalUser().id;
      }
    } else {
      activeUserIDNotifier.value = audioVideoList.first.id;
    }
  }

  void onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    for (final subscription in soundLevelSubscriptions) {
      subscription?.cancel();
    }
    rangeSoundLevels.clear();

    if (ignoreLocalUser) {
      users.removeWhere((user) => user.id == ZegoUIKit().getLocalUser().id);
    }
    for (final user in users) {
      soundLevelSubscriptions.add(user.soundLevel.listen((soundLevel) {
        if (rangeSoundLevels.containsKey(user.id)) {
          rangeSoundLevels[user.id]!.add(soundLevel);
        } else {
          rangeSoundLevels[user.id] = [soundLevel];
        }
      }));
    }
  }

  void updateActiveUserByTimer() {
    var maxAverageSoundLevel = 0.0;
    var activeUserID = '';
    rangeSoundLevels.forEach((userID, soundLevels) {
      final averageSoundLevel =
          soundLevels.reduce((a, b) => a + b) / soundLevels.length;

      if (averageSoundLevel > maxAverageSoundLevel) {
        activeUserID = userID;
        maxAverageSoundLevel = averageSoundLevel;
      }
    });

    if (activeUserID.isEmpty) {
      return;
    }

    if (activeUserID != activeUserIDNotifier.value) {
      ZegoLoggerService.logInfo(
        'update active user:$activeUserID',
        tag: 'live streaming',
        subTag: 'controller.minimize.active_user',
      );
    }

    activeUserIDNotifier.value = activeUserID;
    if (activeUserIDNotifier.value?.isEmpty ?? true) {
      if (!ignoreLocalUser) {
        activeUserIDNotifier.value = ZegoUIKit().getLocalUser().id;
      }
    }

    rangeSoundLevels.clear();
  }

  String? switchActiveUserToRemoteUser() {
    if (activeUserIDNotifier.value != ZegoUIKit().getLocalUser().id) {
      return activeUserIDNotifier.value;
    }

    final audioVideoList = ZegoUIKit().getAudioVideoList(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
    );
    for (int idx = 0; idx < audioVideoList.length; ++idx) {
      final audioVideoUser = audioVideoList[idx];
      if (ZegoUIKit().getLocalUser().id == audioVideoUser.id) {
        continue;
      }

      if (audioVideoUser.id != activeUserIDNotifier.value) {
        ZegoLoggerService.logInfo(
          'switch remote active user:${audioVideoUser.id}',
          tag: 'live streaming',
          subTag: 'controller.minimize.active_user',
        );
      }

      activeUserIDNotifier.value = audioVideoUser.id;

      break;
    }

    return activeUserIDNotifier.value;
  }
}
