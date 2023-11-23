// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/beauty_effect_reset_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/effect_grid.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

/// @nodoc
class ZegoBeautyEffectSheet extends StatefulWidget {
  final ZegoInnerText translationText;
  final bool rootNavigator;
  final List<BeautyEffectType> beautyEffects;
  final ZegoEffectConfig effectConfig;

  const ZegoBeautyEffectSheet({
    Key? key,
    required this.translationText,
    required this.rootNavigator,
    required this.beautyEffects,
    required this.effectConfig,
  }) : super(key: key);

  @override
  State<ZegoBeautyEffectSheet> createState() => _ZegoBeautyEffectSheetState();
}

/// @nodoc
double get _besHeaderHeight => 98.zR;

/// @nodoc
double get _besSliderHeight => 32.zR;

/// @nodoc
double get _besSliderPadding => 43.zR;

/// @nodoc
double get _besSheetTotalHeight => 317.zR;

/// @nodoc
double get _besLineToSheetPadding => 36.zR;

/// @nodoc
double get _besLineHeight => 1.zR;

/// @nodoc
class _ZegoBeautyEffectSheetState extends State<ZegoBeautyEffectSheet> {
  late ZegoEffectGridModel beauty;
  var selectedIDNotifier = ValueNotifier<String>('');
  var selectedEffectTypeNotifier =
      ValueNotifier<BeautyEffectType>(BeautyEffectType.none);

  String faceBeautyIconPath(String name) =>
      'assets/icons/face_beauty_$name.png';

