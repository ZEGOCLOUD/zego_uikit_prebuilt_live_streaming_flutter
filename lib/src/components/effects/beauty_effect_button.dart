// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil_zego/flutter_screenutil_zego.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/beauty_effect_sheet.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class ZegoBeautyEffectButton extends StatefulWidget {
  const ZegoBeautyEffectButton({
    Key? key,
    required this.beautyEffects,
    required this.translationText,
    required this.rootNavigator,
    this.iconSize,
    this.buttonSize,
    this.icon,
  }) : super(key: key);

  final Size? iconSize;
  final Size? buttonSize;
  final ButtonIcon? icon;
  final List<BeautyEffectType> beautyEffects;
  final ZegoTranslationText translationText;
  final bool rootNavigator;

  @override
  State<ZegoBeautyEffectButton> createState() => _ZegoBeautyEffectButtonState();
}

class _ZegoBeautyEffectButtonState extends State<ZegoBeautyEffectButton> {
  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    final sizeBoxSize = widget.iconSize ?? Size(56.r, 56.r);
    return GestureDetector(
      onTap: () async {
        if (ZegoUIKit.instance.getPlugin(ZegoUIKitPluginType.beauty) != null) {
          ZegoUIKit.instance.getBeautyPlugin().showBeautyUI(context);
        } else {
          showBeautyEffectSheet(
            context,
            translationText: widget.translationText,
            rootNavigator: widget.rootNavigator,
            beautyEffects: widget.beautyEffects,
          );
        }
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
                  PrebuiltLiveStreamingIconUrls.toolbarBeautyEffect),
        ),
      ),
    );
  }
}
