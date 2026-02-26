# Events

- [ZegoUIKitPrebuiltLiveStreamingEvents](#zegouikitprebuiltlivestreamingevents)
  - [user](#zegolivestreaminguserevents)
  - [room](#zegolivestreamingroomevents)
  - [audioVideo](#zegolivestreamingaudiovideoevents)
  - [coHost](#zegolivestreamingcohostevents)
    - [host](#zegolivestreamingcohosthostevents)
    - [audience](#zegolivestreamingcohostaudienceevents)
    - [coHost](#zegolivestreamingcohostcohostevents)
  - [pk](#zegolivestreamingpkevents)
  - [topMenuBar](#zegolivestreamingtopmenubarevents)
  - [memberList](#zegolivestreamingmemberlistevents)
  - [inRoomMessage](#zegolivestreaminginroommessageevents)
  - [media](#zegouikitmediaplayerevent)
  - [onLeaveConfirmation](#onleaveconfirmation)
  - [onEnded](#onended)
  - [onStateUpdated](#onstateupdated)
  - [onError](#onerror)

---

## ZegoUIKitPrebuiltLiveStreamingEvents

- `user`: [ZegoLiveStreamingUserEvents](#zegolivestreaminguserevents)
  - events about user.
- `room`: [ZegoLiveStreamingRoomEvents](#zegolivestreamingroomevents)
  - events about room.
- `audioVideo`: [ZegoLiveStreamingAudioVideoEvents](#zegolivestreamingaudiovideoevents)
  - events about audio video.
- `coHost`: [ZegoLiveStreamingCoHostEvents](#zegolivestreamingcohostevents)
  - events about co-host.
- `topMenuBar`: [ZegoLiveStreamingTopMenuBarEvents](#zegolivestreamingtopmenubarevents)
  - events about top menu bar.
- `memberList`: [ZegoLiveStreamingMemberListEvents](#zegolivestreamingmemberlistevents)
  - events about member list.
- `inRoomMessage`: [ZegoLiveStreamingInRoomMessageEvents](#zegolivestreaminginroommessageevents)
  - events about in-room message.
- `duration`: [ZegoLiveStreamingDurationEvents](#zegolivestreamingdurationevents)
  - events about duration.
- `beauty`: [ZegoLiveStreamingBeautyEvents](#zegolivestreamingbeautyevents)
  - events about beauty.
- `media`: [ZegoUIKitMediaPlayerEvent](#zegouikitmediaplayerevent)
  - events about media.

### onLeaveConfirmation

- **Description**
  - Confirmation callback method before leaving the live streaming.
  - If you want to perform more complex business logic before exiting the live streaming, such as updating some records to the backend, you can use the [onLeaveConfirmation] parameter to set it.
  - This parameter requires you to provide a callback method that returns an asynchronous result.
  - If you return true in the callback, the prebuilt page will quit and return to your previous page, otherwise it will be ignored.

- **Prototype**
  ```dart
  Future<bool> Function(
    ZegoLiveStreamingLeaveConfirmationEvent event,
    Future<bool> Function() defaultAction,
  )?
  ```

- **Example**
  ```dart
  onLeaveConfirmation: (
      ZegoLiveStreamingLeaveConfirmationEvent event,
      /// defaultAction to return to the previous page
      Future<bool> Function() defaultAction,
  ) {
    debugPrint('onLeaveConfirmation, do whatever you want');

    /// you can call this defaultAction to return to the previous page,
    return defaultAction.call();
  }
  ```

### onEnded

- **Description**
  - This callback method is called when live streaming ended(all users in live streaming will received).
  - The default behavior of host is return to the previous page(only host) or hide the minimize page.
  - If you override this callback, you must perform the page navigation yourself while it was in a normal state, or hide the minimize page if in minimize state.
  - otherwise the user will remain on the live streaming page.
  - the easy way is call `defaultAction.call()`

- **Prototype**
  ```dart
  void Function(
    ZegoLiveStreamingEndEvent event,
    VoidCallback defaultAction,
  )?
  ```

- **Example**
  ```dart
  onEnded: (
      ZegoLiveStreamingEndEvent event,
      /// defaultAction to return to the previous page
      VoidCallback defaultAction,
  ) {
    debugPrint('onEnded, do whatever you want');

    /// you can call this defaultAction to return to the previous page,
    return defaultAction.call();
  }
  ```

### onStateUpdated

- **Description**
  - This callback method is called when live streaming state update.

- **Prototype**
  ```dart
  void Function(ZegoLiveStreamingState state)?
  ```

- **Example**
  ```dart
  onStateUpdated: (ZegoLiveStreamingState state) {
    // Handle state update
  }
  ```

### onError

- **Description**
  - Error stream.

- **Prototype**
  ```dart
  Function(ZegoUIKitError)?
  ```

- **Example**
  ```dart
  onError: (ZegoUIKitError error) {
    // Handle error
  }
  ```

## ZegoLiveStreamingUserEvents

Events about user.

### onEnter

- **Description**
  - This callback is triggered when user enter.

- **Prototype**
  ```dart
  void Function(ZegoUIKitUser user)?
  ```

- **Example**
  ```dart
  onEnter: (ZegoUIKitUser user) {
    // Handle user enter
  }
  ```

### onLeave

- **Description**
  - This callback is triggered when user leave.

- **Prototype**
  ```dart
  void Function(ZegoUIKitUser user)?
  ```

- **Example**
  ```dart
  onLeave: (ZegoUIKitUser user) {
    // Handle user leave
  }
  ```

## ZegoLiveStreamingRoomEvents

Events about room.

### onStateChanged

- **Description**
  - Triggered when room state changed.

- **Prototype**
  ```dart
  void Function(ZegoUIKitRoomState state)?
  ```

- **Example**
  ```dart
  onStateChanged: (ZegoUIKitRoomState state) {
    // Handle room state change
  }
  ```

### onLoginFailed

- **Description**
  - This callback is triggered when room login failed.

- **Prototype**
  ```dart
  void Function(
    ZegoLiveStreamingRoomLoginFailedEvent event,
    Future<void> Function(ZegoLiveStreamingRoomLoginFailedEvent event) defaultAction,
  )?
  ```

- **Example**
  ```dart
  onLoginFailed: (event, defaultAction) {
    // Handle login failure
  }
  ```

### onTokenExpired

- **Description**
  - The room Token authentication is about to expire.
  - it will be sent 30 seconds before the Token expires.
  - After receiving this callback, the Token can be updated through [ZegoUIKitPrebuiltLiveStreamingController.room.renewToken].
  - If there is no update, it will affect the user's next login and publish streaming operation, and will not affect the current operation.

- **Prototype**
  ```dart
  String? Function(int remainSeconds)?
  ```

- **Example**
  ```dart
  onTokenExpired: (int remainSeconds) {
    // Renew token
    return 'new_token';
  }
  ```

## ZegoLiveStreamingAudioVideoEvents

Events about audio-video.

### onCameraStateChanged

- **Description**
  - This callback is triggered when camera state changed.

- **Prototype**
  ```dart
  void Function(bool)?
  ```

- **Example**
  ```dart
  onCameraStateChanged: (bool isOpened) {
    // Handle camera state change
  }
  ```

### onFrontFacingCameraStateChanged

- **Description**
  - This callback is triggered when front camera state changed.

- **Prototype**
  ```dart
  void Function(bool)?
  ```

- **Example**
  ```dart
  onFrontFacingCameraStateChanged: (bool isFrontFacing) {
    // Handle front camera state change
  }
  ```

### onMicrophoneStateChanged

- **Description**
  - This callback is triggered when microphone state changed.

- **Prototype**
  ```dart
  void Function(bool)?
  ```

- **Example**
  ```dart
  onMicrophoneStateChanged: (bool isOpened) {
    // Handle microphone state change
  }
  ```

### onAudioOutputChanged

- **Description**
  - This callback is triggered when audio output device changed.

- **Prototype**
  ```dart
  void Function(ZegoUIKitAudioRoute)?
  ```

- **Example**
  ```dart
  onAudioOutputChanged: (ZegoUIKitAudioRoute route) {
    // Handle audio output change
  }
  ```

### onCameraTurnOnByOthersConfirmation

- **Description**
  - This callback method is called when someone requests to open your camera, typically when the host wants to open your camera.
  - This method requires returning an asynchronous result.
  - You can display a dialog in this callback to confirm whether to open the camera.
  - Alternatively, you can return `true` without any processing, indicating that when someone requests to open your camera, it can be directly opened.
  - By default, this method does nothing and returns `false`, indicating that others cannot open your camera.

- **Prototype**
  ```dart
  Future<bool> Function(BuildContext context)?
  ```

- **Example**
  ```dart
  onCameraTurnOnByOthersConfirmation: (BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request'),
          content: const Text('Do you agree to turn on the camera?'),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
  ```

### onMicrophoneTurnOnByOthersConfirmation

- **Description**
  - This callback method is called when someone requests to open your microphone, typically when the host wants to open your microphone.
  - This method requires returning an asynchronous result.
  - You can display a dialog in this callback to confirm whether to open the microphone.
  - Alternatively, you can return `true` without any processing, indicating that when someone requests to open your microphone, it can be directly opened.
  - By default, this method does nothing and returns `false`, indicating that others cannot open your microphone.

- **Prototype**
  ```dart
  Future<bool> Function(BuildContext context)?
  ```

- **Example**
  ```dart
  onMicrophoneTurnOnByOthersConfirmation: (BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request'),
          content: const Text('Do you agree to turn on the microphone?'),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
  ```

## ZegoLiveStreamingCoHostEvents

Events about co-host.

- `host`: [ZegoLiveStreamingCoHostHostEvents](#zegolivestreamingcohosthostevents)
  - events about host.
- `audience`: [ZegoLiveStreamingCoHostAudienceEvents](#zegolivestreamingcohostaudienceevents)
  - events about audience.
- `coHost`: [ZegoLiveStreamingCoHostCoHostEvents](#zegolivestreamingcohostcohostevents)
  - events about co-host.

### onMaxCountReached

- **Description**
  - This callback is triggered when the maximum count of co-hosts is reached.

- **Prototype**
  ```dart
  void Function(int count)?
  ```

- **Example**
  ```dart
  onMaxCountReached: (int count) {
    // Handle max count reached
  }
  ```

### onUpdated

- **Description**
  - co-host updated, refers to the event where there is a change in the co-hosts.
  - this can occur when a new co-host joins the session or when an existing co-host leaves the session.

- **Prototype**
  ```dart
  Function(List<ZegoUIKitUser> coHosts)?
  ```

- **Example**
  ```dart
  onUpdated: (List<ZegoUIKitUser> coHosts) {
    // Handle co-hosts update
  }
  ```

## ZegoLiveStreamingCoHostHostEvents

Host Related Events of CoHost.

### onRequestReceived

- **Description**
  - receive a request that audience request to become a co-host.

- **Prototype**
  ```dart
  Function(ZegoLiveStreamingCoHostHostEventRequestReceivedData data)?
  ```

- **Example**
  ```dart
  onRequestReceived: (data) {
    // Handle request received
  }
  ```

### onRequestCanceled

- **Description**
  - audience cancelled the co-host request.

- **Prototype**
  ```dart
  Function(ZegoLiveStreamingCoHostHostEventRequestCanceledData data)?
  ```

- **Example**
  ```dart
  onRequestCanceled: (data) {
    // Handle request canceled
  }
  ```

### onRequestTimeout

- **Description**
  - the audience's co-host request has timed out.

- **Prototype**
  ```dart
  Function(ZegoLiveStreamingCoHostHostEventRequestTimeoutData data)?
  ```

- **Example**
  ```dart
  onRequestTimeout: (data) {
    // Handle request timeout
  }
  ```

### onActionAcceptRequest

- **Description**
  - host accept the audience's co-host request.

- **Prototype**
  ```dart
  Function()?
  ```

- **Example**
  ```dart
  onActionAcceptRequest: () {
    // Handle action accept request
  }
  ```

### onActionRefuseRequest

- **Description**
  - host refuse the audience's co-host request.

- **Prototype**
  ```dart
  Function()?
  ```

- **Example**
  ```dart
  onActionRefuseRequest: () {
    // Handle action refuse request
  }
  ```

### onInvitationSent

- **Description**
  - host sent invitation to become a co-host to the audience.

- **Prototype**
  ```dart
  Function(ZegoLiveStreamingCoHostHostEventInvitationSentData data)?
  ```

- **Example**
  ```dart
  onInvitationSent: (data) {
    // Handle invitation sent
  }
  ```

### onInvitationTimeout

- **Description**
  - the host's co-host invitation has timed out.

- **Prototype**
  ```dart
  Function(ZegoLiveStreamingCoHostHostEventInvitationTimeoutData data)?
  ```

- **Example**
  ```dart
  onInvitationTimeout: (data) {
    // Handle invitation timeout
  }
  ```

### onInvitationAccepted

- **Description**
  - audience accepted to a co-host request from host.

- **Prototype**
  ```dart
  void Function(ZegoLiveStreamingCoHostHostEventInvitationAcceptedData data)?
  ```

- **Example**
  ```dart
  onInvitationAccepted: (data) {
    // Handle invitation accepted
  }
  ```

### onInvitationRefused

- **Description**
  - audience refused to a co-host request from host.

- **Prototype**
  ```dart
  void Function(ZegoLiveStreamingCoHostHostEventInvitationRefusedData data)?
  ```

- **Example**
  ```dart
  onInvitationRefused: (data) {
    // Handle invitation refused
  }
  ```

## ZegoLiveStreamingCoHostAudienceEvents

Audience Related Events of CoHost.

### onRequestSent

- **Description**
  - audience requested to become a co-host to the host.

- **Prototype**
  ```dart
  Function()?
  ```

- **Example**
  ```dart
  onRequestSent: () {
    // Handle request sent
  }
  ```

### onActionCancelRequest

- **Description**
  - audience cancelled the co-host request.

- **Prototype**
  ```dart
  Function()?
  ```

- **Example**
  ```dart
  onActionCancelRequest: () {
    // Handle action cancel request
  }
  ```

### onRequestTimeout

- **Description**
  - the audience's co-host request has timed out.

- **Prototype**
  ```dart
  Function()?
  ```

- **Example**
  ```dart
  onRequestTimeout: () {
    // Handle request timeout
  }
  ```

### onRequestAccepted

- **Description**
  - host accept the audience's co-host request.

- **Prototype**
  ```dart
  Function(ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData data)?
  ```

- **Example**
  ```dart
  onRequestAccepted: (data) {
    // Handle request accepted
  }
  ```

### onRequestRefused

- **Description**
  - host refuse the audience's co-host request.

- **Prototype**
  ```dart
  Function(ZegoLiveStreamingCoHostAudienceEventRequestRefusedData data)?
  ```

- **Example**
  ```dart
  onRequestRefused: (data) {
    // Handle request refused
  }
  ```

### onInvitationReceived

- **Description**
  - received a co-host invitation from the host.

- **Prototype**
  ```dart
  Function(ZegoLiveStreamingCoHostAudienceEventRequestReceivedData data)?
  ```

- **Example**
  ```dart
  onInvitationReceived: (data) {
    // Handle invitation received
  }
  ```

### onInvitationTimeout

- **Description**
  - the host's co-host invitation has timed out.

- **Prototype**
  ```dart
  Function()?
  ```

- **Example**
  ```dart
  onInvitationTimeout: () {
    // Handle invitation timeout
  }
  ```

### onActionAcceptInvitation

- **Description**
  - audience accept co-host invitation from the host.

- **Prototype**
  ```dart
  Function()?
  ```

- **Example**
  ```dart
  onActionAcceptInvitation: () {
    // Handle action accept invitation
  }
  ```

### onActionRefuseInvitation

- **Description**
  - audience refuse co-host invitation from the host.

- **Prototype**
  ```dart
  Function()?
  ```

- **Example**
  ```dart
  onActionRefuseInvitation: () {
    // Handle action refuse invitation
  }
  ```

## ZegoLiveStreamingCoHostCoHostEvents

Co-Host Related Events of CoHost.

### onLocalConnectStateUpdated

- **Description**
  - local connect state updated.

- **Prototype**
  ```dart
  Function(ZegoLiveStreamingAudienceConnectState)?
  ```

- **Example**
  ```dart
  onLocalConnectStateUpdated: (state) {
    // Handle local connect state updated
  }
  ```

### onLocalConnected

- **Description**
  - Audience becomes Cohost.

- **Prototype**
  ```dart
  Function()?
  ```

- **Example**
  ```dart
  onLocalConnected: () {
    // Handle local connected
  }
  ```

### onLocalDisconnected

- **Description**
  - Cohost becomes Audience.

- **Prototype**
  ```dart
  Function()?
  ```

- **Example**
  ```dart
  onLocalDisconnected: () {
    // Handle local disconnected
  }
  ```

## ZegoLiveStreamingTopMenuBarEvents

Events about top menu bar.

### onHostAvatarClicked

- **Description**
  - You can listen to the event of clicking on the host information in the top left corner.
  - For example, if you want to display a popup or dialog with host information after it is clicked.

- **Prototype**
  ```dart
  void Function(ZegoUIKitUser host)?
  ```

- **Example**
  ```dart
  onHostAvatarClicked: (host) {
    // do your own things.
  }
  ```

## ZegoLiveStreamingMemberListEvents

Events about member list.

### onClicked

- **Description**
  - You can listen to the user click event on the member list, for example, if you want to display specific information about a member after they are clicked.

- **Prototype**
  ```dart
  void Function(ZegoUIKitUser user)?
  ```

- **Example**
  ```dart
  onClicked: (user) {
    // Handle member click
  }
  ```

## ZegoLiveStreamingInRoomMessageEvents

Events about in-room message.

### onLocalSend

- **Description**
  - Local message sending callback, This callback method is called when a message is sent successfully or fails to send.

- **Prototype**
  ```dart
  ZegoInRoomMessageViewItemPressEvent?
  ```

- **Example**
  ```dart
  onLocalSend: (event) {
    // Handle local send
  }
  ```

### onClicked

- **Description**
  - Triggered when has click on the message item.

- **Prototype**
  ```dart
  ZegoInRoomMessageViewItemPressEvent?
  ```

- **Example**
  ```dart
  onClicked: (event) {
    // Handle message click
  }
  ```

### onLongPress

- **Description**
  - Triggered when a pointer has remained in contact with the message item at the same location for a long period of time.

- **Prototype**
  ```dart
  ZegoInRoomMessageViewItemPressEvent?
  ```

- **Example**
  ```dart
  onLongPress: (event) {
    // Handle message long press
  }
  ```

## ZegoLiveStreamingDurationEvents

Events about duration.

### onUpdated

- **Description**
  - Call timing callback function, called every second.

- **Prototype**
  ```dart
  void Function(Duration)?
  ```

- **Example**
  ```dart
  onUpdated: (Duration duration) {
    if (duration.inSeconds >= 5 * 60) {
      ZegoUIKitPrebuiltLiveStreamingController().leave(context);
    }
  }
  ```

## ZegoLiveStreamingBeautyEvents

Events about beauty.

### onError

- **Description**
  - error stream.

- **Prototype**
  ```dart
  Function(ZegoBeautyError)?
  ```

- **Example**
  ```dart
  onError: (error) {
    // Handle beauty error
  }
  ```

### onFaceDetection

- **Description**
  - Face detection result callback.

- **Prototype**
  ```dart
  Function(ZegoBeautyPluginFaceDetectionData)?
  ```

- **Example**
  ```dart
  onFaceDetection: (data) {
    // Handle face detection
  }
  ```

## ZegoUIKitMediaPlayerEvent

Events about media.

### onPlayStateChanged

- **Description**
  - play state callback.

- **Prototype**
  ```dart
  void Function(ZegoUIKitMediaPlayState)?
  ```

- **Example**
  ```dart
  onPlayStateChanged: (state) {
    // Handle play state change
  }
  ```
