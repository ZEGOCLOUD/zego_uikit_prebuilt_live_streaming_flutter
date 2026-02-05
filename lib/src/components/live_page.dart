// Dart imports:
import 'dart:async';
import 'dart:core';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimization/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimization/overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/service/services.dart';
import 'central_audio_video_view.dart';
import 'live_page_surface.dart';
import 'utils/pop_up_manager.dart';

/// @nodoc
/// user and sdk should be login and init before page enter
class ZegoLiveStreamingLivePage extends StatefulWidget {
  const ZegoLiveStreamingLivePage({
    super.key,
    required this.appID,
    required this.appSign,
    required this.token,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    required this.events,
    required this.defaultEndAction,
    required this.defaultLeaveConfirmationAction,
    required this.onRoomLoginFailed,
    required this.popUpManager,
    required this.isPrebuiltFromHall,
  });

  final int appID;
  final String appSign;
  final String token;

  final String userID;
  final String userName;

  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;
  final void Function(ZegoLiveStreamingEndEvent event) defaultEndAction;
  final Future<bool> Function(
    ZegoLiveStreamingLeaveConfirmationEvent event,
  ) defaultLeaveConfirmationAction;
  final ZegoLiveStreamingLoginFailedEvent? onRoomLoginFailed;

  final ZegoLiveStreamingPopUpManager popUpManager;
  final bool isPrebuiltFromHall;

  @override
  State<ZegoLiveStreamingLivePage> createState() =>
      _ZegoLiveStreamingLivePageState();
}

