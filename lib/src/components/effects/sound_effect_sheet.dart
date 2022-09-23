// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'effect_grid.dart';

class ZegoSoundEffectSheet extends StatefulWidget {
  final List<VoiceChangerType> voiceChangeEffect;
  final List<ReverbType> reverbEffect;

  const ZegoSoundEffectSheet({
    Key? key,
    required this.voiceChangeEffect,
    required this.reverbEffect,
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

    List<VoiceChangerType> voiceChangeEffect =
        List.from(widget.voiceChangeEffect);
    voiceChangeEffect.removeWhere((effect) => effect == VoiceChangerType.none);
    voiceChangeEffect.insert(0, VoiceChangerType.none);
    voiceChangerModel = ZegoEffectGridModel(
      title: "Voice Changer",
      items: voiceChangeEffect
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
              iconText: effect.name,
              onPressed: () {
                ZegoUIKit().setVoiceChangeType(effect.key);
              },
            ),
          )
          .toList(),
    );
    for (var item in voiceChangerModel.items) {
      item.icon.backgroundColor = const Color(0xff3b3a3d);
      item.selectIcon?.backgroundColor = const Color(0xff3b3a3d);
    }

    List<ReverbType> reverbEffect = List.from(widget.reverbEffect);
    reverbEffect.removeWhere((effect) => effect == ReverbType.none);
    reverbEffect.insert(0, ReverbType.none);
    reverbPresetModel = ZegoEffectGridModel(
      title: "Reverb Preset",
      items: reverbEffect
          .map(
            (effect) => ZegoEffectGridItem<ReverbType>(
              id: effect.index.toString(),
              effectType: effect,
              icon: ButtonIcon(
                icon: PrebuiltLiveStreamingImage.asset(
                    "assets/icons/reverb_preset_" + effect.name + ".png"),
              ),
              iconText: effect.name,
              onPressed: () {
                ZegoUIKit().setReverbPreset(effect.key);
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
          header(98.h),
          Container(height: 1.r, color: Colors.white),
          SizedBox(height: 36.r),
          ZegoEffectGrid(
            model: voiceChangerModel,
            isSpaceEvenly: false,
          ),
          SizedBox(height: 36.r),
          ZegoEffectGrid(
              model: reverbPresetModel,
              isSpaceEvenly: false,
              withBorderColor: true),
        ],
      );
    }));
  }

  Widget header(double height) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SizedBox(
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
              "Sound Effect",
              style: TextStyle(
                fontSize: 36.0.r,
                color: const Color(0xffffffff),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showSoundEffectSheet(
  BuildContext context, {
  required List<VoiceChangerType> voiceChangeEffect,
  required List<ReverbType> reverbEffect,
}) {
  showModalBottomSheet(
    backgroundColor: const Color(0xff242736).withOpacity(0.95),
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
      return FractionallySizedBox(
        heightFactor: 0.55,
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ZegoSoundEffectSheet(
              voiceChangeEffect: voiceChangeEffect,
              reverbEffect: reverbEffect,
            ),
          ),
        ),
      );
    },
  );
}
