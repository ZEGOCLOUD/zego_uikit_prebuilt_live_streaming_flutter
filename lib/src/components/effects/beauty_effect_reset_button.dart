// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

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
        icon: PrebuiltLiveStreamingImage.asset(
            PrebuiltLiveStreamingIconUrls.effectReset),
      ),
      iconSize: widget.iconSize ?? Size(38.r, 38.r),
      buttonSize: widget.buttonSize ?? Size(40.r, 40.r),
    );
  }
}
