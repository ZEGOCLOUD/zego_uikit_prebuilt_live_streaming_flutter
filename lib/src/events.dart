// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/event/defines.dart';

/// You can listen to events that you are interested in here, such as Co-hosting
class ZegoUIKitPrebuiltLiveStreamingEvents {
  /// events about user
  ZegoLiveStreamingUserEvents? user;

  /// events about room
  ZegoLiveStreamingRoomEvents? room;

  /// events about audio video
  ZegoLiveStreamingAudioVideoEvents? audioVideo;

  ZegoLiveStreamingCoHostEvents coHost;

  /// pk events
  ZegoLiveStreamingPKEvents pk;

  ZegoLiveStreamingTopMenuBarEvents topMenuBar;

  ZegoLiveStreamingMemberListEvents memberList;

  ZegoLiveStreamingInRoomMessageEvents inRoomMessage;

  ZegoLiveStreamingDurationEvents duration;

  /// Confirmation callback method before leaving the live streaming.
  ///
  /// If you want to perform more complex business logic before exiting the live streaming, such as updating some records to the backend, you can use the [onLeaveConfirmation] parameter to set it.
  /// This parameter requires you to provide a callback method that returns an asynchronous result.
  /// If you return true in the callback, the prebuilt page will quit and return to your previous page, otherwise it will be ignored.
  ///
  /// Sample Code:
  ///
  /// ``` dart
  /// onLeaveConfirmation: (
  ///     ZegoUIKitLiveStreamingLeaveConfirmationEvent event,
  ///     /// defaultAction to return to the previous page
  ///     Future<bool> Function() defaultAction,
  /// ) {
  ///   debugPrint('onLeaveConfirmation, do whatever you want');
  ///
  ///   /// you can call this defaultAction to return to the previous page,
  ///   return defaultAction.call();
  /// }
  /// ```
  /// <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/live/live_custom_confirm.gif" width=40%/>
  Future<bool> Function(
    ZegoLiveStreamingLeaveConfirmationEvent event,

    /// defaultAction to return to the previous page
    Future<bool> Function() defaultAction,
  )? onLeaveConfirmation;

  /// This callback method is called when live streaming ended(all users in live streaming will received).
  ///
  /// The default behavior of host is return to the previous page(only host) or hide the minimize page.
  /// If you override this callback, you must perform the page navigation
  /// yourself while it was in a normal state, or hide the minimize page if in minimize state.
  /// otherwise the user will remain on the live streaming page.
  /// the easy way is call `defaultAction.call()`
  ///
  /// The [ZegoLiveStreamingEndEvent.isFromMinimizing] it means that the user left the chat room while it was in a minimized state.
  /// You **can not** return to the previous page while it was **in a minimized state**!!!
  /// On the other hand, if the value of the parameter is false, it means that the user left the chat room while it was in a normal state (i.e., not minimized).
  void Function(
    ZegoLiveStreamingEndEvent event,
    VoidCallback defaultAction,
  )? onEnded;

  /// This callback method is called when live streaming state update.
  void Function(ZegoLiveStreamingState state)? onStateUpdated;

  /// error stream
  Function(ZegoUIKitError)? onError;

  ZegoUIKitPrebuiltLiveStreamingEvents({
    this.onError,
    this.onLeaveConfirmation,
    this.onEnded,
    this.onStateUpdated,
    ZegoLiveStreamingUserEvents? user,
    ZegoLiveStreamingRoomEvents? room,
    ZegoLiveStreamingAudioVideoEvents? audioVideo,
    ZegoLiveStreamingCoHostEvents? coHost,
    ZegoLiveStreamingPKEvents? pk,
    ZegoLiveStreamingTopMenuBarEvents? topMenuBar,
    ZegoLiveStreamingMemberListEvents? memberList,
    ZegoLiveStreamingInRoomMessageEvents? inRoomMessage,
    ZegoLiveStreamingDurationEvents? duration,
  })  : user = user ?? ZegoLiveStreamingUserEvents(),
        room = room ?? ZegoLiveStreamingRoomEvents(),
        audioVideo = audioVideo ?? ZegoLiveStreamingAudioVideoEvents(),
        coHost = coHost ?? ZegoLiveStreamingCoHostEvents(),
        pk = pk ?? ZegoLiveStreamingPKEvents(),
        topMenuBar = topMenuBar ?? ZegoLiveStreamingTopMenuBarEvents(),
        memberList = memberList ?? ZegoLiveStreamingMemberListEvents(),
        inRoomMessage = inRoomMessage ?? ZegoLiveStreamingInRoomMessageEvents(),
        duration = duration ?? ZegoLiveStreamingDurationEvents();
}

