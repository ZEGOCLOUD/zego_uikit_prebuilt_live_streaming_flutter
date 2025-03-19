// Dart imports:
import 'dart:async';
import 'dart:core';
import 'dart:io' show Platform;
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:floating/floating.dart';
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
import '../controller/private/pip/pip_android.dart';
import '../controller/private/pip/pip_ios.dart';
import '../internal/defines.dart';
import 'mini_live.dart';

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
    this.token = '',
    this.events,
  }) : super(key: key);

  /// You can create a project and obtain an appID from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final int appID;

  /// You can create a project and obtain an appSign from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final String appSign;

  /// The token issued by the developer's business server is used to ensure security.
  /// For the generation rules, please refer to [Using Token Authentication] (https://doc-zh.zego.im/article/10360), the default is an empty string, that is, no authentication.
  ///
  /// if appSign is not passed in or if appSign is empty, this parameter must be set for authentication when logging in to a room.
  final String token;

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
  var contextInitNotifier = ValueNotifier<bool>(false);
  List<StreamSubscription<dynamic>?> subscriptions = [];
  ZegoLiveStreamingEventListener? _eventListener;

  final popUpManager = ZegoLiveStreamingPopUpManager();

  var startedByLocalNotifier = ValueNotifier<bool>(false);

  bool isFromMinimizing = false;

  ZegoUIKitPrebuiltLiveStreamingEvents get events =>
      widget.events ?? ZegoUIKitPrebuiltLiveStreamingEvents();

  ZegoUIKitPrebuiltLiveStreamingController get controller =>
      ZegoUIKitPrebuiltLiveStreamingController();

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    ZegoLoggerService.logInfo(
      'initState',
      tag: 'live-streaming',
      subTag: 'prebuilt',
    );

    _eventListener = ZegoLiveStreamingEventListener(widget.events);
    _eventListener?.init();

    isFromMinimizing = ZegoLiveStreamingMiniOverlayPageState.idle !=
        ZegoLiveStreamingMiniOverlayMachine().state;

    if (!isFromMinimizing) {
      ZegoLiveStreamingManagers().initPluginAndManagers(
        widget.appID,
        widget.appSign,
        widget.token,
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

      ZegoLiveStreamingManagers().plugins?.init();
    } else {
      ZegoLiveStreamingManagers().updateContextQuery(() {
        return context;
      });
    }
    ZegoLiveStreamingToast.instance.init(
      enabled: widget.config.showToast,
      contextQuery: () {
        return context;
      },
    );

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

    ZegoLoggerService.logInfo(
      'mini machine state is ${ZegoLiveStreamingMiniOverlayMachine().state}',
      tag: 'live-streaming',
      subTag: 'prebuilt',
    );
    if (isFromMinimizing) {
      ZegoLoggerService.logInfo(
        'mini machine state is not idle, context will not be init',
        tag: 'live-streaming',
        subTag: 'prebuilt',
      );

      contextInitNotifier.value = true;
      startedByLocalNotifier.value = true;
    } else {
      initContext().then((_) {
        ZegoLoggerService.logInfo(
          'initContext done',
          tag: 'live-streaming',
          subTag: 'prebuilt',
        );
        contextInitNotifier.value = true;

        initPermissions().then((_) {
          if (mounted) {
            ZegoUIKit()
              ..turnCameraOn(widget.config.turnOnCameraWhenJoining)
              ..turnMicrophoneOn(widget.config.turnOnMicrophoneWhenJoining);
          }
        });
      }).catchError((e) {
        ZegoLoggerService.logError(
          'initContext exception:$e',
          tag: 'live-streaming',
          subTag: 'prebuilt',
        );
      });
    }

    ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
  }

  @override
  void dispose() {
    super.dispose();

    _eventListener?.uninit();

    WidgetsBinding.instance.removeObserver(this);

    if (!ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
      if (ZegoUIKit().getScreenSharingStateNotifier().value) {
        ZegoUIKit().stopSharingScreen();
      }

      ZegoLiveStreamingManagers().uninitPluginAndManagers().then((value) async {
        uninitContext();
      });

      _uninitControllerByPrebuilt();
    } else {
      ZegoLoggerService.logInfo(
        'mini machine state is minimizing, room will not be leave',
        tag: 'live-streaming',
        subTag: 'prebuilt',
      );
    }

    events.onStateUpdated?.call(ZegoLiveStreamingState.idle);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    ZegoLoggerService.logInfo(
      'dispose',
      tag: 'live-streaming',
      subTag: 'prebuilt',
    );
  }

  Future<void> uninitContext() async {
    if (null != widget.config.audienceAudioVideoResourceMode) {
      ZegoUIKit().setAudioVideoResourceMode(
        ZegoAudioVideoResourceMode.defaultMode,
      );
    }

    ZegoUIKit().turnCameraOn(false);
    ZegoUIKit().turnMicrophoneOn(false);

    await uninitBaseBeautyConfig();

    await ZegoUIKit().leaveRoom().then((_) {
      /// only effect call after leave room
      ZegoUIKit().enableCustomVideoProcessing(false);

      widget.config.outsideLives.controller?.private.private.init().then((_) {
        widget.config.outsideLives.controller?.private.private.forceUpdate();
      });
    });
  }

  Future<void> initContext() async {
    assert(widget.userID.isNotEmpty);
    assert(widget.userName.isNotEmpty);
    assert(widget.appID > 0);
    assert(widget.appSign.isNotEmpty || widget.token.isNotEmpty);

    ZegoUIKit().login(widget.userID, widget.userName);

    /// first set before create express
    await ZegoUIKit().setAdvanceConfigs(widget.config.advanceConfigs);

    var enablePlatformView = false;
    if (Platform.isIOS) {
      enablePlatformView = widget.config.mediaPlayer.supportTransparent ||
          playingStreamInPIPUnderIOS;
    }
    await ZegoUIKit()
        .init(
      appID: widget.appID,
      appSign: widget.appSign,
      token: widget.token,
      scenario: ZegoScenario.Broadcast,
      enablePlatformView: enablePlatformView,
      playingStreamInPIPUnderIOS: playingStreamInPIPUnderIOS,
    )
        .then((_) async {
      /// second set after create express
      await ZegoUIKit().setAdvanceConfigs(widget.config.advanceConfigs);

      await ZegoUIKit().enableCustomVideoRender(playingStreamInPIPUnderIOS);

      _setVideoConfig();
      initBaseBeautyConfig();

      ZegoUIKit()
        ..useFrontFacingCamera(widget.config.useFrontFacingCamera)
        ..updateVideoViewMode(
          widget.config.audioVideoView.useVideoViewAspectFill,
        )
        ..enableVideoMirroring(
          widget.config.audioVideoView.isVideoMirror,
        )
        ..setAudioOutputToSpeaker(widget.config.useSpeakerWhenJoining);
      if (widget.config.role == ZegoLiveStreamingRole.audience &&
          null != widget.config.audienceAudioVideoResourceMode) {
        ZegoUIKit().setAudioVideoResourceMode(
          widget.config.audienceAudioVideoResourceMode!,
        );
      }
    });
  }

  Future<void> _setVideoConfig() async {
    ZegoLoggerService.logInfo(
      'video config:${widget.config.video}',
      tag: 'live-streaming',
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

  Future<void> initBaseBeautyConfig() async {
    final useBeautyEffect = widget.config.bottomMenuBar.hostButtons
            .contains(ZegoLiveStreamingMenuBarButtonName.beautyEffectButton) ||
        widget.config.bottomMenuBar.coHostButtons
            .contains(ZegoLiveStreamingMenuBarButtonName.beautyEffectButton);
    final useAdvanceEffect =
        ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) != null;

    ZegoUIKit()
        .enableCustomVideoProcessing(useBeautyEffect || useAdvanceEffect);

    if (!useBeautyEffect || useAdvanceEffect) {
      return;
    }

    await ZegoUIKit()
        .startEffectsEnv()
        .then((value) => ZegoUIKit().enableBeauty(true));
  }

  Future<void> uninitBaseBeautyConfig() async {
    await ZegoUIKit().resetSoundEffect();
    await ZegoUIKit().resetBeautyEffect();
    await ZegoUIKit().stopEffectsEnv();
    await ZegoUIKit().enableBeauty(false);
  }

  void _initControllerByPrebuilt({
    required ZegoLiveStreamingMinimizeData minimizeData,
  }) {
    controller.private.initByPrebuilt();
    controller.pk.private.initByPrebuilt();
    controller.room.private.initByPrebuilt();
    controller.user.private.initByPrebuilt(
      config: widget.config,
    );
    controller.message.private.initByPrebuilt(
      config: widget.config,
    );
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
      config: widget.config,
    );
    controller.pip.private.initByPrebuilt(
      config: widget.config,
    );
    controller.screenSharing.private.initByPrebuilt(
      config: widget.config,
    );
  }

  void _uninitControllerByPrebuilt() {
    controller.private.uninitByPrebuilt();
    controller.pk.private.uninitByPrebuilt();
    controller.room.private.uninitByPrebuilt();
    controller.user.private.uninitByPrebuilt();
    controller.message.private.uninitByPrebuilt();
    controller.coHost.private.uninitByPrebuilt();
    controller.audioVideo.private.uninitByPrebuilt();
    controller.minimize.private.uninitByPrebuilt();
    controller.pip.private.uninitByPrebuilt();
    controller.screenSharing.private.uninitByPrebuilt();
    controller.swiping.private.uninitByPrebuilt();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    ZegoLoggerService.logInfo(
      'didChangeAppLifecycleState $state',
      tag: 'live-streaming',
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
    return ValueListenableBuilder<bool>(
      valueListenable: contextInitNotifier,
      builder: (context, isDone, _) {
        if (isDone) {
          if (Platform.isAndroid) {
            return PiPSwitcher(
              floating: (ZegoUIKitPrebuiltLiveStreamingController()
                      .pip
                      .private
                      .pipImpl() as ZegoLiveStreamingControllerPIPAndroid)
                  .floating,
              childWhenDisabled: normalPage(),
              childWhenEnabled: ZegoScreenUtilInit(
                designSize: const Size(750, 1334),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return pipPage();
                },
              ),
            );
          }

          return normalPage();
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget normalPage() {
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

  Widget pipPage() {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height / 3.0;
    final width = 16 / 9 * height;
    return Scaffold(
      body: ZegoMinimizingStreamingPage(
        size: Size(width, height),
        withCircleBorder: false,
        config: widget.config,
        backgroundBuilder: widget.config.audioVideoView.backgroundBuilder,
        foregroundBuilder: widget.config.audioVideoView.foregroundBuilder,
        avatarBuilder: widget.config.avatarBuilder,
        showMicrophoneButton: false,
        showLeaveButton: false,
        durationConfig: widget.config.duration,
        durationEvents: widget.events?.duration,
        background: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 5.0), // 设定模糊程度
          child: widget.config.pip.android.background ??
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ZegoLiveStreamingImage.assetImage(
                      ZegoLiveStreamingIconUrls.background,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Future<void> initPermissions() async {
    ZegoLoggerService.logInfo(
      'request camera:${widget.config.turnOnCameraWhenJoining}, '
      'request microphone:${widget.config.turnOnMicrophoneWhenJoining}, ',
      tag: 'live-streaming',
      subTag: 'prebuilt, initPermissions',
    );

    var isCameraGranted = true;
    var isMicrophoneGranted = true;
    if (mounted && widget.config.turnOnCameraWhenJoining) {
      isCameraGranted = await requestPermission(Permission.camera);
    }
    if (mounted && widget.config.turnOnMicrophoneWhenJoining) {
      isMicrophoneGranted = await requestPermission(Permission.microphone);
    }

    ZegoLoggerService.logInfo(
      'camera result:$isCameraGranted, '
      'microphone result:$isMicrophoneGranted, ',
      tag: 'live-streaming',
      subTag: 'prebuilt, initPermissions',
    );

    if (!isCameraGranted) {
      if (mounted) {
        await showAppSettingsDialog(
          context: context,
          rootNavigator: widget.config.rootNavigator,
          popUpManager: popUpManager,
          dialogInfo: widget.config.innerText.cameraPermissionSettingDialogInfo,
          kickOutNotifier: ZegoLiveStreamingManagers().kickOutNotifier,
        );
      }
      if (!isMicrophoneGranted) {
        if (mounted) {
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

  void onMeRemovedFromRoom(String fromUserID) {
    ZegoLoggerService.logInfo(
      'local user removed by $fromUserID',
      tag: 'live-streaming',
      subTag: 'prebuilt, removed users',
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

    ZegoUIKitPrebuiltLiveStreamingController().pip.cancelBackground();

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
            tag: 'live-streaming',
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
            tag: 'live-streaming',
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
      tag: 'live-streaming',
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
              tag: 'live-streaming',
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
      tag: 'live-streaming',
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
      config: widget.config,
      popUpManager: popUpManager,
      kickOutNotifier: ZegoLiveStreamingManagers().kickOutNotifier,
    );
  }

  Widget livePage() {
    return ZegoLiveStreamingLivePage(
      appID: widget.appID,
      appSign: widget.appSign,
      token: widget.token,
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
}
