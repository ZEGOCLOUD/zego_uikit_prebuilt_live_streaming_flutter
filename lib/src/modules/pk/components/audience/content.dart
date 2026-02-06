// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

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
