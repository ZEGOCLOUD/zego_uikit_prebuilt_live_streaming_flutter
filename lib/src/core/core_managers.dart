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
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/core.dart';

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
        subTag: 'initPluginAndManagers',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.core-mgr',
      subTag: 'initPluginAndManagers',
    );

    _initialized = true;
    _liveID = liveID;

    hostManager.init(liveID: liveID, config: config);
    liveStatusManager.init(liveID: liveID, config: config, events: events);
    liveDurationManager.init(liveID: liveID);
    connectManager.init(liveID: liveID, config: config, events: events);

    plugins.init(
      appID: appID,
      appSign: appSign,
      token: token,
      userID: userID,
      userName: userName,
      config: config,
      events: events,
    );

    ZegoUIKitPrebuiltLiveStreamingPK().init(
      liveID: liveID,
      config: config,
      events: events,
      contextQuery: contextQuery,
    );
    ZegoLiveStreamingPKBattleStateCombineNotifier().init(
      v2StateNotifier: ZegoUIKitPrebuiltLiveStreamingPK().pkStateNotifier,
      v2RequestReceivedEventInMinimizingNotifier:
          ZegoUIKitPrebuiltLiveStreamingPK()
              .pkBattleRequestReceivedEventInMinimizingNotifier,
    );

    initAudioVideoManagers();

    initializedNotifier.value = true;
  }

  Future<void> uninitPluginAndManagers() async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.core-mgr',
      subTag: 'uninitPluginAndManagers',
    );

    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'had not init',
        tag: 'live.streaming.core-mgr',
        subTag: 'uninitPluginAndManagers',
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
    await ZegoUIKitPrebuiltLiveStreamingPK().uninit();
    ZegoLiveStreamingPKBattleStateCombineNotifier().uninit();

    /// Even if from live hall, still need to uninit plugins, probably won't be used
    await plugins.uninit();

    await hostManager.uninit();
    await liveStatusManager.uninit();
    await liveDurationManager.uninit();
    connectManager.uninit();

    _liveID = '';
  }

  void onRoomSwitched({
    required String liveID,
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
    required ZegoUIKitPrebuiltLiveStreamingEvents? events,
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
