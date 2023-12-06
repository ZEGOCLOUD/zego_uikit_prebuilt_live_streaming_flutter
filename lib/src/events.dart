// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/event/defines.dart';

/// You can listen to events that you are interested in here, such as Co-hosting
class ZegoUIKitPrebuiltLiveStreamingEvents {
  /// co-host updated, refers to the event where there is a change in the co-hosts.
  /// this can occur when a new co-host joins the session or when an existing co-host leaves the session.
  Function(List<ZegoUIKitUser> coHosts)? onCoHostsUpdated;

  /// error stream
  Function(ZegoUIKitError)? onError;

  /// host's events about.
  ZegoUIKitPrebuiltLiveStreamingHostEvents hostEvents;

  /// audience's events about.
  ZegoUIKitPrebuiltLiveStreamingAudienceEvents audienceEvents =
      ZegoUIKitPrebuiltLiveStreamingAudienceEvents();

  /// pk(v2) events
  ZegoUIKitPrebuiltLiveStreamingPKV2Events pkV2Events =
      ZegoUIKitPrebuiltLiveStreamingPKV2Events();

  ZegoUIKitPrebuiltLiveStreamingEvents({
    this.onCoHostsUpdated,
    this.onError,
    ZegoUIKitPrebuiltLiveStreamingHostEvents? hostEvents,
    ZegoUIKitPrebuiltLiveStreamingAudienceEvents? audienceEvents,
    ZegoUIKitPrebuiltLiveStreamingPKV2Events? pkEvents,
  })  : hostEvents = hostEvents ?? ZegoUIKitPrebuiltLiveStreamingHostEvents(),
        audienceEvents =
            audienceEvents ?? ZegoUIKitPrebuiltLiveStreamingAudienceEvents(),
        pkV2Events = pkEvents ?? ZegoUIKitPrebuiltLiveStreamingPKV2Events();
}

/// Host Related Events
class ZegoUIKitPrebuiltLiveStreamingHostEvents {
  /// receive a request that audience request to become a co-host
  Function(ZegoUIKitUser audience)? onCoHostRequestReceived;

  /// audience cancelled the co-host request.
  Function(ZegoUIKitUser audience)? onCoHostRequestCanceled;

  /// the audience's co-host request has timed out.
  Function(ZegoUIKitUser audience)? onCoHostRequestTimeout;

  /// host accept the audience's co-host request.
  Function()? onActionAcceptCoHostRequest;

  /// host refuse the audience's co-host request.
  Function()? onActionRefuseCoHostRequest;

  /// host sent invitation to become a co-host to the audience.
  Function(ZegoUIKitUser audience)? onCoHostInvitationSent;

  /// the host's co-host invitation has timed out.
  Function(ZegoUIKitUser audience)? onCoHostInvitationTimeout;

  /// audience accepted to a co-host request from host
  void Function(ZegoUIKitUser audience)? onCoHostInvitationAccepted;

  /// audience refused to a co-host request from host
  void Function(ZegoUIKitUser audience)? onCoHostInvitationRefused;

  ZegoUIKitPrebuiltLiveStreamingHostEvents({
    this.onCoHostRequestReceived,
    this.onCoHostRequestCanceled,
    this.onCoHostRequestTimeout,
    this.onActionAcceptCoHostRequest,
    this.onActionRefuseCoHostRequest,
    this.onCoHostInvitationSent,
    this.onCoHostInvitationTimeout,
    this.onCoHostInvitationAccepted,
    this.onCoHostInvitationRefused,
  });
}

/// Audience Related Events
class ZegoUIKitPrebuiltLiveStreamingAudienceEvents {
  /// audience requested to become a co-host to the host.
  Function()? onCoHostRequestSent;

  /// audience cancelled the co-host request.
  Function()? onActionCancelCoHostRequest;

  /// the audience's co-host request has timed out.
  Function()? onCoHostRequestTimeout;

  /// host accept the audience's co-host request.
  Function()? onCoHostRequestAccepted;

  /// host refuse the audience's co-host request.
  Function()? onCoHostRequestRefused;

  /// received a co-host invitation from the host.
  void Function(ZegoUIKitUser host)? onCoHostInvitationReceived;

  /// the host's co-host invitation has timed out.
  Function()? onCoHostInvitationTimeout;

  /// audience refuse co-host invitation from the host.
  Function()? onActionAcceptCoHostInvitation;

  /// audience refuse co-host invitation from the host.
  Function()? onActionRefuseCoHostInvitation;

  ZegoUIKitPrebuiltLiveStreamingAudienceEvents({
    this.onCoHostRequestSent,
    this.onActionCancelCoHostRequest,
    this.onCoHostRequestTimeout,
    this.onCoHostRequestAccepted,
    this.onCoHostRequestRefused,
    this.onCoHostInvitationReceived,
    this.onCoHostInvitationTimeout,
    this.onActionAcceptCoHostInvitation,
    this.onActionRefuseCoHostInvitation,
  });
}

