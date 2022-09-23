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

class _ZegoBeautyEffectSheetState extends State<ZegoBeautyEffectSheet> {
  late ZegoEffectGridModel beauty;
  var selectedEffectTypeNotifier =
      ValueNotifier<BeautyEffectType>(BeautyEffectType.none);

  @override
  void initState() {
    super.initState();

    List<BeautyEffectType> beautyEffects = List.from(widget.beautyEffects);
    beautyEffects.removeWhere((effect) => effect == BeautyEffectType.none);
    beauty = ZegoEffectGridModel(
      title: "",
      defaultSelectedIndex: -1,
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
    return LayoutBuilder(builder: ((context, constraints) {
      return Column(
        children: [
          ValueListenableBuilder<BeautyEffectType>(
            valueListenable: selectedEffectTypeNotifier,
            builder: (context, effectType, child) {
              if (BeautyEffectType.none == effectType) {
                return Container(height: 32.h + 43.r);
              }

              return Column(
                children: [
                  slider(height: 32.h),
                  BeautyEffectType.none == selectedEffectTypeNotifier.value
                      ? Container()
                      : SizedBox(height: 43.r),
                ],
              );
            },
          ),
          sheet(
            height: constraints.maxHeight - (32.h + 43.r),
            child: Column(
              children: [
                header(),
                Container(height: 1.r, color: Colors.white),
                SizedBox(height: 36.r),
                ZegoEffectGrid(
                  model: beauty,
                  isSpaceEvenly: true,
                  withBorderColor: true,
                  buttonSize: Size(150.r, 133.r),
                ),
              ],
            ),
          )
        ],
      );
    }));
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
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xff242736).withOpacity(0.95),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0.r),
          topRight: Radius.circular(32.0.r),
        ),
      ),
      child: child,
    );
  }

  Widget header() {
    return SizedBox(
      height: 98.h,
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
            "Beauty Effect",
            style: TextStyle(
              fontSize: 36.0.r,
              color: const Color(0xffffffff),
              decoration: TextDecoration.none,
            ),
          ),
          Expanded(child: Container()),
          ZegoBeautyEffectResetButton(
            buttonSize: Size(98.h, 98.h),
            iconSize: Size(38.r, 38.r),
            onPressed: () {
              beauty.clearSelected();

              selectedEffectTypeNotifier.value = BeautyEffectType.none;

              setState(() {}); //  todo
            },
          ),
        ],
      ),
    );
  }
}

void showBeautyEffectSheet(BuildContext context,
    {required List<BeautyEffectType> beautyEffects}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.6,
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: ZegoBeautyEffectSheet(beautyEffects: beautyEffects),
        ),
      );
    },
  );
}
