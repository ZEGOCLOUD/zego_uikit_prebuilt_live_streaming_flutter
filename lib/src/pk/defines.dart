// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

typedef ZegoDefaultAction = void Function();

class ZegoLiveStreamingPKBattleEvents {
  void Function(
    ZegoIncomingPKBattleRequestReceivedEvent event,
    ZegoDefaultAction defaultAction,
  )? onIncomingPKBattleRequestReceived;
  void Function(
    ZegoIncomingPKBattleRequestAcceptedEvent event,
    ZegoDefaultAction defaultAction,
  )? onIncomingPKBattleRequestAccepted;
  void Function(
    ZegoIncomingPKBattleRequestRejectedEvent event,
    ZegoDefaultAction defaultAction,
  )? onIncomingPKBattleRequestRejected;
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
    ZegoOutgoingPKBattleRequestSendedEvent event,
    ZegoDefaultAction defaultAction,
  )? onOutgoingPKBattleRequestSended;
  void Function(
    ZegoOutgoingPKBattleRequestCanceledEvent event,
    ZegoDefaultAction defaultAction,
  )? onOutgoingPKBattleRequestCanceled;

  void Function(
    ZegoIncomingPKBattleRequestReceivedEvent event,
    ZegoDefaultAction defaultAction,
  )? onPKBattleEndedByAnotherHost;

  ZegoLiveStreamingPKBattleEvents({
    this.onIncomingPKBattleRequestReceived,
    this.onIncomingPKBattleRequestAccepted,
    this.onIncomingPKBattleRequestRejected,
    this.onIncomingPKBattleRequestCancelled,
    this.onIncomingPKBattleRequestTimeout,
    this.onOutgoingPKBattleRequestAccepted,
    this.onOutgoingPKBattleRequestRejected,
    this.onOutgoingPKBattleRequestTimeout,
    this.onOutgoingPKBattleRequestSended,
    this.onOutgoingPKBattleRequestCanceled,
    this.onPKBattleEndedByAnotherHost,
  });
}

enum ZegoPKBattleRequestSubType {
  start,
  stop,
}

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

class ZegoIncomingPKBattleRequestAcceptedEvent {}

class ZegoIncomingPKBattleRequestRejectedEvent {}

class ZegoOutgoingPKBattleRequestSendedEvent {}

class ZegoOutgoingPKBattleRequestCanceledEvent {}

class ZegoPKStartedEvent {}

class ZegoPKViewAvaliableEvent {}

class ZegoPKRelayCDNStateUpdateEvent {}

class ZegoLiveStreamingPKBattleResult {
  const ZegoLiveStreamingPKBattleResult({
    this.error,
  });

  final PlatformException? error;

  @override
  String toString() => '{error: $error}';
}

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
