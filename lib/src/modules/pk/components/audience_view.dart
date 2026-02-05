// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/layout/layout.dart';
import 'common.dart';

/// one stream, more host configs
class ZegoLiveStreamingPKAudienceView extends StatefulWidget {
  const ZegoLiveStreamingPKAudienceView({
    super.key,
    required this.liveID,
    required this.mixerStreamID,
    required this.hosts,
    required this.config,
    required this.mixerLayout,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarConfig,
  });

  final String liveID;
  final String mixerStreamID;
  final ZegoLiveStreamingPKMixerLayout mixerLayout;
  final List<ZegoLiveStreamingPKUser> hosts;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoLiveStreamingPKAudienceView> createState() =>
      ZegoLiveStreamingPKAudienceViewState();
}

class ZegoLiveStreamingPKAudienceViewState
    extends State<ZegoLiveStreamingPKAudienceView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ZegoUIKit().getMixAudioVideoViewNotifier(
        widget.mixerStreamID,
        targetRoomID: widget.liveID,
      ),
      builder: (context, Widget? mixView, _) {
        if (null == mixView) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(builder: (context, constraints) {
          final mixerLayoutResolution = widget.mixerLayout.getResolution();
          final rectList = widget.mixerLayout.getRectList(
            widget.hosts.length,
            scale: constraints.maxWidth / mixerLayoutResolution.width,
          );

          return Stack(
            children: [
              /// The audience pulls the mixed stream,
              /// which is a frame composed of multiple hosts,
              /// so mixView should be placed at the bottom layer
              mixView,
              ...background(rectList),
              ...foreground(rectList),
            ],
          );
        });
      },
    );
  }

  List<Widget> background(List<Rect> rectList) {
    assert(rectList.length == widget.hosts.length);

    List<Widget> widgets = [];
    for (int idx = 0; idx < rectList.length; ++idx) {
      final rect = rectList[idx];
      final host = widget.hosts[idx];

      widgets.add(
        Positioned.fromRect(
          key: ValueKey(host.userInfo.id),
          rect: rect,
          child: ValueListenableBuilder(
            valueListenable: ZegoUIKitUserPropertiesNotifier(
              roomID: widget.liveID,
              host.userInfo,
            ),
            builder: (context, _, __) {
              return ValueListenableBuilder<bool>(
                  valueListenable:
                      ZegoUIKit().getMixAudioVideoCameraStateNotifier(
                    targetRoomID: widget.liveID,
                    widget.mixerStreamID,
                    host.userInfo.id,
                  ),
                  builder: (context, isCameraOn, _) {
                    return _ZegoPKBackgroundDelayedShow(
                      isCameraOn: isCameraOn,
                      childBuilder: () {
                        final updatedUser = ZegoUIKit().getUserInMixerStream(
                          targetRoomID: widget.liveID,
                          host.userInfo.id,
                        );
                        if (updatedUser.name.isEmpty) {
                          updatedUser.name = host.userInfo.name;
                        }

                        return Stack(
                          children: [
                            (widget.backgroundBuilder ??
                                    defaultPKBackgroundBuilder)
                                .call(
                              context,
                              rect.size,
                              updatedUser,
                              {},
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: ZegoLiveStreamingPKAudienceContent(
                                roomID: widget.liveID,
                                user: updatedUser,
                                avatarConfig: widget.avatarConfig,
                                rect: rect,
                                mixerStreamID: widget.mixerStreamID,
                              ),
                            )
                          ],
                        );
                      },
                    );
                  });
            },
          ),
        ),
      );
    }

    return widgets;
  }

  List<Widget> foreground(List<Rect> rectList) {
    assert(rectList.length == widget.hosts.length);

    List<Widget> widgets = [];
    for (int idx = 0; idx < rectList.length; ++idx) {
      final rect = rectList[idx];
      final host = widget.hosts[idx];

      widgets.add(
        Stack(
          children: [
            Positioned.fromRect(
              rect: rect,
              child: ValueListenableBuilder<bool>(
                valueListenable: host.heartbeatBrokenNotifier,
                builder: (context, isHeartbeatBroken, _) {
                  return isHeartbeatBroken
                      ? Container(color: Colors.black)
                      : Container(color: Colors.transparent);
                },
              ),
            ),
            Positioned.fromRect(
              rect: rect,
              child: ValueListenableBuilder(
                valueListenable: ZegoUIKitUserPropertiesNotifier(
                  roomID: widget.liveID,
                  host.userInfo,
                  mixerStreamID: widget.mixerStreamID,
                ),
                builder: (context, _, __) {
                  var updatedUser = ZegoUIKit().getUserInMixerStream(
                    targetRoomID: widget.liveID,
                    host.userInfo.id,
                  );
                  if (updatedUser.name.isEmpty) {
                    updatedUser.name = host.userInfo.name;
                  }

                  return widget.foregroundBuilder?.call(
                        context,
                        rect.size,
                        updatedUser,
                        {},
                      ) ??
                      Container(color: Colors.transparent);
                },
              ),
            ),
            Positioned.fromRect(
              rect: rect,
              child: ValueListenableBuilder<bool>(
                valueListenable: host.heartbeatBrokenNotifier,
                builder: (context, isHeartbeatBroken, _) {
                  final updatedUser = ZegoUIKit().getUserInMixerStream(
                    targetRoomID: widget.liveID,
                    host.userInfo.id,
                  );
                  if (updatedUser.name.isEmpty) {
                    updatedUser.name = host.userInfo.name;
                  }
                  return isHeartbeatBroken
                      ? Center(
                          child: widget.config.pkBattle.hostReconnectingBuilder
                                  ?.call(
                                context,
                                updatedUser,
                                {},
                              ) ??
                              ZegoLoadingIndicator(
                                text: kDebugMode ? "PKAudienceView" : "",
                              ),
                        )
                      : Container(color: Colors.transparent);
                },
              ),
            ),
          ],
        ),
      );
    }

    return widgets;
  }
}

