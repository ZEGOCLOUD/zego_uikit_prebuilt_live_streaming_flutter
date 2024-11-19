// Dart imports:
import 'dart:async';
import 'dart:core';
import 'dart:math';

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
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/service/services.dart';

/// @nodoc
/// user and sdk should be login and init before page enter
class ZegoLiveStreamingLivePage extends StatefulWidget {
  const ZegoLiveStreamingLivePage({
    Key? key,
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
    required this.hostManager,
    required this.liveStatusManager,
    required this.liveDurationManager,
    required this.popUpManager,
    this.plugins,
  }) : super(key: key);

  final int appID;
  final String appSign;
  final String token;

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
  bool isFromMinimizing = false;

  bool get isLiving =>
      LiveStatus.living == widget.liveStatusManager.notifier.value;

  @override
  void initState() {
    super.initState();

    isFromMinimizing = ZegoLiveStreamingMiniOverlayPageState.idle !=
        ZegoLiveStreamingMiniOverlayMachine().state;

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
          .listen(onInRoomLocalMessageFinished))
      ..add(ZegoUIKit().getRoomTokenExpiredStream().listen(onRoomTokenExpired));

    ZegoLiveStreamingManagers().updateContextQuery(() => context);

    if (isFromMinimizing) {
      ZegoLoggerService.logInfo(
        'mini machine state is not idle, context will not be init',
        tag: 'live-streaming',
        subTag: 'prebuilt',
      );
    } else {
      if (ZegoUIKit().engineCreatedNotifier.value) {
        ZegoLiveStreamingManagers()
            .liveStatusManager!
            .checkShouldStopPlayAllAudioVideo()
            .then((_) {
          ZegoUIKit()
              .joinRoom(
            widget.liveID,
            token: widget.token,
            markAsLargeRoom: widget.config.markAsLargeRoom,
          )
              .then((result) {
            onRoomLogin(result);
          });
        });
      } else {
        ZegoLoggerService.logInfo(
          'express engine is not created, waiting',
          tag: 'live-streaming',
          subTag: 'prebuilt',
        );

        ZegoUIKit()
            .engineCreatedNotifier
            .addListener(joinRoomWaitEngineCreated);
      }
    }

    checkFromMinimizing();
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    widget.liveStatusManager.notifier.removeListener(onLiveStatusUpdated);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
    ZegoUIKit().engineCreatedNotifier.removeListener(joinRoomWaitEngineCreated);

    if (!ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
      if (widget.config.role == ZegoLiveStreamingRole.audience) {
        /// audience, should be start play when leave
        ZegoUIKit().startPlayAllAudioVideo();
      }
    } else {
      ZegoLoggerService.logInfo(
        'mini machine state is minimizing, room will not be leave',
        tag: 'live-streaming',
        subTag: 'prebuilt',
      );
    }

    ZegoLiveStreamingManagers().updateContextQuery(null);

    widget.config.outsideLives.controller?.private.private.init().then((_) {
      widget.config.outsideLives.controller?.private.private.forceUpdate();
    });
  }

  void joinRoomWaitEngineCreated() {
    final isCreated = ZegoUIKit().engineCreatedNotifier.value;
    ZegoLoggerService.logInfo(
      'express engine created:$isCreated',
      tag: 'live-streaming',
      subTag: 'prebuilt',
    );

    if (isCreated) {
      ZegoUIKit()
          .engineCreatedNotifier
          .removeListener(joinRoomWaitEngineCreated);
      ZegoLiveStreamingManagers()
          .liveStatusManager!
          .checkShouldStopPlayAllAudioVideo()
          .then((_) {
        ZegoUIKit()
            .joinRoom(
          widget.liveID,
          token: widget.token,
          markAsLargeRoom: widget.config.markAsLargeRoom,
        )
            .then((result) {
          onRoomLogin(result);
        });
      });
    }
  }

  Future<void> onRoomLogin(ZegoRoomLoginResult result) async {
    if (result.errorCode != 0) {
      ZegoLoggerService.logError(
        'failed to login room:${result.errorCode},${result.extendedData}',
        tag: 'live-streaming',
        subTag: 'prebuilt',
      );
    }
    ZegoLoggerService.logError(
      'login room done:${result.errorCode},${result.extendedData}, '
      'room id:${ZegoUIKit().getRoom().id}',
      tag: 'live-streaming',
      subTag: 'prebuilt',
    );
    assert(result.errorCode == 0);

    await ZegoLiveStreamingManagers().hostManager!.init();
    await ZegoLiveStreamingManagers().liveStatusManager!.init();
    await ZegoLiveStreamingManagers().liveDurationManager!.init();

    ZegoLiveStreamingManagers().liveDurationManager!.setRoomPropertyByHost();

    notifyUserJoinByMessage();

    ZegoLiveStreamingManagers()
        .muteCoHostAudioVideo(ZegoUIKit().getAudioVideoList());

    if (widget.hostManager.isLocalHost) {
      ZegoUIKit().setRoomProperty(
          RoomPropertyKey.liveStatus.text, LiveStatus.living.index.toString());
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            return;
          }

          final endConfirmationEvent = ZegoLiveStreamingLeaveConfirmationEvent(
            context: context,
          );
          defaultAction() async {
            return widget.defaultLeaveConfirmationAction(endConfirmationEvent);
          }

          final canLeave = await widget.events.onLeaveConfirmation?.call(
                endConfirmationEvent,
                defaultAction,
              ) ??
              false;
          ZegoLoggerService.logInfo(
            'onPopInvoked, canLeave:$canLeave',
            tag: 'live-streaming',
            subTag: 'prebuilt',
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

          if (canLeave) {
            if (context.mounted) {
              Navigator.of(
                context,
                rootNavigator: widget.config.rootNavigator,
              ).pop(false);
            } else {
              ZegoLoggerService.logInfo(
                'onPopInvoked, context not mounted',
                tag: 'live-streaming',
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
                          sharingMedia(constraints),
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
                valueListenable:
                    ZegoLiveStreamingManagers().connectManager!.coHostCount,
                builder: (context, coHostCount, _) {
                  final spacing = 20.zW;
                  final localRole =
                      ZegoLiveStreamingManagers().connectManager!.localRole;
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
                          size: playerSize,
                          initPosition: Offset(topLeft.x, topLeft.y),
                          config: config,
                          filePathOrURL: sharingPath,
                          event: widget.events.media,
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
                      stream: ZegoUIKit().getMediaListStream(),
                      builder: (context, snapshot) {
                        final mediaUsers = ZegoUIKit().getMediaList();
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
    widget.liveStatusManager.onLiveStatusUpdated();

    if (null !=
        ZegoLiveStreamingManagers()
            .connectManager!
            .dataOfInvitedToJoinCoHostInMinimizingNotifier
            .value) {
      final dataOfInvitedToJoinCoHostInMinimizing = ZegoLiveStreamingManagers()
          .connectManager!
          .dataOfInvitedToJoinCoHostInMinimizingNotifier
          .value!;

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

  void onRoomTokenExpired(int remainSeconds) {
    widget.events.room.onTokenExpired?.call(remainSeconds);
  }
}
