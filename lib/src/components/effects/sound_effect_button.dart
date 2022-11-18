// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'sound_effect_sheet.dart';

class ZegoSoundEffectButton extends StatefulWidget {
  final List<VoiceChangerType> voiceChangeEffect;
  final List<ReverbType> reverbEffect;

  final Size? iconSize;
  final Size? buttonSize;
  final ButtonIcon? icon;

  const ZegoSoundEffectButton({
    Key? key,
    required this.voiceChangeEffect,
    required this.reverbEffect,
    this.iconSize,
    this.buttonSize,
    this.icon,
  }) : super(key: key);

  @override
  State<ZegoSoundEffectButton> createState() => _ZegoSoundEffectButtonState();
}

class _ZegoSoundEffectButtonState extends State<ZegoSoundEffectButton> {
  var voiceChangerSelectedIDNotifier = ValueNotifier<String>("");
  var reverbSelectedIDNotifier = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    Size containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    Size sizeBoxSize = widget.iconSize ?? Size(56.r, 56.r);
    return GestureDetector(
      onTap: () async {
        showSoundEffectSheet(
          context,
          voiceChangeEffect: widget.voiceChangeEffect,
          voiceChangerSelectedIDNotifier: voiceChangerSelectedIDNotifier,
          reverbEffect: widget.reverbEffect,
          reverbSelectedIDNotifier: reverbSelectedIDNotifier,
        );
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ?? Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: widget.icon?.icon ??
              PrebuiltLiveStreamingImage.asset(
                  PrebuiltLiveStreamingIconUrls.toolbarSoundEffect),
        ),
      ),
    );
  }
}