/// events about user
class ZegoLiveStreamingUserEvents {
  /// This callback is triggered when user enter
  void Function(ZegoUIKitUser)? onEnter;

  /// This callback is triggered when user leave
  void Function(ZegoUIKitUser)? onLeave;

  ZegoLiveStreamingUserEvents({
    this.onEnter,
    this.onLeave,
  });
}

/// events about room
class ZegoLiveStreamingRoomEvents {
  void Function(ZegoUIKitRoomState)? onStateChanged;

  ZegoLiveStreamingRoomEvents({
    this.onStateChanged,
  });
}

/// events about audio-video
class ZegoLiveStreamingAudioVideoEvents {
  /// This callback is triggered when camera state changed
  void Function(bool)? onCameraStateChanged;

  /// This callback is triggered when front camera state changed
  void Function(bool)? onFrontFacingCameraStateChanged;

  /// This callback is triggered when microphone state changed
  void Function(bool)? onMicrophoneStateChanged;

  /// This callback is triggered when audio output device changed
  void Function(ZegoUIKitAudioRoute)? onAudioOutputChanged;

  /// This callback method is called when someone requests to open your camera, typically when the host wants to open your camera.
  ///
  /// This method requires returning an asynchronous result.
  ///
  /// You can display a dialog in this callback to confirm whether to open the camera.
  ///
  /// Alternatively, you can return `true` without any processing, indicating that when someone requests to open your camera, it can be directly opened.
  ///
  /// By default, this method does nothing and returns `false`, indicating that others cannot open your camera.
  ///
  /// Example：
  ///
  /// ```dart
  ///
  ///  // eg:
  /// ..onCameraTurnOnByOthersConfirmation =
  ///     (BuildContext context) async {
  ///   const textStyle = TextStyle(
  ///     fontSize: 10,
  ///     color: Colors.white70,
  ///   );
  ///
  ///   return await showDialog(
  ///     context: context,
  ///     barrierDismissible: false,
  ///     builder: (BuildContext context) {
  ///       return AlertDialog(
  ///         backgroundColor: Colors.blue[900]!.withOpacity(0.9),
  ///         title: const Text(
  ///           'You have a request to turn on your camera',
  ///           style: textStyle,
  ///         ),
  ///         content: const Text(
  ///           'Do you agree to turn on the camera?',
  ///           style: textStyle,
  ///         ),
  ///         actions: [
  ///           ElevatedButton(
  ///             child: const Text('Cancel', style: textStyle),
  ///             onPressed: () => Navigator.of(context).pop(false),
  ///           ),
  ///           ElevatedButton(
  ///             child: const Text('OK', style: textStyle),
  ///             onPressed: () {
  ///               Navigator.of(context).pop(true);
  ///             },
  ///           ),
  ///         ],
  ///       );
  ///     },
  ///   );
  /// },
  /// ```
  Future<bool> Function(BuildContext context)?
      onCameraTurnOnByOthersConfirmation;

