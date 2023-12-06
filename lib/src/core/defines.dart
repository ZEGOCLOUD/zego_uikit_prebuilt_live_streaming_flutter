/// @nodoc
enum ZegoInvitationType {
  ///  audience request host to be co-host
  requestCoHost,

  ///  host invite audience be co-host
  inviteToJoinCoHost,

  ///  host ask co-host to be audience
  removeFromCoHost,

  /// cross room PK invitation
  crossRoomPKBattleRequest,

  /// cross room PK invitation
  crossRoomPKBattleRequestV2,
}

/// @nodoc
extension ZegoInvitationTypeExtension on ZegoInvitationType {
  static bool isCoHostType(int type) {
    return type == ZegoInvitationType.requestCoHost.value ||
        type == ZegoInvitationType.inviteToJoinCoHost.value ||
        type == ZegoInvitationType.removeFromCoHost.value;
  }

  static bool isPKV2Type(int type) {
    return type == ZegoInvitationType.crossRoomPKBattleRequestV2.value;
  }

  static const valueMap = {
    ZegoInvitationType.requestCoHost: 2,
    ZegoInvitationType.inviteToJoinCoHost: 3,
    ZegoInvitationType.removeFromCoHost: 4,
    ZegoInvitationType.crossRoomPKBattleRequest: 5,
    ZegoInvitationType.crossRoomPKBattleRequestV2: 6,
  };

  int get value => valueMap[this] ?? -1;

  static const Map<int, ZegoInvitationType> mapValue = {
    2: ZegoInvitationType.requestCoHost,
    3: ZegoInvitationType.inviteToJoinCoHost,
    4: ZegoInvitationType.removeFromCoHost,
    5: ZegoInvitationType.crossRoomPKBattleRequest,
    6: ZegoInvitationType.crossRoomPKBattleRequestV2,
  };
}
