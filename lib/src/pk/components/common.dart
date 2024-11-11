// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

Widget defaultPKBackgroundBuilder(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,
  Map<String, dynamic> extraInfo,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black,
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
      ),
    ),
  );
}