  /// This callback method is called when someone requests to open your microphone, typically when the host wants to open your microphone.
  ///
  /// This method requires returning an asynchronous result.
  ///
  /// You can display a dialog in this callback to confirm whether to open the microphone.
  ///
  /// Alternatively, you can return `true` without any processing, indicating that when someone requests to open your microphone, it can be directly opened.
  ///
  /// By default, this method does nothing and returns `false`, indicating that others cannot open your microphone.
  ///
  /// Example：
  ///
  /// ```dart
  ///
  ///  // eg:
  /// ..onMicrophoneTurnOnByOthersConfirmation =
  ///     (BuildContext context) async {
  ///   const textStyle = TextStyle(
  ///     fontSize: 10,
  ///     color: Colors.white70,
  ///   );
  ///
  ///   return await showDialog(
  ///     context: context,
  ///     barrierDismissible: false,
  ///     builder: (BuildContext context) {
  ///       return AlertDialog(
  ///         backgroundColor: Colors.blue[900]!.withOpacity(0.9),
  ///         title: const Text(
  ///           'You have a request to turn on your microphone',
  ///           style: textStyle,
  ///         ),
  ///         content: const Text(
  ///           'Do you agree to turn on the microphone?',
  ///           style: textStyle,
  ///         ),
  ///         actions: [
  ///           ElevatedButton(
  ///             child: const Text('Cancel', style: textStyle),
  ///             onPressed: () => Navigator.of(context).pop(false),
  ///           ),
  ///           ElevatedButton(
  ///             child: const Text('OK', style: textStyle),
  ///             onPressed: () {
  ///               Navigator.of(context).pop(true);
  ///             },
  ///           ),
  ///         ],
  ///       );
  ///     },
  ///   );
  /// },
  /// ```
  Future<bool> Function(BuildContext context)?
      onMicrophoneTurnOnByOthersConfirmation;

  ZegoLiveStreamingAudioVideoEvents({
    this.onCameraStateChanged,
    this.onFrontFacingCameraStateChanged,
    this.onMicrophoneStateChanged,
    this.onAudioOutputChanged,
    this.onCameraTurnOnByOthersConfirmation,
    this.onMicrophoneTurnOnByOthersConfirmation,
  });
}

/// CoHost Related Events
class ZegoLiveStreamingCoHostEvents {
  /// host's events about.
  ZegoLiveStreamingCoHostHostEvents host;

  /// audience's events about.
  ZegoLiveStreamingCoHostAudienceEvents audience;

  /// This callback is triggered when the maximum count of co-hosts is reached.
  void Function(int count)? onMaxCountReached;

  /// co-host updated, refers to the event where there is a change in the co-hosts.
  /// this can occur when a new co-host joins the session or when an existing co-host leaves the session.
  Function(List<ZegoUIKitUser> coHosts)? onUpdated;

  ZegoLiveStreamingCoHostEvents({
    this.onUpdated,
    this.onMaxCountReached,
    ZegoLiveStreamingCoHostHostEvents? host,
    ZegoLiveStreamingCoHostAudienceEvents? audience,
  })  : host = host ?? ZegoLiveStreamingCoHostHostEvents(),
        audience = audience ?? ZegoLiveStreamingCoHostAudienceEvents();
}

/// Host Related Events of CoHost
class ZegoLiveStreamingCoHostHostEvents {
  /// receive a request that audience request to become a co-host
  Function(ZegoUIKitUser audience)? onRequestReceived;

  /// audience cancelled the co-host request.
  Function(ZegoUIKitUser audience)? onRequestCanceled;

  /// the audience's co-host request has timed out.
  Function(ZegoUIKitUser audience)? onRequestTimeout;

  /// host accept the audience's co-host request.
  Function()? onActionAcceptRequest;

  /// host refuse the audience's co-host request.
  Function()? onActionRefuseRequest;

  /// host sent invitation to become a co-host to the audience.
  Function(ZegoUIKitUser audience)? onInvitationSent;

  /// the host's co-host invitation has timed out.
  Function(ZegoUIKitUser audience)? onInvitationTimeout;

  /// audience accepted to a co-host request from host
  void Function(ZegoUIKitUser audience)? onInvitationAccepted;

  /// audience refused to a co-host request from host
  void Function(ZegoUIKitUser audience)? onInvitationRefused;

  ZegoLiveStreamingCoHostHostEvents({
    this.onRequestReceived,
    this.onRequestCanceled,
    this.onRequestTimeout,
    this.onActionAcceptRequest,
    this.onActionRefuseRequest,
    this.onInvitationSent,
    this.onInvitationTimeout,
    this.onInvitationAccepted,
    this.onInvitationRefused,
  });
}

