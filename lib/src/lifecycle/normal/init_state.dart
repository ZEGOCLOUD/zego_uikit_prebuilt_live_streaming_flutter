// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/permissions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller/private/pip/pip_ios.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';

class ZegoLiveStreamingPageLifeCycleInitState {
  String liveID = '';
  bool isPrebuiltFromHall = false;
  ZegoLiveStreamingPageLifeCycleContextData? contextData;
  ZegoLiveStreamingLoginFailedEvent? onRoomLoginFailed;
  BuildContext Function()? contextQuery;

  final _previewVisibilityListeners = <String, VoidCallback>{};
  final _engineCreatedListeners = <String, VoidCallback>{};

  bool get playingStreamInPIPUnderIOS {
    bool isPlaying = false;
    if (Platform.isIOS) {
      isPlaying = (ZegoUIKitPrebuiltLiveStreamingController()
              .pip
              .private
              .pipImpl() as ZegoLiveStreamingControllerIOSPIP)
          .isSupportInConfig;
    }

    return isPlaying;
  }

  void clear(String targetLiveID) {
    ZegoLoggerService.logInfo(
      'targetLiveID:$targetLiveID, '
      'current liveID:$liveID, ',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'clear',
    );

    if (liveID == targetLiveID) {
      liveID = '';
      contextData = null;
      contextQuery = null;
    }

    if (_previewVisibilityListeners.containsKey(targetLiveID)) {
      ZegoLiveStreamingPageLifeCycle()
          .previewPageVisibilityNotifier
          .removeListener(_previewVisibilityListeners[targetLiveID]!);
      _previewVisibilityListeners.remove(targetLiveID);
    }

    if (_engineCreatedListeners.containsKey(targetLiveID)) {
      ZegoUIKit()
          .engineCreatedNotifier
          .removeListener(_engineCreatedListeners[targetLiveID]!);
      _engineCreatedListeners.remove(targetLiveID);
    }
  }

