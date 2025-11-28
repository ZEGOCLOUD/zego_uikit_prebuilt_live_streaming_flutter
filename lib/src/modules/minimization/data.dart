// Dart imports:
import 'dart:core';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';

/// @nodoc
class ZegoLiveStreamingMinimizationData {
  const ZegoLiveStreamingMinimizationData({
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    required this.isPrebuiltFromMinimizing,
    required this.isPrebuiltFromHall,
    required this.events,
    this.durationStartTime,
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

  final ZegoUIKitPrebuiltLiveStreamingEvents? events;

  final bool isPrebuiltFromMinimizing;

  final bool isPrebuiltFromHall;

  /// call duration
  final DateTime? durationStartTime;

  @override
  String toString() {
    return '{'
        'app id:$appID, '
        'live id:$liveID, '
        'isPrebuiltFromMinimizing: $isPrebuiltFromMinimizing, '
        'isPrebuiltFromHall: $isPrebuiltFromHall, '
        'user id:$userID, user name:$userName, '
        'duration start time:$durationStartTime, '
        'config:$config, '
        '}';
  }
}
