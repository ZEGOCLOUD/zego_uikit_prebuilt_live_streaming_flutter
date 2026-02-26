// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// Represents a user in a PK (Player vs Player) battle.
///
/// This class holds the user information and live ID for a participant
/// in a PK battle between two live streaming rooms.
class ZegoLiveStreamingPKUser {
  /// The user information from ZegoUIKit.
  final ZegoUIKitUser userInfo;

  /// The live streaming room ID.
  final String liveID;

  /// Creates a PK user with the given user info and live ID.
  ///
  /// - [userInfo] is the ZegoUIKitUser object containing user details.
  /// - [liveID] is the ID of the live streaming room.
  ZegoLiveStreamingPKUser({
    required this.userInfo,
    required this.liveID,
  });

  /// Converts the PK user to a JSON map.
  ///
  /// Returns a map containing 'user_info' and 'live_id'.
  Map<String, dynamic> toJson() => {'user_info': userInfo, 'live_id': liveID};

  /// Creates a PK user from a JSON map.
  ///
  /// - [json] is the map containing 'user_info' and 'live_id'.
  factory ZegoLiveStreamingPKUser.fromJson(Map<String, dynamic> json) {
    return ZegoLiveStreamingPKUser(
      userInfo: ZegoUIKitUser.fromJson(json['user_info']),
      liveID: json['live_id'],
    );
  }

  /// Converts this PK user to a ZegoUIKitUser.
  ///
  /// Returns a [ZegoUIKitUser] with the same properties as the original user.
  ZegoUIKitUser get toUIKitUser => ZegoUIKitUser(
        id: userInfo.id,
        name: userInfo.name,
        roomID: userInfo.roomID,
        isAnotherRoomUser: userInfo.isAnotherRoomUser,
      );

  /// The stream ID for this PK user.
  ///
  /// Format: '{liveID}_{userID}_main'
  String get streamID => '${liveID}_${userInfo.id}_main';

  /// The last heartbeat timestamp from this user.
  DateTime? heartbeat;

  /// Notifies when the heartbeat is broken (connection lost).
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
