// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil_zego/flutter_screenutil_zego.dart';
import 'package:zego_uikit/zego_uikit.dart';

Future<bool> showLiveDialog({
  required BuildContext context,
  required bool rootNavigator,
  required String title,
  required String content,
  required String rightButtonText,
  String? leftButtonText,
  VoidCallback? leftButtonCallback,
  VoidCallback? rightButtonCallback,
}) async {
  return showAlertDialog(
    context,
    title,
    content,
    [
      if (leftButtonText != null)
        CupertinoDialogAction(
          onPressed: leftButtonCallback ??
              () => Navigator.of(
                    context,
                    rootNavigator: rootNavigator,
                  ).pop(false),
          child: Text(
            leftButtonText,
            style: TextStyle(
              fontSize: 32.r,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      CupertinoDialogAction(
        onPressed: rightButtonCallback ??
            () => Navigator.of(
                  context,
                  rootNavigator: rootNavigator,
                ).pop(true),
        child: Text(
          rightButtonText,
          style: TextStyle(
            fontSize: 32.r,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
    titleStyle: TextStyle(
      fontSize: 32.0.r,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    contentStyle: TextStyle(
      fontSize: 28.0.r,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    actionsAlignment: MainAxisAlignment.spaceEvenly,
    backgroundColor: const Color(0xff111014).withOpacity(0.8),
  );
}
