// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/service/services.dart';

part 'core_manager.audio_video.dart';

/// todo Split into non-singleton and put in ZegoLiveStreamingPageLifeCycle?
class ZegoLiveStreamingManagers {
  ZegoLiveStreamingManagers({
    required this.liveID,
  })  : pk = ZegoUIKitPrebuiltLiveStreamingPK(liveID: liveID),
        hostManager = ZegoLiveStreamingHostManager(liveID: liveID),
        liveStatusManager = ZegoLiveStreamingStatusManager(liveID: liveID),
        liveDurationManager = ZegoLiveStreamingDurationManager(liveID: liveID),
        connectManager = ZegoLiveStreamingConnectManager(liveID: liveID) {
    rtcContextReadyNotifier.value = ZegoUIKit().isInit;
  }

  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingPK pk;

  void initPluginAndManagers(
    int appID,
    String appSign,
    String token,
    String userID,
    String userName,
    ZegoUIKitPrebuiltLiveStreamingConfig config,
    ZegoUIKitPrebuiltLiveStreamingEvents? events,
    BuildContext Function()? contextQuery,
    ZegoLiveStreamingLoginFailedEvent? onRoomLoginFailed,
  ) {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had init',
        tag: 'live.streaming.core-mgr($liveID)',
        subTag: 'init',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.core-mgr($liveID)',
      subTag: 'init',
    );

    _initialized = true;

    hostManager.init(config: config);
    liveStatusManager.init(config: config, events: events);
    liveDurationManager.init();

    /// 插件登录前监听事件
    pk.addEventListener();

    ZegoLiveStreamingPageLifeCycle().plugins.init(
          appID: appID,
          appSign: appSign,
          token: token,
          userID: userID,
          userName: userName,
          config: config,
          events: events,
          onRoomLoginFailed: onRoomLoginFailed,
        );

    /// plugins.init要先于connectManager.init,connectManager.init有依赖
    connectManager.init(config: config, events: events);

    pk.init(
      config: config,
      events: events,
      contextQuery: contextQuery,
    );

    initAudioVideoManagers();

    initializedNotifier.value = true;
  }

  Future<void> uninitPluginAndManagers({
    required bool isFromMinimize,
  }) async {
    ZegoLoggerService.logInfo(
      'isFromMinimize:$isFromMinimize, ',
      tag: 'live.streaming.core-mgr($liveID)',
      subTag: 'uninit',
    );

    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'had not init',
        tag: 'live.streaming.core-mgr($liveID)',
        subTag: 'uninit',
      );

      return;
    }

    _initialized = false;
    initializedNotifier.value = false;

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    await connectManager.audienceCancelCoHostIfRequesting();

    uninitAudioVideoManagers();
    await pk.uninit(
      isFromMinimize: isFromMinimize,
    );

    /// Even if from live hall, still need to uninit plugins, probably won't be used
    await ZegoLiveStreamingPageLifeCycle().plugins.uninit();

    await hostManager.uninit();
    await liveStatusManager.uninit();
    await liveDurationManager.uninit();
    connectManager.uninit();
  }

  void onRoomWillSwitch({
    required String liveID,
  }) {
    ZegoLoggerService.logInfo(
      'live id:$liveID, ',
      tag: 'live.streaming.core-mgr($liveID)',
      subTag: 'onRoomWillSwitch',
    );

    pk.uninit(
      isFromMinimize: false,
    );

    connectManager.onRoomWillSwitch();
  }

  void onRoomSwitched({
    required int appID,
    required String appSign,
    required String token,
    required String userID,
    required String userName,
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
    required ZegoUIKitPrebuiltLiveStreamingEvents? events,
    required BuildContext Function()? contextQuery,
    required ZegoLiveStreamingLoginFailedEvent? onRoomLoginFailed,
  }) {
    ZegoLoggerService.logInfo(
      'live id:$liveID, ',
      tag: 'live.streaming.core-mgr($liveID)',
      subTag: 'onRoomSwitched',
    );

    hostManager.onRoomSwitched(config: config);
    liveStatusManager.onRoomSwitched(config: config, events: events);
    liveDurationManager.onRoomSwitched();

    ZegoLiveStreamingPageLifeCycle().plugins.init(
          appID: appID,
          appSign: appSign,
          token: token,
          userID: userID,
          userName: userName,
          config: config,
          events: events,
          onRoomLoginFailed: onRoomLoginFailed,
        );

    connectManager.onRoomSwitched(
      config: config,
      events: events,
    );
    pk.init(
      config: config,
      events: events,
      contextQuery: contextQuery,
    );
  }

  bool _initialized = false;
  var initializedNotifier = ValueNotifier<bool>(false);
  final rtcContextReadyNotifier = ValueNotifier<bool>(false);

  List<StreamSubscription<dynamic>?> subscriptions = [];

  final ZegoLiveStreamingHostManager hostManager;
  final ZegoLiveStreamingStatusManager liveStatusManager;
  final ZegoLiveStreamingDurationManager liveDurationManager;
  final ZegoLiveStreamingConnectManager connectManager;
  final kickOutNotifier = ValueNotifier<bool>(false);
}
