// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

class PKServiceV2RequestData {
  const PKServiceV2RequestData({
    required this.inviter,
    required this.invitees,
    required this.liveID,
    required this.isAutoAccept,
    required this.customData,
  });

  final ZegoUIKitUser inviter;
  final List<String> invitees;
  final String liveID;
  final bool isAutoAccept;
  final String customData;

  Map<String, dynamic> toJson() => {
        'inviter': inviter,
        'invitees': invitees,
        'live_id': liveID,
        'auto_accept': isAutoAccept,
        'custom_data': customData,
      };

  factory PKServiceV2RequestData.fromJson(Map<String, dynamic> json) {
    return PKServiceV2RequestData(
      inviter: ZegoUIKitUser.fromJson(
        json['inviter'] as Map<String, dynamic>? ?? {},
      ),
      invitees: List<String>.from(json['invitees']),
      liveID: json['live_id'],
      isAutoAccept: json['auto_accept'],
      customData: json['custom_data'],
    );
  }
}

class PKServiceV2AcceptData {
  const PKServiceV2AcceptData({
    required this.name,
    required this.liveID,
  });

  /// invitee's name
  final String name;

  /// invitee's live id
  final String liveID;

  Map<String, dynamic> toJson() => {
        'name': name,
        'live_id': liveID,
      };

  factory PKServiceV2AcceptData.fromJson(Map<String, dynamic> json) {
    return PKServiceV2AcceptData(
      name: json['name'],
      liveID: json['live_id'],
    );
  }
}

class PKServiceV2RejectData {
  const PKServiceV2RejectData({
    required this.code,
    required this.inviterID,
    required this.inviteeName,
  });

  final int code;
  final String inviterID;
  final String inviteeName;

  Map<String, dynamic> toJson() => {
        'code': code,
        'inviter_id': inviterID,
        'invitee_name': inviteeName,
      };

  factory PKServiceV2RejectData.fromJson(Map<String, dynamic> json) {
    return PKServiceV2RejectData(
      code: json['code'],
      inviteeName: json['invitee_name'],
      inviterID: json['inviter_id'],
    );
  }
}
