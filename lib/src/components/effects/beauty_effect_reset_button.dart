// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

/// @nodoc
class ZegoBeautyEffectResetButton extends StatefulWidget {
  final ButtonIcon? icon;
  final Size? iconSize;
  final Size? buttonSize;
  final VoidCallback? onPressed;

  const ZegoBeautyEffectResetButton({
    Key? key,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.onPressed,
  }) : super(key: key);

  @override
  State<ZegoBeautyEffectResetButton> createState() =>
      _ZegoBeautyEffectResetButtonState();
}

/// @nodoc
class _ZegoBeautyEffectResetButtonState
    extends State<ZegoBeautyEffectResetButton> {
  @override
  Widget build(BuildContext context) {
    return ZegoTextIconButton(
      onPressed: () {
        ZegoUIKit().resetBeautyEffect();

        widget.onPressed?.call();
      },
      icon: ButtonIcon(
        icon: widget.icon?.icon ??
            PrebuiltLiveStreamingImage.asset(
              PrebuiltLiveStreamingIconUrls.effectReset,
            ),
        backgroundColor: widget.icon?.backgroundColor,
      ),
      iconSize: widget.iconSize ?? Size(38.zR, 38.zR),
      buttonSize: widget.buttonSize ?? Size(40.zR, 40.zR),
    );
  }
}
