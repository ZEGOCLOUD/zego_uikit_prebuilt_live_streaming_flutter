// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// The default behavior is to return to the previous page.
///
/// If you override this callback, you must perform the page navigation
/// yourself to return to the previous page!!!
/// otherwise the user will remain on the current call page !!!!!
enum ZegoLiveStreamingEndReason {
  /// the live streaming ended due to host ended
  hostEnd,

  /// local user leave
  localLeave,

  /// being kicked out
  kickOut,
}

class ZegoLiveStreamingLeaveConfirmationEvent {
  BuildContext context;

  ZegoLiveStreamingLeaveConfirmationEvent({
    required this.context,
  });
}

class ZegoLiveStreamingEndEvent {
  /// the user ID of who kick you out
  String? kickerUserID;

  /// end reason
  ZegoLiveStreamingEndReason reason;

  /// The [isFromMinimizing] it means that the user left the live streaming
  /// while it was in a minimized state.
  ///
  /// You **can not** return to the previous page while it was **in a minimized state**!!!
  /// just hide the minimize page by [ZegoUIKitPrebuiltLiveStreamingController().minimize.hide()]
  ///
  /// On the other hand, if the value of the parameter is false, it means
  /// that the user left the live streaming while it was not minimized.
  bool isFromMinimizing;

  ZegoLiveStreamingEndEvent({
    required this.reason,
    required this.isFromMinimizing,
    this.kickerUserID,
  });

  @override
  String toString() {
    return '{'
        'kickerUserID:$kickerUserID, '
        'isFromMinimizing:$isFromMinimizing, '
        'reason:$reason, '
        '}';
  }
}

class ZegoLiveStreamingCoHostHostEventRequestReceivedData {
  ZegoLiveStreamingCoHostHostEventRequestReceivedData({
    required this.audience,
    required this.customData,
  });

  ZegoUIKitUser audience;
  String customData;

  @override
  String toString() {
    return '{'
        'audience:$audience, '
        'customData:$customData, '
        '}';
  }
}

class ZegoLiveStreamingCoHostHostEventRequestCanceledData {
  ZegoLiveStreamingCoHostHostEventRequestCanceledData({
    required this.audience,
    required this.customData,
  });

  ZegoUIKitUser audience;
  String customData;

  @override
  String toString() {
    return '{'
        'audience:$audience, '
        'customData:$customData, '
        '}';
  }
}

class ZegoLiveStreamingCoHostHostEventRequestTimeoutData {
  ZegoLiveStreamingCoHostHostEventRequestTimeoutData({
    required this.audience,
  });

  ZegoUIKitUser audience;

  @override
  String toString() {
    return '{'
        'audience:$audience, '
        '}';
  }
}

class ZegoLiveStreamingCoHostHostEventInvitationSentData {
  ZegoLiveStreamingCoHostHostEventInvitationSentData({
    required this.audience,
  });

  ZegoUIKitUser audience;

  @override
  String toString() {
    return '{'
        'audience:$audience, '
        '}';
  }
}

class ZegoLiveStreamingCoHostHostEventInvitationTimeoutData {
  ZegoLiveStreamingCoHostHostEventInvitationTimeoutData({
    required this.audience,
  });

  ZegoUIKitUser audience;

  @override
  String toString() {
    return '{'
        'audience:$audience, '
        '}';
  }
}

class ZegoLiveStreamingCoHostHostEventInvitationAcceptedData {
  ZegoLiveStreamingCoHostHostEventInvitationAcceptedData({
    required this.audience,
    required this.customData,
  });

  ZegoUIKitUser audience;
  String customData;

  @override
  String toString() {
    return '{'
        'audience:$audience, '
        'customData:$customData, '
        '}';
  }
}

class ZegoLiveStreamingCoHostHostEventInvitationRefusedData {
  ZegoLiveStreamingCoHostHostEventInvitationRefusedData({
    required this.audience,
    required this.customData,
  });

  ZegoUIKitUser audience;
  String customData;

  @override
  String toString() {
    return '{'
        'audience:$audience, '
        'customData:$customData, '
        '}';
  }
}

class ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData {
  ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData({
    required this.customData,
  });

  String customData;

  @override
  String toString() {
    return '{'
        'customData:$customData, '
        '}';
  }
}

class ZegoLiveStreamingCoHostAudienceEventRequestRefusedData {
  ZegoLiveStreamingCoHostAudienceEventRequestRefusedData({
    required this.customData,
  });

  String customData;

  @override
  String toString() {
    return '{'
        'customData:$customData, '
        '}';
  }
}

class ZegoLiveStreamingCoHostAudienceEventRequestReceivedData {
  ZegoLiveStreamingCoHostAudienceEventRequestReceivedData({
    required this.host,
    required this.customData,
  });

  ZegoUIKitUser host;
  String customData;

  @override
  String toString() {
    return '{'
        'host:$host, '
        'customData:$customData, '
        '}';
  }
}
