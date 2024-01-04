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
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/prebuilt_data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/pk_service.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/service/services.dart';

/// @nodoc
/// user and sdk should be login and init before page enter
class ZegoLivePage extends StatefulWidget {
  const ZegoLivePage({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    required this.prebuiltData,
    required this.hostManager,
    required this.liveStatusManager,
    required this.liveDurationManager,
    required this.popUpManager,
    required this.controller,
    this.plugins,
  }) : super(key: key);

  final int appID;
  final String appSign;

  final String userID;
  final String userName;

  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoUIKitPrebuiltLiveStreamingData prebuiltData;

  final ZegoLiveHostManager hostManager;
  final ZegoLiveStatusManager liveStatusManager;
  final ZegoLiveDurationManager liveDurationManager;
  final ZegoPopUpManager popUpManager;
  final ZegoPrebuiltPlugins? plugins;

  final ZegoUIKitPrebuiltLiveStreamingController controller;

  @override
  State<ZegoLivePage> createState() => ZegoLivePageState();
}

/// @nodoc
class ZegoLivePageState extends State<ZegoLivePage>
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
          final canLeave = await widget.config.onLeaveConfirmation!(context);
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
            return ZegoInputBoardWrapper(
              child: clickListener(
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
                            ZegoLivePageCentralAudioVideoView(
                              config: widget.config,
                              hostManager: widget.hostManager,
                              liveStatusManager: widget.liveStatusManager,
                              popUpManager: widget.popUpManager,
                              controller: widget.controller,
                              plugins: widget.plugins,
                              constraints: constraints,
                            ),
                            ZegoLivePageSurface(
                              config: widget.config,
                              hostManager: widget.hostManager,
                              liveStatusManager: widget.liveStatusManager,
                              liveDurationManager: widget.liveDurationManager,
                              popUpManager: widget.popUpManager,
                              connectManager:
                                  ZegoLiveStreamingManagers().connectManager!,
                              controller: widget.controller,
                              plugins: widget.plugins,
                              prebuiltData: widget.prebuiltData,
                            ),
                          ],
                        );
                      });
                }),
              ),
            );
          },
        ),
      ),
    );
  }

  void checkFromMinimizing() {
    if (!widget.prebuiltData.isPrebuiltFromMinimizing) {
      return;
    }

    /// update callback
    widget.liveStatusManager.onLiveStatusUpdated();

    if (null !=
        ZegoLiveStreamingManagers()
            .connectManager!
            .inviterOfInvitedToJoinCoHostInMinimizing) {
      ZegoLoggerService.logInfo(
        'exist a invite to join co-host when minimizing, show now',
        tag: 'live streaming',
        subTag: 'live page',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ZegoLiveStreamingManagers()
            .connectManager!
            .onAudienceReceivedCoHostInvitation(
              ZegoLiveStreamingManagers()
                  .connectManager!
                  .inviterOfInvitedToJoinCoHostInMinimizing!,
            );
      });
    }

    if (null !=
        ZegoUIKitPrebuiltLiveStreamingPKService()
            .pkBattleRequestReceivedEventInMinimizingNotifier
            .value) {
      ZegoLoggerService.logInfo(
        'exist a pk battle request when minimizing, show now',
        tag: 'live streaming',
        subTag: 'live page',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ZegoUIKitPrebuiltLiveStreamingPKService()
            .restorePKBattleRequestReceivedEventFromMinimizing();
      });
    }
    if (null !=
        ZegoUIKitPrebuiltLiveStreamingPKV2()
            .pkBattleRequestReceivedEventInMinimizingNotifier
            .value) {
      ZegoLoggerService.logInfo(
        'exist a pk battle request when minimizing, show now',
        tag: 'live streaming',
        subTag: 'live page',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ZegoUIKitPrebuiltLiveStreamingPKV2()
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
    //     tag: 'live streaming',
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
              image: PrebuiltLiveStreamingImage.assetImage(
                PrebuiltLiveStreamingIconUrls.background,
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
      tag: 'live streaming',
      subTag: 'live page',
    );
  }

  void onLiveStatusUpdated() {
    ZegoLoggerService.logInfo(
      'live page, live status mgr updated, ${widget.liveStatusManager.notifier.value}',
      tag: 'live streaming',
      subTag: 'live page',
    );

    if (!widget.hostManager.isLocalHost) {
      ZegoLoggerService.logInfo(
        'audience, live streaming end by host, '
        'host: ${widget.hostManager.notifier.value}, '
        'live status: ${widget.liveStatusManager.notifier.value}',
        tag: 'live streaming',
        subTag: 'live page',
      );

      if (LiveStatus.ended == widget.liveStatusManager.notifier.value) {
        if (widget.config.onLiveStreamingEnded != null) {
          widget.config.onLiveStreamingEnded!.call(false);
        }

        /// audience or co-host wouldn't return to the previous page by default
      }
    }
  }

  Future<void> onTurnOnYourCameraRequest(String fromUserID) async {
    ZegoLoggerService.logInfo(
      'onTurnOnYourCameraRequest, fromUserID:$fromUserID',
      tag: 'live streaming',
      subTag: 'live page',
    );

    if (ZegoUIKit().getLocalUser().microphone.value) {
      ZegoLoggerService.logInfo(
        'camera is open now, not need request',
        tag: 'live streaming',
        subTag: 'live page',
      );

      return;
    }

    final canCameraTurnOnByOthers =
        await widget.config.onCameraTurnOnByOthersConfirmation?.call(context) ??
            false;
    ZegoLoggerService.logInfo(
      'canMicrophoneTurnOnByOthers:$canCameraTurnOnByOthers',
      tag: 'live streaming',
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
      tag: 'live streaming',
      subTag: 'live page',
    );

    if (ZegoUIKit().getLocalUser().microphone.value) {
      ZegoLoggerService.logInfo(
        'microphone is open now, not need request',
        tag: 'live streaming',
        subTag: 'live page',
      );

      return;
    }

    final canMicrophoneTurnOnByOthers = await widget
            .config.onMicrophoneTurnOnByOthersConfirmation
            ?.call(context) ??
        false;
    ZegoLoggerService.logInfo(
      'canMicrophoneTurnOnByOthers:$canMicrophoneTurnOnByOthers',
      tag: 'live streaming',
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
    widget.config.inRoomMessageConfig.onLocalMessageSend?.call(message);
  }
}