  Future<void> initFromLive({
    required String liveID,
    required ZegoLiveStreamingPageLifeCycleContextData contextData,
    required BuildContext Function()? contextQuery,
    required bool isPrebuiltFromMinimizing,
    required bool isPrebuiltFromHall,
    required ZegoLiveStreamingLoginFailedEvent? onRoomLoginFailed,
    required ValueNotifier<bool> rtcContextReadyNotifier,
  }) async {
    this.liveID = liveID;
    this.contextData = contextData;
    this.contextQuery = contextQuery;
    this.isPrebuiltFromHall = isPrebuiltFromHall;
    this.onRoomLoginFailed = onRoomLoginFailed;

    ZegoLoggerService.logInfo(
      'liveID:$liveID, '
      'isPrebuiltFromMinimizing:$isPrebuiltFromMinimizing, '
      'isPrebuiltFromHall:$isPrebuiltFromHall, '
      'rtcContextReadyNotifier:${rtcContextReadyNotifier.value}, ',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'initFromLive',
    );

    /// Should not be called twice before exiting live streaming
    ZegoUIKit().login(contextData.userID, contextData.userName);

    /// first set before create express
    await ZegoUIKit().setAdvanceConfigs(contextData.config.advanceConfigs);

    var enablePlatformView = false;
    if (Platform.isIOS) {
      enablePlatformView = contextData.config.mediaPlayer.supportTransparent ||
          playingStreamInPIPUnderIOS;
    }
    await ZegoUIKit()
        .init(
      appID: contextData.appID,
      appSign: contextData.appSign,
      token: contextData.token,
      scenario: ZegoUIKitScenario.Broadcast,
      enablePlatformView: enablePlatformView,
      playingStreamInPIPUnderIOS: playingStreamInPIPUnderIOS,
    )
        .then((_) {
      rtcContextReadyNotifier.value = true;
    });

    /// second set after create express
    await ZegoUIKit().setAdvanceConfigs(contextData.config.advanceConfigs);

    await ZegoUIKit().enableCustomVideoRender(playingStreamInPIPUnderIOS);

    await setVideoConfig(liveID: liveID, data: contextData);
    await initBaseBeautyConfig(data: contextData);

    await ZegoUIKit()
        .useFrontFacingCamera(contextData.config.useFrontFacingCamera);
    ZegoUIKit()
      ..updateVideoViewMode(
        contextData.config.audioVideoView.useVideoViewAspectFill,
      )
      ..enableVideoMirroring(
        contextData.config.audioVideoView.isVideoMirror,
      )
      ..setAudioOutputToSpeaker(contextData.config.useSpeakerWhenJoining);
    if (contextData.config.role == ZegoLiveStreamingRole.audience &&
        null != contextData.config.audienceAudioVideoResourceMode) {
      ZegoUIKit().setPlayerResourceMode(
        targetRoomID: liveID,
        contextData.config.audienceAudioVideoResourceMode!,
      );
    }

    await initPermissions(
      liveID: liveID,
      data: contextData,
      contextQuery: contextQuery,
    ).then((_) {
      if (contextQuery?.call().mounted ?? false) {
        ZegoUIKit()
          ..turnCameraOn(
            targetRoomID: liveID,
            contextData.config.turnOnCameraWhenJoining,
          )
          ..turnMicrophoneOn(
            targetRoomID: liveID,
            contextData.config.turnOnMicrophoneWhenJoining,
          );
      }
    });

    /// Wait until live streaming starts
    late VoidCallback onPreviewPageVisibilityUpdated;

    void joinRoomWaitEngineCreated() {
      if (_engineCreatedListeners.containsKey(liveID)) {
        ZegoUIKit()
            .engineCreatedNotifier
            .removeListener(_engineCreatedListeners[liveID]!);
        _engineCreatedListeners.remove(liveID);
      }

      final isCreated = ZegoUIKit().engineCreatedNotifier.value;
      ZegoLoggerService.logInfo(
        'express engine created:$isCreated',
        tag: 'live.streaming.lifecyle-initState',
        subTag: 'joinRoomWaitEngineCreated',
      );

      if (isCreated) {
        ZegoLiveStreamingPageLifeCycle()
            .manager(liveID)
            .liveStatusManager
            .checkShouldStopPlayAllAudioVideo(
              isPrebuiltFromHall: isPrebuiltFromHall,
            )
            .then((_) {
          joinRoom(
            liveID: liveID,
            contextData: contextData,
            roomID: liveID,
            token: contextData.token,
            markAsLargeRoom: contextData.config.markAsLargeRoom,
          );
        });
      }
    }

    onPreviewPageVisibilityUpdated = () {
      final isPreviewPageVisible =
          ZegoLiveStreamingPageLifeCycle().previewPageVisibilityNotifier.value;

      ZegoLoggerService.logInfo(
        'onPreviewPageVisibilityUpdated:$isPreviewPageVisible, ',
        tag: 'live.streaming.lifecyle-initState',
        subTag: 'onPreviewPageVisibilityUpdated',
      );

      if (isPreviewPageVisible) {
        /// Still on live preview page
        return;
      }

      /// Enter live streaming page
      if (_previewVisibilityListeners.containsKey(liveID)) {
        ZegoLiveStreamingPageLifeCycle()
            .previewPageVisibilityNotifier
            .removeListener(_previewVisibilityListeners[liveID]!);
        _previewVisibilityListeners.remove(liveID);
      }

      if (ZegoUIKit().engineCreatedNotifier.value) {
        ZegoLiveStreamingPageLifeCycle()
            .manager(liveID)
            .liveStatusManager
            .checkShouldStopPlayAllAudioVideo(
              isPrebuiltFromHall: isPrebuiltFromHall,
            )
            .then((_) {
          joinRoom(
            liveID: liveID,
            contextData: contextData,
            roomID: liveID,
            token: contextData.token,
            markAsLargeRoom: contextData.config.markAsLargeRoom,
          );
        });
      } else {
        ZegoLoggerService.logInfo(
          'express engine is not created, waiting',
          tag: 'live.streaming.lifecyle-initState',
          subTag: 'prebuilt',
        );

        _engineCreatedListeners[liveID] = joinRoomWaitEngineCreated;
        ZegoUIKit()
            .engineCreatedNotifier
            .addListener(joinRoomWaitEngineCreated);
      }
    };

    _previewVisibilityListeners[liveID] = onPreviewPageVisibilityUpdated;
    onPreviewPageVisibilityUpdated();

    if (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .hostManager
        .configIsHost) {
      ZegoLiveStreamingPageLifeCycle()
          .previewPageVisibilityNotifier
          .addListener(onPreviewPageVisibilityUpdated);
    }
  }

  Future<void> initPermissions({
    required String liveID,
    required ZegoLiveStreamingPageLifeCycleContextData data,
    required BuildContext Function()? contextQuery,
  }) async {
    ZegoLoggerService.logInfo(
      'request camera:${data.config.turnOnCameraWhenJoining}, '
      'request microphone:${data.config.turnOnMicrophoneWhenJoining}, ',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'initPermissions',
    );

    var isCameraGranted = true;
    var isMicrophoneGranted = true;
    if ((contextQuery?.call()?.mounted ?? false) &&
        data.config.turnOnCameraWhenJoining) {
      isCameraGranted = await requestPermission(Permission.camera);
    }
    if ((contextQuery?.call()?.mounted ?? false) &&
        data.config.turnOnMicrophoneWhenJoining) {
      isMicrophoneGranted = await requestPermission(Permission.microphone);
    }

    ZegoLoggerService.logInfo(
      'camera result:$isCameraGranted, '
      'microphone result:$isMicrophoneGranted, ',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'initPermissions',
    );

    if (!isCameraGranted) {
      if (contextQuery?.call()?.mounted ?? false) {
        await showAppSettingsDialog(
          context: contextQuery!.call(),
          rootNavigator: data.config.rootNavigator,
          popUpManager: data.popUpManager,
          dialogInfo: data.config.innerText.cameraPermissionSettingDialogInfo,
          kickOutNotifier:
              ZegoLiveStreamingPageLifeCycle().manager(liveID).kickOutNotifier,
        );
      }
    }

    if (!isMicrophoneGranted) {
      if (contextQuery?.call()?.mounted ?? false) {
        await showAppSettingsDialog(
          context: contextQuery!.call(),
          rootNavigator: data.config.rootNavigator,
          popUpManager: data.popUpManager,
          dialogInfo:
              data.config.innerText.microphonePermissionSettingDialogInfo,
          kickOutNotifier:
              ZegoLiveStreamingPageLifeCycle().manager(liveID).kickOutNotifier,
        );
      }
    }
  }

