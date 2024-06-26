// Dart imports:
import 'dart:async';
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/central_audio_video_view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_page_surface.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/service/services.dart';

/// @nodoc
/// user and sdk should be login and init before page enter
class ZegoLiveStreamingLivePage extends StatefulWidget {
  const ZegoLiveStreamingLivePage({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    required this.events,
    required this.defaultEndAction,
    required this.defaultLeaveConfirmationAction,
    required this.hostManager,
    required this.liveStatusManager,
    required this.liveDurationManager,
    required this.popUpManager,
    this.plugins,
  }) : super(key: key);

  final int appID;
  final String appSign;

  final String userID;
  final String userName;

  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoUIKitPrebuiltLiveStreamingEvents events;
  final void Function(ZegoLiveStreamingEndEvent event) defaultEndAction;
  final Future<bool> Function(
    ZegoLiveStreamingLeaveConfirmationEvent event,
  ) defaultLeaveConfirmationAction;

  final ZegoLiveStreamingHostManager hostManager;
  final ZegoLiveStreamingStatusManager liveStatusManager;
  final ZegoLiveStreamingDurationManager liveDurationManager;
  final ZegoLiveStreamingPopUpManager popUpManager;
  final ZegoLiveStreamingPlugins? plugins;

  @override
  State<ZegoLiveStreamingLivePage> createState() =>
      _ZegoLiveStreamingLivePageState();
}

