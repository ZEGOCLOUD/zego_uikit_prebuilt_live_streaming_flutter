// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/components/common.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/layout/layout.dart';

class ZegoLiveStreamingPKHostView extends StatefulWidget {
  const ZegoLiveStreamingPKHostView({
    Key? key,
    required this.hosts,
    required this.mixerLayout,
    required this.config,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarConfig,
  }) : super(key: key);

  final ZegoPKV2MixerLayout mixerLayout;
  final List<ZegoUIKitPrebuiltLiveStreamingPKUser> hosts;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoLiveStreamingPKHostView> createState() =>
      ZegoLiveStreamingPKHostViewState();
}

class ZegoLiveStreamingPKHostViewState
    extends State<ZegoLiveStreamingPKHostView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final mixerLayoutResolution = widget.mixerLayout.getResolution();
      final rectList = widget.mixerLayout.getRectList(
        widget.hosts.length,
        scale: constraints.maxWidth / mixerLayoutResolution.width,
      );

      return Stack(
        children: [
          ...hostAudioVideoViews(rectList, constraints),
        ],
      );
    });
  }

  List<Widget> hostAudioVideoViews(
    List<Rect> rectList,
    BoxConstraints constraints,
  ) {
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
              child: ZegoAudioVideoView(
                user: host.userInfo,
                foregroundBuilder: (
                  BuildContext context,
                  Size size,
                  ZegoUIKitUser? user,
                  Map<String, dynamic> extraInfo,
                ) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: host.heartbeatBrokenNotifier,
                    builder: (context, isHeartbeatBroken, _) {
                      final updatedUser =
                          ZegoUIKit().getUserInMixerStream(host.userInfo.id);
                      return isHeartbeatBroken
                          ? Stack(
                              children: [
                                Container(
                                  color: Colors.black,
                                ),
                                widget.config.audioVideoViewConfig
                                        .foregroundBuilder
                                        ?.call(
                                      context,
                                      size,
                                      user,
                                      extraInfo,
                                    ) ??
                                    Container(color: Colors.transparent),
                                Center(
                                  child: widget.config.pkBattleV2Config
                                          .hostReconnectingBuilder
                                          ?.call(
                                        context,
                                        updatedUser,
                                        {},
                                      ) ??
                                      const CircularProgressIndicator(),
                                ),
                              ],
                            )
                          : widget.config.audioVideoViewConfig.foregroundBuilder
                                  ?.call(
                                context,
                                size,
                                user,
                                extraInfo,
                              ) ??
                              Container(color: Colors.transparent);
                    },
                  );
                },
                backgroundBuilder:
                    widget.config.audioVideoViewConfig.backgroundBuilder ??
                        defaultPKBackgroundBuilder,
                avatarConfig: widget.avatarConfig ??
                    ZegoAvatarConfig(
                      showInAudioMode: widget
                          .config.audioVideoViewConfig.showAvatarInAudioMode,
                      showSoundWavesInAudioMode: widget.config
                          .audioVideoViewConfig.showSoundWavesInAudioMode,
                      builder: widget.config.avatarBuilder,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return widgets;
  }
}
