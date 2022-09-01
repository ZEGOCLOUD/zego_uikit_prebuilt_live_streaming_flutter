// Flutter imports:
import 'package:flutter/material.dart';

class PrebuiltLiveStreamingImage {
  static Image asset(String name) {
    return Image.asset(name, package: "zego_uikit_prebuilt_live_streaming");
  }
}

class PrebuiltLiveStreamingIconUrls {
  static const String iconS1ControlBarMore =
      'assets/icons/s1_ctrl_bar_more_normal.png';
  static const String iconS1ControlBarMoreChecked =
      'assets/icons/s1_ctrl_bar_more_checked.png';

  static const String iconMessage = 'assets/icons/chat.png';
}
