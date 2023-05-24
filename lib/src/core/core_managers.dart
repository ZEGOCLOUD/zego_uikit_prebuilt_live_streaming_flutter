// Flutter imports:
// Project imports:
import 'package:flutter/cupertino.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/minimizing/prebuilt_data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class ZegoLiveStreamingManagers {
  factory ZegoLiveStreamingManagers() => _instance;

  ZegoLiveStreamingManagers._internal();

  static final ZegoLiveStreamingManagers _instance =
      ZegoLiveStreamingManagers._internal();

  void initPluginAndManagers(
    ZegoUIKitPrebuiltLiveStreamingData prebuiltData,
    ValueNotifier<bool> startedByLocalNotifier,
  ) {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had init',
        tag: 'audio room',
        subTag: 'core manager',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'init plugin and managers',
      tag: 'audio room',
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
      config: prebuiltData.config,
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
      );

      ZegoLiveStreamingPKBattleManager().init(
        hostManager: ZegoLiveStreamingManagers().hostManager!,
        liveStatusNotifier:
            ZegoLiveStreamingManagers().liveStatusManager!.notifier,
        config: prebuiltData.config,
        translationText: prebuiltData.config.innerText,
        startedByLocalNotifier: startedByLocalNotifier,
      );
    }

    connectManager = ZegoLiveConnectManager(
      config: prebuiltData.config,
      hostManager: hostManager!,
      liveStatusNotifier: liveStatusManager!.notifier,
      translationText: prebuiltData.config.innerText,
    );
    connectManager!.init();

    hostManager!.setConnectManger(connectManager!);
    liveStatusManager!.setConnectManger(connectManager!);
  }

  void updateContextQuery(BuildContext Function()? contextQuery) {
    ZegoLoggerService.logInfo(
      'update context query',
      tag: 'audio room',
      subTag: 'core manager',
    );

    ZegoLiveStreamingPKBattleManager().contextQuery = contextQuery;
    connectManager?.contextQuery = contextQuery;
  }

  void unintPluginAndManagers() {
    ZegoLoggerService.logInfo(
      'uninit plugin and managers',
      tag: 'audio room',
      subTag: 'core manager',
    );

    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'had not init',
        tag: 'audio room',
        subTag: 'core manager',
      );

      return;
    }

    _initialized = false;

    ZegoLiveStreamingPKBattleManager().uninit();

    plugins?.uninit();
    hostManager?.uninit();
    liveStatusManager?.uninit();
    liveDurationManager?.uninit();

    connectManager?.uninit();

    hostManager = null;
    liveStatusManager = null;
    liveDurationManager = null;
    plugins = null;

    connectManager = null;
  }

  bool _initialized = false;
  ZegoLiveHostManager? hostManager;
  ZegoLiveStatusManager? liveStatusManager;
  ZegoLiveDurationManager? liveDurationManager;
  ZegoPrebuiltPlugins? plugins;

  ZegoLiveConnectManager? connectManager;
}