class _ZegoLiveStreamingLivePageState extends State<ZegoLiveStreamingLivePage>
    with SingleTickerProviderStateMixin {
  List<StreamSubscription<dynamic>?> subscriptions = [];

  bool get isLiving =>
      LiveStatus.living == widget.liveStatusManager.notifier.value;

  @override
  void initState() {
    super.initState();

    widget.hostManager.notifier.addListener(onHostManagerUpdated);
    widget.liveStatusManager.notifier.addListener(onLiveStatusUpdated);

    subscriptions
      ..add(ZegoUIKit()
          .getTurnOnYourCameraRequestStream()
          .listen(onTurnOnYourCameraRequest))
      ..add(ZegoUIKit()
          .getTurnOnYourMicrophoneRequestStream()
          .listen(onTurnOnYourMicrophoneRequest))
      ..add(ZegoUIKit()
          .getInRoomLocalMessageStream()
          .listen(onInRoomLocalMessageFinished));

    ZegoLiveStreamingManagers().updateContextQuery(() => context);
    ZegoLiveStreamingManagers()
        .muteCoHostAudioVideo(ZegoUIKit().getAudioVideoList());

    if (widget.hostManager.isLocalHost) {
      ZegoUIKit().setRoomProperty(
          RoomPropertyKey.liveStatus.text, LiveStatus.living.index.toString());
    }
    correctConfigValue();

    checkFromMinimizing();
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    widget.liveStatusManager.notifier.removeListener(onLiveStatusUpdated);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    ZegoLiveStreamingManagers().updateContextQuery(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: () async {
          final endConfirmationEvent = ZegoLiveStreamingLeaveConfirmationEvent(
            context: context,
          );
          defaultAction() async {
            return widget.defaultLeaveConfirmationAction(endConfirmationEvent);
          }

          final canLeave = await widget.events.onLeaveConfirmation!(
            endConfirmationEvent,
            defaultAction,
          );
          if (canLeave) {
            if (widget.hostManager.isLocalHost) {
              /// live is ready to end, host will update if receive property notify
              /// so need to keep current host value, DISABLE local host value UPDATE
              widget.hostManager.hostUpdateEnabledNotifier.value = false;
              ZegoUIKit().updateRoomProperties({
                RoomPropertyKey.host.text: '',
                RoomPropertyKey.liveStatus.text:
                    LiveStatus.ended.index.toString()
              });
            }
          }
          return canLeave;
        },
        child: ZegoScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return clickListener(
              child: LayoutBuilder(builder: (context, constraints) {
                return ValueListenableBuilder<ZegoUIKitUser?>(
                    valueListenable: widget.hostManager.notifier,
                    builder: (context, host, _) {
                      return Stack(
                        children: [
                          ...background(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          ZegoLiveStreamingCentralAudioVideoView(
                            config: widget.config,
                            hostManager: widget.hostManager,
                            liveStatusManager: widget.liveStatusManager,
                            popUpManager: widget.popUpManager,
                            plugins: widget.plugins,
                            constraints: constraints,
                          ),
                          ZegoLiveStreamingLivePageSurface(
                            config: widget.config,
                            events: widget.events,
                            defaultEndAction: widget.defaultEndAction,
                            defaultLeaveConfirmationAction:
                                widget.defaultLeaveConfirmationAction,
                            hostManager: widget.hostManager,
                            liveStatusManager: widget.liveStatusManager,
                            liveDurationManager: widget.liveDurationManager,
                            popUpManager: widget.popUpManager,
                            connectManager:
                                ZegoLiveStreamingManagers().connectManager!,
                            plugins: widget.plugins,
                          ),
                        ],
                      );
                    });
              }),
            );
          },
        ),
      ),
    );
  }

  void checkFromMinimizing() {
    if (!(ZegoUIKitPrebuiltLiveStreamingController()
            .minimize
            .private
            .minimizeData
            ?.isPrebuiltFromMinimizing ??
        false)) {
      return;
    }

    /// update callback
    widget.liveStatusManager.onLiveStatusUpdated();

    if (null !=
        ZegoLiveStreamingManagers()
            .connectManager!
            .dataOfInvitedToJoinCoHostInMinimizing) {
      final dataOfInvitedToJoinCoHostInMinimizing = ZegoLiveStreamingManagers()
          .connectManager!
          .dataOfInvitedToJoinCoHostInMinimizing!;

      ZegoLoggerService.logInfo(
        'exist a invite to join co-host when minimizing($dataOfInvitedToJoinCoHostInMinimizing), show now',
        tag: 'live-streaming',
        subTag: 'live page',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ZegoLiveStreamingManagers()
            .connectManager!
            .onAudienceReceivedCoHostInvitation(
              dataOfInvitedToJoinCoHostInMinimizing.host,
              dataOfInvitedToJoinCoHostInMinimizing.customData,
            );
      });
    }

    if (null !=
        ZegoUIKitPrebuiltLiveStreamingPK()
            .pkBattleRequestReceivedEventInMinimizingNotifier
            .value) {
      ZegoLoggerService.logInfo(
        'exist a pk battle request when minimizing, show now',
        tag: 'live-streaming',
        subTag: 'live page',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ZegoUIKitPrebuiltLiveStreamingPK()
            .restorePKBattleRequestReceivedEventFromMinimizing();
      });
    }
  }

  void correctConfigValue() {
    /// will max than 5 if custom
    // if (widget.config.bottomMenuBarConfig.maxCount > 5) {
    //   widget.config.bottomMenuBarConfig.maxCount = 5;
    //   ZegoLoggerService.logInfo(
    //     "menu bar buttons limited count's value  is exceeding the maximum limit",
    //     tag: 'live-streaming',
    //     subTag: 'live page',
    //   );
    // }
  }

  Widget clickListener({required Widget child}) {
    return GestureDetector(
      onTap: () {
        /// listen only click event in empty space
      },
      child: Listener(
        ///  listen for all click events in current view, include the click
        ///  receivers(such as button...), but only listen
        child: AbsorbPointer(
          absorbing: false,
          child: child,
        ),
      ),
    );
  }

  Widget backgroundTips() {
    return ValueListenableBuilder(
      valueListenable: widget.liveStatusManager.notifier,
      builder: (BuildContext context, LiveStatus liveStatus, Widget? child) {
        return LiveStatus.living == liveStatus
            ? Container()
            : Center(
                child: Text(
                  widget.config.innerText.noHostOnline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.zR,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              );
      },
    );
  }

  List<Widget> background(double width, double height) {
    if (widget.config.background != null) {
      /// full screen
      return [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: widget.config.background!,
        )
      ];
    }

    return [
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: width,
          height: height,
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
      if (widget.config.showBackgroundTips) backgroundTips(),
    ];
  }

  void onHostManagerUpdated() {
    ZegoLoggerService.logInfo(
      'live page, host mgr updated, ${widget.hostManager.notifier.value}',
      tag: 'live-streaming',
      subTag: 'live page',
    );
  }

  void onLiveStatusUpdated() {
    ZegoLoggerService.logInfo(
      'live page, live status mgr updated, ${widget.liveStatusManager.notifier.value}',
      tag: 'live-streaming',
      subTag: 'live page',
    );

    if (!widget.hostManager.isLocalHost) {
      ZegoLoggerService.logInfo(
        'audience, live streaming end by host, '
        'host: ${widget.hostManager.notifier.value}, '
        'live status: ${widget.liveStatusManager.notifier.value}',
        tag: 'live-streaming',
        subTag: 'live page',
      );

      if (LiveStatus.ended == widget.liveStatusManager.notifier.value) {
        final endEvent = ZegoLiveStreamingEndEvent(
          reason: ZegoLiveStreamingEndReason.hostEnd,
          isFromMinimizing: ZegoLiveStreamingMiniOverlayPageState.minimizing ==
              ZegoUIKitPrebuiltLiveStreamingController().minimize.state,
        );
        defaultAction() {
          widget.defaultEndAction(endEvent);
        }

        if (widget.events.onEnded != null) {
          widget.events.onEnded!.call(endEvent, defaultAction);
        } else {
          defaultAction.call();
        }
      }
    }
  }

  Future<void> onTurnOnYourCameraRequest(String fromUserID) async {
    ZegoLoggerService.logInfo(
      'onTurnOnYourCameraRequest, fromUserID:$fromUserID',
      tag: 'live-streaming',
      subTag: 'live page',
    );

    if (ZegoUIKit().getLocalUser().microphone.value) {
      ZegoLoggerService.logInfo(
        'camera is open now, not need request',
        tag: 'live-streaming',
        subTag: 'live page',
      );

      return;
    }

    final canCameraTurnOnByOthers = await widget
            .events.audioVideo.onCameraTurnOnByOthersConfirmation
            ?.call(context) ??
        false;
    ZegoLoggerService.logInfo(
      'canMicrophoneTurnOnByOthers:$canCameraTurnOnByOthers',
      tag: 'live-streaming',
      subTag: 'live page',
    );
    if (canCameraTurnOnByOthers) {
      ZegoUIKit().turnCameraOn(true);
    }
  }

  Future<void> onTurnOnYourMicrophoneRequest(
      ZegoUIKitReceiveTurnOnLocalMicrophoneEvent event) async {
    ZegoLoggerService.logInfo(
      'onTurnOnYourMicrophoneRequest, event:$event',
      tag: 'live-streaming',
      subTag: 'live page',
    );

    if (ZegoUIKit().getLocalUser().microphone.value) {
      ZegoLoggerService.logInfo(
        'microphone is open now, not need request',
        tag: 'live-streaming',
        subTag: 'live page',
      );

      return;
    }

    final canMicrophoneTurnOnByOthers = await widget
            .events.audioVideo.onMicrophoneTurnOnByOthersConfirmation
            ?.call(context) ??
        false;
    ZegoLoggerService.logInfo(
      'canMicrophoneTurnOnByOthers:$canMicrophoneTurnOnByOthers',
      tag: 'live-streaming',
      subTag: 'live page',
    );
    if (canMicrophoneTurnOnByOthers) {
      ZegoUIKit().turnMicrophoneOn(
        true,
        muteMode: event.muteMode,
      );
    }
  }

  void onInRoomLocalMessageFinished(ZegoInRoomMessage message) {
    widget.events.inRoomMessage.onLocalSend?.call(message);
  }
}
