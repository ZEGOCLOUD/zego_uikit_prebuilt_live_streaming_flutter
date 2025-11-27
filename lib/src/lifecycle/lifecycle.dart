// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/swiping/swiping.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimizing/data.dart';

import 'defines.dart';
import 'normal/normal.dart';

/// Lifecycle management for ZegoLiveStreamingPage
///
/// Because multiple live rooms can cause ZegoLiveStreamingPage creation and disposal to be out of order, leading to room sequence disorder, unified management is done here
/// Multiple live rooms use swiping, normal live rooms use normal
class ZegoLiveStreamingPageLifeCycle {
  String currentLiveID = '';
  ZegoLiveStreamingPageLifeCycleContextData? currentContextData;

  /// Only start initialization after RTC room login is complete
  final currentManagers = ZegoLiveStreamingManagers();

  final swiping = ZegoLiveStreamingSwipingLifeCycle();
  final normal = ZegoLiveStreamingNormalLifeCycle();

  BuildContext Function()? contextQuery;
  final List<StreamSubscription<dynamic>?> _subscriptions = [];

  /// Whether preview page is visible
  var previewPageVisibilityNotifier = ValueNotifier<bool>(true);

  void updatePreviewPageVisibility(bool value) {
    previewPageVisibilityNotifier.value = value;
  }

  final rtcContextReadyNotifier = ValueNotifier<bool>(false);

  Future<void> initFromPreview({
    required String targetLiveID,
    required bool isPrebuiltFromHall,
    required bool isPrebuiltFromMinimizing,
    required ZegoLiveStreamingPageLifeCycleContextData contextData,
  }) async {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'init before, ignore',
        tag: 'live-streaming-lifecyle',
        subTag: 'initFromPreview',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'targetLiveID:$targetLiveID, '
      'isPrebuiltFromHall:$isPrebuiltFromHall, '
      'isPrebuiltFromMinimizing:$isPrebuiltFromMinimizing, '
      'contextData:$contextData, ',
      tag: 'live-streaming-lifecyle',
      subTag: 'initFromPreview',
    );
    _initialized = true;

    assert(contextData.userID.isNotEmpty);
    assert(contextData.userName.isNotEmpty);
    assert(contextData.appID > 0);
    assert(contextData.appSign.isNotEmpty || contextData.token.isNotEmpty);

    currentLiveID = targetLiveID;
    currentContextData = contextData;

    rtcContextReadyNotifier.value =
        isPrebuiltFromMinimizing || isPrebuiltFromHall;

    _initControllerByPrebuilt(
      data: contextData,
      minimizeData: ZegoLiveStreamingMinimizeData(
        appID: contextData.appID,
        appSign: contextData.appSign,
        liveID: targetLiveID,
        userID: contextData.userID,
        userName: contextData.userName,
        config: contextData.config,
        events: contextData.events,
        isPrebuiltFromMinimizing: isPrebuiltFromMinimizing,
      ),
    );
    swiping.initFromPreview(
      token: contextData.token,
      liveID: targetLiveID,
      swipingConfig: contextData.config.swiping,
      hallConfig: contextData.config.hall,
      isPrebuiltFromHall: isPrebuiltFromHall,
      contextData: contextData,
    );
    currentManagers.initPluginAndManagers(
      contextData.appID,
      contextData.appSign,
      contextData.token,
      contextData.userID,
      contextData.userName,
      targetLiveID,
      contextData.config,
      contextData.events,
      contextQuery,
    );

    normal.initFromPreview(
      liveID: targetLiveID,
    );

