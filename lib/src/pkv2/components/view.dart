// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/components/audience_view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/components/host_view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/service/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/layout/layout.dart';

class ZegoLiveStreamingPKV2View extends StatefulWidget {
  const ZegoLiveStreamingPKV2View({
    Key? key,
    required this.constraints,
    required this.hostManager,
    required this.config,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarConfig,
  }) : super(key: key);

  final ZegoLiveHostManager hostManager;

  final BoxConstraints constraints;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoLiveStreamingPKV2View> createState() =>
      ZegoLiveStreamingPKV2ViewState();
}

class ZegoLiveStreamingPKV2ViewState extends State<ZegoLiveStreamingPKV2View> {
  ZegoPKV2MixerLayout get mixerLayout =>
      widget.config.pkBattleV2Config.mixerLayout ??
      ZegoPKV2MixerDefaultLayout();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: widget.constraints,
      child: ValueListenableBuilder<List<ZegoUIKitPrebuiltLiveStreamingPKUser>>(
        valueListenable: ZegoUIKitPrebuiltLiveStreamingPKV2
            .instance.connectedPKHostsNotifier,
        builder: (context, __, _) {
          final pkHosts = List<ZegoUIKitPrebuiltLiveStreamingPKUser>.from(
              ZegoUIKitPrebuiltLiveStreamingPKV2
                  .instance.connectedPKHostsNotifier.value);
          return Column(
            children: [
              widget.config.pkBattleV2Config.pkBattleViewTopBuilder?.call(
                    context,
                    pkHosts.map((e) => e.userInfo).toList(),
                    {},
                  ) ??
                  const SizedBox.shrink(),
              Stack(
                children: [
                  audioVideoView(
                    hosts: pkHosts,
                    mixerStreamID: ZegoUIKitPrebuiltLiveStreamingPKV2
                        .instance.currentMixerStreamID,
                  ),
                  widget.config.pkBattleV2Config.pkBattleViewForegroundBuilder
                          ?.call(
                        context,
                        pkHosts.map((e) => e.userInfo).toList(),
                        {},
                      ) ??
                      const SizedBox.shrink(),
                ],
              ),
              widget.config.pkBattleV2Config.pkBattleViewBottomBuilder?.call(
                    context,
                    pkHosts.map((e) => e.userInfo).toList(),
                    {},
                  ) ??
                  const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  Widget audioVideoView({
    required List<ZegoUIKitPrebuiltLiveStreamingPKUser> hosts,
    required String mixerStreamID,
  }) {
    return ValueListenableBuilder<ZegoLiveStreamingPKBattleStateV2>(
      valueListenable:
          ZegoUIKitPrebuiltLiveStreamingPKV2.instance.pkStateNotifier,
      builder: (BuildContext context, pkBattleState, Widget? child) {
        if (!ZegoUIKitPrebuiltLiveStreamingPKV2.instance.isInPK) {
          return const SizedBox.shrink();
        } else {
          return ConstrainedBox(
            constraints: widget.constraints,
            child: ValueListenableBuilder(
              valueListenable: widget.hostManager.notifier,
              builder: (context, _, __) {
                final view = widget.hostManager.isLocalHost
                    ? ZegoLiveStreamingPKHostView(
                        hosts: hosts,
                        mixerLayout: mixerLayout,
                        config: widget.config,
                        foregroundBuilder: widget.foregroundBuilder,
                        backgroundBuilder: widget.backgroundBuilder,
                        avatarConfig: widget.avatarConfig,
                      )
                    : ZegoLiveStreamingPKAudienceView(
                        mixerStreamID: mixerStreamID,
                        mixerLayout: mixerLayout,
                        hosts: hosts,
                        config: widget.config,
                        foregroundBuilder: widget.foregroundBuilder,
                        backgroundBuilder: widget.backgroundBuilder,
                        avatarConfig: widget.avatarConfig,
                      );

                return AspectRatio(
                  aspectRatio:
                      zegoPK2MixerCanvasWidth / zegoPK2MixerCanvasHeight,
                  child: view,
                );
              },
            ),
          );
        }
      },
    );
  }
}
