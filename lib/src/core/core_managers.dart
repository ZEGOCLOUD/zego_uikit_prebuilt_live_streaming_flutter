// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/prebuilt_data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

part 'core_manager.audio_video.dart';

class ZegoLiveStreamingManagers {
  factory ZegoLiveStreamingManagers() => _instance;

  ZegoLiveStreamingManagers._internal();

  static final ZegoLiveStreamingManagers _instance =
      ZegoLiveStreamingManagers._internal();

  set swipingCurrentLiveID(String value) {
    ZegoLoggerService.logInfo(
      'set switching current live id:$value',
      tag: 'live streaming',
      subTag: 'core manager.swiping',
    );
    _swipingCurrentLiveID = value;
  }

  String get swipingCurrentLiveID => _swipingCurrentLiveID;

  void initPluginAndManagers(
    ZegoPopUpManager popUpManager,
    ZegoUIKitPrebuiltLiveStreamingData prebuiltData,
    ValueNotifier<bool> startedByLocalNotifier,
    BuildContext Function()? contextQuery,
  ) {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had init',
        tag: 'live streaming',
        subTag: 'core manager',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'init plugin and managers',
      tag: 'live streaming',
      subTag: 'core manager',
    );

    _initialized = true;

    hostManager = ZegoLiveHostManager(config: prebuiltData.config);
    liveStatusManager = ZegoLiveStatusManager(
      hostManager: hostManager!,
      config: prebuiltData.config,
    );
    liveDurationManager = ZegoLiveDurationManager(
      hostManager: hostManager!,
    );

    if (prebuiltData.config.plugins.isNotEmpty) {
      plugins = ZegoPrebuiltPlugins(
        appID: prebuiltData.appID,
        appSign: prebuiltData.appSign,
        userID: prebuiltData.userID,
        userName: prebuiltData.userName,
        roomID: prebuiltData.liveID,
        plugins: prebuiltData.config.plugins,
        beautyConfig: prebuiltData.config.beautyConfig,
        onError: prebuiltData.events.onError,
      );

      ZegoLiveStreamingPKBattleManager().init(
        hostManager: ZegoLiveStreamingManagers().hostManager!,
        liveStatusNotifier:
            ZegoLiveStreamingManagers().liveStatusManager!.notifier,
        config: prebuiltData.config,
        innerText: prebuiltData.config.innerText,
        startedByLocalNotifier: startedByLocalNotifier,
        contextQuery: contextQuery,
      );

      ZegoUIKitPrebuiltLiveStreamingPKV2().init(
        config: prebuiltData.config,
        controller: prebuiltData.controller,
        events: prebuiltData.events,
        innerText: prebuiltData.config.innerText,
        hostManager: ZegoLiveStreamingManagers().hostManager!,
        liveStatusNotifier:
            ZegoLiveStreamingManagers().liveStatusManager!.notifier,
        startedByLocalNotifier: startedByLocalNotifier,
        contextQuery: contextQuery,
      );

      ZegoLiveStreamingPKBattleStateCombineNotifier().init(
        v1StateNotifier: ZegoLiveStreamingPKBattleManager().state,
        v2StateNotifier: ZegoUIKitPrebuiltLiveStreamingPKV2().pkStateNotifier,
        v1RequestReceivedEventInMinimizingNotifier:
            ZegoUIKitPrebuiltLiveStreamingPKService()
                .pkBattleRequestReceivedEventInMinimizingNotifier,
        v2RequestReceivedEventInMinimizingNotifier:
            ZegoUIKitPrebuiltLiveStreamingPKV2()
                .pkBattleRequestReceivedEventInMinimizingNotifier,
      );
    }

    connectManager = ZegoLiveConnectManager(
      config: prebuiltData.config,
      controller: prebuiltData.controller,
      events: prebuiltData.events,
      hostManager: hostManager!,
      popUpManager: popUpManager,
      liveStatusNotifier: liveStatusManager!.notifier,
      translationText: prebuiltData.config.innerText,
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
      tag: 'live streaming',
      subTag: 'core manager',
    );
    connectManager?.contextQuery = contextQuery;

    ZegoLiveStreamingPKBattleManager().contextQuery = contextQuery;
    ZegoUIKitPrebuiltLiveStreamingPKV2().updateContextQuery(contextQuery);
  }

  Future<void> uninitPluginAndManagers() async {
    ZegoLoggerService.logInfo(
      'uninit plugin and managers',
      tag: 'live streaming',
      subTag: 'core manager',
    );

    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'had not init',
        tag: 'live streaming',
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
    await ZegoUIKitPrebuiltLiveStreamingPKV2().uninit();
    await ZegoLiveStreamingPKBattleManager().uninit();
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

  ZegoLiveHostManager? hostManager;
  ZegoLiveStatusManager? liveStatusManager;
  ZegoLiveDurationManager? liveDurationManager;
  ZegoPrebuiltPlugins? plugins;

  ZegoLiveConnectManager? connectManager;

  String _swipingCurrentLiveID = '';

  final kickOutNotifier = ValueNotifier<bool>(false);
}
