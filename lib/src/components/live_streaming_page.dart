// Dart imports:
import 'dart:async';
import 'dart:core';
import 'dart:io' show Platform;
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:floating/floating.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller/private/pip/pip_android.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimization/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimization/overlay_machine.dart';
import 'live_page.dart';
import 'mini_live.dart';
import 'preview_page.dart';
import 'utils/dialogs.dart';
import 'utils/pop_up_manager.dart';
import 'utils/toast.dart';

/// Live Streaming Widget.
///
/// You can embed this widget into any page of your project to integrate the functionality of a live streaming.
///
/// You can refer to our [documentation](https://docs.zegocloud.com/article/14846), [documentation with cohosting](https://docs.zegocloud.com/article/14882)
/// or our [sample code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_live_streaming_example_flutter).
class ZegoLiveStreamingPage extends StatefulWidget {
  const ZegoLiveStreamingPage({
    super.key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    required this.popUpManager,
    required this.isPrebuiltFromMinimizing,
    required this.isPrebuiltFromHall,
    required this.onRoomLoginFailed,
    this.token = '',
    this.events,
  });

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

  final ZegoLiveStreamingPopUpManager popUpManager;

  final bool isPrebuiltFromMinimizing;

  final bool isPrebuiltFromHall;
  final ZegoLiveStreamingLoginFailedEvent? onRoomLoginFailed;

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

