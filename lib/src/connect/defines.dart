// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

enum ZegoInvitationType {
  ///  audience request host to be co-host
  requestCoHost,

  ///  host invite audience be co-host
  inviteToJoinCoHost,

  ///  host ask co-host to be audience
  removeFromCoHost,
}

extension ZegoInvitationTypeExtension on ZegoInvitationType {
  static const valueMap = {
    ZegoInvitationType.requestCoHost: 2,
    ZegoInvitationType.inviteToJoinCoHost: 3,
    ZegoInvitationType.removeFromCoHost: 4,
  };

  int get value => valueMap[this] ?? -1;

  static const Map<int, ZegoInvitationType> mapValue = {
    2: ZegoInvitationType.requestCoHost,
    3: ZegoInvitationType.inviteToJoinCoHost,
    4: ZegoInvitationType.removeFromCoHost,
  };
}

enum ConnectState {
  idle,
  connecting,
  connected,
}

bool isCoHost(ZegoUIKitUser user) {
  return ZegoUIKit().getCameraStateNotifier(user.id).value ||
      ZegoUIKit().getMicrophoneStateNotifier(user.id).value;
}
