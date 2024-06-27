// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_styled_toast/flutter_styled_toast.dart' as styled_toast;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/overlay_machine.dart';

/// @nodoc
typedef ContextQuery = BuildContext Function();

/// @nodoc
class ZegoLiveStreamingToast {
  ContextQuery? contextQuery;

  ZegoLiveStreamingToast._internal();

  factory ZegoLiveStreamingToast() => instance;
  static final ZegoLiveStreamingToast instance =
      ZegoLiveStreamingToast._internal();

  TextStyle get textStyle => TextStyle(
        fontSize: 28.zR,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      );

  void init({required ContextQuery contextQuery}) {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'live-streaming',
      subTag: 'toast',
    );

    this.contextQuery = contextQuery;
  }

  void show(String message, {Color? backgroundColor}) {
    styled_toast.showToast(
      message,
      duration: const Duration(seconds: 3),
      context: contextQuery?.call(),
      position: styled_toast.StyledToastPosition.top,
      textStyle: textStyle,
      toastHorizontalMargin: 0,
      fullWidth: true,
      backgroundColor: backgroundColor,
    );
  }
}

/// @nodoc
void showToast(String message) {
  if (ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
    return;
  }

  ZegoLiveStreamingToast.instance.show(message);
}

/// @nodoc
void showDebugToast(String message) {
  if (ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
    return;
  }

  if (kDebugMode) {
    ZegoLiveStreamingToast.instance.show(message);
  }
}

/// @nodoc
void showSuccess(String message) {
  if (ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
    return;
  }

  ZegoLiveStreamingToast.instance
      .show(message, backgroundColor: const Color(0xff55BC9E));
}

/// @nodoc
void showError(String message) {
  if (ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
    return;
  }

  ZegoLiveStreamingToast.instance
      .show(message, backgroundColor: const Color(0xffBD5454));
}
