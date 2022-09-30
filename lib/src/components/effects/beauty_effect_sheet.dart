// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'beauty_effect_reset_button.dart';
import 'effect_grid.dart';

class ZegoBeautyEffectSheet extends StatefulWidget {
  final List<BeautyEffectType> beautyEffects;

  const ZegoBeautyEffectSheet({
    Key? key,
    required this.beautyEffects,
  }) : super(key: key);

  @override
  State<ZegoBeautyEffectSheet> createState() => _ZegoBeautyEffectSheetState();
}

get _besHeaderHeight => 98.r;
get _besSliderHeight => 32.r;
get _besSliderPadding => 43.r;
get _besSheetTotalHeight => 317.r;
get _besLineToSheetPadding => 36.r;
get _besLineHeight => 1.r;

class _ZegoBeautyEffectSheetState extends State<ZegoBeautyEffectSheet> {
  late ZegoEffectGridModel beauty;
  var selectedIDNotifier = ValueNotifier<String>("");
  var selectedEffectTypeNotifier =
      ValueNotifier<BeautyEffectType>(BeautyEffectType.none);

  @override
  void initState() {
    super.initState();

    List<BeautyEffectType> beautyEffects = List.from(widget.beautyEffects);
    beautyEffects.removeWhere((effect) => effect == BeautyEffectType.none);
    beauty = ZegoEffectGridModel(
      title: "",
      selectedID: selectedIDNotifier,
      items: beautyEffects
          .map(
            (effect) => ZegoEffectGridItem<BeautyEffectType>(
              id: effect.index.toString(),
              effectType: effect,
              icon: ButtonIcon(
                icon: PrebuiltLiveStreamingImage.asset(
                    "assets/icons/face_beauty_" + effect.name + ".png"),
              ),
              iconText: effect.text,
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
                BeautyEffectType.none == selectedEffectTypeNotifier.value
                    ? Container()
                    : SizedBox(height: _besSliderPadding),
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
                    (2 * 5.r),
                child: ListView(
                  children: [
                    ZegoEffectGrid(
                      model: beauty,
                      isSpaceEvenly: true,
                      withBorderColor: true,
                      buttonSize: Size(150.r, 133.r),
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
    var beautyParam = ZegoUIKit().getBeautyValue();
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
    );
  }

  Widget sheet({required Widget child, required double height}) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(vertical: 5.r, horizontal: 10.r),
      decoration: BoxDecoration(
        color: ZegoUIKitDefaultTheme.viewBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0.r),
          topRight: Radius.circular(32.0.r),
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
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 70.r,
              height: 70.r,
              child: PrebuiltLiveStreamingImage.asset(
                  PrebuiltLiveStreamingIconUrls.back),
            ),
          ),
          SizedBox(width: 10.r),
          Text(
            "Face beautification",
            style: TextStyle(
              fontSize: 36.0.r,
              color: const Color(0xffffffff),
              decoration: TextDecoration.none,
            ),
          ),
          Expanded(child: Container()),
          ZegoBeautyEffectResetButton(
            buttonSize: Size(_besHeaderHeight, _besHeaderHeight),
            iconSize: Size(38.r, 38.r),
            onPressed: () {
              beauty.selectedID.value = "";

              selectedEffectTypeNotifier.value = BeautyEffectType.none;

              setState(() {}); //  todo
            },
          ),
        ],
      ),
    );
  }
}

void showBeautyEffectSheet(
  BuildContext context, {
  required List<BeautyEffectType> beautyEffects,
}) {
  showModalBottomSheet(
    context: context,
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 50),
        child: SizedBox(
          height: _besSheetTotalHeight + (_besSliderHeight + _besSliderPadding),
          child: ZegoBeautyEffectSheet(beautyEffects: beautyEffects),
        ),
      );
    },
  );
}