/// A widget that delays the display of the background when the camera is off.
/// This prevents the background from flashing briefly before the video stream is ready
/// when the initial camera state might be false but quickly becomes true.
class _ZegoPKBackgroundDelayedShow extends StatefulWidget {
  const _ZegoPKBackgroundDelayedShow({
    super.key,
    required this.isCameraOn,
    required this.childBuilder,
    this.delay = const Duration(milliseconds: 500),
  });

  final bool isCameraOn;
  final Widget Function() childBuilder;
  final Duration delay;

  @override
  State<_ZegoPKBackgroundDelayedShow> createState() =>
      _ZegoPKBackgroundDelayedShowState();
}

class _ZegoPKBackgroundDelayedShowState
    extends State<_ZegoPKBackgroundDelayedShow> {
  Timer? _timer;
  bool _showBackground = false;

  @override
  void initState() {
    super.initState();
    _updateState();
  }

  @override
  void didUpdateWidget(_ZegoPKBackgroundDelayedShow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCameraOn != widget.isCameraOn) {
      _updateState();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateState() {
    _timer?.cancel();

    if (widget.isCameraOn) {
      // Camera is ON, hide background immediately
      _showBackground = false;
    } else {
      // Camera is OFF, delay showing background
      if (!_showBackground) {
        _timer = Timer(widget.delay, () {
          if (mounted) {
            setState(() {
              _showBackground = true;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCameraOn) {
      return Container(color: Colors.transparent);
    }

    if (_showBackground) {
      return widget.childBuilder();
    }

    return Container(color: Colors.transparent);
  }
}

class ZegoLiveStreamingPKAudienceContent extends StatelessWidget {
  const ZegoLiveStreamingPKAudienceContent({
    super.key,
    required this.roomID,
    required this.user,
    required this.rect,
    required this.mixerStreamID,
    this.avatarConfig,
  });

  final String roomID;
  final ZegoUIKitUser user;
  final ZegoAvatarConfig? avatarConfig;
  final Rect rect;
  final String mixerStreamID;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: avatarConfig?.size?.width ?? rect.width / 2,
      height: avatarConfig?.size?.height ?? rect.width / 2,
      child: ZegoAvatar(
        roomID: roomID,
        avatarSize: avatarConfig?.size ?? rect.size / 2,
        user: user,
        showAvatar: avatarConfig?.showInAudioMode ?? true,
        showSoundLevel: avatarConfig?.showSoundWavesInAudioMode ?? true,
        avatarBuilder: avatarConfig?.builder,
        soundLevelSize: avatarConfig?.size,
        soundLevelColor: avatarConfig?.soundWaveColor,
        mixerStreamID: mixerStreamID,
      ),
    );
  }
}
