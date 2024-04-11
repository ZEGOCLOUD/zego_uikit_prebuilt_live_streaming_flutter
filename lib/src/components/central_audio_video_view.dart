// Dart imports:
import 'dart:async';
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/audio_video_view_foreground.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/components/view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/service/defines.dart';

/// @nodoc
class ZegoLiveStreamingCentralAudioVideoView extends StatefulWidget {
  const ZegoLiveStreamingCentralAudioVideoView({
    Key? key,
    required this.config,
    required this.hostManager,
    required this.liveStatusManager,
    required this.popUpManager,
    required this.constraints,
    this.plugins,
  }) : super(key: key);

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoLiveStreamingHostManager hostManager;
  final ZegoLiveStreamingStatusManager liveStatusManager;
  final ZegoLiveStreamingPopUpManager popUpManager;
  final ZegoLiveStreamingPlugins? plugins;

  final BoxConstraints constraints;

  @override
  State<ZegoLiveStreamingCentralAudioVideoView> createState() =>
      ZegoLiveStreamingCentralAudioVideoViewState();
}

/// @nodoc
class ZegoLiveStreamingCentralAudioVideoViewState
    extends State<ZegoLiveStreamingCentralAudioVideoView> {
  /// had sort the host be first
  bool audioVideoContainerHostHadSorted = false;
  List<StreamSubscription<dynamic>?> subscriptions = [];

  bool get isLivingWithHost =>
      LiveStatus.living == widget.liveStatusManager.notifier.value &&
      widget.hostManager.notifier.value != null;

  @override
  void initState() {
    super.initState();

    widget.liveStatusManager.notifier.addListener(onLiveStatusUpdated);
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    widget.liveStatusManager.notifier.removeListener(onLiveStatusUpdated);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state,
      builder: (context, isInPK, _) {
        if (isInPK) {
          if (ZegoUIKitPrebuiltLiveStreamingPK.instance.pkStateNotifier.value ==
                  ZegoLiveStreamingPKBattleState.inPK ||
              ZegoUIKitPrebuiltLiveStreamingPK.instance.pkStateNotifier.value ==
                  ZegoLiveStreamingPKBattleState.loading) {
            return pkBattleView(
              constraints: widget.constraints,
            );
          }
        }

        return StreamBuilder<List<ZegoUIKitUser>>(
          stream: ZegoUIKit().getScreenSharingListStream(),
          builder: (context, snapshot) {
            final screenSharingUsers = ZegoUIKit().getScreenSharingList();
            return ValueListenableBuilder<ZegoUIKitUser?>(
              valueListenable: widget.hostManager.notifier,
              builder: (context, host, _) {
                return audioVideoView(
                  host,
                  widget.constraints.maxWidth,
                  widget.constraints.maxHeight,
                  screenSharingUsers.isNotEmpty,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget pkBattleView({
    required BoxConstraints constraints,
  }) {
    final topPadding = widget.config.pkBattle.topPadding ?? 164.zR;

    final displayConstraints = BoxConstraints(
      maxWidth: constraints.maxWidth,
      maxHeight: constraints.maxHeight - topPadding - 2.zR,
    );

    final view = ZegoLiveStreamingPKV2View(
      constraints: displayConstraints,
      hostManager: widget.hostManager,
      config: widget.config,
      foregroundBuilder: widget.config.audioVideoView.foregroundBuilder,
      backgroundBuilder: widget.config.audioVideoView.backgroundBuilder,
      avatarConfig: ZegoAvatarConfig(
        showInAudioMode: widget.config.audioVideoView.showAvatarInAudioMode,
        showSoundWavesInAudioMode:
            widget.config.audioVideoView.showSoundWavesInAudioMode,
        builder: widget.config.avatarBuilder,
      ),
    );

    final customRect = widget.config.pkBattle.containerRect?.call();
    return null != customRect
        ? Positioned.fromRect(rect: customRect, child: view)
        : Positioned(top: topPadding, child: view);
  }

  Widget audioVideoView(
    ZegoUIKitUser? host,
    double preferWidth,
    double preferHeight,
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
                    preferWidth,
                    preferHeight,
                    withScreenSharing,
                  );
                },
              );
            },
          )
        : audioVideoWidget(
            preferWidth,
            preferHeight,
            withScreenSharing,
          );
  }

  Widget audioVideoWidget(
    double preferWidth,
    double preferHeight,
    bool withScreenSharing,
  ) {
    return ValueListenableBuilder(
      valueListenable: widget.liveStatusManager.notifier,
      builder: (context, LiveStatus liveStatusValue, Widget? child) {
        Widget children = Container();

        audioVideoViewCreator(ZegoUIKitUser user) {
          return ZegoAudioVideoView(
            user: user,
            backgroundBuilder: audioVideoViewBackground,
            foregroundBuilder: audioVideoViewForeground,
            borderRadius: 18.0.zW,
            borderColor: Colors.transparent,
            avatarConfig: ZegoAvatarConfig(
              showInAudioMode:
                  widget.config.audioVideoView.showAvatarInAudioMode,
              showSoundWavesInAudioMode:
                  widget.config.audioVideoView.showSoundWavesInAudioMode,
              builder: widget.config.avatarBuilder,
            ),
          );
        }

        final audioVideoContainer =
            null != widget.config.audioVideoView.containerBuilder
                ? StreamBuilder<List<ZegoUIKitUser>>(
                    stream: ZegoUIKit().getUserListStream(),
                    builder: (context, snapshot) {
                      final allUsers = ZegoUIKit().getAllUsers();
                      return StreamBuilder<List<ZegoUIKitUser>>(
                        stream: ZegoUIKit().getAudioVideoListStream(),
                        builder: (context, snapshot) {
                          return widget.config.audioVideoView.containerBuilder
                                  ?.call(
                                context,
                                allUsers,
                                ZegoUIKit().getAudioVideoList(),
                                audioVideoViewCreator,
                              ) ??
                              defaultAudioVideoContainer(withScreenSharing);
                        },
                      );
                    },
                  )
                : defaultAudioVideoContainer(withScreenSharing);

        if (LiveStatus.living == liveStatusValue) {
          children = audioVideoContainer;
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
                  return audioVideoContainer;
                },
              );
            },
          );
        }

        return Positioned.fromRect(
          rect: widget.config.audioVideoView.containerRect?.call() ??
              Rect.fromLTWH(0, 0, preferWidth, preferHeight),
          child: null != widget.config.audioVideoView.containerRect
              ? children
              : ZegoInputBoardWrapper(child: children),
        );
      },
    );
  }

  Widget defaultAudioVideoContainer(bool withScreenSharing) {
    return ZegoAudioVideoContainer(
      layout: getAudioVideoContainerLayout(withScreenSharing),
      foregroundBuilder: audioVideoViewForeground,
      backgroundBuilder: audioVideoViewBackground,
      sortAudioVideo: audioVideoViewSorter,
      filterAudioVideo: audioVideoViewFilter,
      avatarConfig: ZegoAvatarConfig(
        showInAudioMode: widget.config.audioVideoView.showAvatarInAudioMode,
        showSoundWavesInAudioMode:
            widget.config.audioVideoView.showSoundWavesInAudioMode,
        builder: widget.config.avatarBuilder,
      ),
      screenSharingViewController: ZegoUIKitPrebuiltLiveStreamingController()
          .screenSharing
          .viewController,
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
      return widget.config.audioVideoView.foregroundBuilder
              ?.call(context, size, user, extraInfo) ??
          Container(color: Colors.transparent);
    }

    return Stack(
      children: [
        widget.config.audioVideoView.foregroundBuilder
                ?.call(context, size, user, extraInfo) ??
            Container(color: Colors.transparent),
        ValueListenableBuilder<bool>(
            valueListenable:
                ZegoUIKit().getMicrophoneStateNotifier(user?.id ?? ''),
            builder: (context, isMicrophoneEnabled, _) {
              return ZegoLiveStreamingAudioVideoForeground(
                size: size,
                user: user,
                hostManager: widget.hostManager,
                connectManager: ZegoLiveStreamingManagers().connectManager!,
                popUpManager: widget.popUpManager,
                translationText: widget.config.innerText,
                isPluginEnabled: widget.plugins?.isEnabled ?? false,
                //  only show if close
                showMicrophoneStateOnView: !isMicrophoneEnabled,
                showCameraStateOnView: false,
                showUserNameOnView:
                    widget.config.audioVideoView.showUserNameOnView,
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
        widget.config.audioVideoView.backgroundBuilder?.call(
              context,
              size,
              user,
              extraInfo,
            ) ??
            Container(color: Colors.transparent),
      ],
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
      if (null != widget.config.audioVideoView.visible) {
        var targetUserRole = ZegoLiveStreamingRole.coHost;
        if (ZegoLiveStreamingManagers().hostManager?.isHost(targetUser) ??
            false) {
          targetUserRole = ZegoLiveStreamingRole.host;
        }
        if (!widget.config.audioVideoView.visible!.call(
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

  void onLiveStatusUpdated() {
    ZegoLoggerService.logInfo(
      'live page, live status mgr updated, ${widget.liveStatusManager.notifier.value}',
      tag: 'live streaming',
      subTag: 'central audio video view',
    );

    if (LiveStatus.ended == widget.liveStatusManager.notifier.value) {
      /// host changed
      audioVideoContainerHostHadSorted = false;
    }
  }
}