  bool isFromMinimizing = false;
  BuildContext? _savedContext;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    ZegoLoggerService.logInfo(
      'initState',
      tag: 'live.streaming.page',
      subTag: 'prebuilt',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _savedContext = context;
      ZegoLiveStreamingPageLifeCycle().updateContextQuery(() {
        return context;
      });
    });

    ZegoLiveStreamingToast.instance.init(
      enabled: widget.config.showToast,
      contextQuery: () {
        return context;
      },
    );

    _eventListener = ZegoLiveStreamingEventListener(
      liveID: widget.liveID,
      widget.events,
    );
    _eventListener?.init();

    isFromMinimizing = ZegoLiveStreamingMiniOverlayPageState.idle !=
        ZegoLiveStreamingMiniOverlayMachine().state;

    subscriptions
      ..add(ZegoUIKit()
          .getMeRemovedFromRoomStream(targetRoomID: widget.liveID)
          .listen(onMeRemovedFromRoom))
      ..add(ZegoUIKit().getErrorStream().listen(onUIKitError));

    ZegoLoggerService.logInfo(
      'mini machine state is ${ZegoLiveStreamingMiniOverlayMachine().state}',
      tag: 'live.streaming.page',
      subTag: 'prebuilt',
    );

    ZegoLiveStreamingPageLifeCycle().initFromLive(
      isPrebuiltFromMinimizing: widget.isPrebuiltFromMinimizing,
      isPrebuiltFromHall: widget.isPrebuiltFromHall,
      onRoomLoginFailed: widget.onRoomLoginFailed,
    );
  }

  @override
  void dispose() {
    super.dispose();

    ZegoLoggerService.logInfo(
      'dispose',
      tag: 'live.streaming.page',
      subTag: 'prebuilt',
    );

    _eventListener?.uninit();

    WidgetsBinding.instance.removeObserver(this);

    if (ZegoLiveStreamingPageLifeCycle().swiping.usingRoomSwiping) {
      /// In swiping case, use page builder's events as basis for room entry/exit
    } else {
      ZegoLiveStreamingPageLifeCycle().disposeFromLive(
        targetLiveID: widget.liveID,
      );
    }

    widget.events?.onStateUpdated?.call(ZegoLiveStreamingState.idle);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    ZegoLiveStreamingPageLifeCycle()
        .updateContextQuery(null, contextToRemove: _savedContext);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    ZegoLoggerService.logInfo(
      'didChangeAppLifecycleState $state',
      tag: 'live.streaming.page',
      subTag: 'prebuilt',
    );

    switch (state) {
      case AppLifecycleState.resumed:
        ZegoLiveStreamingPageLifeCycle().currentManagers.plugins.tryReLogin();
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
    return Stack(
      children: [
        page(),
        ValueListenableBuilder<bool>(
          valueListenable:
              ZegoLiveStreamingPageLifeCycle().rtcContextReadyNotifier,
          builder: (context, isReady, _) {
            if (!isReady) {
              return const Center(child: CircularProgressIndicator());
            }

            return Container();
          },
        ),
      ],
    );
  }

  Widget page() {
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

  Widget normalPage() {
    return (ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .hostManager
            .isLocalHost)
        ? ValueListenableBuilder<ZegoUIKitUser?>(
            valueListenable: ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .hostManager
                .notifier,
            builder: (context, host, _) {
              /// local is host, but host updated
              if (ZegoLiveStreamingPageLifeCycle()
                  .currentManagers
                  .hostManager
                  .isLocalHost) {
                return widget.config.preview.showPreviewForHost
                    ? ValueListenableBuilder<bool>(
                        valueListenable: ZegoLiveStreamingPageLifeCycle()
                            .previewPageVisibilityNotifier,
                        builder: (context, showPreview, _) {
                          return showPreview ? previewPage() : livePage();
                        },
                      )
                    : livePage();
              } else {
                return livePage();
              }
            },
          )
        : livePage();
  }

  Widget pipPage() {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height / 3.0;
    final width = 16 / 9 * height;
    return Scaffold(
      body: ZegoMinimizingStreamingPage(
        liveID: widget.liveID,
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
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 5.0), // Set blur level
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

  void onMeRemovedFromRoom(String fromUserID) {
    ZegoLoggerService.logInfo(
      'local user removed by $fromUserID',
      tag: 'live.streaming.page',
      subTag: 'prebuilt, removed users',
    );

    ZegoLiveStreamingPageLifeCycle().currentManagers.kickOutNotifier.value =
        true;

    ///more button, member list, chat dialog
    widget.popUpManager.autoPop(context, widget.config.rootNavigator);

    final endEvent = ZegoLiveStreamingEndEvent(
      kickerUserID: fromUserID,
      reason: ZegoLiveStreamingEndReason.kickOut,
      isFromMinimizing: ZegoLiveStreamingMiniOverlayPageState.minimizing ==
          ZegoUIKitPrebuiltLiveStreamingController().minimize.state,
    );
    defaultAction() {
      defaultEndAction(endEvent);
    }

    ZegoUIKitPrebuiltLiveStreamingController().pip.cancelBackground();

    if (null != widget.events?.onEnded) {
      widget.events?.onEnded!.call(endEvent, defaultAction);
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
            tag: 'live.streaming.page',
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
            tag: 'live.streaming.page',
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
      'default end event, '
      'event:$event, '
      'isPrebuiltFromHall:${widget.isPrebuiltFromHall}, '
      'hall onPagePushReplace:${null != widget.events?.hall.onPagePushReplace}, ',
      tag: 'live.streaming.page',
      subTag: 'prebuilt',
    );

    switch (event.reason) {
      case ZegoLiveStreamingEndReason.hostEnd:
        break;
      case ZegoLiveStreamingEndReason.localLeave:
      case ZegoLiveStreamingEndReason.kickOut:
        if (event.isFromMinimizing) {
          /// now is minimizing state, not need to navigate, just switch to idle
          ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
        } else {
          try {
            if (widget.isPrebuiltFromHall) {
              ZegoLiveStreamingPageLifeCycle()
                  .currentManagers
                  .connectManager
                  .removeRTCUsersDeviceListeners(
                    ZegoUIKit().getRemoteUsers(targetRoomID: widget.liveID),
                  );

              ZegoUIKit().stopPublishingAllStream(targetRoomID: widget.liveID);
              final hostStreamID = ZegoLiveStreamingPageLifeCycle()
                      .currentManagers
                      .hostManager
                      .notifier
                      .value
                      ?.streamID ??
                  '';
              ZegoUIKit().stopPlayingAllStream(
                targetRoomID: widget.liveID,
                ignoreStreamIDs: hostStreamID.isEmpty
                    ? []
                    : [
                        hostStreamID // host流不能停
                      ],
              );

              widget.events?.hall.onPagePushReplace?.call(
                context,
                widget.liveID,
                widget.config.swiping?.model,
                widget.config.swiping?.modelDelegate,
              );
              if (null == widget.events?.hall.onPagePushReplace) {
                ZegoLoggerService.logError(
                  'please assign value to ZegoUIKitPrebuiltLiveStreamingEvents.hall.onPagePushReplace',
                  tag: 'live.streaming.page',
                  subTag: 'prebuilt',
                );

                assert(false);
              }
            } else {
              Navigator.of(
                context,
                rootNavigator: widget.config.rootNavigator,
              ).pop(true);
            }
          } catch (e) {
            ZegoLoggerService.logError(
              'live end, navigator exception:$e, '
              'isPrebuiltFromHall:${widget.isPrebuiltFromHall}, '
              'event:$event',
              tag: 'live.streaming.page',
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
      tag: 'live.streaming.page',
      subTag: 'prebuilt',
    );

    widget.events?.onError?.call(error);
  }

  Widget previewPage() {
    return ZegoLiveStreamingPreviewPage(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      liveID: widget.liveID,
      config: widget.config,
      popUpManager: widget.popUpManager,
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
      events: widget.events,
      defaultEndAction: defaultEndAction,
      defaultLeaveConfirmationAction: defaultLeaveConfirmationAction,
      popUpManager: widget.popUpManager,
      isPrebuiltFromHall: widget.isPrebuiltFromHall,
      onRoomLoginFailed: widget.onRoomLoginFailed,
    );
  }
}
