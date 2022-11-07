// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoAvatar extends StatelessWidget {
  final Size avatarSize;
  final ZegoUIKitUser? user;
  final bool showAvatar;
  final bool showSoundLevel;
  final ZegoAvatarBuilder? avatarBuilder;
  final Size? soundLevelSize;

  const ZegoAvatar({
    Key? key,
    required this.avatarSize,
    this.user,
    this.showAvatar = true,
    this.showSoundLevel = false,
    this.avatarBuilder,
    this.soundLevelSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showAvatar || user == null) {
      return Container(color: Colors.transparent);
    }

    var centralAvatar = avatarBuilder?.call(context, avatarSize, user, {}) ??
        circleName(context, avatarSize, user);

    return Center(
      child: SizedBox.fromSize(
        size: showSoundLevel ? soundLevelSize : avatarSize,
        child: showSoundLevel
            ? ZegoRippleAvatar(
                minRadius: math.min(avatarSize.width, avatarSize.height) / 2,
                radiusIncrement: 0.06,
                soundLevelStream:
                    ZegoUIKit().getSoundLevelStream(user?.id ?? ""),
                child: centralAvatar,
              )
            : centralAvatar,
      ),
    );
  }

  Widget circleName(BuildContext context, Size size, ZegoUIKitUser? user) {
    var userName = user?.name ?? "";
    return SizedBox.fromSize(
      size: size,
      child: Container(
        decoration: const BoxDecoration(
            color: Color(0xffDBDDE3), shape: BoxShape.circle),
        child: Center(
          child: Text(
            userName.isNotEmpty ? userName.characters.first : "",
            style: TextStyle(
              fontSize: showSoundLevel ? size.width / 4 : size.width / 5 * 4,
              color: const Color(0xff222222),
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
