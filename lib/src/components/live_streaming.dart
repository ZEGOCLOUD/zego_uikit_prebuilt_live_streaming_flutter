// Dart imports:
import 'dart:async';
import 'dart:core';
import 'dart:developer';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_page.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/permissions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/preview_page.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/prebuilt_data.dart';

/// Live Streaming Widget.
///
/// You can embed this widget into any page of your project to integrate the functionality of a live streaming.
///
/// You can refer to our [documentation](https://docs.zegocloud.com/article/14846), [documentation with cohosting](https://docs.zegocloud.com/article/14882)
/// or our [sample code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_live_streaming_example_flutter).
class ZegoUIKitPrebuiltLiveStreamingPage extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreamingPage({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    this.controller,
    this.events,
    @Deprecated('Since 2.15.0') this.onDispose,
    @Deprecated('Since 2.4.1') this.appDesignSize,
  }) : super(key: key);

  /// You can create a project and obtain an appID from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final int appID;

  /// You can create a project and obtain an appSign from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final String appSign;

  /// The ID of the currently logged-in user.
  /// It can be any valid string.
  /// Typically, you would use the ID from your own user system, such as Firebase.
  final String userID;

  /// The name of the currently logged-in user.
  /// It can be any valid string.
  /// Typically, you would use the name from your own user system, such as Firebase.
  final String userName;

  /// You can customize the live ID arbitrarily,
  /// just need to know: users who use the same live ID can talk with each other.
  final String liveID;

  /// Initialize the configuration for the live-streaming.
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  /// You can invoke the methods provided by [ZegoUIKitPrebuiltLiveStreamingPage] through the [controller].
  final ZegoUIKitPrebuiltLiveStreamingController? controller;

  /// You can listen to events that you are interested in here.
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;

  /// Callback when the page is destroyed.
  @Deprecated('Since 2.15.0')
  final VoidCallback? onDispose;

  /// @nodoc
  @Deprecated('Since 2.4.1')
  final Size? appDesignSize;

  /// @nodoc
  @override
  State<ZegoUIKitPrebuiltLiveStreamingPage> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingState();
}