class _ZegoLiveStreamingLivePageState extends State<ZegoLiveStreamingLivePage>
    with SingleTickerProviderStateMixin {
  List<StreamSubscription<dynamic>?> subscriptions = [];
  bool isFromMinimizing = false;
  BuildContext? _savedContext;

  bool get isLiving =>
      LiveStatus.living ==
      ZegoLiveStreamingPageLifeCycle()
          .manager(widget.liveID)
          .liveStatusManager
          .notifier
          .value;

  @override
  void initState() {
    super.initState();

    isFromMinimizing = ZegoLiveStreamingMiniOverlayPageState.idle !=
        ZegoLiveStreamingMiniOverlayMachine().state;

    /// todo move
    ZegoLiveStreamingPageLifeCycle()
        .manager(widget.liveID)
        .hostManager
        .notifier
        .addListener(onHostManagerUpdated);
    ZegoLiveStreamingPageLifeCycle()
        .manager(widget.liveID)
        .liveStatusManager
        .notifier
        .addListener(onLiveStatusUpdated);

    subscriptions
      ..add(ZegoUIKit()
          .getTurnOnYourCameraRequestStream(targetRoomID: widget.liveID)
          .listen(onTurnOnYourCameraRequest))
      ..add(ZegoUIKit()
          .getTurnOnYourMicrophoneRequestStream(targetRoomID: widget.liveID)
          .listen(onTurnOnYourMicrophoneRequest))
      ..add(ZegoUIKit()
          .getInRoomLocalMessageStream(targetRoomID: widget.liveID)
          .listen(onInRoomLocalMessageFinished))
      ..add(ZegoUIKit()
          .getRoomTokenExpiredStream(targetRoomID: widget.liveID)
          .listen(onRoomTokenExpired));

    /// ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _savedContext = context;
      ZegoLiveStreamingPageLifeCycle().updateContextQuery(() => _savedContext!);
    });

    checkFromMinimizing();
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    ZegoLiveStreamingPageLifeCycle()
        .manager(widget.liveID)
        .liveStatusManager
        .notifier
        .removeListener(onLiveStatusUpdated);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    ZegoLiveStreamingPageLifeCycle()
        .updateContextQuery(null, contextToRemove: _savedContext);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }

          final endConfirmationEvent = ZegoLiveStreamingLeaveConfirmationEvent(
            context: context,
          );
          defaultAction() async {
            return widget.defaultLeaveConfirmationAction(endConfirmationEvent);
          }

          final canLeave = await widget.events?.onLeaveConfirmation?.call(
                endConfirmationEvent,
                defaultAction,
              ) ??
              false;
          ZegoLoggerService.logInfo(
            'onPopInvoked, canLeave:$canLeave',
            tag: 'live.streaming.page',
            subTag: 'prebuilt',
          );

          if (canLeave) {
            if (ZegoLiveStreamingPageLifeCycle()
                .manager(widget.liveID)
                .hostManager
                .isLocalHost) {
              /// live is ready to end, host will update if receive property notify
              /// so need to keep current host value, DISABLE local host value UPDATE
              ZegoLiveStreamingPageLifeCycle()
                  .manager(widget.liveID)
                  .hostManager
                  .hostUpdateEnabledNotifier
                  .value = false;
              ZegoUIKit().updateRoomProperties(
                targetRoomID: widget.liveID,
                {
                  RoomPropertyKey.host.text: '',
                  RoomPropertyKey.liveStatus.text:
                      LiveStatus.ended.index.toString()
                },
              );
            }
          }

          if (canLeave) {
            if (context.mounted) {
              Navigator.of(
                context,
                rootNavigator: widget.config.rootNavigator,
              ).pop(false);
            } else {
              ZegoLoggerService.logInfo(
                'onPopInvoked, context not mounted',
                tag: 'live.streaming.page',
                subTag: 'prebuilt',
              );
            }
          }
        },
        child: ZegoScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return clickListener(
              child: LayoutBuilder(builder: (context, constraints) {
                return ValueListenableBuilder<ZegoUIKitUser?>(
                    valueListenable: ZegoLiveStreamingPageLifeCycle()
                        .manager(widget.liveID)
                        .hostManager
                        .notifier,
                    builder: (context, host, _) {
                      return Stack(
                        children: [
                          ...background(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          ZegoLiveStreamingCentralAudioVideoView(
                            liveID: widget.liveID,
                            config: widget.config,
                            popUpManager: widget.popUpManager,
                            constraints: constraints,
                            isPrebuiltFromHall: widget.isPrebuiltFromHall,
                          ),
                          sharingMedia(constraints),
                          ZegoLiveStreamingLivePageSurface(
                            liveID: widget.liveID,
                            config: widget.config,
                            events: widget.events,
                            defaultEndAction: widget.defaultEndAction,
                            defaultLeaveConfirmationAction:
                                widget.defaultLeaveConfirmationAction,
                            popUpManager: widget.popUpManager,
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

  Widget sharingMedia(BoxConstraints constraints) {
    if (!widget.config.mediaPlayer.defaultPlayer.support) {
      return Container();
    }

    ZegoUIKitPrebuiltLiveStreamingController()
        .media
        .defaultPlayer
        .visibleNotifier
        .value = true;
    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKitPrebuiltLiveStreamingController()
          .media
          .defaultPlayer
          .visibleNotifier,
      builder: (context, viewVisibility, _) {
        return viewVisibility
            ? ValueListenableBuilder<int>(
                valueListenable: ZegoLiveStreamingPageLifeCycle()
                    .manager(widget.liveID)
                    .connectManager
                    .coHostCount,
                builder: (context, coHostCount, _) {
                  final spacing = 20.zW;
                  final localRole = ZegoLiveStreamingPageLifeCycle()
                      .manager(widget.liveID)
                      .connectManager
                      .localRole;
                  final queryParameter =
                      ZegoLiveStreamingMediaPlayerQueryParameter(
                    localRole: localRole,
                  );

                  final rect = widget.config.mediaPlayer.defaultPlayer.rectQuery
                      ?.call(queryParameter);
                  final playerSize = rect?.size ??
                      Size(
                        constraints.maxWidth - spacing * 2,
                        constraints.maxWidth * 9 / 16,
                      );
                  final topLeft = widget
                          .config.mediaPlayer.defaultPlayer.topLeftQuery
                          ?.call(queryParameter) ??
                      Point<double>(
                        spacing,
                        constraints.maxHeight - playerSize.height - spacing,
                      );

                  var config = widget
                          .config.mediaPlayer.defaultPlayer.configQuery
                          ?.call(queryParameter) ??
                      ZegoUIKitMediaPlayerConfig(
                        canControl: ZegoLiveStreamingRole.host == localRole,
                      );

                  final mediaPlayer = Positioned.fromRect(
                    rect: rect ??
                        Rect.fromLTWH(
                          spacing,
                          spacing,
                          constraints.maxWidth - 2 * spacing,
                          constraints.maxHeight - 2 * spacing,
                        ),
                    child: ValueListenableBuilder<String?>(
                      valueListenable:
                          ZegoUIKitPrebuiltLiveStreamingController()
                              .media
                              .defaultPlayer
                              .private
                              .sharingPathNotifier,
                      builder: (context, sharingPath, _) {
                        return ZegoUIKitMediaPlayer(
                          roomID: widget.liveID,
                          size: playerSize,
                          initPosition: Offset(topLeft.x, topLeft.y),
                          config: config,
                          filePathOrURL: sharingPath,
                          event: widget.events?.media,
                          style: widget
                              .config.mediaPlayer.defaultPlayer.styleQuery
                              ?.call(queryParameter),
                        );
                      },
                    ),
                  );

                  if (widget.config.mediaPlayer.defaultPlayer.rolesCanControl
                      .contains(localRole)) {
                    return mediaPlayer;
                  } else {
                    return StreamBuilder<List<ZegoUIKitUser>>(
                      stream: ZegoUIKit().getMediaListStream(
                        targetRoomID: widget.liveID,
                      ),
                      builder: (context, snapshot) {
                        final mediaUsers = ZegoUIKit().getMediaList(
                          targetRoomID: widget.liveID,
                        );
                        if (mediaUsers.isEmpty) {
                          return Container();
                        }

                        return mediaPlayer;
                      },
                    );
                  }
                },
              )
            : Container();
      },
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
    ZegoLiveStreamingPageLifeCycle()
        .manager(widget.liveID)
        .liveStatusManager
        .onLiveStatusUpdated();

    if (null !=
        ZegoLiveStreamingPageLifeCycle()
            .manager(widget.liveID)
            .connectManager
            .dataOfInvitedToJoinCoHostInMinimizingNotifier
            .value) {
      final dataOfInvitedToJoinCoHostInMinimizing =
          ZegoLiveStreamingPageLifeCycle()
              .manager(widget.liveID)
              .connectManager
              .dataOfInvitedToJoinCoHostInMinimizingNotifier
              .value!;

      ZegoLoggerService.logInfo(
        'exist a invite to join co-host when minimizing($dataOfInvitedToJoinCoHostInMinimizing), show now',
        tag: 'live.streaming.page',
        subTag: 'live page',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ZegoLiveStreamingPageLifeCycle()
            .manager(widget.liveID)
            .connectManager
            .onAudienceReceivedCoHostInvitation(
              dataOfInvitedToJoinCoHostInMinimizing.host,
              dataOfInvitedToJoinCoHostInMinimizing.customData,
            );
      });
    }

    if (null !=
        ZegoLiveStreamingPageLifeCycle()
            .manager(widget.liveID)
            .pk
            .pkBattleRequestReceivedEventInMinimizingNotifier
            .value) {
      ZegoLoggerService.logInfo(
        'exist a pk battle request when minimizing, show now',
        tag: 'live.streaming.page',
        subTag: 'live page',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ZegoLiveStreamingPageLifeCycle()
            .manager(widget.liveID)
            .pk
            .restorePKBattleRequestReceivedEventFromMinimizing();
      });
    }
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
      valueListenable: ZegoLiveStreamingPageLifeCycle()
          .manager(widget.liveID)
          .liveStatusManager
          .notifier,
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
      'live page, host mgr updated, ${ZegoLiveStreamingPageLifeCycle().manager(widget.liveID).hostManager.notifier.value}',
      tag: 'live.streaming.page',
      subTag: 'live page',
    );
  }

  void onLiveStatusUpdated() {
    ZegoLoggerService.logInfo(
      'live page, live status mgr updated, ${ZegoLiveStreamingPageLifeCycle().manager(widget.liveID).liveStatusManager.notifier.value}',
      tag: 'live.streaming.page',
      subTag: 'live page',
    );

    if (!ZegoLiveStreamingPageLifeCycle()
        .manager(widget.liveID)
        .hostManager
        .isLocalHost) {
      ZegoLoggerService.logInfo(
        'audience, live streaming end by host, '
        'host: ${ZegoLiveStreamingPageLifeCycle().manager(widget.liveID).hostManager.notifier.value}, '
        'live status: ${ZegoLiveStreamingPageLifeCycle().manager(widget.liveID).liveStatusManager.notifier.value}',
        tag: 'live.streaming.page',
        subTag: 'live page',
      );

      if (LiveStatus.ended ==
          ZegoLiveStreamingPageLifeCycle()
              .manager(widget.liveID)
              .liveStatusManager
              .notifier
              .value) {
        final endEvent = ZegoLiveStreamingEndEvent(
          reason: ZegoLiveStreamingEndReason.hostEnd,
          isFromMinimizing: ZegoLiveStreamingMiniOverlayPageState.minimizing ==
              ZegoUIKitPrebuiltLiveStreamingController().minimize.state,
        );
        defaultAction() {
          widget.defaultEndAction(endEvent);
        }

        if (widget.events?.onEnded != null) {
          widget.events?.onEnded!.call(endEvent, defaultAction);
        } else {
          defaultAction.call();
        }
      }
    }
  }

  Future<void> onTurnOnYourCameraRequest(String fromUserID) async {
    ZegoLoggerService.logInfo(
      'onTurnOnYourCameraRequest, fromUserID:$fromUserID',
      tag: 'live.streaming.page',
      subTag: 'live page',
    );

    if (ZegoUIKit().getLocalUser().microphone.value) {
      ZegoLoggerService.logInfo(
        'camera is open now, not need request',
        tag: 'live.streaming.page',
        subTag: 'live page',
      );

      return;
    }

    final canCameraTurnOnByOthers = await widget
            .events?.audioVideo.onCameraTurnOnByOthersConfirmation
            ?.call(context) ??
        false;
    ZegoLoggerService.logInfo(
      'canMicrophoneTurnOnByOthers:$canCameraTurnOnByOthers',
      tag: 'live.streaming.page',
      subTag: 'live page',
    );
    if (canCameraTurnOnByOthers) {
      ZegoUIKit().turnCameraOn(targetRoomID: widget.liveID, true);
    }
  }

  Future<void> onTurnOnYourMicrophoneRequest(
      ZegoUIKitReceiveTurnOnLocalMicrophoneEvent event) async {
    ZegoLoggerService.logInfo(
      'onTurnOnYourMicrophoneRequest, event:$event',
      tag: 'live.streaming.page',
      subTag: 'live page',
    );

    if (ZegoUIKit().getLocalUser().microphone.value) {
      ZegoLoggerService.logInfo(
        'microphone is open now, not need request',
        tag: 'live.streaming.page',
        subTag: 'live page',
      );

      return;
    }

    final canMicrophoneTurnOnByOthers = await widget
            .events?.audioVideo.onMicrophoneTurnOnByOthersConfirmation
            ?.call(context) ??
        false;
    ZegoLoggerService.logInfo(
      'canMicrophoneTurnOnByOthers:$canMicrophoneTurnOnByOthers',
      tag: 'live.streaming.page',
      subTag: 'live page',
    );
    if (canMicrophoneTurnOnByOthers) {
      ZegoUIKit().turnMicrophoneOn(
        targetRoomID: widget.liveID,
        true,
        muteMode: event.muteMode,
      );
    }
  }

  void onInRoomLocalMessageFinished(ZegoInRoomMessage message) {
    widget.events?.inRoomMessage.onLocalSend?.call(message);
  }

  void onRoomTokenExpired(int remainSeconds) {
    widget.events?.room.onTokenExpired?.call(remainSeconds);
  }
}
