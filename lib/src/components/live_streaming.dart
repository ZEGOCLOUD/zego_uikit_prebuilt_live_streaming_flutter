// Dart imports:
import 'dart:async';
import 'dart:core';
import 'dart:developer';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_page.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/preview_page.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/permissions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/overlay_machine.dart';

/// Live Streaming Widget.
///
/// You can embed this widget into any page of your project to integrate the functionality of a live streaming.
///
/// You can refer to our [documentation](https://docs.zegocloud.com/article/14846), [documentation with cohosting](https://docs.zegocloud.com/article/14882)
/// or our [sample code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_live_streaming_example_flutter).
class ZegoLiveStreamingPage extends StatefulWidget {
  const ZegoLiveStreamingPage({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    this.events,
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

  /// You can listen to events that you are interested in here.
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;

  /// @nodoc
  @override
  State<ZegoLiveStreamingPage> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingState();
}

/// @nodoc
class _ZegoUIKitPrebuiltLiveStreamingState extends State<ZegoLiveStreamingPage>
    with WidgetsBindingObserver {
  List<StreamSubscription<dynamic>?> subscriptions = [];
  ZegoLiveStreamingEventListener? _eventListener;

  final popUpManager = ZegoLiveStreamingPopUpManager();

  var readyNotifier = ValueNotifier<bool>(false);
  var startedByLocalNotifier = ValueNotifier<bool>(false);

  bool isFromMinimizing = false;

  ZegoUIKitPrebuiltLiveStreamingEvents get events =>
      widget.events ?? ZegoUIKitPrebuiltLiveStreamingEvents();

  ZegoUIKitPrebuiltLiveStreamingController get controller =>
      ZegoUIKitPrebuiltLiveStreamingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    ZegoLoggerService.logInfo(
      'initState',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );

    ZegoUIKit().getZegoUIKitVersion().then((version) {
      log('version: zego_uikit_prebuilt_live_streaming: 3.5.0; $version');
    });

    _eventListener = ZegoLiveStreamingEventListener(widget.events);
    _eventListener?.init();

    isFromMinimizing = ZegoLiveStreamingMiniOverlayPageState.idle !=
        ZegoLiveStreamingMiniOverlayMachine().state;

    if (!isFromMinimizing) {
      ZegoLiveStreamingManagers().initPluginAndManagers(
        widget.appID,
        widget.appSign,
        widget.userID,
        widget.userName,
        widget.liveID,
        widget.config,
        events,
        popUpManager,
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
    ZegoLiveStreamingToast.instance.init(contextQuery: () {
      return context;
    });

    ZegoLiveStreamingManagers().plugins?.init();

    subscriptions
      ..add(
          ZegoUIKit().getMeRemovedFromRoomStream().listen(onMeRemovedFromRoom))
      ..add(ZegoUIKit().getErrorStream().listen(onUIKitError));

    _initControllerByPrebuilt(
      minimizeData: ZegoLiveStreamingMinimizeData(
        appID: widget.appID,
        appSign: widget.appSign,
        liveID: widget.liveID,
        userID: widget.userID,
        userName: widget.userName,
        config: widget.config,
        events: events,
        isPrebuiltFromMinimizing: isFromMinimizing,
      ),
    );

    startedByLocalNotifier.addListener(onStartedByLocalValueChanged);

    ZegoLoggerService.logInfo(
      'mini machine state is ${ZegoLiveStreamingMiniOverlayMachine().state}',
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

    ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
  }

  @override
  void dispose() {
    super.dispose();

    _eventListener?.uninit();

    startedByLocalNotifier.removeListener(onStartedByLocalValueChanged);
    WidgetsBinding.instance.removeObserver(this);

    if (!ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
      ZegoLiveStreamingManagers().uninitPluginAndManagers().then((value) {
        uninitContext();
      });

      _uninitControllerByPrebuilt();
    } else {
      ZegoLoggerService.logInfo(
        'mini machine state is minimizing, room will not be leave',
        tag: 'live streaming',
        subTag: 'prebuilt',
      );
    }

    events.onStateUpdated?.call(ZegoLiveStreamingState.idle);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    ZegoLoggerService.logInfo(
      'dispose',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );
  }

  void _initControllerByPrebuilt({
    required ZegoLiveStreamingMinimizeData minimizeData,
  }) {
    controller.private.initByPrebuilt();
    controller.pk.private.initByPrebuilt();
    controller.room.private.initByPrebuilt();
    controller.message.private.initByPrebuilt();
    controller.coHost.private.initByPrebuilt(
      events: widget.events,
    );
    controller.swiping.private.initByPrebuilt(
      swipingConfig: widget.config.swiping,
    );
    controller.audioVideo.private.initByPrebuilt(
      config: widget.config,
    );
    controller.minimize.private.initByPrebuilt(
      minimizeData: minimizeData,
    );
  }

  void _uninitControllerByPrebuilt() {
    controller.private.uninitByPrebuilt();
    controller.pk.private.uninitByPrebuilt();
    controller.room.private.uninitByPrebuilt();
    controller.message.private.uninitByPrebuilt();
    controller.coHost.private.uninitByPrebuilt();
    controller.audioVideo.private.uninitByPrebuilt();
    controller.minimize.private.uninitByPrebuilt();
    controller.swiping.private.uninitByPrebuilt();
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
      // case AppLifecycleState.hidden:
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZegoLiveStreamingManagers().hostManager!.isLocalHost
        ? ValueListenableBuilder<ZegoUIKitUser?>(
            valueListenable: ZegoLiveStreamingManagers().hostManager!.notifier,
            builder: (context, host, _) {
              /// local is host, but host updated
              if (ZegoLiveStreamingManagers().hostManager!.isLocalHost) {
                return widget.config.preview.showPreviewForHost
                    ? ValueListenableBuilder<bool>(
                        valueListenable: startedByLocalNotifier,
                        builder: (context, isLiveStarted, _) {
                          return isLiveStarted ? livePage() : previewPage();
                        })
                    : livePage();
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
      if (context.mounted) {
        await showAppSettingsDialog(
          context: context,
          rootNavigator: widget.config.rootNavigator,
          popUpManager: popUpManager,
          dialogInfo: widget.config.innerText.cameraPermissionSettingDialogInfo,
          kickOutNotifier: ZegoLiveStreamingManagers().kickOutNotifier,
        );
      }
      if (!isMicrophoneGranted) {
        if (context.mounted) {
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
    }
  }

  void initContext() {
    assert(widget.userID.isNotEmpty);
    assert(widget.userName.isNotEmpty);
    assert(widget.appID > 0);
    assert(widget.appSign.isNotEmpty);

    initPermissions().then((value) async {
      ZegoUIKit().login(widget.userID, widget.userName);

      /// first set before create express
      await ZegoUIKit().setAdvanceConfigs(widget.config.advanceConfigs);

      var enablePlatformView = false;
      if (Platform.isIOS && widget.config.mediaPlayer.supportTransparent) {
        enablePlatformView = true;
      }
      ZegoUIKit()
          .init(
        appID: widget.appID,
        appSign: widget.appSign,
        scenario: ZegoScenario.Broadcast,
        enablePlatformView: enablePlatformView,
      )
          .then((_) async {
        /// second set after create express
        await ZegoUIKit().setAdvanceConfigs(widget.config.advanceConfigs);

        _setVideoConfig();
        _setBeautyConfig();

        ZegoUIKit()
          ..useFrontFacingCamera(true)
          ..updateVideoViewMode(
            widget.config.audioVideoView.useVideoViewAspectFill,
          )
          ..enableVideoMirroring(
            widget.config.audioVideoView.isVideoMirror,
          )
          ..turnCameraOn(widget.config.turnOnCameraWhenJoining)
          ..turnMicrophoneOn(widget.config.turnOnMicrophoneWhenJoining)
          ..setAudioOutputToSpeaker(widget.config.useSpeakerWhenJoining);
        if (widget.config.role == ZegoLiveStreamingRole.audience &&
            null != widget.config.audienceAudioVideoResourceMode) {
          ZegoUIKit().setAudioVideoResourceMode(
            widget.config.audienceAudioVideoResourceMode!,
          );
        }

        ZegoUIKit()
            .joinRoom(
          widget.liveID,
          markAsLargeRoom: widget.config.markAsLargeRoom,
        )
            .then((result) async {
          await onRoomLogin(result);
        });
      });
    });
  }

  Future<void> _setVideoConfig() async {
    ZegoLoggerService.logInfo(
      'video config:${widget.config.video}',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );

    await ZegoUIKit().enableTrafficControl(
      true,
      [
        ZegoUIKitTrafficControlProperty.adaptiveResolution,
        ZegoUIKitTrafficControlProperty.adaptiveFPS,
      ],
      minimizeVideoConfig: ZegoUIKitVideoConfig.preset360P(),
      isFocusOnRemote: false,
      streamType: ZegoStreamType.main,
    );

    await ZegoUIKit().setVideoConfig(
      widget.config.video,
    );
  }

  Future<void> _setBeautyConfig() async {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoUIKit().enableCustomVideoProcessing(true);
    }

    final useBeautyEffect = widget.config.bottomMenuBar.hostButtons
            .contains(ZegoLiveStreamingMenuBarButtonName.beautyEffectButton) ||
        widget.config.bottomMenuBar.coHostButtons
            .contains(ZegoLiveStreamingMenuBarButtonName.beautyEffectButton);
    if (useBeautyEffect) {
      await ZegoUIKit()
          .startEffectsEnv()
          .then((value) => ZegoUIKit().enableBeauty(true));
    }
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

    if (!widget.config.preview.showPreviewForHost) {
      startedByLocalNotifier.value = true;
    }

    notifyUserJoinByMessage();
  }

  Future<void> notifyUserJoinByMessage() async {
    if (!widget.config.inRoomMessage.notifyUserJoin) {
      return;
    }

    final messageAttributes = widget.config.inRoomMessage.attributes?.call();
    if (messageAttributes?.isEmpty ?? true) {
      await ZegoUIKit().sendInRoomMessage(widget.config.innerText.userEnter);
    } else {
      await ZegoUIKit().sendInRoomMessage(
        ZegoInRoomMessage.jsonBody(
          message: widget.config.innerText.userEnter,
          attributes: messageAttributes!,
        ),
      );
    }
  }

  Future<void> uninitContext() async {
    if (null != widget.config.audienceAudioVideoResourceMode) {
      ZegoUIKit().setAudioVideoResourceMode(
        ZegoAudioVideoResourceMode.defaultMode,
      );
    }

    await ZegoUIKit().resetSoundEffect();
    await ZegoUIKit().resetBeautyEffect();

    await ZegoUIKit().leaveRoom();
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

    final endEvent = ZegoLiveStreamingEndEvent(
      kickerUserID: fromUserID,
      reason: ZegoLiveStreamingEndReason.kickOut,
      isFromMinimizing: ZegoLiveStreamingMiniOverlayPageState.minimizing ==
          controller.minimize.state,
    );
    defaultAction() {
      defaultEndAction(endEvent);
    }

    if (null != events.onEnded) {
      events.onEnded!.call(endEvent, defaultAction);
    } else {
      defaultAction.call();
    }
  }

  Future<bool> defaultLeaveConfirmationAction(
    ZegoLiveStreamingLeaveConfirmationEvent event,
  ) async {
    if (widget.config.confirmDialogInfo == null) {
      return true;
    }

    return showLiveDialog(
      context: event.context,
      rootNavigator: widget.config.rootNavigator,
      title: widget.config.confirmDialogInfo!.title,
      content: widget.config.confirmDialogInfo!.message,
      leftButtonText: widget.config.confirmDialogInfo!.cancelButtonName,
      leftButtonCallback: () {
        try {
          //  pop this dialog
          Navigator.of(
            event.context,
            rootNavigator: widget.config.rootNavigator,
          ).pop(false);
        } catch (e) {
          ZegoLoggerService.logError(
            'leave confirmation left click, '
            'navigator exception:$e, '
            'event:$event',
            tag: 'live streaming',
            subTag: 'prebuilt',
          );
        }
      },
      rightButtonText: widget.config.confirmDialogInfo!.confirmButtonName,
      rightButtonCallback: () {
        try {
          //  pop this dialog
          Navigator.of(
            event.context,
            rootNavigator: widget.config.rootNavigator,
          ).pop(true);
        } catch (e) {
          ZegoLoggerService.logError(
            'leave confirmation right click, '
            'navigator exception:$e, '
            'event:$event',
            tag: 'live streaming',
            subTag: 'prebuilt',
          );
        }
      },
    );
  }

  void defaultEndAction(
    ZegoLiveStreamingEndEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'default end event, event:$event',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );

    switch (event.reason) {
      case ZegoLiveStreamingEndReason.hostEnd:
        break;
      case ZegoLiveStreamingEndReason.localLeave:
      case ZegoLiveStreamingEndReason.kickOut:
        if (event.isFromMinimizing) {
          /// now is minimizing state, not need to navigate, just switch to idle
          controller.minimize.hide();
        } else {
          try {
            Navigator.of(
              context,
              rootNavigator: widget.config.rootNavigator,
            ).pop(true);
          } catch (e) {
            ZegoLoggerService.logError(
              'live end, navigator exception:$e, event:$event',
              tag: 'live streaming',
              subTag: 'prebuilt',
            );
          }
        }
        break;
    }
  }

  void onUIKitError(ZegoUIKitError error) {
    ZegoLoggerService.logError(
      'on uikit error:$error',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );

    events.onError?.call(error);
  }

  Widget previewPage() {
    return ZegoLiveStreamingPreviewPage(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      liveID: widget.liveID,
      startedNotifier: startedByLocalNotifier,
      hostManager: ZegoLiveStreamingManagers().hostManager!,
      liveStreamingPageReady: readyNotifier,
      config: widget.config,
      popUpManager: popUpManager,
      kickOutNotifier: ZegoLiveStreamingManagers().kickOutNotifier,
    );
  }

  Widget livePage() {
    return ZegoLiveStreamingLivePage(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      liveID: widget.liveID,
      config: widget.config,
      events: events,
      defaultEndAction: defaultEndAction,
      defaultLeaveConfirmationAction: defaultLeaveConfirmationAction,
      hostManager: ZegoLiveStreamingManagers().hostManager!,
      liveStatusManager: ZegoLiveStreamingManagers().liveStatusManager!,
      liveDurationManager: ZegoLiveStreamingManagers().liveDurationManager!,
      popUpManager: popUpManager,
      plugins: ZegoLiveStreamingManagers().plugins,
    );
  }

  void onStartedByLocalValueChanged() {
    if (!isFromMinimizing) {
      ZegoLiveStreamingManagers().liveDurationManager!.setRoomPropertyByHost();
    }
  }
}
