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
import 'package:zego_uikit_prebuilt_live_streaming/src/core/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/service/services.dart';

part 'core_manager.audio_video.dart';

/// todo Split into non-singleton and put in ZegoLiveStreamingPageLifeCycle?
class ZegoLiveStreamingManagers {
  String get liveID {
    assert(_liveID.isNotEmpty);
    return _liveID;
  }

  void initPluginAndManagers(
    int appID,
    String appSign,
    String token,
    String userID,
    String userName,
    String liveID,
    ZegoUIKitPrebuiltLiveStreamingConfig config,
    ZegoUIKitPrebuiltLiveStreamingEvents? events,
    BuildContext Function()? contextQuery,
  ) {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had init',
        tag: 'live.streaming.core-mgr',
        subTag: 'init',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.core-mgr',
      subTag: 'init',
    );

    _initialized = true;
    _liveID = liveID;

    hostManager.init(liveID: liveID, config: config);
    liveStatusManager.init(liveID: liveID, config: config, events: events);
    liveDurationManager.init(liveID: liveID);

    /// 插件登录前监听事件
    ZegoUIKitPrebuiltLiveStreamingPK.instance.addEventListener(
      liveID: liveID,
    );

    plugins.init(
      appID: appID,
      appSign: appSign,
      token: token,
      userID: userID,
      userName: userName,
      config: config,
      events: events,
    );

    /// plugins.init要先于connectManager.init,connectManager.init有依赖
    connectManager.init(liveID: liveID, config: config, events: events);

    ZegoUIKitPrebuiltLiveStreamingPK.instance.init(
      liveID: liveID,
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
      tag: 'live.streaming.core-mgr',
      subTag: 'uninit',
    );

    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'had not init',
        tag: 'live.streaming.core-mgr',
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
    await ZegoUIKitPrebuiltLiveStreamingPK.instance.uninit(
      isFromMinimize: isFromMinimize,
    );

    /// Even if from live hall, still need to uninit plugins, probably won't be used
    await plugins.uninit();

    await hostManager.uninit();
    await liveStatusManager.uninit();
    await liveDurationManager.uninit();
    connectManager.uninit();

    _liveID = '';
  }

  void onRoomWillSwitch({
    required String liveID,
  }) {
    ZegoLoggerService.logInfo(
      'live id:$liveID, ',
      tag: 'live.streaming.core-mgr',
      subTag: 'onRoomWillSwitch',
    );

    ZegoUIKitPrebuiltLiveStreamingPK.instance.uninit(
      isFromMinimize: false,
    );

    /// 切换房间前监听事件
    ZegoUIKitPrebuiltLiveStreamingPK.instance.addEventListener(
      liveID: liveID,
    );
    connectManager.onRoomWillSwitch(liveID: liveID);
  }

  void onRoomSwitched({
    required String liveID,
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
    required ZegoUIKitPrebuiltLiveStreamingEvents? events,
    required BuildContext Function()? contextQuery,
  }) {
    ZegoLoggerService.logInfo(
      'live id:$liveID, ',
      tag: 'live.streaming.core-mgr',
      subTag: 'onRoomSwitched',
    );

    _liveID = liveID;

    hostManager.onRoomSwitched(liveID: liveID, config: config);
    liveStatusManager.onRoomSwitched(liveID: liveID);
    liveDurationManager.onRoomSwitched(liveID: liveID);
    connectManager.onRoomSwitched(
      liveID: liveID,
      config: config,
      events: events,
    );
    ZegoUIKitPrebuiltLiveStreamingPK.instance.init(
      liveID: liveID,
      config: config,
      events: events,
      contextQuery: contextQuery,
    );
  }

  bool _initialized = false;
  String _liveID = '';
  var initializedNotifier = ValueNotifier<bool>(false);

  List<StreamSubscription<dynamic>?> subscriptions = [];

  final hostManager = ZegoLiveStreamingHostManager();
  final liveStatusManager = ZegoLiveStreamingStatusManager();
  final liveDurationManager = ZegoLiveStreamingDurationManager();
  final connectManager = ZegoLiveStreamingConnectManager();
  final plugins = ZegoLiveStreamingPlugins();
  final kickOutNotifier = ValueNotifier<bool>(false);
}
