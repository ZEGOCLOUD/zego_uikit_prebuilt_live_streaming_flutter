// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

/// Room property key for storing PK users.
const String roomPropKeyPKUsers = "pk_users";

/// Room property key for storing host information.
const String roomPropKeyHost = "host";

/// Room property key for storing request ID.
const String roomPropKeyRequestID = "r_id";

/// Event triggered when receiving an incoming PK battle request.
///
/// This event is fired when another host sends a PK battle invitation to the local user.
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

  /// The ID of the current PK session.
  final String requestID;

  /// Timestamp (in seconds) when the PK started.
  final int startTimestampSecond;

  /// Timeout in seconds for this request.
  final int timeoutSecond;

  /// The host who initiated the PK request.
  final ZegoUIKitUser fromHost;

  /// The live streaming ID of the host who initiated the PK request.
  final String fromLiveID;

  /// Whether the PK request is automatically accepted.
  final bool isAutoAccept;

  /// Custom data associated with the PK request.
  final String customData;

  /// The hosts already involved in the same PK session,
  /// meaning the hosts that have already participated in the PK when you receive the PK invitation.
  final List<ZegoLiveStreamingIncomingPKBattleRequestUser> sessionHosts;

  @override
  String toString() => '{'
      'requestID:$requestID, '
      'fromHost:${fromHost.id}(${fromHost.name}), '
      'timeoutSecond:$timeoutSecond, '
      'fromLiveID:$fromLiveID, '
      'isAutoAccept:$isAutoAccept, '
      'customData:$customData, '
      'startTimestampSecond:$startTimestampSecond, '
      'sessionHosts:$sessionHosts, '
      '}';
}

/// Represents a user in an incoming PK battle request.
class ZegoLiveStreamingIncomingPKBattleRequestUser {
  /// Creates an incoming PK battle request user.
  ///
  /// - [id] is the user's ID.
  /// - [state] is the user's invitation state.
  /// - [customData] is custom data associated with the user.
  /// - [name] is the user's name.
  /// - [fromLiveID] is the live ID the user is from.
  ZegoLiveStreamingIncomingPKBattleRequestUser({
    this.id = '',
    this.state = ZegoSignalingPluginInvitationUserState.unknown,
    this.customData = '',
    this.name = '',
    this.fromLiveID = '',
  });

  /// The user's ID.
  final String id;

  /// The user's name.
  String name;

  /// The live streaming ID the user is from.
  String fromLiveID;

  /// The user's invitation state.
  final ZegoSignalingPluginInvitationUserState state;

  /// Custom data associated with the user.
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

  /// The ID of the current PK session.
  final String requestID;

  /// The host whose request timed out.
  final ZegoUIKitUser fromHost;

  @override
  String toString() => '{'
      'requestID:$requestID, '
      'anotherHost:$fromHost'
      '}';
}

class ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent {
  const ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent({
    required this.requestID,
    required this.fromHost,
    required this.customData,
  });

  /// The ID of the current PK session.
  final String requestID;

  /// The host who cancelled the PK request.
  final ZegoUIKitUser fromHost;

  /// Custom data associated with the request.
  final String customData;

  @override
  String toString() => '{'
      'requestID:$requestID, '
      'fromHost:$fromHost, '
      'customData:$customData'
      '}';
}

/// @nodoc
class ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent {
  const ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent({
    required this.requestID,
    required this.fromHost,
    required this.fromLiveID,
  });

  /// The ID of the current PK session.
  final String requestID;

  /// The host who accepted the PK request.
  final ZegoUIKitUser fromHost;

  /// The live streaming ID of the host who accepted the request.
  final String fromLiveID;

  @override
  String toString() => '{'
      'requestID:$requestID, '
      'fromHost:$fromHost, '
      'fromLiveID:$fromLiveID,'
      '}';
}

/// @nodoc
class ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent {
  const ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent({
    required this.requestID,
    required this.fromHost,
    required this.refuseCode,
  });

  /// The ID of the current PK session.
  final String requestID;

  /// The host who rejected the PK request.
  final ZegoUIKitUser fromHost;

  /// Reject reason code.
  final int refuseCode;

  @override
  String toString() => '{'
      'requestID:$requestID, '
      'fromHost:$fromHost), '
      'refuseCode:$refuseCode'
      '}';
}

/// @nodoc
class ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent {
  const ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent({
    required this.requestID,
    required this.fromHost,
  });

  /// The ID of the current PK session.
  final String requestID;

  /// The host whose request timed out.
  final ZegoUIKitUser fromHost;

  @override
  String toString() => '{'
      'requestID:$requestID, '
      'fromHost:$fromHost, '
      '}';
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

  /// The ID of the current PK session.
  final String requestID;

  /// The host who ended the PK battle.
  final ZegoUIKitUser fromHost;

  /// End time (timestamp).
  final int time;

  /// End reason code.
  final int code;

  /// Request may be from remote or local.
  final bool isRequestFromLocal;

  @override
  String toString() => '{'
      'requestID:$requestID, '
      'isRequestFromLocal:$isRequestFromLocal, '
      'fromHost:$fromHost, '
      'time:$time, '
      'code:$code, '
      '}';
}

/// @nodoc
class ZegoLiveStreamingPKBattleUserOfflineEvent {
  const ZegoLiveStreamingPKBattleUserOfflineEvent({
    required this.requestID,
    required this.fromHost,
  });

  /// The ID of the current PK session.
  final String requestID;

  /// The host who went offline.
  final ZegoUIKitUser fromHost;

  @override
  String toString() => '{'
      'requestID:$requestID, '
      'fromHost:$fromHost, '
      '}';
}

/// @nodoc
class ZegoLiveStreamingPKBattleUserQuitEvent {
  const ZegoLiveStreamingPKBattleUserQuitEvent({
    required this.requestID,
    required this.fromHost,
  });

  /// The ID of the current PK session.
  final String requestID;

  /// The host who quit the PK battle.
  final ZegoUIKitUser fromHost;

  @override
  String toString() => '{'
      'requestID:$requestID, '
      'fromHost:$fromHost, '
      '}';
}
