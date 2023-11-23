// Dart imports:
import 'dart:async';
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/src/pk_impl.dart';

/// @nodoc
class ZegoLiveStreamingPKBattleView extends StatefulWidget {
  const ZegoLiveStreamingPKBattleView({
    required this.constraints,
    required this.config,
    required this.foregroundBuilder,
    required this.backgroundBuilder,
    required this.avatarConfig,
    this.withAspectRatio = true,
    Key? key,
  }) : super(key: key);

  final BoxConstraints constraints;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;
  final ZegoAvatarConfig? avatarConfig;

  final bool withAspectRatio;

  @override
  State<ZegoLiveStreamingPKBattleView> createState() =>
      _ZegoLiveStreamingPKBattleViewState();
}

/// @nodoc
class _ZegoLiveStreamingPKBattleViewState
    extends State<ZegoLiveStreamingPKBattleView> {
  List<StreamSubscription<dynamic>> subscriptions = [];

  Timer? heartBeatTimer;
  Map<String, DateTime> heartBeatMap = {};

  final pkManager = ZegoLiveStreamingPKBattleManager();

  ValueNotifier<bool> leftUserHeartBeatBrokenNotifier =
      ValueNotifier<bool>(false);
  ValueNotifier<bool> rightUserHeartBeatBrokenNotifier =
      ValueNotifier<bool>(false);

  ZegoUIKitUser? get leftUser => pkManager.isHost
      ? ZegoUIKit().getLocalUser()
      : pkManager.hostManager.notifier.value;

  ZegoUIKitUser? get rightUser => pkManager.anotherHost;

  List<ZegoUIKitUser?> get hosts => [leftUser, rightUser];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: widget.constraints,
      child: Column(
        children: [
          widget.config.pkBattleConfig.pkBattleViewTopBuilder
                  ?.call(context, hosts, {}) ??
              const SizedBox.shrink(),
          Stack(
            children: [
              hostsView(),
              widget.config.pkBattleConfig.pkBattleViewForegroundBuilder
                      ?.call(context, hosts, {}) ??
                  const SizedBox.shrink(),
            ],
          ),
          widget.config.pkBattleConfig.pkBattleViewBottomBuilder
                  ?.call(context, hosts, {}) ??
              const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget hostsView() {
    return ValueListenableBuilder(
      valueListenable: pkManager.state,
      builder: (BuildContext context,
          ZegoLiveStreamingPKBattleState pkBattleState, Widget? child) {
        if (pkBattleState != ZegoLiveStreamingPKBattleState.inPKBattle) {
          return const SizedBox.shrink();
        } else {
          final audioVideoViews = SizedBox(
            width: widget.constraints.maxWidth,
            height: widget.constraints.maxHeight,
            child: Builder(builder: (context) {
              if (pkManager.isHost) {
                return Row(children: [
                  Expanded(
                    child: ZegoAudioVideoView(
                      user: ZegoUIKit().getLocalUser(),
                      foregroundBuilder:
                          widget.config.audioVideoViewConfig.foregroundBuilder,
                      backgroundBuilder:
                          widget.config.audioVideoViewConfig.backgroundBuilder,
                      avatarConfig: widget.avatarConfig ??
                          ZegoAvatarConfig(
                            showInAudioMode: widget.config.audioVideoViewConfig
                                .showAvatarInAudioMode,
                            showSoundWavesInAudioMode: widget.config
                                .audioVideoViewConfig.showSoundWavesInAudioMode,
                            builder: widget.config.avatarBuilder,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Builder(builder: (context) {
                      return ValueListenableBuilder(
                        valueListenable: rightUserHeartBeatBrokenNotifier,
                        builder: (context, bool heartBeatBroken, _) {
                          if (heartBeatBroken) {
                            return hostReconnecting(left: false);
                          } else {
                            return ZegoAudioVideoView(
                              user: pkManager.anotherHost,
                              foregroundBuilder: widget.config
                                  .audioVideoViewConfig.foregroundBuilder,
                              backgroundBuilder: widget.config
                                  .audioVideoViewConfig.backgroundBuilder,
                              avatarConfig: widget.avatarConfig ??
                                  ZegoAvatarConfig(
                                    showInAudioMode: widget
                                        .config
                                        .audioVideoViewConfig
                                        .showAvatarInAudioMode,
                                    showSoundWavesInAudioMode: widget
                                        .config
                                        .audioVideoViewConfig
                                        .showSoundWavesInAudioMode,
                                    builder: widget.config.avatarBuilder,
                                  ),
                            );
                          }
                        },
                      );
                    }),
                  ),
                ]);
              } else {
                return audienceView();
              }
            }),
          );

          return ConstrainedBox(
            constraints: widget.constraints,
            child: widget.withAspectRatio
                ? AspectRatio(
                    aspectRatio: 16.0 / 18.0,
                    child: audioVideoViews,
                  )
                : audioVideoViews,
          );
        }
      },
    );
  }

  Widget hostReconnecting({required bool left}) {
    return widget.config.pkBattleConfig.hostReconnectingBuilder != null
        ? widget.config.pkBattleConfig.hostReconnectingBuilder!.call(
            context,
            left ? leftUser : rightUser,
            {},
          )
        : Container(
            color: Colors.black,
            child: Center(
              child: Text(
                'Host is reconnecting…',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.zSP,
                ),
              ),
            ),
          );
  }

  Widget audienceView() {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(child: background(left: true)),
            Expanded(child: background(left: false)),
          ],
        ),
        videoView(),
        Row(
          children: [
            Expanded(child: foreground(left: true)),
            Expanded(child: foreground(left: false)),
          ],
        ),
      ],
    );
  }

  Widget videoView() {
    return ValueListenableBuilder(
        valueListenable: pkManager.hostManager.notifier,
        builder: (context, ZegoUIKitUser? leftuser, _) {
          final mixerID = pkManager.streamCreator!.mixerID;

          return ValueListenableBuilder(
              valueListenable: ZegoUIKit().getMixAudioVideoCameraStateNotifier(
                  mixerID, leftuser?.id ?? ''),
              builder: (context, bool leftuserCameraOn, _) {
                return ValueListenableBuilder(
                  valueListenable: ZegoUIKit()
                      .getMixAudioVideoCameraStateNotifier(
                          mixerID, rightUser?.id ?? ''),
                  builder: (context, bool rightUserCameraOn, _) {
                    return ValueListenableBuilder(
                      valueListenable: ZegoUIKit().getMixAudioVideoViewNotifier(
                        pkManager.streamCreator!.mixerID,
                      ),
                      builder: (context, Widget? mixView, _) {
                        if (mixView == null) return const SizedBox.shrink();
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black
                                    .withOpacity(leftuserCameraOn ? 1 : 0),
                                Colors.black
                                    .withOpacity(leftuserCameraOn ? 1 : 0),
                                Colors.black
                                    .withOpacity(rightUserCameraOn ? 1 : 0),
                                Colors.black
                                    .withOpacity(rightUserCameraOn ? 1 : 0),
                              ],
                              stops: const [0, 0.5, 0.5, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: mixView,
                        );
                      },
                    );
                  },
                );
              });
        });
  }

  Widget background({required bool left}) {
    final user = left ? leftUser : rightUser;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: ZegoUIKitUserPropertiesNotifier(
                  user ?? ZegoUIKitUser.empty()),
              builder: (context, _, __) {
                return widget.config.audioVideoViewConfig.backgroundBuilder
                        ?.call(
                      context,
                      Size(constraints.maxWidth, constraints.maxHeight),
                      user,
                      {},
                    ) ??
                    Container(color: Colors.transparent);
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    avatar(user, constraints.maxWidth, constraints.maxHeight)
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget foreground({required bool left}) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: left
              ? leftUserHeartBeatBrokenNotifier
              : rightUserHeartBeatBrokenNotifier,
          builder: (context, bool heartBeatBroken, _) {
            if (heartBeatBroken) {
              return hostReconnecting(left: left);
            } else {
              return Container(color: Colors.transparent);
            }
          },
        ),
        if (widget.config.audioVideoViewConfig.foregroundBuilder != null)
          LayoutBuilder(
            builder: (context, constraints) {
              return ValueListenableBuilder(
                valueListenable: ZegoUIKitUserPropertiesNotifier(
                  (left ? leftUser : rightUser) ?? ZegoUIKitUser.empty(),
                ),
                builder: (context, _, __) {
                  return widget.config.audioVideoViewConfig.foregroundBuilder!
                      .call(
                    context,
                    Size(constraints.maxWidth, constraints.maxHeight),
                    left ? leftUser : rightUser,
                    {},
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget avatar(ZegoUIKitUser? user, double maxWidth, double maxHeight) {
    final avatarConfig = widget.avatarConfig ??
        ZegoAvatarConfig(
          showInAudioMode:
              widget.config.audioVideoViewConfig.showAvatarInAudioMode,
          showSoundWavesInAudioMode:
              widget.config.audioVideoViewConfig.showSoundWavesInAudioMode,
          builder: widget.config.avatarBuilder,
        );

    final screenSize = MediaQuery.of(context).size;
    final isSmallView = maxHeight < screenSize.height / 2;
    final avatarSize =
        isSmallView ? Size(110.zR, 110.zR) : Size(258.zR, 258.zR);

    return Positioned(
      top: (maxHeight - avatarSize.height) / 2,
      left: (maxWidth - avatarSize.width) / 2,
      child: SizedBox(
        width: avatarConfig.size?.width ?? avatarSize.width,
        height: avatarConfig.size?.height ?? avatarSize.width,
        child: ZegoAvatar(
          avatarSize: avatarConfig.size ?? avatarSize,
          user: user,
          showAvatar: avatarConfig.showInAudioMode ?? true,
          showSoundLevel: avatarConfig.showSoundWavesInAudioMode ?? true,
          avatarBuilder: avatarConfig.builder,
          soundLevelSize: avatarConfig.size,
          soundLevelColor: avatarConfig.soundWaveColor,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    subscriptions.addAll([
      ZegoUIKit().getReceiveSEIStream().where((event) {
        return event.typeIdentifier ==
            ZegoUIKitInnerSEIType.mixerDeviceState.name;
      }).listen(onReceiveSEIEvent),
    ]);

    if (!pkManager.isHost && leftUser != null) {
      heartBeatMap[leftUser!.id] = DateTime.now();
    }
    heartBeatMap[rightUser!.id] = DateTime.now();

    heartBeatTimer =
        Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (!mounted) return;
      final now = DateTime.now();
      final needDeleteIDs = <String>[];
      heartBeatMap.forEach((id, timestamp) {
        if (now.difference(timestamp).inSeconds > 5) {
          if (id == (leftUser?.id ?? '')) {
            leftUserHeartBeatBrokenNotifier.value = true;
          } else if (id == (rightUser?.id ?? '')) {
            rightUserHeartBeatBrokenNotifier.value = true;
          }
          needDeleteIDs.add(id);
        }
      });

      needDeleteIDs.forEach(heartBeatMap.remove);
    });
  }

  void onReceiveSEIEvent(ZegoUIKitReceiveSEIEvent event) {
    heartBeatMap[event.senderID] = DateTime.now();
    if (event.senderID == (leftUser?.id ?? '')) {
      leftUserHeartBeatBrokenNotifier.value = false;
    } else if (event.senderID == (rightUser?.id ?? '')) {
      rightUserHeartBeatBrokenNotifier.value = false;
    }
  }

  @override
  void dispose() {
    heartBeatTimer?.cancel();
    for (final sub in subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
