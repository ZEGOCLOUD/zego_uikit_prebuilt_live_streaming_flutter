// Flutter imports:
import 'package:flutter/material.dart';

class PrebuiltLiveStreamingImage {
  static Image asset(String name) {
    return Image.asset(name, package: "zego_uikit_prebuilt_live_streaming");
  }

  static AssetImage assetImage(String name) {
    return AssetImage(name, package: "zego_uikit_prebuilt_live_streaming");
  }
}

class PrebuiltLiveStreamingIconUrls {
  static const String im = 'assets/icons/im.png';
  static const String background = 'assets/icons/bg.png';
  static const String back = 'assets/icons/back.png';
  static const String toolbarSoundEffect = 'assets/icons/toolbar_sound.png';
  static const String toolbarBeautyEffect = 'assets/icons/toolbar_beauty.png';

  static const String effectReset = "assets/icons/effect_reset.png";
}