/// Audience Related Events of CoHost
class ZegoLiveStreamingCoHostAudienceEvents {
  /// audience requested to become a co-host to the host.
  Function()? onRequestSent;

  /// audience cancelled the co-host request.
  Function()? onActionCancelRequest;

  /// the audience's co-host request has timed out.
  Function()? onRequestTimeout;

  /// host accept the audience's co-host request.
  Function()? onRequestAccepted;

  /// host refuse the audience's co-host request.
  Function()? onRequestRefused;

  /// received a co-host invitation from the host.
  void Function(ZegoUIKitUser host)? onInvitationReceived;

  /// the host's co-host invitation has timed out.
  Function()? onInvitationTimeout;

  /// audience refuse co-host invitation from the host.
  Function()? onActionAcceptInvitation;

  /// audience refuse co-host invitation from the host.
  Function()? onActionRefuseInvitation;

  ZegoLiveStreamingCoHostAudienceEvents({
    this.onRequestSent,
    this.onActionCancelRequest,
    this.onRequestTimeout,
    this.onRequestAccepted,
    this.onRequestRefused,
    this.onInvitationReceived,
    this.onInvitationTimeout,
    this.onActionAcceptInvitation,
    this.onActionRefuseInvitation,
  });
}

/// pk related events
///
/// The [defaultAction] is the internal default behavior (popup).
/// If you override the event and still require these default actions, please execute `defaultAction.call()`.
class ZegoLiveStreamingPKEvents {
  /// Received a PK invitation from [event.fromHost], with the ID [event.requestID].
  ///
  /// When receiving a PK battle request, the Live Streaming Kit
  /// (ZegoUIKitPrebuiltLiveStreaming) defaults to check whether you are
  /// accepting the PK battle request through a pop-up window. You can
  /// receive callback notifications or customize your business logic by
  /// listening to or setting up the [onIncomingRequestReceived].
  void Function(
    ZegoIncomingPKBattleRequestReceivedEvent event,
    VoidCallback defaultAction,
  )? onIncomingRequestReceived;

  /// The received PK invitation has been canceled by the inviting host [event.fromHost].
  ///
  /// You can receive callback notifications or customize your business logic
  /// by listening to or setting up the [onIncomingRequestCancelled]
  /// when the PK battle request has been canceled.
  Function(
    ZegoIncomingPKBattleRequestCancelledEvent event,
    VoidCallback defaultAction,
  )? onIncomingRequestCancelled;

  /// The received PK invitation has timed out.
  ///
  /// You can receive callback notifications or customize your business logic
  /// by listening to or setting up the [onIncomingRequestTimeout]
  /// when the received PK battle request has timed out.
  void Function(
    ZegoIncomingPKBattleRequestTimeoutEvent event,
    VoidCallback defaultAction,
  )? onIncomingRequestTimeout;

  /// The PK invitation to [event.fromHost] has been accepted.
  ///
  /// When the sent PK battle request is accepted, the Live Streaming Kit
  /// (ZegoUIKitPrebuiltLiveStreaming) starts the PK battle by default.
  /// Once it starts, you can receive callback notifications or customize
  /// your business logic by listening to or setting up the [onOutgoingRequestAccepted].
  void Function(
    ZegoOutgoingPKBattleRequestAcceptedEvent event,
    VoidCallback defaultAction,
  )? onOutgoingRequestAccepted;

  /// The PK invitation to [event.fromHost] has been rejected.
  ///
  /// When the sent PK battle request is rejected, the default behaviour is
  /// notify you that the host has rejected your PK battle request through a pop-up window.
  /// You can receive callback notifications or customize your business logic
  /// by listening to or setting up the [onOutgoingRequestRejected].
  ///
  /// The PK battle request will be rejected automatically when the invited host is in a busy state.
  /// Busy state: the host has not initiated his live stream yet, the host is
  /// in a PK battle with others, the host is being invited, and the host is sending a PK battle request to others.
  void Function(
    ZegoOutgoingPKBattleRequestRejectedEvent event,
    VoidCallback defaultAction,
  )? onOutgoingRequestRejected;

