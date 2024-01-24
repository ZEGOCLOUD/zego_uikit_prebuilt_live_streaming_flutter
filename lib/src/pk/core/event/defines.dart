// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

const String roomPropKeyPKUsers = "pk_users";
const String roomPropKeyHost = "host";
const String roomPropKeyRequestID = "r_id";

class ZegoIncomingPKBattleRequestReceivedEvent {
  const ZegoIncomingPKBattleRequestReceivedEvent({
    required this.requestID,
    required this.fromHost,
    required this.fromLiveID,
    required this.isAutoAccept,
    required this.customData,
    required this.startTimestampSecond,
    required this.timeoutSecond,
    this.sessionHosts = const [],
  });

  /// The ID of the current PK session
  final String requestID;

  /// timestamp(second) of PK start
  final int startTimestampSecond;

  ///  timeout second of this request
  final int timeoutSecond;

  final ZegoUIKitUser fromHost;
  final String fromLiveID;
  final bool isAutoAccept;
  final String customData;

  /// The hosts already involved in the same PK session,
  /// meaning the hosts that have already participated in the PK when you receive the PK invitation.
  final List<ZegoIncomingPKBattleRequestUser> sessionHosts;

  @override
  String toString() => '{requestID:$requestID, '
      'fromHost:${fromHost.id}(${fromHost.name}), '
      'timeoutSecond:$timeoutSecond, '
      'fromLiveID:$fromLiveID, '
      'isAutoAccept:$isAutoAccept, '
      'customData:$customData, '
      'startTimestampSecond:$startTimestampSecond, '
      'sessionHosts:$sessionHosts, '
      '}';
}

class ZegoIncomingPKBattleRequestUser {
  ZegoIncomingPKBattleRequestUser({
    this.id = '',
    this.state = ZegoSignalingPluginInvitationUserState.unknown,
    this.customData = '',
    this.name = '',
    this.fromLiveID = '',
  });

  final String id;

  String name;
  String fromLiveID;

  final ZegoSignalingPluginInvitationUserState state;
  final String customData;

  @override
  String toString() => '{'
      'id:$id, '
      'name:$name, '
      'state:$state, '
      'fromLiveID:$fromLiveID, '
      'customData:$customData'
      '}';
}

/// @nodoc
class ZegoIncomingPKBattleRequestTimeoutEvent {
  const ZegoIncomingPKBattleRequestTimeoutEvent({
    required this.requestID,
    required this.fromHost,
  });

  /// The ID of the current PK session
  final String requestID;
  final ZegoUIKitUser fromHost;

  @override
  String toString() => '{requestID:$requestID, '
      'anotherHost:$fromHost}';
}

class ZegoIncomingPKBattleRequestCancelledEvent {
  const ZegoIncomingPKBattleRequestCancelledEvent({
    required this.requestID,
    required this.fromHost,
    required this.customData,
  });

  /// The ID of the current PK session
  final String requestID;
  final ZegoUIKitUser fromHost;
  final String customData;

  @override
  String toString() => '{requestID:$requestID, '
      'fromHost:$fromHost, '
      'customData:$customData}';
}

/// @nodoc
class ZegoOutgoingPKBattleRequestAcceptedEvent {
  const ZegoOutgoingPKBattleRequestAcceptedEvent({
    required this.requestID,
    required this.fromHost,
    required this.fromLiveID,
  });

  /// The ID of the current PK session
  final String requestID;
  final ZegoUIKitUser fromHost;
  final String fromLiveID;

  @override
  String toString() => '{requestID:$requestID, '
      'fromHost:$fromHost, '
      'fromLiveID:$fromLiveID,}';
}

/// @nodoc
class ZegoOutgoingPKBattleRequestRejectedEvent {
  const ZegoOutgoingPKBattleRequestRejectedEvent({
    required this.requestID,
    required this.fromHost,
    required this.refuseCode,
  });

  /// The ID of the current PK session
  final String requestID;
  final ZegoUIKitUser fromHost;

  /// reject reason code
  final int refuseCode;

  @override
  String toString() =>
      '{requestID:$requestID, fromHost:$fromHost), refuseCode:$refuseCode}';
}

/// @nodoc
class ZegoOutgoingPKBattleRequestTimeoutEvent {
  const ZegoOutgoingPKBattleRequestTimeoutEvent({
    required this.requestID,
    required this.fromHost,
  });

  /// The ID of the current PK session
  final String requestID;
  final ZegoUIKitUser fromHost;

  @override
  String toString() => '{requestID:$requestID, '
      'fromHost:$fromHost}';
}

/// @nodoc
class ZegoPKBattleEndedEvent {
  const ZegoPKBattleEndedEvent({
    required this.requestID,
    required this.isRequestFromLocal,
    required this.fromHost,
    required this.time,
    required this.code,
  });

  /// The ID of the current PK session
  final String requestID;
  final ZegoUIKitUser fromHost;

  /// end tie
  final int time;

  /// end reason
  final int code;

  /// request may be from remote or local
  final bool isRequestFromLocal;

  @override
  String toString() => '{'
      'requestID:$requestID, '
      'isRequestFromLocal:$isRequestFromLocal, '
      'fromHost:$fromHost, '
      'time:$time, '
      'code:$code,}';
}

/// @nodoc
class ZegoPKBattleUserOfflineEvent {
  const ZegoPKBattleUserOfflineEvent({
    required this.requestID,
    required this.fromHost,
  });

  /// The ID of the current PK session
  final String requestID;
  final ZegoUIKitUser fromHost;

  @override
  String toString() => '{requestID:$requestID, fromHost:$fromHost}';
}

/// @nodoc
class ZegoPKBattleUserQuitEvent {
  const ZegoPKBattleUserQuitEvent({
    required this.requestID,
    required this.fromHost,
  });

  /// The ID of the current PK session
  final String requestID;
  final ZegoUIKitUser fromHost;

  @override
  String toString() => '{requestID:$requestID, fromHost:$fromHost}';
}