  @override
  void initState() {
    super.initState();

    final beautyEffects = List<BeautyEffectType>.from(widget.beautyEffects)
      ..removeWhere((effect) => effect == BeautyEffectType.none);
    beauty = ZegoEffectGridModel(
      title: '',
      selectedID: selectedIDNotifier,
      items: beautyEffects
          .map(
            (effect) => ZegoEffectGridItem<BeautyEffectType>(
              id: effect.index.toString(),
              effectType: effect,
              icon: ButtonIcon(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    widget.effectConfig.normalIconColor ??
                        const Color(0xffCCCCCC),
                    BlendMode.srcATop,
                  ),
                  child: PrebuiltLiveStreamingImage.asset(
                    faceBeautyIconPath(effect.name),
                  ),
                ),
              ),
              selectIcon: ButtonIcon(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    widget.effectConfig.selectedIconColor ??
                        const Color(0xffA653FF),
                    BlendMode.srcATop,
                  ),
                  child: PrebuiltLiveStreamingImage.asset(
                    faceBeautyIconPath(effect.name),
                  ),
                ),
              ),
              iconText: beautyEffectTypeText(effect),
              onPressed: () {
                selectedEffectTypeNotifier.value = effect;
              },
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<BeautyEffectType>(
          valueListenable: selectedEffectTypeNotifier,
          builder: (context, effectType, child) {
            if (BeautyEffectType.none == effectType) {
              return Container(height: _besSliderHeight + _besSliderPadding);
            }

            return Column(
              children: [
                slider(height: _besSliderHeight),
                if (BeautyEffectType.none == selectedEffectTypeNotifier.value)
                  Container()
                else
                  SizedBox(height: _besSliderPadding),
              ],
            );
          },
        ),
        sheet(
          height: _besSheetTotalHeight,
          child: Column(
            children: [
              header(height: _besHeaderHeight),
              Container(height: _besLineHeight, color: Colors.white),
              SizedBox(height: _besLineToSheetPadding),
              SizedBox(
                height: _besSheetTotalHeight -
                    _besHeaderHeight -
                    _besLineHeight -
                    _besLineToSheetPadding -
                    (2 * 5.zR),
                child: ListView(
                  children: [
                    ZegoEffectGrid(
                      model: beauty,
                      isSpaceEvenly: true,
                      withBorderColor: true,
                      buttonSize: Size(150.zR, 133.zR),
                      selectedIconBorderColor:
                          widget.effectConfig.selectedIconBorderColor,
                      normalIconBorderColor:
                          widget.effectConfig.normalIconBorderColor,
                      selectedTextStyle: widget.effectConfig.selectedTextStyle,
                      normalTextStyle: widget.effectConfig.normalTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget slider({required double height}) {
    var selectedEffectValue = 50;
    final beautyParam = ZegoUIKit().getBeautyValue();
    switch (selectedEffectTypeNotifier.value) {
      case BeautyEffectType.whiten:
        selectedEffectValue = beautyParam.whitenIntensity;
        break;
      case BeautyEffectType.rosy:
        selectedEffectValue = beautyParam.rosyIntensity;
        break;
      case BeautyEffectType.smooth:
        selectedEffectValue = beautyParam.smoothIntensity;
        break;
      case BeautyEffectType.sharpen:
        selectedEffectValue = beautyParam.sharpenIntensity;
        break;
      case BeautyEffectType.none:
        break;
    }

    return ZegoBeautyEffectSlider(
      effectType: selectedEffectTypeNotifier.value,
      thumpHeight: height,
      defaultValue: selectedEffectValue,
      textStyle: widget.effectConfig.sliderTextStyle,
      textBackgroundColor: widget.effectConfig.sliderTextBackgroundColor,
      activeTrackColor: widget.effectConfig.sliderActiveTrackColor,
      inactiveTrackColor: widget.effectConfig.sliderInactiveTrackColor,
      thumbColor: widget.effectConfig.sliderThumbColor,
      thumbRadius: widget.effectConfig.sliderThumbRadius,
    );
  }

  Widget sheet({required Widget child, required double height}) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(vertical: 5.zR, horizontal: 10.zR),
      decoration: BoxDecoration(
        color: widget.effectConfig.backgroundColor ??
            ZegoUIKitDefaultTheme.viewBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0.zR),
          topRight: Radius.circular(32.0.zR),
        ),
      ),
      child: child,
    );
  }

  Widget header({required double height}) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: widget.rootNavigator,
              ).pop();
            },
            child: SizedBox(
              width: 70.zR,
              height: 70.zR,
              child: widget.effectConfig.backIcon ??
                  PrebuiltLiveStreamingImage.asset(
                    PrebuiltLiveStreamingIconUrls.back,
                  ),
            ),
          ),
          SizedBox(width: 10.zR),
          Text(
            widget.translationText.beautyEffectTitle,
            style: widget.effectConfig.headerTitleTextStyle ??
                TextStyle(
                  fontSize: 36.0.zR,
                  color: const Color(0xffffffff),
                  decoration: TextDecoration.none,
                ),
          ),
          Expanded(child: Container()),
          ZegoBeautyEffectResetButton(
            icon: ButtonIcon(icon: widget.effectConfig.resetIcon),
            iconSize: Size(38.zR, 38.zR),
            buttonSize: Size(_besHeaderHeight, _besHeaderHeight),
            onPressed: () {
              beauty.selectedID.value = '';

              selectedEffectTypeNotifier.value = BeautyEffectType.none;

              setState(() {}); //  todo
            },
          ),
        ],
      ),
    );
  }

  String beautyEffectTypeText(BeautyEffectType effectType) {
    switch (effectType) {
      case BeautyEffectType.whiten:
        return widget.translationText.beautyEffectTypeWhitenTitle;
      case BeautyEffectType.rosy:
        return widget.translationText.beautyEffectTypeRosyTitle;
      case BeautyEffectType.smooth:
        return widget.translationText.beautyEffectTypeSmoothTitle;
      case BeautyEffectType.sharpen:
        return widget.translationText.beautyEffectTypeSharpenTitle;
      case BeautyEffectType.none:
        return widget.translationText.beautyEffectTypeNoneTitle;
    }
  }
}

/// @nodoc
void showBeautyEffectSheet(
  BuildContext context, {
  required ZegoInnerText translationText,
  required bool rootNavigator,
  required ZegoEffectConfig effectConfig,
  required List<BeautyEffectType> beautyEffects,
}) {
  showModalBottomSheet(
    context: context,
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    useRootNavigator: rootNavigator,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 50),
        child: SizedBox(
          height: _besSheetTotalHeight + (_besSliderHeight + _besSliderPadding),
          child: ZegoBeautyEffectSheet(
            translationText: translationText,
            rootNavigator: rootNavigator,
            beautyEffects: beautyEffects,
            effectConfig: effectConfig,
          ),
        ),
      );
    },
  );
}