  /// Your PK invitation has been timeout
  ///
  /// If the invited host didn't respond after the timeout duration, the PK
  /// battle request timed out by default. While the Live Streaming Kit
  /// updates the internal state while won't trigger any default behaviors.
  /// You can receive callback notifications or customize your business
  /// logic by listening to or setting up the onOutgoingPKBattleRequestTimeout.
  void Function(
    ZegoOutgoingPKBattleRequestTimeoutEvent event,
    VoidCallback defaultAction,
  )? onOutgoingRequestTimeout;

  /// PK invitation had been ended by [event.fromHost]
  void Function(
    ZegoPKBattleEndedEvent event,
    VoidCallback defaultAction,
  )? onEnded;

  /// PK host offline
  void Function(
    ZegoPKBattleUserOfflineEvent event,
    VoidCallback defaultAction,
  )? onUserOffline;

  /// PK host quit
  void Function(
    ZegoPKBattleUserQuitEvent event,
    VoidCallback defaultAction,
  )? onUserQuited;

  /// pk user enter
  void Function(ZegoUIKitUser user)? onUserJoined;

  /// pk user disconnect events
  void Function(ZegoUIKitUser user)? onUserDisconnected;
  void Function(ZegoUIKitUser user)? onUserReconnecting;
  void Function(ZegoUIKitUser user)? onUserReconnected;

  ZegoLiveStreamingPKEvents({
    this.onIncomingRequestReceived,
    this.onIncomingRequestCancelled,
    this.onIncomingRequestTimeout,
    this.onOutgoingRequestAccepted,
    this.onOutgoingRequestRejected,
    this.onOutgoingRequestTimeout,
    this.onEnded,
    this.onUserOffline,
    this.onUserQuited,
    this.onUserJoined,
    this.onUserDisconnected,
    this.onUserReconnecting,
    this.onUserReconnected,
  });
}

class ZegoLiveStreamingTopMenuBarEvents {
  ZegoLiveStreamingTopMenuBarEvents({
    this.onHostAvatarClicked,
  });

  /// You can listen to the event of clicking on the host information in the top left corner.
  /// For example, if you want to display a popup or dialog with host information after it is clicked.
  ///
  /// ```dart
  /// onHostAvatarClicked = (host) {
  ///   // do your own things.
  ///
  /// }
  /// ```
  void Function(ZegoUIKitUser host)? onHostAvatarClicked;
}

class ZegoLiveStreamingMemberListEvents {
  ZegoLiveStreamingMemberListEvents({
    this.onClicked,
  });

  /// You can listen to the user click event on the member list,
  /// for example, if you want to display specific information about a member after they are clicked.
  void Function(ZegoUIKitUser user)? onClicked;
}

class ZegoLiveStreamingInRoomMessageEvents {
  ZegoLiveStreamingInRoomMessageEvents({
    this.onLocalSend,
    this.onClicked,
    this.onLongPress,
  });

  /// Local message sending callback, This callback method is called when a message is sent successfully or fails to send.
  ZegoInRoomMessageViewItemPressEvent? onLocalSend;

  /// Triggered when has click on the message item
  ZegoInRoomMessageViewItemPressEvent? onClicked;

  /// Triggered when a pointer has remained in contact with the message item at
  /// the same location for a long period of time.
  ZegoInRoomMessageViewItemPressEvent? onLongPress;
}

class ZegoLiveStreamingDurationEvents {
  ZegoLiveStreamingDurationEvents({
    this.onUpdate,
  });

  /// Call timing callback function, called every second.
  ///
  /// Example: Set to automatically leave after 5 minutes.
  ///```dart
  /// ..duration.onUpdate = (Duration duration) {
  ///   if (duration.inSeconds >= 5 * 60) {
  ///     ZegoUIKitPrebuiltLiveStreamingController().leave(context);
  ///   }
  /// }
  /// ```
  void Function(Duration)? onUpdate;
}