/// pk(version 2) related events
///
/// The [defaultAction] is the internal default behavior (popup).
/// If you override the event and still require these default actions, please execute `defaultAction.call()`.
class ZegoUIKitPrebuiltLiveStreamingPKV2Events {
  /// Received a PK invitation from [event.fromHost], with the ID [event.requestID].
  ///
  /// When receiving a PK battle request, the Live Streaming Kit
  /// (ZegoUIKitPrebuiltLiveStreaming) defaults to check whether you are
  /// accepting the PK battle request through a pop-up window. You can
  /// receive callback notifications or customize your business logic by
  /// listening to or setting up the [onIncomingPKBattleRequestReceived].
  void Function(
    ZegoIncomingPKBattleRequestReceivedEventV2 event,
    VoidCallback defaultAction,
  )? onIncomingPKBattleRequestReceived;

  /// The received PK invitation has been canceled by the inviting host [event.fromHost].
  ///
  /// You can receive callback notifications or customize your business logic
  /// by listening to or setting up the [onIncomingPKBattleRequestCancelled]
  /// when the PK battle request has been canceled.
  Function(
    ZegoIncomingPKBattleRequestCancelledEventV2 event,
    VoidCallback defaultAction,
  )? onIncomingPKBattleRequestCancelled;

  /// The received PK invitation has timed out.
  ///
  /// You can receive callback notifications or customize your business logic
  /// by listening to or setting up the [onIncomingPKBattleRequestTimeout]
  /// when the received PK battle request has timed out.
  void Function(
    ZegoIncomingPKBattleRequestTimeoutEventV2 event,
    VoidCallback defaultAction,
  )? onIncomingPKBattleRequestTimeout;

  /// The PK invitation to [event.fromHost] has been accepted.
  ///
  /// When the sent PK battle request is accepted, the Live Streaming Kit
  /// (ZegoUIKitPrebuiltLiveStreaming) starts the PK battle by default.
  /// Once it starts, you can receive callback notifications or customize
  /// your business logic by listening to or setting up the [onOutgoingPKBattleRequestAccepted].
  void Function(
    ZegoOutgoingPKBattleRequestAcceptedEventV2 event,
    VoidCallback defaultAction,
  )? onOutgoingPKBattleRequestAccepted;

  /// The PK invitation to [event.fromHost] has been rejected.
  ///
  /// When the sent PK battle request is rejected, the default behaviour is
  /// notify you that the host has rejected your PK battle request through a pop-up window.
  /// You can receive callback notifications or customize your business logic
  /// by listening to or setting up the [onOutgoingPKBattleRequestRejected].
  ///
  /// The PK battle request will be rejected automatically when the invited host is in a busy state.
  /// Busy state: the host has not initiated his live stream yet, the host is
  /// in a PK battle with others, the host is being invited, and the host is sending a PK battle request to others.
  void Function(
    ZegoOutgoingPKBattleRequestRejectedEventV2 event,
    VoidCallback defaultAction,
  )? onOutgoingPKBattleRequestRejected;

  /// Your PK invitation has been timeout
  ///
  /// If the invited host didn't respond after the timeout duration, the PK
  /// battle request timed out by default. While the Live Streaming Kit
  /// updates the internal state while won't trigger any default behaviors.
  /// You can receive callback notifications or customize your business
  /// logic by listening to or setting up the onOutgoingPKBattleRequestTimeout.
  void Function(
    ZegoOutgoingPKBattleRequestTimeoutEventV2 event,
    VoidCallback defaultAction,
  )? onOutgoingPKBattleRequestTimeout;

  /// PK invitation had been ended by [event.fromHost]
  void Function(
    ZegoPKBattleEndedEventV2 event,
    VoidCallback defaultAction,
  )? onPKBattleEnded;

  /// PK host offline
  void Function(
    ZegoPKBattleUserOfflineEventV2 event,
    VoidCallback defaultAction,
  )? onUserOffline;

  /// PK host quit
  void Function(
    ZegoPKBattleUserQuitEventV2 event,
    VoidCallback defaultAction,
  )? onUserQuited;

  /// pk user enter
  void Function(ZegoUIKitUser user)? onUserJoined;

  /// pk user disconnect events
  void Function(ZegoUIKitUser user)? onUserDisconnected;
  void Function(ZegoUIKitUser user)? onUserReconnecting;
  void Function(ZegoUIKitUser user)? onUserReconnected;

  ZegoUIKitPrebuiltLiveStreamingPKV2Events({
    this.onIncomingPKBattleRequestReceived,
    this.onIncomingPKBattleRequestCancelled,
    this.onIncomingPKBattleRequestTimeout,
    this.onOutgoingPKBattleRequestAccepted,
    this.onOutgoingPKBattleRequestRejected,
    this.onOutgoingPKBattleRequestTimeout,
    this.onPKBattleEnded,
    this.onUserOffline,
    this.onUserQuited,
    this.onUserJoined,
    this.onUserDisconnected,
    this.onUserReconnecting,
    this.onUserReconnected,
  });
}
