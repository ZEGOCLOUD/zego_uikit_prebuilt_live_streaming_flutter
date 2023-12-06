// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/components/common.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/layout/layout.dart';

/// one stream, more host configs
class ZegoLiveStreamingPKAudienceView extends StatefulWidget {
  const ZegoLiveStreamingPKAudienceView({
    Key? key,
    required this.mixerStreamID,
    required this.hosts,
    required this.config,
    required this.mixerLayout,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarConfig,
  }) : super(key: key);

  final String mixerStreamID;
  final ZegoPKV2MixerLayout mixerLayout;
  final List<ZegoUIKitPrebuiltLiveStreamingPKUser> hosts;

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
          rect: rect,
          child: ValueListenableBuilder(
            valueListenable: ZegoUIKitUserPropertiesNotifier(
              host.userInfo,
            ),
            builder: (context, _, __) {
              return ValueListenableBuilder<bool>(
                  valueListenable:
                      ZegoUIKit().getMixAudioVideoCameraStateNotifier(
                    widget.mixerStreamID,
                    host.userInfo.id,
                  ),
                  builder: (context, isCameraOn, _) {
                    if (isCameraOn) {
                      /// hide foreground when use camera
                      return Container(color: Colors.transparent);
                    }

                    final updatedUser =
                        ZegoUIKit().getUserInMixerStream(host.userInfo.id);
                    return Stack(
                      children: [
                        (widget.backgroundBuilder ?? defaultPKBackgroundBuilder)
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
                          child: avatar(host, rect),
                        )
                      ],
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
                      ? Container(
                          color: Colors.black,
                        )
                      : Container(color: Colors.transparent);
                },
              ),
            ),
            Positioned.fromRect(
              rect: rect,
              child: ValueListenableBuilder(
                valueListenable: ZegoUIKitUserPropertiesNotifier(
                  host.userInfo,
                  mixerStreamID: widget.mixerStreamID,
                ),
                builder: (context, _, __) {
                  final updatedUser =
                      ZegoUIKit().getUserInMixerStream(host.userInfo.id);
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
                  final updatedUser =
                      ZegoUIKit().getUserInMixerStream(host.userInfo.id);
                  return isHeartbeatBroken
                      ? Center(
                          child: widget.config.pkBattleV2Config
                                  .hostReconnectingBuilder
                                  ?.call(
                                context,
                                updatedUser,
                                {},
                              ) ??
                              const CircularProgressIndicator(),
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

  Widget avatar(
    ZegoUIKitPrebuiltLiveStreamingPKUser host,
    Rect rect,
  ) {
    return SizedBox(
      width: widget.avatarConfig?.size?.width ?? rect.width / 2,
      height: widget.avatarConfig?.size?.height ?? rect.width / 2,
      child: ZegoAvatar(
        avatarSize: widget.avatarConfig?.size ?? rect.size / 2,
        user: host.userInfo,
        showAvatar: widget.avatarConfig?.showInAudioMode ?? true,
        showSoundLevel: widget.avatarConfig?.showSoundWavesInAudioMode ?? true,
        avatarBuilder: widget.avatarConfig?.builder,
        soundLevelSize: widget.avatarConfig?.size,
        soundLevelColor: widget.avatarConfig?.soundWaveColor,
        mixerStreamID: widget.mixerStreamID,
      ),
    );
  }
}
