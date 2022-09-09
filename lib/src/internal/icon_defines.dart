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
  static const String message = 'assets/icons/chat.png';
  static const String background = 'assets/icons/bg.png';
}
