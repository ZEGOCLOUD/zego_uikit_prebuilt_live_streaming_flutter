# ZegoUIKitPrebuiltLiveStreamingEvents

- [onLeaveConfirmation](#onleaveconfirmation)
- [onEnded](#onended)
- [onStateUpdated](#onstateupdated)
- [onError](#onerror)
- [user](#zegouikitprebuiltlivestreaminguserevents)
  - [onEnter](#onenter)
  - [onLeave](#onleave)
- [room](#zegouikitprebuiltlivestreamingroomevents)
  - [onStateChanged](#onstatechanged)
  - [onTokenExpired](#ontokenexpired)
- [audioVideo](#zegouikitprebuiltlivestreamingaudiovideoevents)
  - [onCameraStateChanged](#oncamerastatechanged)
  - [onFrontFacingCameraStateChanged](#onfrontfacingcamerastatechanged)
  - [onMicrophoneStateChanged](#onmicrophonestatechanged)
  - [onAudioOutputChanged](#onaudiooutputchanged)
  - [onCameraTurnOnByOthersConfirmation](#oncameraturnonbyothersconfirmation)
  - [onMicrophoneTurnOnByOthersConfirmation](#onmicrophoneturnonbyothersconfirmation)
- [coHost](#cohost)
  - [onMaxCountReached](#onmaxcountreached)
  - [onUpdated](#onupdated)
  - [host](#host)
    - [onRequestReceived](#onrequestreceived)
    - [onRequestCanceled](#onrequestcanceled)
    - [onRequestTimeout](#onrequesttimeout)
    - [onActionAcceptRequest](#onactionacceptrequest)
    - [onActionRefuseRequest](#onactionrefuserequest)
    - [onInvitationSent](#oninvitationsent)
    - [onInvitationTimeout](#oninvitationtimeout)
    - [onInvitationAccepted](#oninvitationaccepted)
    - [onInvitationRefused](#oninvitationrefused)
  - [audience](#audience)
    - [onRequestSent](#onrequestsent)
    - [onActionCancelRequest](#onactioncancelrequest)
    - [onRequestTimeout](#onrequesttimeout-2)
    - [onRequestAccepted](#onrequestaccepted)
    - [onRequestRefused](#onrequestrefused)
    - [onInvitationReceived](#oninvitationreceived)
    - [onInvitationTimeout](#oninvitationtimeout-2)
    - [onActionAcceptInvitation](#onactionacceptinvitation)
    - [onActionRefuseInvitation](#onactionrefuseinvitation)
  - [coHost](#cohost-2)
    - [onLocalConnectStateUpdated](#onlocalconnectstateupdated)
    - [onLocalConnected](#onlocalconnected)
    - [onLocalDisconnected](#onlocaldisconnected)
- [pk](#pk)
  - [onIncomingRequestReceived](#onincomingrequestreceived)
  - [onIncomingRequestCancelled](#onincomingrequestcancelled)
  - [onIncomingRequestTimeout](#onincomingrequesttimeout)
  - [onOutgoingRequestAccepted](#onoutgoingrequestaccepted)
  - [onOutgoingRequestRejected](#onoutgoingrequestrejected)
  - [onOutgoingRequestTimeout](#onoutgoingrequesttimeout)
  - [onEnded](#onended-2)
  - [onUserOffline](#onuseroffline)
  - [onUserQuited](#onuserquited)
  - [onUserJoined](#onuserjoined)
  - [onUserDisconnected/onUserReconnecting/onUserReconnected](#onuserdisconnectedonuserreconnectingonuserreconnected)
- [topMenuBar](#topmenubar)
  - [onHostAvatarClicked](#onhostavatarclicked)
- [memberList](#memberlist)
  - [onClicked](#onclicked)
- [inRoomMessage](#inroommessage)
  - [onLocalSend](#onlocalsend)
  - [onClicked](#onclicked-2)
  - [onLongPress](#onlongpress)
- [duration](#duration)
  - [onUpdate](#onupdate)
- [media](#media)

---

# onLeaveConfirmation

>
>
> Confirmation callback method before leaving the live streaming.
>
> If you want to perform more complex business logic before exiting the
live streaming, such as updating some records to the backend, you can use the [onLeaveConfirmation] parameter to set it.
>
> This parameter requires you to provide a callback method that returns an
asynchronous result.
>
> If you return true in the callback, the prebuilt page will quit and
return to your previous page, otherwise it will be ignored.
>
> ![live_custom_confirm](https://doc.oa.zego.im/Pics/ZegoUIKit/live/live_custom_confirm.gif)
>
>- function prototype:
>```dart
> Future<bool> Function(
>    ZegoLiveStreamingLeaveConfirmationEvent event,
>
>    /// defaultAction to return to the previous page
>    Future<bool> Function() defaultAction,
> )? onLeaveConfirmation
>
> class ZegoLiveStreamingLeaveConfirmationEvent {
>   BuildContext context;
> }
>
>```
>
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     onLeaveConfirmation: (
>       ZegoLiveStreamingLeaveConfirmationEvent event,
> 
>       /// defaultAction to return to the previous page
>       Future<bool> Function() defaultAction,
>     ) {
>       debugPrint('onLeaveConfirmation, do whatever you want');
> 
>       /// you can call this defaultAction to return to the previous page,
>       return defaultAction.call();
>     },
>   ),
>   ...
> );
>```

# onEnded

>
> This callback method is called when live streaming ended(all users in live
streaming will received).
>
> The default behavior of host is return to the previous page(only host!!).
> If you override this callback, you must perform the page navigation
yourself while it was in a normal state,
> otherwise the user will remain on the live streaming page.
>
> The `ZegoLiveStreamingEndEvent.isFromMinimizing` it means that the
user left the chat room while it was in a minimized state.
> You **can not** return to the previous page while it was **in a minimized
state**!!!
> On the other hand, if the value of the parameter is false, it means that
the user left the chat room while it was in a normal state (i.e., not minimized).
>
>- function prototype:
>```dart
>  void Function(
>    ZegoLiveStreamingEndEvent event,
>    VoidCallback defaultAction,
>  )? onLiveStreamingEnded
>
>
> class ZegoLiveStreamingEndEvent {
>   /// the user ID of who kick you out
>   String? kickerUserID;
> 
>   /// end reason
>   ZegoLiveStreamingEndReason reason;
> 
>   /// The `isFromMinimizing` it means that the user left the live streaming
>   /// while it was in a minimized state.
>   ///
>   /// You **can not** return to the previous page while it was **in a minimized state**!!!
>   /// just hide the minimize page by `ZegoUIKitPrebuiltLiveStreamingController().minimize.hide()`
>   ///
>   /// On the other hand, if the value of the parameter is false, it means
>   /// that the user left the live streaming while it was not minimized.
>   bool isFromMinimizing;
> }
>```
>
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     onEnded: (
>       ZegoLiveStreamingEndEvent event,
>       VoidCallback defaultAction,
>     ) {
>       debugPrint('onLiveStreamingEnded, do whatever you want');
> 
>       /// you can call this defaultAction to return to the previous page,
>       return defaultAction.call();
>     },
>   ),
>   ...
> );
>```
>

# onStateUpdated

>
> This callback method is called when live streaming state update.
>
>- function prototype:
>```dart
>void Function(ZegoLiveStreamingState state)? onLiveStreamingStateUpdate
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     onStateUpdated: (
>       ZegoLiveStreamingState state,
>     ) {
>     },
>   ),
>   ...
> );
>```

# onError

>
> error stream
>
>- function prototype:
>```dart
>Function(ZegoUIKitError)? onError
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     onError: (
>       ZegoUIKitError error,
>     ) {
>     },
>   ),
>   ...
> );
>```

# ZegoLiveStreamingUserEvents

>
> events about user

## onEnter

>
> This callback is triggered when user enter
>
>- function prototype:
>```dart
>void Function(ZegoUIKitUser)? onEnter;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>       user: ZegoLiveStreamingUserEvents(
>           onEnter: (user) {
>               ...
>           },
>       ),
>   ),
>);
>```

## onLeave

>
> This callback is triggered when user leave
>- function prototype:
>```dart
>void Function(ZegoUIKitUser)? onLeave;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>       user: ZegoLiveStreamingUserEvents(
>           onLeave: (user) {
>               ...
>           },
>       ),
>   ),
>);
>```

# ZegoLiveStreamingRoomEvents

>
> events about room

## onStateChanged

>
> This callback is triggered when room state changed, you can get the current call room entry status by using the **state.reason**.
>
>- function prototype:
>```dart
>void Function(ZegoUIKitRoomState)? onStateChanged;
>
>class ZegoUIKitRoomState {
>  ///  Room state change reason.
>  ZegoRoomStateChangedReason reason;
>
>  /// Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for >details.
>  int errorCode;
>
>  /// Extended Information with state updates. When the room login is successful, the key >"room_session_id" can be used to obtain the unique RoomSessionID of each audio and video communication, >which identifies the continuous communication from the first user in the room to the end of the audio and >video communication. It can be used in scenarios such as call quality scoring and call problem diagnosis.
>  Map<String, dynamic> extendedData;
>}
>
>/// Room state change reason.
>enum ZegoRoomStateChangedReason {
>  /// Logging in to the room. When calling [loginRoom] to log in to the room or [switchRoom] to switch to >the target room, it will enter this state, indicating that it is requesting to connect to the server. The >application interface is usually displayed through this state.
>  Logining,
>
>  /// Log in to the room successfully. When the room is successfully logged in or switched, it will enter >this state, indicating that the login to the room has been successful, and users can normally receive >callback notifications of other users in the room and all stream information additions and deletions.
>  Logined,
>
>  /// Failed to log in to the room. When the login or switch room fails, it will enter this state, >indicating that the login or switch room has failed, for example, AppID or Token is incorrect, etc.
>  LoginFailed,
>
>  /// The room connection is temporarily interrupted. If the interruption occurs due to poor network >quality, the SDK will retry internally.
>  Reconnecting,
>
>  /// The room is successfully reconnected. If there is an interruption due to poor network quality, the >SDK will retry internally, and enter this state after successful reconnection.
>  Reconnected,
>
>  /// The room fails to reconnect. If there is an interruption due to poor network quality, the SDK will >retry internally, and enter this state after the reconnection fails.
>  ReconnectFailed,
>
>  /// Kicked out of the room by the server. For example, if you log in to the room with the same user >name in other places, and the local end is kicked out of the room, it will enter this state.
>  KickOut,
>
>  /// Logout of the room is successful. It is in this state by default before logging into the room. When >calling [logoutRoom] to log out of the room successfully or [switchRoom] to log out of the current room >successfully, it will enter this state.
>  Logout,
>
>  /// Failed to log out of the room. Enter this state when calling [logoutRoom] fails to log out of the >room or [switchRoom] fails to log out of the current room internally.
>  LogoutFailed
>}
>```
>- example:
>```dart
>ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>       user: ZegoLiveStreamingRoomEvents(
>           onStateChanged: (state) {
>               ...
>           },
>       ),
>   ),
>);
>```

## onTokenExpired

>
> This callback is triggered when the room token expires.
>
>- function prototype:
>```dart
>void Function()? onTokenExpired
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     room: ZegoLiveStreamingRoomEvents(
>       onTokenExpired: () {
>         // handle token expired
>       },
>     ),
>   ),
>   ...
> );
>```

# ZegoLiveStreamingAudioVideoEvents

>
> events about audio video

## onCameraStateChanged

>
> This callback is triggered when camera state changed
>
>- function prototype:
>``` dart
>void Function(bool)? onCameraStateChanged;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>       audioVideo: ZegoLiveStreamingAudioVideoEvents(
>           onCameraStateChanged: (isOpened) {
>               ...
>           },
>       ),
>   ),
>);
>```

## onFrontFacingCameraStateChanged

>
> This callback is triggered when front camera state changed
>
>- function prototype:
>``` dart
>void Function(bool)? onFrontFacingCameraStateChanged;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>       audioVideo: ZegoLiveStreamingAudioVideoEvents(
>           onFrontFacingCameraStateChanged: (isFronted) {
>               ...
>           },
>       ),
>   ),
>);
>```

## onMicrophoneStateChanged

>
> This callback is triggered when microphone state changed
>
>- function prototype:
>``` dart
>void Function(bool)? onMicrophoneStateChanged;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>       audioVideo: ZegoLiveStreamingAudioVideoEvents(
>           onMicrophoneStateChanged: (isOpened) {
>               ...
>           },
>       ),
>   ),
>);
>```

## onAudioOutputChanged

>
> This callback is triggered when audio output device changed
>
>- function prototype:
>``` dart
>void Function(ZegoUIKitAudioRoute)? onAudioOutputChanged;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>       audioVideo: ZegoLiveStreamingAudioVideoEvents(
>           onAudioOutputChanged: (audioRoute) {
>               ...
>           },
>       ),
>   ),
>);
>```

## onCameraTurnOnByOthersConfirmation

>
> This callback method is called when someone requests to open your camera,
typically when the host wants to open your camera.
>
> This method requires returning an asynchronous result.
>
> You can display a dialog in this callback to confirm whether to open the
camera.
>
> Alternatively, you can return `true` without any processing, indicating
that when someone requests to open your camera, it can be directly opened.
>
> By default, this method does nothing and returns `false`, indicating that
others cannot open your camera.
>
> Example：
>
> ```dart
>
>  // eg:
> ..onCameraTurnOnByOthersConfirmation =
>     (BuildContext context) async {
>   const textStyle = TextStyle(
>     fontSize: 10,
>     color: Colors.white70,
>   );
>
>   return await showDialog(
>     context: context,
>     barrierDismissible: false,
>     builder: (BuildContext context) {
>       return AlertDialog(
>         backgroundColor: Colors.blue[900]!.withOpacity(0.9),
>         title: const Text(
>           'You have a request to turn on your camera',
>           style: textStyle,
>         ),
>         content: const Text(
>           'Do you agree to turn on the camera?',
>           style: textStyle,
>         ),
>         actions: [
>           ElevatedButton(
>             child: const Text('Cancel', style: textStyle),
>             onPressed: () => Navigator.of(context).pop(false),
>           ),
>           ElevatedButton(
>             child: const Text('OK', style: textStyle),
>             onPressed: () {
>               Navigator.of(context).pop(true);
>             },
>           ),
>         ],
>       );
>     },
>   );
> },
> ```
>
>- function prototype:
>```dart
>Future<bool> Function(BuildContext context)? onCameraTurnOnByOthersConfirmation
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     audioVideo: ZegoLiveStreamingAudioVideoEvents(
>       onCameraTurnOnByOthersConfirmation: (
>         BuildContext contex,
>       ) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onMicrophoneTurnOnByOthersConfirmation

>
> This callback method is called when someone requests to open your
microphone, typically when the host wants to open your microphone.
>
> This method requires returning an asynchronous result.
>
> You can display a dialog in this callback to confirm whether to open the
microphone.
>
> Alternatively, you can return `true` without any processing, indicating
that when someone requests to open your microphone, it can be directly opened.
>
> By default, this method does nothing and returns `false`, indicating that
others cannot open your microphone.
>
> Example：
>
> ```dart
>
>  // eg:
> ..onMicrophoneTurnOnByOthersConfirmation =
>     (BuildContext context) async {
>   const textStyle = TextStyle(
>     fontSize: 10,
>     color: Colors.white70,
>   );
>
>   return await showDialog(
>     context: context,
>     barrierDismissible: false,
>     builder: (BuildContext context) {
>       return AlertDialog(
>         backgroundColor: Colors.blue[900]!.withOpacity(0.9),
>         title: const Text(
>           'You have a request to turn on your microphone',
>           style: textStyle,
>         ),
>         content: const Text(
>           'Do you agree to turn on the microphone?',
>           style: textStyle,
>         ),
>         actions: [
>           ElevatedButton(
>             child: const Text('Cancel', style: textStyle),
>             onPressed: () => Navigator.of(context).pop(false),
>           ),
>           ElevatedButton(
>             child: const Text('OK', style: textStyle),
>             onPressed: () {
>               Navigator.of(context).pop(true);
>             },
>           ),
>         ],
>       );
>     },
>   );
> },
> ```
>
>- function prototype:
>```dart
>Future<bool> Function(BuildContext context)? onMicrophoneTurnOnByOthersConfirmation
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     audioVideo: ZegoLiveStreamingAudioVideoEvents(
>       onMicrophoneTurnOnByOthersConfirmation: (
>         context,
>       ) {
>       },
>     ),
>   ),
>   ...
> );
>```

# coHost

## onMaxCountReached

>
> This callback is triggered when the maximum count of co-hosts is reached.
>
>- function prototype:
>```dart
>void Function(int)? onMaxReached
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       onMaxCountReached: (int count) {
>
>       },
>     ),
>   ),
>   ...
> );
>```

## onUpdated

>
> co-host updated, refers to the event where there is a change in the
co-hosts.
> this can occur when a new co-host joins the session or when an existing
>
>- function prototype:
>```dart
>Function(List<ZegoUIKitUser> coHosts)? onUpdated
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       onUpdated: (List<ZegoUIKitUser> coHosts) {
>
>       },
>     ),
>   ),
>   ...
> );
>```

## host

>
> Host Related Events

### onRequestReceived

>
> receive a request that audience request to become a co-host
>
>- function prototype:
>```dart
>Function(ZegoLiveStreamingCoHostHostEventRequestReceivedData data)? onRequestReceived
>
> class ZegoLiveStreamingCoHostHostEventRequestReceivedData {
>   ZegoUIKitUser audience;
>   String customData;
> }
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       host: ZegoLiveStreamingHostEvents(
>         onRequestReceived: (ZegoLiveStreamingCoHostHostEventRequestReceivedData data) {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onRequestCanceled

>
> audience cancelled the co-host request.
>
>- function prototype:
>```dart
>Function(ZegoLiveStreamingCoHostHostEventRequestCanceledData data)? onRequestCanceled
>
> class ZegoLiveStreamingCoHostHostEventRequestCanceledData {
>   ZegoUIKitUser audience;
>   String customData;
> }
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       host: ZegoLiveStreamingHostEvents(
>         onRequestCanceled: (ZegoLiveStreamingCoHostHostEventRequestCanceledData data) {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onRequestTimeout

>
> the audience's co-host request has timed out.
>
>- function prototype:
>```dart
>Function(ZegoLiveStreamingCoHostHostEventRequestTimeoutData data)? onRequestTimeout
>
> class ZegoLiveStreamingCoHostHostEventRequestTimeoutData {
>   ZegoUIKitUser audience;
> }

>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       host: ZegoLiveStreamingHostEvents(
>         onRequestTimeout: (ZegoLiveStreamingCoHostHostEventRequestTimeoutData data) {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onActionAcceptRequest

>
> host accept the audience's co-host request.
>
>- function prototype:
>```dart
>Function()? onActionAcceptRequest
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       host: ZegoLiveStreamingHostEvents(
>         onActionAcceptRequest: () {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onActionRefuseRequest

>
> host refuse the audience's co-host request.
>
>- function prototype:
>```dart
>Function()? onActionRefuseRequest
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       host: ZegoLiveStreamingHostEvents(
>         onActionRefuseRequest: () {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onInvitationSent

>
> host sent invitation to become a co-host to the audience.
>
>- function prototype:
>```dart
>Function(ZegoLiveStreamingCoHostHostEventInvitationSentData data)? onInvitationSent
>
> class ZegoLiveStreamingCoHostHostEventInvitationSentData {
>   ZegoUIKitUser audience;
> }
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       host: ZegoLiveStreamingHostEvents(
>         onInvitationSent: (ZegoLiveStreamingCoHostHostEventInvitationSentData data) {
>         },
>       ),
>     ),,
>   ),
>   ...
> );
>```

### onInvitationTimeout

>
> the host's co-host invitation has timed out.
>
>- function prototype:
>```dart
>Function(ZegoLiveStreamingCoHostHostEventInvitationTimeoutData data)? onInvitationTimeout
>
> class ZegoLiveStreamingCoHostHostEventInvitationTimeoutData {
>   ZegoUIKitUser audience;
> }
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       host: ZegoLiveStreamingHostEvents(
>         onInvitationTimeout: (ZegoLiveStreamingCoHostHostEventInvitationTimeoutData data) {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onInvitationAccepted

>
> audience accepted to a co-host request from host
>
>- function prototype:
>```dart
>void Function(ZegoLiveStreamingCoHostHostEventInvitationAcceptedData data)? onInvitationAccepted
>
> class ZegoLiveStreamingCoHostHostEventInvitationAcceptedData {
>   ZegoUIKitUser audience;
>   String customData;
> }
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       host: ZegoLiveStreamingHostEvents(
>         onInvitationAccepted: (ZegoLiveStreamingCoHostHostEventInvitationAcceptedData data) {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onInvitationRefused

>
> audience refused to a co-host request from host
>
>- function prototype:
>```dart
>void Function(ZegoLiveStreamingCoHostHostEventInvitationRefusedData data)? onInvitationRefused
>
> class ZegoLiveStreamingCoHostHostEventInvitationRefusedData {
>   ZegoUIKitUser audience;
>   String customData;
> }
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       host: ZegoLiveStreamingHostEvents(
>         onInvitationRefused: (ZegoLiveStreamingCoHostHostEventInvitationRefusedData data) {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

## audience

>
> Audience Related Events

### onRequestSent

>
> audience requested to become a co-host to the host.
>
>- function prototype:
>```dart
>Function()? onRequestSent
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       audience: ZegoLiveStreamingAudienceEvents(
>         onRequestSent: () {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onActionCancelRequest

>
> audience cancelled the co-host request.
>
>- function prototype:
>```dart
>Function()? onActionCancelRequest
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       audience: ZegoLiveStreamingAudienceEvents(
>         onActionCancelRequest: () {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onRequestTimeout

>
> the audience's co-host request has timed out.
>
>- function prototype:
>```dart
>Function()? onRequestTimeout
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       audience: ZegoLiveStreamingAudienceEvents(
>         onRequestTimeout: () {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onRequestAccepted

>
> host accept the audience's co-host request.
>
>- function prototype:
>```dart
>Function(ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData data)? onRequestAccepted
>
> class ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData {
>   String customData;
> }
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       audience: ZegoLiveStreamingAudienceEvents(
>         onRequestAccepted: (ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData data) {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onRequestRefused

>
> host refuse the audience's co-host request.
>
>- function prototype:
>```dart
>Function(ZegoLiveStreamingCoHostAudienceEventRequestRefusedData data)? onRequestRefused
>
> class ZegoLiveStreamingCoHostAudienceEventRequestRefusedData {
>   String customData;
> }
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       audience: ZegoLiveStreamingAudienceEvents(
>         onRequestRefused: (ZegoLiveStreamingCoHostAudienceEventRequestRefusedData data) {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onInvitationReceived

>
> received a co-host invitation from the host.
>
>- function prototype:
>```dart
>void Function(ZegoLiveStreamingCoHostAudienceEventRequestReceivedData data)? onInvitationReceived
>
> class ZegoLiveStreamingCoHostAudienceEventRequestReceivedData {
>   ZegoUIKitUser host;
>   String customData;
> }
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       audience: ZegoLiveStreamingAudienceEvents(
>         onInvitationReceived: (ZegoLiveStreamingCoHostAudienceEventRequestReceivedData data) {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onInvitationTimeout

>
> the host's co-host invitation has timed out.
>
>- function prototype:
>```dart
>Function()? onInvitationTimeout
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       audience: ZegoLiveStreamingAudienceEvents(
>         onInvitationTimeout: () {
>         },
>       ),
>     ),
>   ),
>   ...
> );
>```

### onActionAcceptInvitation

>
> audience refuse co-host invitation from the host.
>
>- function prototype:
>```dart
>Function()? onActionAcceptInvitation
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       audience: ZegoLiveStreamingAudienceEvents(
>         onActionAcceptInvitation: () {
>         },
>       ),
>     ),  
>   ),
>   ...
> );
>```

### onActionRefuseInvitation

>
> audience refuse co-host invitation from the host.
>
>- function prototype:
>```dart
>Function()? onActionRefuseInvitation
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       audience: ZegoLiveStreamingAudienceEvents(
>         onActionRefuseInvitation: () {
>         },
>       ),
>     ),  
>   ),
>   ...
> );
>```


## coHost

### onLocalConnectStateUpdated

>
> local connect state updated
>
>- function prototype:
>```dart
>Function(ZegoLiveStreamingAudienceConnectState)? onLocalConnectStateUpdated
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       coHost: ZegoLiveStreamingCoHostCoHostEvents(
>         onLocalConnectStateUpdated: (state) {
>         },
>       ),
>     ),  
>   ),
>   ...
> );
>```

### onLocalConnected

>
> Audience becomes Cohost
>
>- function prototype:
>```dart
>Function()? onLocalConnected
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       coHost: ZegoLiveStreamingCoHostCoHostEvents(
>         onLocalConnected: () {
>         },
>       ),
>     ),  
>   ),
>   ...
> );
>```

### onLocalDisconnected

>
> Cohost becomes Audience
>
>- function prototype:
>```dart
>Function()? onLocalDisconnected
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     coHost: ZegoLiveStreamingCoHostEvents(
>       coHost: ZegoLiveStreamingCoHostCoHostEvents(
>         onLocalDisconnected: () {
>         },
>       ),
>     ),  
>   ),
>   ...
> );
>```


# pk

>
> pk related events
>
> The `defaultAction` is the internal default behavior (popup).
> If you override the event and still require these default actions, please execute `defaultAction.call()`.

## onIncomingRequestReceived

>
> Received a PK invitation from `event.fromHost`, with the ID `event.requestID`.
>
> When receiving a PK battle request, the Live Streaming Kit
> (ZegoUIKitPrebuiltLiveStreaming) defaults to check whether you are
> accepting the PK battle request through a pop-up window. You can
> receive callback notifications or customize your business logic by
> listening to or setting up the `onIncomingRequestReceived`.
>
>- function prototype:
>```dart
>  void Function(
>    ZegoIncomingPKBattleRequestReceivedEvent event,
>    VoidCallback defaultAction,
>  )? onIncomingRequestReceived
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onIncomingRequestReceived: (
>         ZegoIncomingPKBattleRequestReceivedEvent event,
>         VoidCallback defaultAction,
>     ) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onIncomingRequestCancelled

>
> The received PK invitation has been canceled by the inviting host `event.fromHost`.
>
> You can receive callback notifications or customize your business logic
> by listening to or setting up the `onIncomingRequestCancelled`
> when the PK battle request has been canceled.
>
>- function prototype:
>```dart
>Function(
>    ZegoIncomingPKBattleRequestCancelledEvent event,
>    VoidCallback defaultAction,
>  )? onIncomingRequestCancelled
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onIncomingRequestCancelled: (
>         ZegoIncomingPKBattleRequestCancelledEvent event,
>         VoidCallback defaultAction,
>     ) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onIncomingRequestTimeout

>
> The received PK invitation has timed out.
>
> You can receive callback notifications or customize your business logic
> by listening to or setting up the `onIncomingRequestTimeout`
> when the received PK battle request has timed out.
>
>- function prototype:
>```dart
>void Function(
>    ZegoIncomingPKBattleRequestTimeoutEvent event,
>    VoidCallback defaultAction,
>  )? onIncomingRequestTimeout
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onIncomingRequestTimeout: (
>         ZegoIncomingPKBattleRequestTimeoutEvent event,
>         VoidCallback defaultAction,
>     ) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onOutgoingRequestAccepted

>
> The PK invitation to `event.fromHost` has been accepted.
>
> When the sent PK battle request is accepted, the Live Streaming Kit
> (ZegoUIKitPrebuiltLiveStreaming) starts the PK battle by default.
> Once it starts, you can receive callback notifications or customize
> your business logic by listening to or setting up the `onOutgoingRequestAccepted`.
>
>- function prototype:
>```dart
>void Function(
>    ZegoOutgoingPKBattleRequestAcceptedEvent event,
>    VoidCallback defaultAction,
>  )? onOutgoingRequestAccepted
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onOutgoingRequestAccepted: (
>         ZegoOutgoingPKBattleRequestAcceptedEvent event,
>         VoidCallback defaultAction,
>     ) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onOutgoingRequestRejected

>
> The PK invitation to `event.fromHost` has been rejected.
>
> When the sent PK battle request is rejected, the default behaviour is
> notify you that the host has rejected your PK battle request through a
pop-up window.
> You can receive callback notifications or customize your business logic
> by listening to or setting up the `onOutgoingRequestRejected`.
>
> The PK battle request will be rejected automatically when the invited
host is in a busy state.
> Busy state: the host has not initiated his live stream yet, the host is
> in a PK battle with others, the host is being invited, and the host is
sending a PK battle request to others.
>
>- function prototype:
>```dart
>void Function(
>    ZegoOutgoingPKBattleRequestRejectedEvent event,
>    VoidCallback defaultAction,
>  )? onOutgoingRequestRejected
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onOutgoingRequestRejected: (
>         ZegoOutgoingPKBattleRequestRejectedEvent event,
>         VoidCallback defaultAction,
>     ) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onOutgoingRequestTimeout

>
> Your PK invitation has been timeout
>
> If the invited host didn't respond after the timeout duration, the PK
> battle request timed out by default. While the Live Streaming Kit
> updates the internal state while won't trigger any default behaviors.
> You can receive callback notifications or customize your business
> logic by listening to or setting up the onOutgoingRequestTimeout.
>
>- function prototype:
>```dart
>void Function(
>    ZegoOutgoingPKBattleRequestTimeoutEvent event,
>    VoidCallback defaultAction,
>  )? onOutgoingRequestTimeout
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onOutgoingRequestTimeout: (
>         ZegoOutgoingPKBattleRequestTimeoutEvent event,
>         VoidCallback defaultAction,
>     ) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onEnded

>
> PK invitation had been ended by `event.fromHost`
>
>- function prototype:
>```dart
>void Function(
>    ZegoPKBattleEndedEvent event,
>    VoidCallback defaultAction,
>  )? onEnded
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onEnded: (
>         ZegoPKBattleEndedEvent event,
>         VoidCallback defaultAction,
>     ) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onUserOffline

>
> PK host offline
>
>- function prototype:
>```dart
>void Function(
>    ZegoPKBattleUserOfflineEvent event,
>    VoidCallback defaultAction,
>  )? onUserOffline
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onUserOffline: (
>         ZegoPKBattleUserOfflineEvent event,
>         VoidCallback defaultAction,
>     ) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onUserQuited

>
> PK host quit
>
>- function prototype:
>```dart
>void Function(
>    ZegoPKBattleUserQuitEvent event,
>    VoidCallback defaultAction,
>  )? onUserQuited
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onUserQuited: (
>         ZegoPKBattleUserQuitEvent event,
>         VoidCallback defaultAction,
>     ) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onUserJoined

>
> pk user enter
>
>- function prototype:
>```dart
>void Function(ZegoUIKitUser user)? onUserJoined
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onUserJoined: (ZegoUIKitUser user) {
>       },
>     ),
>   ),
>   ...
> );
>```

## onUserDisconnected/onUserReconnecting/onUserReconnected

>
> pk user enter
>
>- function prototype:
>```dart
>void Function(ZegoUIKitUser user)? onUserDisconnected;
>void Function(ZegoUIKitUser user)? onUserReconnecting;
>void Function(ZegoUIKitUser user)? onUserReconnected;
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     pk: ZegoLiveStreamingPKEvents(
>       onUserDisconnected: (ZegoUIKitUser user) {
>       },
>       onUserReconnecting: (ZegoUIKitUser user) {
>       },
>       onUserReconnected: (ZegoUIKitUser user) {
>       },
>     ),
>   ),
>   ...
> );
>```

# topMenuBar

## onHostAvatarClicked

>
> You can listen to the event of clicking on the host information in the top left corner.
>
>- function prototype:
>```dart
>void Function(ZegoUIKitUser host)? onHostAvatarClicked
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     topMenuBar: ZegoLiveStreamingTopMenuBarEvents(
>       onHostAvatarClicked: (ZegoUIKitUser) {
>
>       },
>     ),
>   ),
>   ...
> );
>```

# memberList

## onClicked

>
> Local message sending callback, This callback method is called when a message is sent successfully or fails to send.
>
>- function prototype:
>```dart
>void Function(ZegoUIKitUser user)? onClicked
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     memberList: ZegoLiveStreamingMemberListEvents(
>       onClicked: (ZegoUIKitUser) {
>
>       },
>     ),
>   ),
>   ...
> );
>```

# inRoomMessage

## onLocalSend

>
> Local message sending callback, This callback method is called when a message is sent successfully or fails to send.
>
>- function prototype:
>```dart
>void Function(ZegoInRoomMessage message)? onLocalSend
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     inRoomMessage: ZegoUIKitPrebuiltLiveStreamingEvents(
>       onLocalSend: (ZegoInRoomMessage) {
>
>       },
>     ),
>   ),
>   ...
> );
>```

## onClicked

>
> Triggered when has click on the message item
>
>- function prototype:
>```dart
>void Function(ZegoInRoomMessage message) onClicked
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     inRoomMessage: ZegoUIKitPrebuiltLiveStreamingEvents(
>       onClicked: (ZegoInRoomMessage) {
>
>       },
>     ),
>   ),
>   ...
> );
>```

## onLongPress

>
> Triggered when a pointer has remained in contact with the message item at
> the same location for a long period of time.
>
>- function prototype:
>```dart
>void Function(ZegoInRoomMessage message) onLongPress
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     inRoomMessage: ZegoUIKitPrebuiltLiveStreamingEvents(
>       onLongPress: (ZegoInRoomMessage) {
>
>       },
>     ),
>   ),
>   ...
> );
>```

# duration
## onUpdate

>
> Call timing callback function, called every second.
>
> Example: Set to automatically leave after 5 minutes.
>```dart
> ..duration.onUpdate = (Duration duration) {
>   if (duration.inSeconds >= 5 * 60) {
>     ZegoUIKitPrebuiltLiveStreamingController().leave(context);
>   }
> }
> ```
>
>- function prototype:
>```dart
>void Function(Duration)? onUpdate
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     duration: ZegoLiveStreamingDurationEvents(
>       onUpdate: (Duration) {
>
>       },
>     ),
>   ),
>   ...
> );
>```

# media

> events about media player
>
>- function prototype:
>```dart
>ZegoUIKitMediaPlayerEvent media
>```
>- example:
>```dart
> ZegoUIKitPrebuiltLiveStreaming(
>   ...
>   events: ZegoUIKitPrebuiltLiveStreamingEvents(
>     media: ZegoUIKitMediaPlayerEvent(
>       // media player events
>     ),
>   ),
>   ...
> );
>```

# Event Data Structures

## ZegoLiveStreamingEndReason

> The reason why the live streaming ended
>
>- function prototype:
>```dart
>enum ZegoLiveStreamingEndReason {
>  /// the live streaming ended due to host ended
>  hostEnd,
>
>  /// local user leave
>  localLeave,
>
>  /// being kicked out
>  kickOut,
>}
>```

## ZegoLiveStreamingLeaveConfirmationEvent

> Event data for leave confirmation
>
>- function prototype:
>```dart
>class ZegoLiveStreamingLeaveConfirmationEvent {
>  BuildContext context;
>
>  ZegoLiveStreamingLeaveConfirmationEvent({
>    required this.context,
>  });
>}
>```

## ZegoLiveStreamingEndEvent

> Event data for live streaming end
>
>- function prototype:
>```dart
>class ZegoLiveStreamingEndEvent {
>  /// the user ID of who kick you out
>  String? kickerUserID;
>
>  /// end reason
>  ZegoLiveStreamingEndReason reason;
>
>  /// The [isFromMinimizing] it means that the user left the live streaming
>  /// while it was in a minimized state.
>  bool isFromMinimizing;
>
>  ZegoLiveStreamingEndEvent({
>    required this.reason,
>    required this.isFromMinimizing,
>    this.kickerUserID,
>  });
>}
>```

## ZegoLiveStreamingCoHostHostEventRequestReceivedData

> Event data for co-host request received
>
>- function prototype:
>```dart
>class ZegoLiveStreamingCoHostHostEventRequestReceivedData {
>  ZegoUIKitUser audience;
>  String customData;
>
>  ZegoLiveStreamingCoHostHostEventRequestReceivedData({
>    required this.audience,
>    required this.customData,
>  });
>}
>```

## ZegoLiveStreamingCoHostHostEventRequestCanceledData

> Event data for co-host request canceled
>
>- function prototype:
>```dart
>class ZegoLiveStreamingCoHostHostEventRequestCanceledData {
>  ZegoUIKitUser audience;
>  String customData;
>
>  ZegoLiveStreamingCoHostHostEventRequestCanceledData({
>    required this.audience,
>    required this.customData,
>  });
>}
>```

## ZegoLiveStreamingCoHostHostEventRequestTimeoutData

> Event data for co-host request timeout
>
>- function prototype:
>```dart
>class ZegoLiveStreamingCoHostHostEventRequestTimeoutData {
>  ZegoUIKitUser audience;
>
>  ZegoLiveStreamingCoHostHostEventRequestTimeoutData({
>    required this.audience,
>  });
>}
>```

## ZegoLiveStreamingCoHostHostEventInvitationSentData

> Event data for co-host invitation sent
>
>- function prototype:
>```dart
>class ZegoLiveStreamingCoHostHostEventInvitationSentData {
>  ZegoUIKitUser audience;
>
>  ZegoLiveStreamingCoHostHostEventInvitationSentData({
>    required this.audience,
>  });
>}
>```

## ZegoLiveStreamingCoHostHostEventInvitationTimeoutData

> Event data for co-host invitation timeout
>
>- function prototype:
>```dart
>class ZegoLiveStreamingCoHostHostEventInvitationTimeoutData {
>  ZegoUIKitUser audience;
>
>  ZegoLiveStreamingCoHostHostEventInvitationTimeoutData({
>    required this.audience,
>  });
>}
>```

## ZegoLiveStreamingCoHostHostEventInvitationAcceptedData

> Event data for co-host invitation accepted
>
>- function prototype:
>```dart
>class ZegoLiveStreamingCoHostHostEventInvitationAcceptedData {
>  ZegoUIKitUser audience;
>  String customData;
>
>  ZegoLiveStreamingCoHostHostEventInvitationAcceptedData({
>    required this.audience,
>    required this.customData,
>  });
>}
>```

## ZegoLiveStreamingCoHostHostEventInvitationRefusedData

> Event data for co-host invitation refused
>
>- function prototype:
>```dart
>class ZegoLiveStreamingCoHostHostEventInvitationRefusedData {
>  ZegoUIKitUser audience;
>  String customData;
>
>  ZegoLiveStreamingCoHostHostEventInvitationRefusedData({
>    required this.audience,
>    required this.customData,
>  });
>}
>```

## ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData

> Event data for audience co-host request accepted
>
>- function prototype:
>```dart
>class ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData {
>  String customData;
>
>  ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData({
>    required this.customData,
>  });
>}
>```

## ZegoLiveStreamingCoHostAudienceEventRequestRefusedData

> Event data for audience co-host request refused
>
>- function prototype:
>```dart
>class ZegoLiveStreamingCoHostAudienceEventRequestRefusedData {
>  String customData;
>
>  ZegoLiveStreamingCoHostAudienceEventRequestRefusedData({
>    required this.customData,
>  });
>}
>```

## ZegoLiveStreamingCoHostAudienceEventRequestReceivedData

> Event data for audience co-host request received
>
>- function prototype:
>```dart
>class ZegoLiveStreamingCoHostAudienceEventRequestReceivedData {
>  ZegoUIKitUser host;
>  String customData;
>
>  ZegoLiveStreamingCoHostAudienceEventRequestReceivedData({
>    required this.host,
>    required this.customData,
>  });
>}
>```