    /// Only host needs preview page, audience directly enters room
    updatePreviewPageVisibility(
      !isPrebuiltFromMinimizing &&
          currentManagers.hostManager.isLocalHost &&
          contextData.config.preview.showPreviewForHost,
    );
  }

  Future<void> uninitFromPreview({
    required BuildContext context,
    required String liveID,
    required bool isPrebuiltFromMinimizing,
    required bool isPrebuiltFromHall,
    required ZegoUIKitPrebuiltLiveStreamingEvents? events,
  }) async {
    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'not init, ignore',
        tag: 'live-streaming-lifecyle',
        subTag: 'uninitFromPreview',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'isPrebuiltFromMinimizing:$isPrebuiltFromMinimizing, '
      'isPrebuiltFromHall:$isPrebuiltFromHall, '
      'currentLiveID:$currentLiveID, '
      'currentContextData:$currentContextData, ',
      tag: 'live-streaming-lifecyle',
      subTag: 'uninitFromPreview',
    );

    _initialized = false;
    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }

    if (!isPrebuiltFromHall) {
      /// If not entered from live hall, should completely exit room
      /// Should make leaving room directly stop pulling streams
      await ZegoUIKit().enableSwitchRoomNotStopPlay(false);
    }

    final hostID = currentManagers.hostManager.notifier.value?.id;

    /// host id
    if (swiping.usingRoomSwiping) {
      /// Using live streaming swiping
      /// 1. Need to leave room: If not from live hall, need to leave room because entire ZegoUIKitPrebuiltLiveStreaming is exiting
      /// 2. Need to switch room: From live hall
      normal.disposeDelegate.run(
        targetLiveID: ZegoUIKit().getCurrentRoom().id,
        currentManagers: currentManagers,
        data: currentContextData!,
        canLeaveRoom: !isPrebuiltFromHall,
      );
    }

    /// Handle live hall scenario
    await swiping.uninitFromPreview(isPrebuiltFromHall: isPrebuiltFromHall);
    normal.uninitFromPreview();

    currentLiveID = '';
    currentContextData = null;
  }

  /// Initiated from ZegoLiveStreamingPage
  ///
  /// ZegoLiveStreamingPage initState is called
  bool initFromLive({
    required bool isPrebuiltFromMinimizing,
    required bool isPrebuiltFromHall,
  }) {
    ZegoLoggerService.logInfo(
      'isPrebuiltFromMinimizing:$isPrebuiltFromMinimizing, '
      'isPrebuiltFromHall:$isPrebuiltFromHall, '
      'currentLiveID:$currentLiveID, ',
      tag: 'live-streaming-lifecyle',
      subTag: 'initFromLive',
    );

    ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
    if (isPrebuiltFromMinimizing) {
      ZegoLoggerService.logInfo(
        'isPrebuiltFromMinimizing, ignore, ',
        tag: 'live-streaming-lifecyle',
        subTag: 'initFromLive',
      );

      return false;
    }
    if (ZegoUIKit().hasRoomLogin() &&
        ZegoLiveStreamingPageLifeCycle().swiping.usingRoomSwiping) {
      /// When using swiping, use page builder's events to drive room entry/exit
      ZegoLoggerService.logInfo(
        'using swiping, wait run by page builder, ',
        tag: 'live-streaming-lifecyle',
        subTag: 'initFromLive',
      );
    } else {
      /// Single live scenario, or swiping first time entering from non-hall, will enter here, same data as initFromPreview
      normal.initStateDelegate.initFromLive(
        liveID: currentLiveID,
        contextData: currentContextData!,
        contextQuery: contextQuery,
        isPrebuiltFromMinimizing: isPrebuiltFromMinimizing,
        isPrebuiltFromHall: isPrebuiltFromHall,
        rtcContextReadyNotifier: rtcContextReadyNotifier,
      );
    }

    return true;
  }

  /// Initiated from ZegoLiveStreamingPage
  ///
  /// ZegoLiveStreamingPage dispose is called
  Future<bool> disposeFromLive({
    required String targetLiveID,
  }) async {
    ZegoLoggerService.logInfo(
      'currentLiveID:$currentLiveID, ',
      tag: 'live-streaming-lifecyle',
      subTag: 'disposeFromLive',
    );

    normal.initStateDelegate.clear();

    if (null == currentContextData || currentLiveID != targetLiveID) {
      return false;
    }

    await normal.disposeDelegate.run(
      targetLiveID: targetLiveID,
      data: currentContextData!,
      currentManagers: currentManagers,
      canLeaveRoom: true,
    );

    currentLiveID = '';
    currentContextData = null;

    return false;
  }

  void updateContextQuery(BuildContext Function()? contextQuery) {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live-streaming-lifecyle',
      subTag: 'updateContextQuery',
    );
    this.contextQuery = contextQuery;
  }

  void _initControllerByPrebuilt({
    required ZegoLiveStreamingPageLifeCycleContextData data,
    required ZegoLiveStreamingMinimizeData minimizeData,
  }) {
    ZegoLoggerService.logInfo(
      'minimizeData:$minimizeData, ',
      tag: 'live-streaming-lifecyle',
      subTag: 'initControllerByPrebuilt',
    );

    ZegoUIKitPrebuiltLiveStreamingController().private.initByPrebuilt(
          liveID: currentLiveID,
          config: data.config,
          events: data.events,
          minimizeData: minimizeData,
        );
  }

  factory ZegoLiveStreamingPageLifeCycle() => _instance;

  ZegoLiveStreamingPageLifeCycle._internal();

  static final ZegoLiveStreamingPageLifeCycle _instance =
      ZegoLiveStreamingPageLifeCycle._internal();

  bool _initialized = false;
}