  Future<void> setVideoConfig({
    required String liveID,
    required ZegoLiveStreamingPageLifeCycleContextData data,
  }) async {
    ZegoLoggerService.logInfo(
      'video config:${data.config.video}',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'setVideoConfig',
    );

    await ZegoUIKit().enableTrafficControl(
      targetRoomID: liveID,
      true,
      [
        ZegoUIKitTrafficControlProperty.adaptiveResolution,
        ZegoUIKitTrafficControlProperty.adaptiveFPS,
      ],
      minimizeVideoConfig: ZegoVideoConfigExtension.preset360P(),
      isFocusOnRemote: false,
      streamType: ZegoStreamType.main,
    );

    await ZegoUIKit().setVideoConfig(
      data.config.video,
    );
  }

  Future<void> initBaseBeautyConfig({
    required ZegoLiveStreamingPageLifeCycleContextData data,
  }) async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'initBaseBeautyConfig',
    );

    final useBeautyEffect = data.config.bottomMenuBar.hostButtons
            .contains(ZegoLiveStreamingMenuBarButtonName.beautyEffectButton) ||
        data.config.bottomMenuBar.coHostButtons
            .contains(ZegoLiveStreamingMenuBarButtonName.beautyEffectButton);
    final useAdvanceEffect =
        ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null;
    if (!useBeautyEffect || useAdvanceEffect) {
      return;
    }

    await ZegoUIKit()
        .startEffectsEnv()
        .then((value) => ZegoUIKit().enableBeauty(true));
  }

  Future<void> joinRoom({
    required String liveID,
    required ZegoLiveStreamingPageLifeCycleContextData contextData,
    required String roomID,
    required String token,
    required bool markAsLargeRoom,
  }) async {
    ZegoLoggerService.logInfo(
      'room id:$roomID, '
      'markAsLargeRoom:$markAsLargeRoom, ',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'joinRoom',
    );

    if (isPrebuiltFromHall) {
      onRoomLogin(
        liveID: liveID,
        contextData: contextData,
        result: ZegoUIKitRoomLoginResult(ZegoUIKitErrorCode.success, {}),
      );
    } else {
      ZegoUIKit()
          .joinRoom(
        liveID,
        token: token,
        markAsLargeRoom: markAsLargeRoom,
      )
          .then((result) {
        onRoomLogin(
          liveID: liveID,
          contextData: contextData,
          result: result,
        );
      });
    }
  }

  Future<void> onRoomLogin({
    required String liveID,
    required ZegoLiveStreamingPageLifeCycleContextData contextData,
    required ZegoUIKitRoomLoginResult result,
  }) async {
    if (result.errorCode != 0) {
      onRoomLoginFailed?.call(result.errorCode, result.extendedData.toString());
      ZegoLoggerService.logError(
        'failed to login room:${result.errorCode},${result.extendedData}',
        tag: 'live-streaming',
        subTag: 'prebuilt',
      );
    }

    ZegoLoggerService.logInfo(
      'login room done, '
      'room id:$liveID',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'onRoomLogin',
    );

    notifyUserJoinByMessage(liveID: liveID, contextData: contextData);

    ZegoLiveStreamingPageLifeCycle().manager(liveID).muteCoHostAudioVideo(
          ZegoUIKit().getAudioVideoList(targetRoomID: liveID),
        );
  }

  Future<void> notifyUserJoinByMessage({
    required String liveID,
    required ZegoLiveStreamingPageLifeCycleContextData contextData,
  }) async {
    if (!(contextData.config.inRoomMessage.notifyUserJoin)) {
      return;
    }

    final messageAttributes =
        contextData.config.inRoomMessage.attributes?.call();
    if (messageAttributes?.isEmpty ?? true) {
      await ZegoUIKit().sendInRoomMessage(
        targetRoomID: liveID,
        contextData.config.innerText.userEnter,
      );
    } else {
      await ZegoUIKit().sendInRoomMessage(
        targetRoomID: liveID,
        ZegoInRoomMessage.jsonBody(
          message: contextData.config.innerText.userEnter,
          attributes: messageAttributes!,
        ),
      );
    }
  }
}
