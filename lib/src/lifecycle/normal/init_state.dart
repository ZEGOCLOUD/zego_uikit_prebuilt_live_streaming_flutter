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

  void clear() {
    ZegoLoggerService.logInfo(
      'liveID:$liveID, ',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'clear',
    );

    liveID = '';
    contextData = null;
    contextQuery = null;
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
      subTag: 'clear',
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

    await setVideoConfig(data: contextData);
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
    onPreviewPageVisibilityUpdated();
    if (ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .configIsHost) {
      ZegoLiveStreamingPageLifeCycle()
          .previewPageVisibilityNotifier
          .addListener(onPreviewPageVisibilityUpdated);
    }
  }

  void onPreviewPageVisibilityUpdated() {
    final isPreviewPageVisible =
        ZegoLiveStreamingPageLifeCycle().previewPageVisibilityNotifier.value;

    ZegoLoggerService.logInfo(
      'onPreviewPageVisibilityUpdated:$onPreviewPageVisibilityUpdated, ',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'onPreviewPageVisibilityUpdated',
    );

    if (isPreviewPageVisible) {
      /// Still on live preview page
      return;
    }

    /// Enter live streaming page
    ZegoLiveStreamingPageLifeCycle()
        .previewPageVisibilityNotifier
        .removeListener(onPreviewPageVisibilityUpdated);
    if (ZegoUIKit().engineCreatedNotifier.value) {
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .liveStatusManager
          .checkShouldStopPlayAllAudioVideo(
            isPrebuiltFromHall: isPrebuiltFromHall,
          )
          .then((_) {
        joinRoom(
          roomID: liveID,
          token: contextData?.token ?? '',
          markAsLargeRoom: contextData?.config.markAsLargeRoom ?? false,
        );
      });
    } else {
      ZegoLoggerService.logInfo(
        'hashcode:$hashCode, '
        'express engine is not created, waiting',
        tag: 'live.streaming.lifecyle-initState',
        subTag: 'prebuilt',
      );

      ZegoUIKit().engineCreatedNotifier.addListener(joinRoomWaitEngineCreated);
    }
  }

  Future<void> initPermissions({
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
    if ((contextQuery?.call().mounted ?? false) &&
        data.config.turnOnCameraWhenJoining) {
      isCameraGranted = await requestPermission(Permission.camera);
    }
    if ((contextQuery?.call().mounted ?? false) &&
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
      if (contextQuery?.call().mounted ?? false) {
        await showAppSettingsDialog(
          context: contextQuery!.call(),
          rootNavigator: data.config.rootNavigator,
          popUpManager: data.popUpManager,
          dialogInfo: data.config.innerText.cameraPermissionSettingDialogInfo,
          kickOutNotifier:
              ZegoLiveStreamingPageLifeCycle().currentManagers.kickOutNotifier,
        );
      }
    }

    if (!isMicrophoneGranted) {
      if (contextQuery?.call().mounted ?? false) {
        await showAppSettingsDialog(
          context: contextQuery!.call(),
          rootNavigator: data.config.rootNavigator,
          popUpManager: data.popUpManager,
          dialogInfo:
              data.config.innerText.microphonePermissionSettingDialogInfo,
          kickOutNotifier:
              ZegoLiveStreamingPageLifeCycle().currentManagers.kickOutNotifier,
        );
      }
    }
  }

  Future<void> setVideoConfig({
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

  void joinRoomWaitEngineCreated() {
    ZegoUIKit().engineCreatedNotifier.removeListener(joinRoomWaitEngineCreated);

    final isCreated = ZegoUIKit().engineCreatedNotifier.value;
    ZegoLoggerService.logInfo(
      'express engine created:$isCreated',
      tag: 'live.streaming.lifecyle-initState',
      subTag: 'joinRoomWaitEngineCreated',
    );

    if (isCreated) {
      ZegoUIKit()
          .engineCreatedNotifier
          .removeListener(joinRoomWaitEngineCreated);
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .liveStatusManager
          .checkShouldStopPlayAllAudioVideo(
            isPrebuiltFromHall: isPrebuiltFromHall,
          )
          .then((_) {
        joinRoom(
          roomID: liveID,
          token: contextData?.token ?? '',
          markAsLargeRoom: contextData?.config.markAsLargeRoom ?? false,
        );
      });
    }
  }

  Future<void> joinRoom({
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
      onRoomLogin(ZegoUIKitRoomLoginResult(ZegoUIKitErrorCode.success, {}));
    } else {
      ZegoUIKit()
          .joinRoom(
        liveID,
        token: contextData?.token ?? '',
        markAsLargeRoom: contextData?.config.markAsLargeRoom ?? false,
      )
          .then((result) {
        onRoomLogin(result);
      });
    }
  }

  Future<void> onRoomLogin(ZegoUIKitRoomLoginResult result) async {
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

    notifyUserJoinByMessage();

    ZegoLiveStreamingPageLifeCycle().currentManagers.muteCoHostAudioVideo(
          ZegoUIKit().getAudioVideoList(targetRoomID: liveID),
        );
  }

  Future<void> notifyUserJoinByMessage() async {
    if (!(contextData?.config.inRoomMessage.notifyUserJoin ?? false)) {
      return;
    }

    final messageAttributes =
        contextData?.config.inRoomMessage.attributes?.call();
    if (messageAttributes?.isEmpty ?? true) {
      await ZegoUIKit().sendInRoomMessage(
        targetRoomID: liveID,
        contextData?.config.innerText.userEnter ?? '',
      );
    } else {
      await ZegoUIKit().sendInRoomMessage(
        targetRoomID: liveID,
        ZegoInRoomMessage.jsonBody(
          message: contextData?.config.innerText.userEnter ?? '',
          attributes: messageAttributes!,
        ),
      );
    }
  }
}
