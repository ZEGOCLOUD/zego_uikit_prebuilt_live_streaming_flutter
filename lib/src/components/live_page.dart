// Dart imports:
import 'dart:async';
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/audio_video_view_foreground.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_page_surface.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/prebuilt_data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/pk_service.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/pk_view.dart';

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
  /// had sort the host be first
  bool audioVideoContainerHostHadSorted = false;
  List<StreamSubscription<dynamic>?> subscriptions = [];

  bool get isLiving =>
      LiveStatus.living == widget.liveStatusManager.notifier.value;

  bool get isLivingWithHost =>
      LiveStatus.living == widget.liveStatusManager.notifier.value &&
      widget.hostManager.notifier.value != null;

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
                          avContainerOrPKBattleView(constraints),
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
            );
          },
        ),
      ),
    );
  }

  Widget avContainerOrPKBattleView(BoxConstraints constraints) {
    return ValueListenableBuilder(
      valueListenable: ZegoLiveStreamingPKBattleManager().state,
      builder: (context, ZegoLiveStreamingPKBattleState pkBattleState, _) {
        if (pkBattleState != ZegoLiveStreamingPKBattleState.inPKBattle) {
          return StreamBuilder<List<ZegoUIKitUser>>(
            stream: ZegoUIKit().getScreenSharingListStream(),
            builder: (context, snapshot) {
              final screenSharingUsers = ZegoUIKit().getScreenSharingList();
              return ValueListenableBuilder<ZegoUIKitUser?>(
                valueListenable: widget.hostManager.notifier,
                builder: (context, host, _) {
                  return audioVideoContainer(
                    host,
                    constraints.maxWidth,
                    constraints.maxHeight,
                    screenSharingUsers.isNotEmpty,
                  );
                },
              );
            },
          );
        } else {
          return Positioned(
            top: widget.config.pkBattleConfig.pKBattleViewTopPadding ?? 164.zR,
            child: ZegoLiveStreamingPKBattleView(
              constraints: constraints,
              config: widget.config,
              foregroundBuilder:
                  widget.config.audioVideoViewConfig.foregroundBuilder,
              backgroundBuilder:
                  widget.config.audioVideoViewConfig.backgroundBuilder,
              avatarConfig: ZegoAvatarConfig(
                showInAudioMode:
                    widget.config.audioVideoViewConfig.showAvatarInAudioMode,
                showSoundWavesInAudioMode: widget
                    .config.audioVideoViewConfig.showSoundWavesInAudioMode,
                builder: widget.config.avatarBuilder,
              ),
            ),
          );
        }
      },
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

  Widget audioVideoContainer(
    ZegoUIKitUser? host,
    double maxWidth,
    double maxHeight,
    bool withScreenSharing,
  ) {
    return host != null
        ? ValueListenableBuilder<bool>(
            valueListenable: ZegoUIKit()
                .getCameraStateNotifier(widget.hostManager.notifier.value!.id),
            builder: (context, isCameraEnabled, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: ZegoUIKit().getMicrophoneStateNotifier(
                    widget.hostManager.notifier.value!.id),
                builder: (context, isMicrophoneEnabled, _) {
                  if (!isCameraEnabled && !isMicrophoneEnabled) {
                    audioVideoContainerHostHadSorted = false;
                  }

                  return audioVideoWidget(
                    maxWidth,
                    maxHeight,
                    withScreenSharing,
                  );
                },
              );
            },
          )
        : audioVideoWidget(
            maxWidth,
            maxHeight,
            withScreenSharing,
          );
  }

  Widget audioVideoWidget(
    double width,
    double height,
    bool withScreenSharing,
  ) {
    return ValueListenableBuilder(
      valueListenable: widget.liveStatusManager.notifier,
      builder: (context, LiveStatus liveStatusValue, Widget? child) {
        final audioVideoContainerLayout =
            getAudioVideoContainerLayout(withScreenSharing);

        Widget children = Container();

        if (LiveStatus.living == liveStatusValue) {
          children = ZegoAudioVideoContainer(
            layout: audioVideoContainerLayout,
            foregroundBuilder: audioVideoViewForeground,
            backgroundBuilder: audioVideoViewBackground,
            sortAudioVideo: audioVideoViewSorter,
            filterAudioVideo: audioVideoViewFilter,
            avatarConfig: ZegoAvatarConfig(
              showInAudioMode:
                  widget.config.audioVideoViewConfig.showAvatarInAudioMode,
              showSoundWavesInAudioMode:
                  widget.config.audioVideoViewConfig.showSoundWavesInAudioMode,
              builder: widget.config.avatarBuilder,
            ),
            screenSharingViewController:
                widget.controller.screen.screenSharingViewController,
          );
        } else if (LiveStatus.living != liveStatusValue &&
            null != widget.hostManager.notifier.value) {
          /// support local co-host view in host preparing
          return ValueListenableBuilder<bool>(
            valueListenable: ZegoUIKit()
                .getCameraStateNotifier(ZegoUIKit().getLocalUser().id),
            builder: (context, isCameraEnabled, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: ZegoUIKit()
                    .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id),
                builder: (context, isMicrophoneEnabled, _) {
                  if (!isCameraEnabled && !isMicrophoneEnabled) {
                    return Container();
                  }

                  /// local open camera or microphone
                  return ZegoAudioVideoContainer(
                    layout: audioVideoContainerLayout,
                    backgroundBuilder: audioVideoViewBackground,
                    foregroundBuilder: audioVideoViewForeground,
                    sortAudioVideo: audioVideoViewSorter,
                    filterAudioVideo: audioVideoViewFilter,
                    avatarConfig: ZegoAvatarConfig(
                      showInAudioMode: widget
                          .config.audioVideoViewConfig.showAvatarInAudioMode,
                      showSoundWavesInAudioMode: widget.config
                          .audioVideoViewConfig.showSoundWavesInAudioMode,
                      builder: widget.config.avatarBuilder,
                    ),
                    screenSharingViewController:
                        widget.controller.screen.screenSharingViewController,
                  );
                },
              );
            },
          );
        }

        return Positioned(
          top: 0,
          left: 0,
          child: SizedBox(
            width: width,
            height: height,
            child: children,
          ),
        );
      },
    );
  }

  ZegoLayout getAudioVideoContainerLayout(bool withScreenSharing) {
    if (withScreenSharing) {
      if (widget.config.layout != null &&
          widget.config.layout is ZegoLayoutGalleryConfig) {
        return widget.config.layout!;
      } else {
        return ZegoLayout.gallery(
          showNewScreenSharingViewInFullscreenMode: true,
          showScreenSharingFullscreenModeToggleButtonRules:
              ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed,
        );
      }
    }

    return widget.config.layout ??
        ZegoLayout.pictureInPicture(
          smallViewPosition: ZegoViewPosition.bottomRight,
          isSmallViewDraggable: false,
          smallViewSize: Size(139.5.zW, 248.0.zH),
          smallViewMargin: EdgeInsets.only(
            left: 24.zR,
            top: 144.zR,
            right: 24.zR,
            bottom: 144.zR,
          ),
          showNewScreenSharingViewInFullscreenMode: true,
          showScreenSharingFullscreenModeToggleButtonRules:
              ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed,
        );
  }

  List<ZegoUIKitUser> audioVideoViewSorter(List<ZegoUIKitUser> users) {
    if (audioVideoContainerHostHadSorted) {
      return users;
    }

    if (isLivingWithHost &&
        (ZegoUIKit()
                .getCameraStateNotifier(
                    widget.hostManager.notifier.value?.id ?? '')
                .value ||
            ZegoUIKit()
                .getMicrophoneStateNotifier(
                    widget.hostManager.notifier.value?.id ?? '')
                .value)) {
      /// put host on first position
      users
        ..removeWhere(
            (user) => user.id == widget.hostManager.notifier.value!.id)
        ..insert(0, widget.hostManager.notifier.value!);

      /// not sort before next host changed
      audioVideoContainerHostHadSorted = true;
    }

    return users;
  }

  List<ZegoUIKitUser> audioVideoViewFilter(List<ZegoUIKitUser> users) {
    users.removeWhere((targetUser) {
      if (null != widget.config.audioVideoViewConfig.visible) {
        var targetUserRole = ZegoLiveStreamingRole.coHost;
        if (ZegoLiveStreamingManagers().hostManager?.isHost(targetUser) ??
            false) {
          targetUserRole = ZegoLiveStreamingRole.host;
        }
        if (!widget.config.audioVideoViewConfig.visible!.call(
          ZegoUIKit().getLocalUser(),
          ZegoLiveStreamingManagers().connectManager?.localRole ??
              ZegoLiveStreamingRole.audience,
          targetUser,
          targetUserRole,
        )) {
          /// only hide if invisible
          return true;
        }
      }

      return !targetUser.camera.value &&
          (!targetUser.microphone.value &&

              /// if mic is in mute mode, same as open state
              !targetUser.microphoneMuteMode.value);
    });

    return users;
  }

  Widget audioVideoViewForeground(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    if (extraInfo[ZegoViewBuilderMapExtraInfoKey.isScreenSharingView.name]
            as bool? ??
        false) {
      /// live streaming not need microphone/camera/user name foreground
      return widget.config.audioVideoViewConfig.foregroundBuilder
              ?.call(context, size, user, extraInfo) ??
          Container(color: Colors.transparent);
    }

    return Stack(
      children: [
        widget.config.audioVideoViewConfig.foregroundBuilder
                ?.call(context, size, user, extraInfo) ??
            Container(color: Colors.transparent),
        ValueListenableBuilder<bool>(
            valueListenable:
                ZegoUIKit().getMicrophoneStateNotifier(user?.id ?? ''),
            builder: (context, isMicrophoneEnabled, _) {
              return ZegoAudioVideoForeground(
                size: size,
                user: user,
                hostManager: widget.hostManager,
                connectManager: ZegoLiveStreamingManagers().connectManager!,
                popUpManager: widget.popUpManager,
                prebuiltController: widget.controller,
                translationText: widget.config.innerText,
                isPluginEnabled: widget.plugins?.isEnabled ?? false,
                //  only show if close
                showMicrophoneStateOnView: !isMicrophoneEnabled,
                showCameraStateOnView: false,
                showUserNameOnView:
                    widget.config.audioVideoViewConfig.showUserNameOnView,
              );
            }),
      ],
    );
  }

  Widget audioVideoViewBackground(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallView = (screenSize.width - size.width).abs() > 1;
    return Stack(
      children: [
        Container(
            color: isSmallView
                ? const Color(0xff333437)
                : const Color(0xff4A4B4D)),
        widget.config.audioVideoViewConfig.backgroundBuilder?.call(
              context,
              size,
              user,
              extraInfo,
            ) ??
            Container(color: Colors.transparent),
      ],
    );
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

    if (LiveStatus.ended == widget.liveStatusManager.notifier.value) {
      /// host changed
      audioVideoContainerHostHadSorted = false;
    }

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
      }
    }
  }

  Future<void> onTurnOnYourCameraRequest(String fromUserID) async {
    ZegoLoggerService.logInfo(
      'onTurnOnYourCameraRequest, fromUserID:$fromUserID',
      tag: 'live streaming',
      subTag: 'live page',
    );

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
