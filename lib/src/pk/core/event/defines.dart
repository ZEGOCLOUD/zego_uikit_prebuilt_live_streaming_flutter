// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

const String roomPropKeyPKUsers = "pk_users";
const String roomPropKeyHost = "host";
const String roomPropKeyRequestID = "r_id";

class ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent {
  const ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent({
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
  final List<ZegoLiveStreamingIncomingPKBattleRequestUser> sessionHosts;

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

class ZegoLiveStreamingIncomingPKBattleRequestUser {
  ZegoLiveStreamingIncomingPKBattleRequestUser({
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
class ZegoLiveStreamingIncomingPKBattleRequestTimeoutEvent {
  const ZegoLiveStreamingIncomingPKBattleRequestTimeoutEvent({
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

class ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent {
  const ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent({
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
class ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent {
  const ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent({
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
class ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent {
  const ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent({
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
class ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent {
  const ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent({
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
class ZegoLiveStreamingPKBattleEndedEvent {
  const ZegoLiveStreamingPKBattleEndedEvent({
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
class ZegoLiveStreamingPKBattleUserOfflineEvent {
  const ZegoLiveStreamingPKBattleUserOfflineEvent({
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
class ZegoLiveStreamingPKBattleUserQuitEvent {
  const ZegoLiveStreamingPKBattleUserQuitEvent({
    required this.requestID,
    required this.fromHost,
  });

  /// The ID of the current PK session
  final String requestID;
  final ZegoUIKitUser fromHost;

  @override
  String toString() => '{requestID:$requestID, fromHost:$fromHost}';
}
