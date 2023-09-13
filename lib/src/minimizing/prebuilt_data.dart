// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_events.dart';

/// @nodoc
class ZegoUIKitPrebuiltLiveStreamingData {
  const ZegoUIKitPrebuiltLiveStreamingData({
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    required this.isPrebuiltFromMinimizing,
    required this.controller,
    required this.events,
    this.durationStartTime,
    this.onDispose,
  });

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appID you obtained from console.zegocloud.com
  final String appSign;

  /// local user info
  final String userID;
  final String userName;

  /// You can customize the liveName arbitrarily,
  /// just need to know: users who use the same liveName can talk with each other.
  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final VoidCallback? onDispose;

  final ZegoUIKitPrebuiltLiveStreamingController controller;

  final ZegoUIKitPrebuiltLiveStreamingEvents events;

  final bool isPrebuiltFromMinimizing;

  /// call duration
  final DateTime? durationStartTime;

  @override
  String toString() {
    return 'app id:$appID, app sign:$appSign, live id:$liveID, '
        'isPrebuiltFromMinimizing: $isPrebuiltFromMinimizing, '
        'user id:$userID, user name:$userName, '
        'duration start time:$durationStartTime, '
        'config:$config ';
  }
}
