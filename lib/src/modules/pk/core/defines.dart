// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoLiveStreamingPKUser {
  final ZegoUIKitUser userInfo;
  final String liveID;

  ZegoLiveStreamingPKUser({
    required this.userInfo,
    required this.liveID,
  });

  Map<String, dynamic> toJson() => {'user_info': userInfo, 'live_id': liveID};

  factory ZegoLiveStreamingPKUser.fromJson(Map<String, dynamic> json) {
    return ZegoLiveStreamingPKUser(
      userInfo: ZegoUIKitUser.fromJson(json['user_info']),
      liveID: json['live_id'],
    );
  }

  ZegoUIKitUser get toUIKitUser => ZegoUIKitUser(
        id: userInfo.id,
        name: userInfo.name,
        roomID: userInfo.roomID,
        isAnotherRoomUser: userInfo.isAnotherRoomUser,
      );

  String get streamID => '${liveID}_${userInfo.id}_main';

  DateTime? heartbeat;
  final heartbeatBrokenNotifier = ValueNotifier<bool>(false);

  @override
  String toString() {
    return '{'
        'live id:$liveID, '
        'user:$userInfo, '
        'streamID:$streamID, '
        'heartbeat:$heartbeat, '
        'heartbeat broken:${heartbeatBrokenNotifier.value}, '
        '}';
  }
}
