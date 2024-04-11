// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/components/audience_view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/components/host_view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/service/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/layout/layout.dart';

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

  final ZegoLiveStreamingHostManager hostManager;

  final BoxConstraints constraints;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoLiveStreamingPKV2View> createState() =>
      _ZegoLiveStreamingPKV2ViewState();
}

class _ZegoLiveStreamingPKV2ViewState extends State<ZegoLiveStreamingPKV2View> {
  ZegoLiveStreamingPKMixerLayout get mixerLayout =>
      widget.config.pkBattle.mixerLayout ??
      ZegoLiveStreamingPKMixerDefaultLayout();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: widget.constraints,
      child: ValueListenableBuilder<List<ZegoLiveStreamingPKUser>>(
        valueListenable:
            ZegoUIKitPrebuiltLiveStreamingPK.instance.connectedPKHostsNotifier,
        builder: (context, __, _) {
          final pkHosts = List<ZegoLiveStreamingPKUser>.from(
            ZegoUIKitPrebuiltLiveStreamingPK
                .instance.connectedPKHostsNotifier.value,
          );

          final mixerLayoutResolution = mixerLayout.getResolution();

          return LayoutBuilder(builder: (context, constraints) {
            final centralConstraints = BoxConstraints(
              maxWidth: constraints.maxWidth,
              maxHeight: (constraints.maxWidth * mixerLayoutResolution.height) /
                  mixerLayoutResolution.width,
            );
            return Column(
              children: [
                widget.config.pkBattle.topBuilder?.call(
                      context,
                      pkHosts.map((e) => e.userInfo).toList(),
                      {},
                    ) ??
                    const SizedBox.shrink(),
                Stack(
                  children: [
                    audioVideoView(
                      hosts: pkHosts,
                      mixerStreamID: ZegoUIKitPrebuiltLiveStreamingPK
                          .instance.currentMixerStreamID,
                      constraints: centralConstraints,
                    ),
                    ConstrainedBox(
                      constraints: centralConstraints,
                      child: widget.config.pkBattle.foregroundBuilder?.call(
                            context,
                            pkHosts.map((e) => e.userInfo).toList(),
                            {},
                          ) ??
                          const SizedBox.shrink(),
                    ),
                  ],
                ),
                widget.config.pkBattle.bottomBuilder?.call(
                      context,
                      pkHosts.map((e) => e.userInfo).toList(),
                      {},
                    ) ??
                    const SizedBox.shrink(),
              ],
            );
          });
        },
      ),
    );
  }

  Widget audioVideoView({
    required List<ZegoLiveStreamingPKUser> hosts,
    required String mixerStreamID,
    required BoxConstraints constraints,
  }) {
    return ValueListenableBuilder<ZegoLiveStreamingPKBattleState>(
      valueListenable:
          ZegoUIKitPrebuiltLiveStreamingPK.instance.pkStateNotifier,
      builder: (BuildContext context, pkBattleState, Widget? child) {
        if (!ZegoUIKitPrebuiltLiveStreamingPK.instance.isInPK) {
          return const SizedBox.shrink();
        } else {
          return ConstrainedBox(
            constraints: constraints,
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

                return view;
                // return AspectRatio(
                //   aspectRatio:
                //       zegoPK2MixerCanvasWidth / zegoPK2MixerCanvasHeight,
                //   child: view,
                // );
              },
            ),
          );
        }
      },
    );
  }
}
