/// @nodoc
enum ZegoLiveStreamingInvitationType {
  ///  audience request host to be co-host
  requestCoHost,

  ///  host invite audience be co-host
  inviteToJoinCoHost,

  ///  host ask co-host to be audience
  removeFromCoHost,

  // /// cross room PK invitation
  // crossRoomPKBattleRequest,

  /// cross room PK invitation
  crossRoomPKBattleRequestV2,
}
// ZegoCallInvitationType.voiceCall: 0,
// ZegoCallInvitationType.videoCall: 1,

/// @nodoc
extension ZegoInvitationTypeExtension on ZegoLiveStreamingInvitationType {
  static bool isCoHostType(int type) {
    return type == ZegoLiveStreamingInvitationType.requestCoHost.value ||
        type == ZegoLiveStreamingInvitationType.inviteToJoinCoHost.value ||
        type == ZegoLiveStreamingInvitationType.removeFromCoHost.value;
  }

  static bool isPKType(int type) {
    return type ==
        ZegoLiveStreamingInvitationType.crossRoomPKBattleRequestV2.value;
  }

  static const valueMap = {
    ZegoLiveStreamingInvitationType.requestCoHost: 2,
    ZegoLiveStreamingInvitationType.inviteToJoinCoHost: 3,
    ZegoLiveStreamingInvitationType.removeFromCoHost: 4,
    // ZegoLiveStreamingInvitationType.crossRoomPKBattleRequest: 5,
    ZegoLiveStreamingInvitationType.crossRoomPKBattleRequestV2: 6,
  };

  int get value => valueMap[this] ?? -1;

  static const Map<int, ZegoLiveStreamingInvitationType> mapValue = {
    2: ZegoLiveStreamingInvitationType.requestCoHost,
    3: ZegoLiveStreamingInvitationType.inviteToJoinCoHost,
    4: ZegoLiveStreamingInvitationType.removeFromCoHost,
    // 5: ZegoLiveStreamingInvitationType.crossRoomPKBattleRequest,
    6: ZegoLiveStreamingInvitationType.crossRoomPKBattleRequestV2,
  };
}
