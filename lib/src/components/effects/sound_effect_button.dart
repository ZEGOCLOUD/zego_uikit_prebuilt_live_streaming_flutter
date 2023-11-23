// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/sound_effect_sheet.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

/// @nodoc
class ZegoSoundEffectButton extends StatefulWidget {
  final List<VoiceChangerType> voiceChangeEffect;
  final List<ReverbType> reverbEffect;

  final Size? iconSize;
  final Size? buttonSize;
  final ButtonIcon? icon;
  final ZegoInnerText translationText;
  final bool rootNavigator;

  final ZegoEffectConfig effectConfig;

  const ZegoSoundEffectButton({
    Key? key,
    required this.translationText,
    required this.rootNavigator,
    required this.voiceChangeEffect,
    required this.reverbEffect,
    required this.effectConfig,
    this.iconSize,
    this.buttonSize,
    this.icon,
  }) : super(key: key);

  @override
  State<ZegoSoundEffectButton> createState() => _ZegoSoundEffectButtonState();
}

/// @nodoc
class _ZegoSoundEffectButtonState extends State<ZegoSoundEffectButton> {
  var voiceChangerSelectedIDNotifier = ValueNotifier<String>('');
  var reverbSelectedIDNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);
    return GestureDetector(
      onTap: () async {
        showSoundEffectSheet(
          context,
          translationText: widget.translationText,
          rootNavigator: widget.rootNavigator,
          voiceChangeEffect: widget.voiceChangeEffect,
          voiceChangerSelectedIDNotifier: voiceChangerSelectedIDNotifier,
          reverbEffect: widget.reverbEffect,
          reverbSelectedIDNotifier: reverbSelectedIDNotifier,
          effectConfig: widget.effectConfig,
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
                PrebuiltLiveStreamingIconUrls.toolbarSoundEffect,
              ),
        ),
      ),
    );
  }
}
