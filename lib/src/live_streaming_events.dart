// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// You can listen to events that you are interested in here, such as Co-hosting
class ZegoUIKitPrebuiltLiveStreamingEvents {
  /// co-host updated, refers to the event where there is a change in the co-hosts.
  /// this can occur when a new co-host joins the session or when an existing co-host leaves the session.
  Function(List<ZegoUIKitUser> coHosts)? onCoHostsUpdated;

  /// host's events about.
  ZegoUIKitPrebuiltLiveStreamingHostEvents hostEvents;

  /// audience's events about.
  ZegoUIKitPrebuiltLiveStreamingAudienceEvents audienceEvents =
      ZegoUIKitPrebuiltLiveStreamingAudienceEvents();

  ZegoUIKitPrebuiltLiveStreamingEvents({
    this.onCoHostsUpdated,
    ZegoUIKitPrebuiltLiveStreamingHostEvents? hostEvents,
    ZegoUIKitPrebuiltLiveStreamingAudienceEvents? audienceEvents,
  })  : hostEvents = hostEvents ?? ZegoUIKitPrebuiltLiveStreamingHostEvents(),
        audienceEvents =
            audienceEvents ?? ZegoUIKitPrebuiltLiveStreamingAudienceEvents();
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
