// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/beauty_effect_sheet.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

/// @nodoc
class ZegoLiveStreamingBeautyEffectButton extends StatefulWidget {
  const ZegoLiveStreamingBeautyEffectButton({
    Key? key,
    required this.effectConfig,
    required this.translationText,
    required this.rootNavigator,
    this.icon,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  final Size? iconSize;
  final Size? buttonSize;
  final ButtonIcon? icon;
  final ZegoUIKitPrebuiltLiveStreamingInnerText translationText;
  final bool rootNavigator;
  final ZegoLiveStreamingEffectConfig effectConfig;

  @override
  State<ZegoLiveStreamingBeautyEffectButton> createState() =>
      _ZegoLiveStreamingBeautyEffectButtonState();
}

/// @nodoc
class _ZegoLiveStreamingBeautyEffectButtonState
    extends State<ZegoLiveStreamingBeautyEffectButton> {
  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);
    return GestureDetector(
      onTap: () async {
        if (ZegoUIKit.instance.getPlugin(ZegoUIKitPluginType.beauty) != null) {
          ZegoUIKit.instance.getBeautyPlugin().showBeautyUI(context);
        } else {
          showBeautyEffectSheet(
            context,
            translationText: widget.translationText,
            rootNavigator: widget.rootNavigator,
            beautyEffects: widget.effectConfig.beautyEffects,
            config: widget.effectConfig,
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
              ZegoLiveStreamingImage.asset(
                ZegoLiveStreamingIconUrls.toolbarBeautyEffect,
              ),
        ),
      ),
    );
  }
}