/// @nodoc
class _ZegoUIKitPrebuiltLiveStreamingState
    extends State<ZegoUIKitPrebuiltLiveStreamingPage>
    with WidgetsBindingObserver {
  List<StreamSubscription<dynamic>?> subscriptions = [];
  final popUpManager = ZegoPopUpManager();

  var readyNotifier = ValueNotifier<bool>(false);
  var startedByLocalNotifier = ValueNotifier<bool>(false);

  bool isFromMinimizing = false;
  late ZegoUIKitPrebuiltLiveStreamingData prebuiltData;

  ZegoUIKitPrebuiltLiveStreamingController get controller =>
      widget.controller ?? ZegoUIKitPrebuiltLiveStreamingController();

  ZegoUIKitPrebuiltLiveStreamingEvents get events =>
      widget.events ?? ZegoUIKitPrebuiltLiveStreamingEvents();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);

    ZegoLoggerService.logInfo(
      'initState',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );

    ZegoUIKit().getZegoUIKitVersion().then((version) {
      log('version: zego_uikit_prebuilt_live_streaming: 2.21.2; $version');
    });

    isFromMinimizing = PrebuiltLiveStreamingMiniOverlayPageState.idle !=
        ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().state();

    prebuiltData = ZegoUIKitPrebuiltLiveStreamingData(
      appID: widget.appID,
      appSign: widget.appSign,
      liveID: widget.liveID,
      userID: widget.userID,
      userName: widget.userName,
      config: widget.config,
      onDispose: widget.onDispose,
      controller: controller,
      events: events,
      isPrebuiltFromMinimizing: isFromMinimizing,
    );

    if (!isFromMinimizing) {
      ZegoLiveStreamingManagers().initPluginAndManagers(
        popUpManager,
        prebuiltData,
        startedByLocalNotifier,
        () {
          return context;
        },
      );
    } else {
      ZegoLiveStreamingManagers().updateContextQuery(() {
        return context;
      });
    }

    ZegoLiveStreamingManagers().plugins?.init();

    subscriptions.add(
        ZegoUIKit().getMeRemovedFromRoomStream().listen(onMeRemovedFromRoom));

    controller.initByPrebuilt(events: widget.events);

    initToast();

    startedByLocalNotifier.addListener(onStartedByLocalValueChanged);

    ZegoLoggerService.logInfo(
      'mini machine state is ${ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().state()}',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );
    if (isFromMinimizing) {
      ZegoLoggerService.logInfo(
        'mini machine state is not idle, context will not be init',
        tag: 'live streaming',
        subTag: 'prebuilt',
      );

      startedByLocalNotifier.value = true;
    } else {
      initContext();
    }

    ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().changeState(
      PrebuiltLiveStreamingMiniOverlayPageState.idle,
    );
  }

  @override
  void dispose() {
    super.dispose();

    startedByLocalNotifier.removeListener(onStartedByLocalValueChanged);
    WidgetsBinding.instance?.removeObserver(this);

    if (PrebuiltLiveStreamingMiniOverlayPageState.minimizing !=
        ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().state()) {
      ZegoLiveStreamingManagers().uninitPluginAndManagers().then((value) {
        uninitContext();
      });

      controller.uninitByPrebuilt();
    } else {
      ZegoLoggerService.logInfo(
        'mini machine state is minimizing, room will not be leave',
        tag: 'live streaming',
        subTag: 'prebuilt',
      );
    }

    widget.config.onLiveStreamingStateUpdate?.call(ZegoLiveStreamingState.idle);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    widget.onDispose?.call();

    ZegoLoggerService.logInfo(
      'dispose',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    ZegoLoggerService.logInfo(
      'didChangeAppLifecycleState $state',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );

    switch (state) {
      case AppLifecycleState.resumed:
        ZegoLiveStreamingManagers().plugins?.tryReLogin();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.config.onLeaveConfirmation ??= onLeaveConfirmation;

    return ZegoLiveStreamingManagers().hostManager!.isLocalHost
        ? ValueListenableBuilder<ZegoUIKitUser?>(
            valueListenable: ZegoLiveStreamingManagers().hostManager!.notifier,
            builder: (context, host, _) {
              /// local is host, but host updated
              if (ZegoLiveStreamingManagers().hostManager!.isLocalHost) {
                return ValueListenableBuilder<bool>(
                    valueListenable: startedByLocalNotifier,
                    builder: (context, isLiveStarted, _) {
                      return isLiveStarted ? livePage() : previewPage();
                    });
              } else {
                return livePage();
              }
            })
        : livePage();
  }

  Future<void> initPermissions() async {
    var isCameraGranted = true;
    var isMicrophoneGranted = true;
    if (widget.config.turnOnCameraWhenJoining) {
      isCameraGranted = await requestPermission(Permission.camera);
    }
    if (widget.config.turnOnMicrophoneWhenJoining) {
      isMicrophoneGranted = await requestPermission(Permission.microphone);
    }

    if (!isCameraGranted) {
      await showAppSettingsDialog(
        context: context,
        rootNavigator: widget.config.rootNavigator,
        popUpManager: popUpManager,
        dialogInfo: widget.config.innerText.cameraPermissionSettingDialogInfo,
        kickOutNotifier: ZegoLiveStreamingManagers().kickOutNotifier,
      );
    }
    if (!isMicrophoneGranted) {
      await showAppSettingsDialog(
        context: context,
        rootNavigator: widget.config.rootNavigator,
        popUpManager: popUpManager,
        dialogInfo:
            widget.config.innerText.microphonePermissionSettingDialogInfo,
        kickOutNotifier: ZegoLiveStreamingManagers().kickOutNotifier,
      );
    }
  }

  void initContext() {
    assert(widget.userID.isNotEmpty);
    assert(widget.userName.isNotEmpty);
    assert(widget.appID > 0);
    assert(widget.appSign.isNotEmpty);

    initPermissions().then((value) async {
      ZegoUIKit().login(widget.userID, widget.userName);

      await ZegoUIKit().setAdvanceConfigs(widget.config.advanceConfigs);

      ZegoUIKit()
          .init(
        appID: widget.appID,
        appSign: widget.appSign,
        scenario: ZegoScenario.Broadcast,
      )
          .then((_) async {
        await ZegoUIKit().setAdvanceConfigs(widget.config.advanceConfigs);

        onContextInit();
      });
    });
  }

  void onContextInit() {
    ZegoLoggerService.logInfo(
      'video config, preset:${widget.config.videoConfig.preset}, '
      'bitrate:${widget.config.videoConfig.bitrate}, '
      'fps: ${widget.config.videoConfig.fps}',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );
    final videoConfig =
        ZegoVideoConfig.preset(widget.config.videoConfig.preset);
    if (null != widget.config.videoConfig.bitrate) {
      videoConfig.bitrate = widget.config.videoConfig.bitrate!;
    }
    if (null != widget.config.videoConfig.fps) {
      videoConfig.fps = widget.config.videoConfig.fps!;
    }
    ZegoUIKit().setVideoConfig(videoConfig, ZegoStreamType.main);

    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoUIKit().enableCustomVideoProcessing(true);
    }

    final useBeautyEffect = widget.config.bottomMenuBarConfig.hostButtons
            .contains(ZegoMenuBarButtonName.beautyEffectButton) ||
        widget.config.bottomMenuBarConfig.coHostButtons
            .contains(ZegoMenuBarButtonName.beautyEffectButton);

    if (useBeautyEffect) {
      ZegoUIKit()
          .startEffectsEnv()
          .then((value) => ZegoUIKit().enableBeauty(true));
    }

    ZegoUIKit()
      ..useFrontFacingCamera(true)
      ..updateVideoViewMode(
          widget.config.audioVideoViewConfig.useVideoViewAspectFill)
      ..enableVideoMirroring(widget.config.audioVideoViewConfig.isVideoMirror)
      ..turnCameraOn(widget.config.turnOnCameraWhenJoining)
      ..turnMicrophoneOn(widget.config.turnOnMicrophoneWhenJoining)
      ..setAudioOutputToSpeaker(widget.config.useSpeakerWhenJoining);

    ZegoUIKit()
        .joinRoom(
      widget.liveID,
      markAsLargeRoom: widget.config.markAsLargeRoom,
    )
        .then((result) async {
      await onRoomLogin(result);
    });
  }

  Future<void> onRoomLogin(ZegoRoomLoginResult result) async {
    assert(result.errorCode == 0);

    if (result.errorCode != 0) {
      ZegoLoggerService.logError(
        'failed to login room:${result.errorCode},${result.extendedData}',
        tag: 'live streaming',
        subTag: 'prebuilt',
      );
    }

    await ZegoLiveStreamingManagers().hostManager!.init();
    await ZegoLiveStreamingManagers().liveStatusManager!.init();
    await ZegoLiveStreamingManagers().liveDurationManager!.init();

    readyNotifier.value = true;

    if (!widget.config.previewConfig.showPreviewForHost) {
      startedByLocalNotifier.value = true;
    }
  }

  Future<void> uninitContext() async {
    await ZegoUIKit().resetSoundEffect();
    await ZegoUIKit().resetBeautyEffect();

    await ZegoUIKit().leaveRoom();
  }

  void initToast() {
    ZegoToast.instance.init(contextQuery: () {
      return context;
    });
  }

  Future<bool> onLeaveConfirmation(BuildContext context) async {
    if (widget.config.confirmDialogInfo == null) {
      return true;
    }

    return showLiveDialog(
      context: context,
      rootNavigator: widget.config.rootNavigator,
      title: widget.config.confirmDialogInfo!.title,
      content: widget.config.confirmDialogInfo!.message,
      leftButtonText: widget.config.confirmDialogInfo!.cancelButtonName,
      leftButtonCallback: () {
        //  pop this dialog
        Navigator.of(
          context,
          rootNavigator: widget.config.rootNavigator,
        ).pop(false);
      },
      rightButtonText: widget.config.confirmDialogInfo!.confirmButtonName,
      rightButtonCallback: () {
        //  pop this dialog
        Navigator.of(
          context,
          rootNavigator: widget.config.rootNavigator,
        ).pop(true);
      },
    );
  }

  void onMeRemovedFromRoom(String fromUserID) {
    ZegoLoggerService.logInfo(
      'local user removed by $fromUserID',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );

    ZegoLiveStreamingManagers().kickOutNotifier.value = true;

    ///more button, member list, chat dialog
    popUpManager.autoPop(context, widget.config.rootNavigator);

    if (null != widget.config.onMeRemovedFromRoom) {
      widget.config.onMeRemovedFromRoom!.call(fromUserID);
    } else {
      //  pop this dialog
      Navigator.of(
        context,
        rootNavigator: widget.config.rootNavigator,
      ).pop(true);
    }
  }

  Widget previewPage() {
    return ZegoPreviewPage(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      liveID: widget.liveID,
      liveStreamingConfig: widget.config,
      startedNotifier: startedByLocalNotifier,
      hostManager: ZegoLiveStreamingManagers().hostManager!,
      liveStreamingPageReady: readyNotifier,
      config: widget.config,
      popUpManager: popUpManager,
      kickOutNotifier: ZegoLiveStreamingManagers().kickOutNotifier,
    );
  }

  Widget livePage() {
    return ZegoLivePage(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      liveID: widget.liveID,
      config: widget.config,
      hostManager: ZegoLiveStreamingManagers().hostManager!,
      liveStatusManager: ZegoLiveStreamingManagers().liveStatusManager!,
      liveDurationManager: ZegoLiveStreamingManagers().liveDurationManager!,
      popUpManager: popUpManager,
      plugins: ZegoLiveStreamingManagers().plugins,
      controller: controller,
      prebuiltData: prebuiltData,
    );
  }

  void onStartedByLocalValueChanged() {
    if (!isFromMinimizing) {
      ZegoLiveStreamingManagers().liveDurationManager!.setRoomPropertyByHost();
    }
  }
}
