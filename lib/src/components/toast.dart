// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart' as styled_toast;

typedef ContextQuery = BuildContext Function();

class ZegoToast {
  ContextQuery? contextQuery;

  ZegoToast._internal();

  factory ZegoToast() => instance;
  static final ZegoToast instance = ZegoToast._internal();

  TextStyle get textStyle => TextStyle(
        fontSize: 28.r,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      );

  init({required ContextQuery contextQuery}) {
    this.contextQuery = contextQuery;
  }

  show(String message, {Color? backgroundColor}) {
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

showToast(String message) {}

showDebugToast(String message) {
  if (kDebugMode) {
    ZegoToast.instance.show(message);
  }
}

showSuccess(String message) {
  ZegoToast.instance.show(message, backgroundColor: const Color(0xff55BC9E));
}

showError(String message) {
  ZegoToast.instance.show(message, backgroundColor: const Color(0xffBD5454));
}
