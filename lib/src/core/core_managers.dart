// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/core.dart';

part 'core_manager.audio_video.dart';

class ZegoLiveStreamingManagers {
  factory ZegoLiveStreamingManagers() => _instance;

  ZegoLiveStreamingManagers._internal();

  static final ZegoLiveStreamingManagers _instance =
      ZegoLiveStreamingManagers._internal();

  set swipingCurrentLiveID(String value) {
    ZegoLoggerService.logInfo(
      'set switching current live id:$value',
      tag: 'live-streaming',
      subTag: 'core manager.swiping',
    );
    _swipingCurrentLiveID = value;
  }

  String get swipingCurrentLiveID => _swipingCurrentLiveID;

  void initPluginAndManagers(
    int appID,
    String appSign,
    String token,
    String userID,
    String userName,
    String liveID,
    ZegoUIKitPrebuiltLiveStreamingConfig config,
    ZegoUIKitPrebuiltLiveStreamingEvents events,
    ZegoLiveStreamingPopUpManager popUpManager,
    ValueNotifier<bool> startedByLocalNotifier,
    BuildContext Function()? contextQuery,
  ) {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had init',
        tag: 'live-streaming',
        subTag: 'core manager',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'init plugin and managers',
      tag: 'live-streaming',
      subTag: 'core manager',
    );

    _initialized = true;

    hostManager = ZegoLiveStreamingHostManager(config: config);
    liveStatusManager = ZegoLiveStreamingStatusManager(
      hostManager: hostManager!,
      config: config,
      events: events,
    );
    liveDurationManager = ZegoLiveStreamingDurationManager(
      hostManager: hostManager!,
    );

    if (config.plugins.isNotEmpty) {
      plugins = ZegoLiveStreamingPlugins(
        appID: appID,
        appSign: appSign,
        token: token,
        userID: userID,
        userName: userName,
        roomID: liveID,
        plugins: config.plugins,
        beautyConfig: config.beauty,
        onError: events.onError,
      );

      ZegoUIKitPrebuiltLiveStreamingPK().init(
        config: config,
        events: events,
        innerText: config.innerText,
        hostManager: ZegoLiveStreamingManagers().hostManager!,
        liveStatusNotifier:
            ZegoLiveStreamingManagers().liveStatusManager!.notifier,
        startedByLocalNotifier: startedByLocalNotifier,
        contextQuery: contextQuery,
      );

      ZegoLiveStreamingPKBattleStateCombineNotifier().init(
        v2StateNotifier: ZegoUIKitPrebuiltLiveStreamingPK().pkStateNotifier,
        v2RequestReceivedEventInMinimizingNotifier:
            ZegoUIKitPrebuiltLiveStreamingPK()
                .pkBattleRequestReceivedEventInMinimizingNotifier,
      );
    }

    connectManager = ZegoLiveStreamingConnectManager(
      config: config,
      events: events,
      hostManager: hostManager!,
      popUpManager: popUpManager,
      liveStatusNotifier: liveStatusManager!.notifier,
      contextQuery: contextQuery,
      kickOutNotifier: kickOutNotifier,
    );
    connectManager!.init();

    hostManager!.setConnectManger(connectManager!);
    liveStatusManager!.setConnectManger(connectManager!);

    initAudioVideoManagers();

    initializedNotifier.value = true;
  }

  void updateContextQuery(BuildContext Function()? contextQuery) {
    ZegoLoggerService.logInfo(
      'update context query',
      tag: 'live-streaming',
      subTag: 'core manager',
    );
    connectManager?.contextQuery = contextQuery;

    ZegoUIKitPrebuiltLiveStreamingPK().updateContextQuery(contextQuery);
  }

  Future<void> uninitPluginAndManagers() async {
    ZegoLoggerService.logInfo(
      'uninit plugin and managers',
      tag: 'live-streaming',
      subTag: 'core manager',
    );

    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'had not init',
        tag: 'live-streaming',
        subTag: 'core manager',
      );

      return;
    }

    _initialized = false;
    initializedNotifier.value = false;

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    await connectManager?.audienceCancelCoHostIfRequesting();

    uninitAudioVideoManagers();
    await ZegoUIKitPrebuiltLiveStreamingPK().uninit();
    ZegoLiveStreamingPKBattleStateCombineNotifier().uninit();

    await plugins?.uninit();
    await hostManager?.uninit();
    await liveStatusManager?.uninit();
    await liveDurationManager?.uninit();

    connectManager?.uninit();

    hostManager = null;
    liveStatusManager = null;
    liveDurationManager = null;
    plugins = null;

    connectManager = null;
  }

  bool _initialized = false;
  var initializedNotifier = ValueNotifier<bool>(false);

  List<StreamSubscription<dynamic>?> subscriptions = [];

  ZegoLiveStreamingHostManager? hostManager;
  ZegoLiveStreamingStatusManager? liveStatusManager;
  ZegoLiveStreamingDurationManager? liveDurationManager;
  ZegoLiveStreamingConnectManager? connectManager;
  ZegoLiveStreamingPlugins? plugins;

  String _swipingCurrentLiveID = '';

  final kickOutNotifier = ValueNotifier<bool>(false);
}
