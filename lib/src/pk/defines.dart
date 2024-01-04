// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
typedef ZegoDefaultAction = void Function();

@Deprecated(
    'Since 2.23.0,Please use [ZegoUIKitPrebuiltLiveStreamingController.pkV2], '
    '[ZegoUIKitPrebuiltLiveStreamingEvents.pkV2Events], '
    '[ZegoLiveStreamingPKBattleV2Config] instead')
class ZegoLiveStreamingPKBattleEvents {
  void Function(
    ZegoIncomingPKBattleRequestReceivedEvent event,
    ZegoDefaultAction defaultAction,
  )? onIncomingPKBattleRequestReceived;

  Function(
    ZegoIncomingPKBattleRequestCancelledEvent event,
    ZegoDefaultAction defaultAction,
  )? onIncomingPKBattleRequestCancelled;

  void Function(
    ZegoIncomingPKBattleRequestTimeoutEvent event,
    ZegoDefaultAction defaultAction,
  )? onIncomingPKBattleRequestTimeout;

  void Function(
    ZegoOutgoingPKBattleRequestAcceptedEvent event,
    ZegoDefaultAction defaultAction,
  )? onOutgoingPKBattleRequestAccepted;

  void Function(
    ZegoOutgoingPKBattleRequestRejectedEvent event,
    ZegoDefaultAction defaultAction,
  )? onOutgoingPKBattleRequestRejected;

  void Function(
    ZegoOutgoingPKBattleRequestTimeoutEvent event,
    ZegoDefaultAction defaultAction,
  )? onOutgoingPKBattleRequestTimeout;

  void Function(
    ZegoIncomingPKBattleRequestReceivedEvent event,
    ZegoDefaultAction defaultAction,
  )? onPKBattleEndedByAnotherHost;

  ZegoLiveStreamingPKBattleEvents({
    this.onIncomingPKBattleRequestReceived,
    this.onIncomingPKBattleRequestCancelled,
    this.onIncomingPKBattleRequestTimeout,
    this.onOutgoingPKBattleRequestAccepted,
    this.onOutgoingPKBattleRequestRejected,
    this.onOutgoingPKBattleRequestTimeout,
    this.onPKBattleEndedByAnotherHost,
  });
}

/// @nodoc
enum ZegoPKBattleRequestSubType {
  start,
  stop,
}

/// @nodoc
class ZegoIncomingPKBattleRequestReceivedEvent {
  const ZegoIncomingPKBattleRequestReceivedEvent({
    required this.anotherHost,
    required this.anotherHostLiveID,
    required this.customData,
    required this.timeoutSecond,
    required this.requestID,
    required this.subType,
  });

  final ZegoUIKitUser anotherHost;
  final String anotherHostLiveID;
  final int timeoutSecond;
  final String customData;
  final String requestID;
  final ZegoPKBattleRequestSubType subType;

  @override
  String toString() => '{requestID: $requestID, '
      'anotherHost: ${anotherHost.id}(${anotherHost.name}), '
      'timeoutSecond: $timeoutSecond, '
      'anotherHostLiveID: $anotherHostLiveID, '
      'customData: $customData}';
}

class ZegoIncomingPKBattleRequestCancelledEvent {
  const ZegoIncomingPKBattleRequestCancelledEvent({
    required this.requestID,
    required this.anotherHost,
    required this.customData,
  });

  final String requestID;
  final ZegoUIKitUser anotherHost;
  final String customData;

  @override
  String toString() => '{requestID: $requestID, '
      'anotherHost: ${anotherHost.id}(${anotherHost.name}), '
      'customData: $customData}';
}

/// @nodoc
class ZegoOutgoingPKBattleRequestAcceptedEvent {
  const ZegoOutgoingPKBattleRequestAcceptedEvent({
    required this.requestID,
    required this.anotherHost,
    required this.anotherHostLiveID,
    required this.subType,
  });

  final String requestID;
  final ZegoUIKitUser anotherHost;
  final String anotherHostLiveID;
  final ZegoPKBattleRequestSubType subType;

  @override
  String toString() => '{requestID: $requestID, '
      'anotherHost: ${anotherHost.id}(${anotherHost.name}), '
      'anotherHostLiveID: $anotherHostLiveID, '
      'subType: $subType}';
}

/// @nodoc
class ZegoOutgoingPKBattleRequestRejectedEvent {
  const ZegoOutgoingPKBattleRequestRejectedEvent({
    required this.requestID,
    required this.anotherHost,
    required this.code,
    required this.subType,
  });

  final String requestID;
  final ZegoUIKitUser anotherHost;
  final int code;
  final ZegoPKBattleRequestSubType subType;

  @override
  String toString() => '{requestID: $requestID, '
      'anotherHost: ${anotherHost.id}(${anotherHost.name}), '
      'code: $code}, '
      'subType: $subType}';
}

/// @nodoc
class ZegoIncomingPKBattleRequestTimeoutEvent {
  const ZegoIncomingPKBattleRequestTimeoutEvent({
    required this.requestID,
    required this.anotherHost,
    required this.subType,
  });

  final String requestID;
  final ZegoUIKitUser anotherHost;
  final ZegoPKBattleRequestSubType subType;

  @override
  String toString() => '{requestID: $requestID, subType: $subType} '
      'anotherHost: ${anotherHost.id}(${anotherHost.name})}';
}

/// @nodoc
class ZegoOutgoingPKBattleRequestTimeoutEvent {
  const ZegoOutgoingPKBattleRequestTimeoutEvent({
    required this.requestID,
    required this.anotherHost,
  });

  final String requestID;
  final ZegoUIKitUser anotherHost;

  @override
  String toString() => '{requestID: $requestID, '
      'anotherHost: ${anotherHost.id}(${anotherHost.name})}';
}

/// @nodoc
class ZegoLiveStreamingPKBattleResult {
  const ZegoLiveStreamingPKBattleResult({
    this.error,
  });

  final PlatformException? error;

  @override
  String toString() => '{error: $error}';
}

/// @nodoc
enum ZegoLiveStreamingPKBattleRejectCode {
  /// 0:
  /// the invited host rejects your PK request.
  reject,

  /// 1:
  /// the invited host hasn't started his own live stream yet,
  /// the host is in a PK battle with others,
  /// the host is being invited,
  /// or the host is sending a PK battle request to others.
  hostStateError,

  /// 2:
  /// the host is in a PK battle with others,
  /// the host is being invited,
  /// or the host is sending a PK battle request to others.
  busy,
}
