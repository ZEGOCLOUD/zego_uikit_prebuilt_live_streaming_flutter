// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'effect_grid.dart';

class ZegoSoundEffectSheet extends StatefulWidget {
  final List<VoiceChangerType> voiceChangerEffect;
  final ValueNotifier<String> voiceChangerSelectedIDNotifier;

  final List<ReverbType> reverbEffect;
  final ValueNotifier<String> reverbSelectedIDNotifier;

  const ZegoSoundEffectSheet({
    Key? key,
    required this.voiceChangerEffect,
    required this.voiceChangerSelectedIDNotifier,
    required this.reverbEffect,
    required this.reverbSelectedIDNotifier,
  }) : super(key: key);

  @override
  State<ZegoSoundEffectSheet> createState() => _ZegoSoundEffectSheetState();
}

class _ZegoSoundEffectSheetState extends State<ZegoSoundEffectSheet> {
  late ZegoEffectGridModel voiceChangerModel;
  late ZegoEffectGridModel reverbPresetModel;

  @override
  void initState() {
    super.initState();

    initVoiceChangerData();
    initReverbData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header(98.r),
        Container(height: 1.r, color: Colors.white.withOpacity(0.15)),
        SizedBox(height: 36.r),
        SizedBox(
          height: 600.r - 98.r - 36.r - 1.r,
          child: ListView(
            children: [
              ZegoEffectGrid(
                model: voiceChangerModel,
                isSpaceEvenly: false,
              ),
              SizedBox(height: 36.r),
              ZegoEffectGrid(
                model: reverbPresetModel,
                isSpaceEvenly: false,
                withBorderColor: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget header(double height) {
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
            "Audio effect",
            style: TextStyle(
              fontSize: 36.0.r,
              color: const Color(0xffffffff),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  void initVoiceChangerData() {
    List<VoiceChangerType> voiceChangerEffect =
        List.from(widget.voiceChangerEffect);
    voiceChangerEffect.removeWhere((effect) => effect == VoiceChangerType.none);
    voiceChangerEffect.insert(0, VoiceChangerType.none);
    if (widget.voiceChangerSelectedIDNotifier.value.isEmpty) {
      widget.voiceChangerSelectedIDNotifier.value =
          voiceChangerEffect.first.index.toString();
    }

    voiceChangerModel = ZegoEffectGridModel(
      title: "Voice changing",
      selectedID: widget.voiceChangerSelectedIDNotifier,
      items: voiceChangerEffect
          .map(
            (effect) => ZegoEffectGridItem<VoiceChangerType>(
              id: effect.index.toString(),
              effectType: effect,
              icon: ButtonIcon(
                icon: PrebuiltLiveStreamingImage.asset(
                    "assets/icons/voice_changer_" + effect.name + ".png"),
              ),
              selectIcon: ButtonIcon(
                icon: PrebuiltLiveStreamingImage.asset(
                    "assets/icons/voice_changer_" +
                        effect.name +
                        "_selected.png"),
              ),
              iconText: effect.text,
              onPressed: () {
                ZegoUIKit().setVoiceChangerType(effect.key);
              },
            ),
          )
          .toList(),
    );
    for (var item in voiceChangerModel.items) {
      item.icon.backgroundColor = const Color(0xff3b3a3d);
      item.selectIcon?.backgroundColor = const Color(0xff3b3a3d);
    }
  }

  void initReverbData() {
    List<ReverbType> reverbEffect = List.from(widget.reverbEffect);
    reverbEffect.removeWhere((effect) => effect == ReverbType.none);
    reverbEffect.insert(0, ReverbType.none);
    if (widget.reverbSelectedIDNotifier.value.isEmpty) {
      widget.reverbSelectedIDNotifier.value =
          reverbEffect.first.index.toString();
    }

    reverbPresetModel = ZegoEffectGridModel(
      title: "Reverb",
      selectedID: widget.reverbSelectedIDNotifier,
      items: reverbEffect
          .map(
            (effect) => ZegoEffectGridItem<ReverbType>(
              id: effect.index.toString(),
              effectType: effect,
              icon: ButtonIcon(
                icon: PrebuiltLiveStreamingImage.asset(
                    "assets/icons/reverb_preset_" + effect.name + ".png"),
              ),
              iconText: effect.text,
              onPressed: () {
                ZegoUIKit().setReverbType(effect.key);
              },
            ),
          )
          .toList(),
    );
  }
}

void showSoundEffectSheet(
  BuildContext context, {
  required List<VoiceChangerType> voiceChangeEffect,
  required List<ReverbType> reverbEffect,
  required ValueNotifier<String> voiceChangerSelectedIDNotifier,
  required ValueNotifier<String> reverbSelectedIDNotifier,
}) {
  showModalBottomSheet(
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    backgroundColor: ZegoUIKitDefaultTheme.viewBackgroundColor,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0),
        topRight: Radius.circular(32.0),
      ),
    ),
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 50),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: SizedBox(
            height: 600.r,
            child: ZegoSoundEffectSheet(
              voiceChangerEffect: voiceChangeEffect,
              voiceChangerSelectedIDNotifier: voiceChangerSelectedIDNotifier,
              reverbEffect: reverbEffect,
              reverbSelectedIDNotifier: reverbSelectedIDNotifier,
            ),
          ),
        ),
      );
    },
  );
}
