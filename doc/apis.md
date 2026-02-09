# APIs

- [ZegoUIKitPrebuiltLiveStreamingController](#zegouikitprebuiltlivestreamingcontroller)
  - [leave](#leave)
  - [liveState](#livestate)
  - [isLeaveRequestingNotifier](#isleaverequestingnotifier)
  - [AudioVideo](#audiovideo)
  - [Message](#message)
  - [Minimization](#minimization)
  - [PIP](#pip)
  - [Room](#room)
  - [User](#user)
  - [Screen](#screen)
  - [CoHost](#cohost)
  - [PK](#pk)
  - [Log](#log)
  - [Media](#media)
  - [Hall](#hall)
- [Hall](#hall-1)
  - [ZegoUIKitLiveStreamingHallList](#zegouikitlivestreaminghalllist)
  - [ZegoLiveStreamingHallListController](#zegolivestreaminghalllistcontroller)
  - [ZegoLiveStreamingHallListStyle](#zegolivestreaminghallliststyle)
  - [ZegoLiveStreamingHallListForegroundStyle](#zegolivestreaminghalllistforegroundstyle)
  - [ZegoLiveStreamingHallListConfig](#zegolivestreaminghalllistconfig)

---

## ZegoUIKitPrebuiltLiveStreamingController

Used to control the live streaming functionality.

`ZegoUIKitPrebuiltLiveStreamingController` is a **singleton instance** class, you can directly invoke it by `ZegoUIKitPrebuiltLiveStreamingController()`.

### version

- **Description**
  - Get the SDK version.
- **Prototype**
  ```dart
  String get version;
  ```
- **Example**
  ```dart
  String version = ZegoUIKitPrebuiltLiveStreamingController().version;
  ```

### liveState

- **Description**
  - Get the live state.
- **Prototype**
  ```dart
  ZegoLiveStreamingState get liveState;
  ```
- **Example**
  ```dart
  ZegoLiveStreamingState state = ZegoUIKitPrebuiltLiveStreamingController().liveState;
  ```

### leave

- **Description**
  - This function is used to end the Live Streaming.
  - You can pass the context [context] for any necessary pop-ups or page transitions.
  - By using the [showConfirmation] parameter, you can control whether to display a confirmation dialog to confirm ending the Live Streaming.
  - This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the [ZegoUIKitPrebuiltLiveStreamingEvents.onLeaveConfirmation], [ZegoUIKitPrebuiltLiveStreamingEvents.onEnded] settings in the config.
- **Prototype**
  ```dart
  Future<bool> leave(
    BuildContext context, {
    bool showConfirmation = false,
  })
  ```
- **Example**
  ```dart
  ZegoUIKitPrebuiltLiveStreamingController().leave(context);
  ```

### isLeaveRequestingNotifier

- **Description**
  - Notifier for the leave request status.
- **Prototype**
  ```dart
  ValueNotifier<bool> get isLeaveRequestingNotifier;
  ```

---

### AudioVideo

**ZegoLiveStreamingControllerAudioVideo**

#### microphone

**ZegoLiveStreamingControllerAudioVideoMicrophoneImpl**

- **localState**
  - **Description**
    - Microphone state of local user.
  - **Prototype**
    ```dart
    bool get localState;
    ```

- **localStateNotifier**
  - **Description**
    - Microphone state notifier of local user.
  - **Prototype**
    ```dart
    ValueNotifier<bool> get localStateNotifier;
    ```

- **state**
  - **Description**
    - Microphone state of [userID].
  - **Prototype**
    ```dart
    bool state(String userID);
    ```

- **stateNotifier**
  - **Description**
    - Microphone state notifier of [userID].
  - **Prototype**
    ```dart
    ValueNotifier<bool> stateNotifier(String userID);
    ```

- **turnOn**
  - **Description**
    - Turn on/off [userID] microphone, if [userID] is empty, then it refers to local user.
  - **Prototype**
    ```dart
    Future<void> turnOn(bool isOn, {String? userID});
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().audioVideo.microphone.turnOn(true);
    ```

- **switchState**
  - **Description**
    - Switch [userID] microphone state, if [userID] is empty, then it refers to local user.
  - **Prototype**
    ```dart
    void switchState({String? userID});
    ```

#### camera

**ZegoLiveStreamingControllerAudioVideoCameraImpl**

- **localState**
  - **Description**
    - Camera state of local user.
  - **Prototype**
    ```dart
    bool get localState;
    ```

- **localStateNotifier**
  - **Description**
    - Camera state notifier of local user.
  - **Prototype**
    ```dart
    ValueNotifier<bool> get localStateNotifier;
    ```

- **state**
  - **Description**
    - Camera state of [userID].
  - **Prototype**
    ```dart
    bool state(String userID);
    ```

- **stateNotifier**
  - **Description**
    - Camera state notifier of [userID].
  - **Prototype**
    ```dart
    ValueNotifier<bool> stateNotifier(String userID);
    ```

- **turnOn**
  - **Description**
    - Turn on/off [userID] camera, if [userID] is empty, then it refers to local user.
  - **Prototype**
    ```dart
    Future<void> turnOn(bool isOn, {String? userID});
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().audioVideo.camera.turnOn(true);
    ```

- **switchState**
  - **Description**
    - Switch [userID] camera state, if [userID] is empty, then it refers to local user.
  - **Prototype**
    ```dart
    void switchState({String? userID});
    ```

- **switchFrontFacing**
  - **Description**
    - Local use front facing camera.
  - **Prototype**
    ```dart
    void switchFrontFacing(bool isFrontFacing);
    ```

- **switchVideoMirroring**
  - **Description**
    - Set video mirror mode.
  - **Prototype**
    ```dart
    void switchVideoMirroring(bool isVideoMirror);
    ```

#### audioOutput

**ZegoLiveStreamingControllerAudioVideoAudioOutputImpl**

- **localNotifier**
  - **Description**
    - Local audio output device notifier.
  - **Prototype**
    ```dart
    ValueNotifier<ZegoUIKitAudioRoute> get localNotifier;
    ```

- **notifier**
  - **Description**
    - Get audio output device notifier.
  - **Prototype**
    ```dart
    ValueNotifier<ZegoUIKitAudioRoute> notifier(String userID);
    ```

- **switchToSpeaker**
  - **Description**
    - Set audio output to speaker or earpiece(telephone receiver).
  - **Prototype**
    ```dart
    void switchToSpeaker(bool isSpeaker);
    ```

---

### Message

**ZegoLiveStreamingControllerMessage**

- **send**
  - **Description**
    - Send message.
  - **Prototype**
    ```dart
    Future<bool> send(String message, {ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().message.send("Hello");
    ```

- **list**
  - **Description**
    - Get message list stream.
  - **Prototype**
    ```dart
    Stream<List<ZegoInRoomMessage>> list()
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().message.list().listen((messages) {
      // handle messages
    });
    ```

- **stream**
  - **Description**
    - Get message stream.
  - **Prototype**
    ```dart
    Stream<ZegoInRoomMessage> stream()
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().message.stream().listen((message) {
      // handle message
    });
    ```

- **delete**
  - **Description**
    - Delete message.
  - **Prototype**
    ```dart
    Future<void> delete(int messageID)
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().message.delete(123);
    ```

---

### Minimization

**ZegoLiveStreamingControllerMinimizing**

- **state**
  - **Description**
    - Get current minimization state.
  - **Prototype**
    ```dart
    ZegoLiveStreamingMiniOverlayPageState get state
    ```
  - **Example**
    ```dart
    var state = ZegoUIKitPrebuiltLiveStreamingController().minimize.state;
    ```

- **restore**
  - **Description**
    - Restore the minimized window.
  - **Prototype**
    ```dart
    bool restore(BuildContext context, {bool rootNavigator = true, bool withSafeArea = false})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().minimize.restore(context);
    ```

- **minimize**
  - **Description**
    - Minimize the window.
  - **Prototype**
    ```dart
    bool minimize(BuildContext context, {bool rootNavigator = true})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().minimize.minimize(context);
    ```

- **hide**
  - **Description**
    - Hide the minimized window.
  - **Prototype**
    ```dart
    void hide()
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
    ```

---

### PIP

**ZegoLiveStreamingControllerPIP**

- **enable**
  - **Description**
    - Enable Picture-in-Picture.
  - **Prototype**
    ```dart
    Future<ZegoPiPStatus> enable({int aspectWidth = 9, int aspectHeight = 16})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pip.enable();
    ```

- **enableWhenBackground**
  - **Description**
    - Enable Picture-in-Picture when app goes to background.
  - **Prototype**
    ```dart
    Future<ZegoPiPStatus> enableWhenBackground({int aspectWidth = 9, int aspectHeight = 16})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pip.enableWhenBackground();
    ```

- **cancelBackground**
  - **Description**
    - Cancel background Picture-in-Picture.
  - **Prototype**
    ```dart
    Future<void> cancelBackground()
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pip.cancelBackground();
    ```

---

### Room

**ZegoLiveStreamingControllerRoom**

- **leave**
  - **Description**
    - Leave the room.
  - **Prototype**
    ```dart
    Future<bool> leave(BuildContext context, {bool showConfirmation = false})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().room.leave(context);
    ```

- **updateProperty**
  - **Description**
    - Update a room property.
  - **Prototype**
    ```dart
    Future<bool> updateProperty({required String roomID, required String key, required String value, bool isForce = false, bool isDeleteAfterOwnerLeft = false, bool isUpdateOwner = false})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().room.updateProperty(roomID: "123", key: "test", value: "1");
    ```

- **updateProperties**
  - **Description**
    - Update multiple room properties.
  - **Prototype**
    ```dart
    Future<bool> updateProperties({required String roomID, required Map<String, String> roomProperties, bool isForce = false, bool isDeleteAfterOwnerLeft = false, bool isUpdateOwner = false})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().room.updateProperties(roomID: "123", roomProperties: {"test": "1"});
    ```

- **deleteProperties**
  - **Description**
    - Delete room properties.
  - **Prototype**
    ```dart
    Future<bool> deleteProperties({required String roomID, required List<String> keys, bool isForce = false})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().room.deleteProperties(roomID: "123", keys: ["test"]);
    ```

- **renewToken**
  - **Description**
    - Renew room token.
  - **Prototype**
    ```dart
    Future<bool> renewToken({required String token})
    ```

---

### User

**ZegoLiveStreamingControllerUser**

- **countNotifier**
  - **Description**
    - Get user count notifier.
  - **Prototype**
    ```dart
    ValueNotifier<int> get countNotifier
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().user.countNotifier.addListener(() {});
    ```

- **stream**
  - **Description**
    - Get user list stream.
  - **Prototype**
    ```dart
    Stream<List<ZegoUIKitUser>> stream({bool includeFakeUser = true})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().user.stream().listen((users) {});
    ```

- **remove**
  - **Description**
    - Remove users from the room (kick out).
  - **Prototype**
    ```dart
    Future<bool> remove(List<String> userIDs)
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().user.remove(["user1"]);
    ```

- **addFakeUser**
  - **Description**
    - Add a fake user (for testing/simulation).
  - **Prototype**
    ```dart
    void addFakeUser(ZegoUIKitUser user)
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().user.addFakeUser(ZegoUIKitUser(id: "fake", name: "Fake"));
    ```

- **removeFakeUser**
  - **Description**
    - Remove a fake user.
  - **Prototype**
    ```dart
    void removeFakeUser(ZegoUIKitUser user)
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().user.removeFakeUser(ZegoUIKitUser(id: "fake", name: "Fake"));
    ```

---

### Screen

**ZegoLiveStreamingControllerScreen**

- **viewController**
  - **Description**
    - Get screen sharing view controller.
  - **Prototype**
    ```dart
    ZegoScreenSharingViewController get viewController
    ```
  - **Example**
    ```dart
    var vc = ZegoUIKitPrebuiltLiveStreamingController().screenSharing.viewController;
    ```

- **showViewInFullscreenMode**
  - **Description**
    - Show screen sharing view in fullscreen mode.
  - **Prototype**
    ```dart
    void showViewInFullscreenMode(String userID, bool isFullscreen)
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().screenSharing.showViewInFullscreenMode("user1", true);
    ```

- **start**
  - **Description**
    - Start screen sharing.
  - **Prototype**
    ```dart
    Future<void> start({bool isUseSurfaceView = false})
    ```

- **stop**
  - **Description**
    - Stop screen sharing.
  - **Prototype**
    ```dart
    Future<void> stop()
    ```

---

### CoHost

**ZegoLiveStreamingControllerCoHostImpl**

- **audienceLocalConnectStateNotifier**
  - **Description**
    - For audience: current audience connection state, audience or co-host(connected).
  - **Prototype**
    ```dart
    ValueNotifier<ZegoLiveStreamingAudienceConnectState> get audienceLocalConnectStateNotifier
    ```

- **hostNotifier**
  - **Description**
    - Host notifier.
  - **Prototype**
    ```dart
    ValueNotifier<ZegoUIKitUser?> get hostNotifier
    ```

- **requestCoHostUsersNotifier**
  - **Description**
    - For host: current requesting co-host's audiences.
  - **Prototype**
    ```dart
    ValueNotifier<List<ZegoUIKitUser>> get requestCoHostUsersNotifier
    ```

- **coHostCountNotifier**
  - **Description**
    - Current co-host total count.
  - **Prototype**
    ```dart
    ValueNotifier<int> get coHostCountNotifier
    ```

- **hostSendCoHostInvitationToAudience**
  - **Description**
    - Host invite [audience] to be a co-host.
  - **Prototype**
    ```dart
    Future<bool> hostSendCoHostInvitationToAudience(
      ZegoUIKitUser audience, {
      bool withToast = false,
      int timeoutSecond = 60,
      String customData = '',
    })
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.hostSendCoHostInvitationToAudience(user);
    ```

- **audienceAgreeCoHostInvitation**
  - **Description**
    - Audience agrees to co-host invitation.
  - **Prototype**
    ```dart
    Future<bool> audienceAgreeCoHostInvitation({bool withToast = false, String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.audienceAgreeCoHostInvitation();
    ```

- **audienceRejectCoHostInvitation**
  - **Description**
    - Audience rejects co-host invitation.
  - **Prototype**
    ```dart
    Future<bool> audienceRejectCoHostInvitation({String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.audienceRejectCoHostInvitation();
    ```

- **audienceSendCoHostRequest**
  - **Description**
    - Audience requests to become a co-host by sending a request to the host.
  - **Prototype**
    ```dart
    Future<bool> audienceSendCoHostRequest({bool withToast = false, String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.audienceSendCoHostRequest();
    ```

- **audienceCancelCoHostRequest**
  - **Description**
    - Audience cancels the co-host request.
  - **Prototype**
    ```dart
    Future<bool> audienceCancelCoHostRequest({String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.audienceCancelCoHostRequest();
    ```

- **startCoHost**
  - **Description**
    - Audience switches to be a co-host directly, without request to host.
  - **Prototype**
    ```dart
    Future<bool> startCoHost()
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.startCoHost();
    ```

- **stopCoHost**
  - **Description**
    - Co-host ends the connection and switches to the audience role voluntarily.
  - **Prototype**
    ```dart
    Future<bool> stopCoHost({bool showRequestDialog = true})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.stopCoHost();
    ```

- **hostAgreeCoHostRequest**
  - **Description**
    - Host approve the co-host request made by [audience].
  - **Prototype**
    ```dart
    Future<bool> hostAgreeCoHostRequest(ZegoUIKitUser audience, {String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.hostAgreeCoHostRequest(audience);
    ```

- **hostRejectCoHostRequest**
  - **Description**
    - Host reject the co-host request made by [audience].
  - **Prototype**
    ```dart
    Future<bool> hostRejectCoHostRequest(ZegoUIKitUser audience, {String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.hostRejectCoHostRequest(audience);
    ```

- **removeCoHost**
  - **Description**
    - Host remove the co-host, make [coHost] to be an audience.
  - **Prototype**
    ```dart
    Future<bool> removeCoHost(ZegoUIKitUser coHost, {String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.removeCoHost(coHost);
    ```

---

### PK

**ZegoLiveStreamingControllerPKImpl**

- **stateNotifier**
  - **Description**
    - PK state stream.
  - **Prototype**
    ```dart
    ValueNotifier<ZegoLiveStreamingPKBattleState> get stateNotifier
    ```

- **mutedUsersNotifier**
  - **Description**
    - Mute users stream.
  - **Prototype**
    ```dart
    ValueNotifier<List<String>> get mutedUsersNotifier
    ```

- **isInPK**
  - **Description**
    - Is in PK or not.
  - **Prototype**
    ```dart
    bool get isInPK
    ```

- **currentRequestID**
  - **Description**
    - Get current PK request ID.
  - **Prototype**
    ```dart
    String get currentRequestID
    ```

- **currentInitiatorID**
  - **Description**
    - Get current PK initiator ID.
  - **Prototype**
    ```dart
    String get currentInitiatorID
    ```

- **getHosts**
  - **Description**
    - Get the host list in invitation or in PK.
  - **Prototype**
    ```dart
    List<AdvanceInvitationUser> getHosts(String requestID)
    ```

- **sendRequest**
  - **Description**
    - Send PK battle request.
  - **Prototype**
    ```dart
    Future<ZegoLiveStreamingPKServiceSendRequestResult> sendRequest({
      required List<String> targetHostIDs,
      int timeout = 60,
      String customData = '',
      bool isAutoAccept = false,
    })
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pk.sendRequest(targetHostIDs: ["host2"]);
    ```

- **cancelRequest**
  - **Description**
    - Cancel PK battle request.
  - **Prototype**
    ```dart
    Future<ZegoLiveStreamingPKServiceResult> cancelRequest({required List<String> targetHostIDs, String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pk.cancelRequest(targetHostIDs: ["host2"]);
    ```

- **acceptRequest**
  - **Description**
    - Accept PK battle request.
  - **Prototype**
    ```dart
    Future<ZegoLiveStreamingPKServiceResult> acceptRequest({required String requestID, required ZegoLiveStreamingPKUser targetHost, int timeout = 60, String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pk.acceptRequest(requestID: "req1", targetHost: host);
    ```

- **rejectRequest**
  - **Description**
    - Reject PK battle request.
  - **Prototype**
    ```dart
    Future<ZegoLiveStreamingPKServiceResult> rejectRequest({required String requestID, required String targetHostID, int timeout = 60, String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pk.rejectRequest(requestID: "req1", targetHostID: "host2");
    ```

- **quit**
  - **Description**
    - Quit PK on your own.
  - **Prototype**
    ```dart
    Future<ZegoLiveStreamingPKServiceResult> quit()
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pk.quit();
    ```

- **stop**
  - **Description**
    - Stop PK to all pk-hosts, only the PK Initiator can stop it.
  - **Prototype**
    ```dart
    Future<ZegoLiveStreamingPKServiceResult> stop()
    ```

- **muteAudios**
  - **Description**
    - Silence the [targetHostIDs] in PK.
  - **Prototype**
    ```dart
    Future<bool> muteAudios({required List<String> targetHostIDs, required bool isMute})
    ```

---

### Log

**ZegoLiveStreamingControllerLog**

- **exportLogs**
  - **Description**
    - Export logs.
  - **Prototype**
    ```dart
    Future<bool> exportLogs({String? title, String? content, String? fileName, List<ZegoLogExporterFileType> fileTypes = const [ZegoLogExporterFileType.txt, ZegoLogExporterFileType.log, ZegoLogExporterFileType.zip], List<ZegoLogExporterDirectoryType> directories = const [ZegoLogExporterDirectoryType.zegoUIKits, ZegoLogExporterDirectoryType.zimAudioLog, ZegoLogExporterDirectoryType.zimLogs, ZegoLogExporterDirectoryType.zefLogs, ZegoLogExporterDirectoryType.zegoLogs], void Function(double progress)? onProgress})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().log.exportLogs();
    ```

---

### Media

**ZegoLiveStreamingControllerMedia**

- **play**
  - **Description**
    - Start play media.
  - **Prototype**
    ```dart
    Future<ZegoUIKitMediaPlayResult> play({required String filePathOrURL, bool enableRepeat = false, bool autoStart = true})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.play(filePathOrURL: "http://test.com/a.mp4");
    ```

- **stop**
  - **Description**
    - Stop play media.
  - **Prototype**
    ```dart
    Future<void> stop()
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.stop();
    ```

- **pause**
  - **Description**
    - Pause media.
  - **Prototype**
    ```dart
    Future<void> pause()
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.pause();
    ```

- **resume**
  - **Description**
    - Resume media.
  - **Prototype**
    ```dart
    Future<void> resume()
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.resume();
    ```

- **seekTo**
  - **Description**
    - Seek to specified position.
  - **Prototype**
    ```dart
    Future<ZegoUIKitMediaSeekToResult> seekTo(int millisecond)
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.seekTo(1000);
    ```

- **setVolume**
  - **Description**
    - Set media volume.
  - **Prototype**
    ```dart
    Future<void> setVolume(int volume, {bool isSyncToRemote = false})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.setVolume(50);
    ```

- **muteLocal**
  - **Description**
    - Mute local playback.
  - **Prototype**
    ```dart
    Future<void> muteLocal(bool mute)
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.muteLocal(true);
    ```

- **pickFile**
  - **Description**
    - Pick media file.
  - **Prototype**
    ```dart
    Future<List<ZegoUIKitPlatformFile>> pickFile({List<String>? allowedExtensions})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.pickFile();
    ```

---

### Hall

**ZegoLiveStreamingControllerHall**

- **getRoomList**
  - **Description**
    - Get the list of live streaming rooms.
  - **Prototype**
    ```dart
    Future<ZegoUIKitHallRoomListQueryResult> getRoomList({int pageIndex = 1, int pageSize = 20})
    ```

---

## Hall

### ZegoUIKitLiveStreamingHallList

The Hall List Widget.

- **Parameters**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| appID | You can create a project and obtain an appID from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com). | `int` | |
| appSign | log in by using [appID] + [appSign]. | `String` | `''` |
| token | log in by using [appID] + [token]. | `String` | `''` |
| userID | The ID of the currently logged-in user. | `String` | |
| userName | The name of the currently logged-in user. | `String` | |
| configsQuery | Initialize the configuration for the live-streaming. | `ZegoUIKitPrebuiltLiveStreamingConfig Function(String liveID)` | |
| eventsQuery | You can listen to events that you are interested in here. | `ZegoUIKitPrebuiltLiveStreamingEvents? Function(String liveID)?` | `null` |
| hallStyle | Hall style. | `ZegoLiveStreamingHallListStyle` | |
| hallConfig | Hall configuration. | `ZegoLiveStreamingHallListConfig` | |
| hallController | Hall controller. | `ZegoLiveStreamingHallListController?` | `null` |
| hallModel | When swiping up or down, the corresponding LIVE information will be returned via this model. | `ZegoLiveStreamingHallListModel?` | `null` |
| hallModelDelegate | If you want to manage data yourself, set this delegate. | `ZegoLiveStreamingHallListModelDelegate?` | `null` |

### ZegoLiveStreamingHallListController

- **roomID**
  - **Description**
    - Get current room ID.
  - **Prototype**
    ```dart
    String get roomID
    ```
  - **Example**
    ```dart
    var roomID = controller.roomID;
    ```

### ZegoLiveStreamingHallListStyle

- **Parameters**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| loadingBuilder | Custom loading widget builder. | `Widget? Function(BuildContext context)?` | `null` |
| item | Item style configuration. | `ZegoLiveStreamingHallListItemStyle` | `const ZegoUIKitHallRoomListItemStyle()` |
| foreground | Foreground style configuration. | `ZegoLiveStreamingHallListForegroundStyle` | `const ZegoLiveStreamingHallListForegroundStyle()` |

### ZegoLiveStreamingHallListForegroundStyle

- **Parameters**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| showUserInfo | Whether to show user info. | `bool` | `true` |
| showLivingFlag | Whether to show living flag. | `bool` | `true` |
| showCloseButton | Whether to show close button. | `bool` | `true` |

### ZegoLiveStreamingHallListConfig

- **Parameters**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| video | Configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate. | `ZegoUIKitVideoConfig?` | `null` |
| streamMode | Stream mode. | `ZegoUIKitHallRoomStreamMode` | |
| audioVideoResourceMode | Audio video resource mode. | `ZegoUIKitStreamResourceMode?` | `null` |

