# APIs

- [ZegoUIKitPrebuiltLiveStreamingController](#zegouikitprebuiltlivestreamingcontroller)
  - [leave](#leave)
  - [liveState](#livestate)
  - [isLeaveRequestingNotifier](#isleaverequestingnotifier)
  - [AudioVideo](#audiovideo)
  - [Message](#message)
  - [PIP](#pip)
  - [Room](#room)
  - [User](#user)
  - [Screen](#screen)
  - [CoHost](#cohost)
  - [Log](#log)
  - [Media](#media)

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
  - You can pass the context `context` for any necessary pop-ups or page transitions.
  - By using the `showConfirmation` parameter, you can control whether to display a confirmation dialog to confirm ending the Live Streaming.
  - This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the `ZegoUIKitPrebuiltLiveStreamingEvents.onLeaveConfirmation`, `ZegoUIKitPrebuiltLiveStreamingEvents.onEnded` settings in the config.
- **Prototype**
  ```dart
  Future<bool> leave(
    BuildContext context, {
    bool showConfirmation = false,
  })
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | context | for any necessary pop-ups or page transitions | `BuildContext` | `Optional` |
    | showConfirmation | parameter, you can control whether to display a confirmation dialog to confirm ending the Live Streaming | `bool` | `false` |

- **Example**
  ```dart
  ZegoUIKitPrebuiltLiveStreamingController().leave(context);
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | context | for any necessary pop-ups or page transitions | `BuildContext` | `Optional` |
    | showConfirmation | parameter, you can control whether to display a confirmation dialog to confirm ending the Live Streaming | `bool` | `false` |


### isLeaveRequestingNotifier

- **Description**
  - Notifier for the leave request status.
- **Prototype**
  ```dart
  ValueNotifier<bool> get isLeaveRequestingNotifier;
  ```
- **Example**
  ```dart
  ZegoUIKitPrebuiltLiveStreamingController().isLeaveRequestingNotifier.addListener(() {});
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
    - Microphone state of `userID`.
  - **Prototype**
    ```dart
    bool state(String userID);
    ```

- **stateNotifier**
  - **Description**
    - Microphone state notifier of `userID`.
  - **Prototype**
    ```dart
    ValueNotifier<bool> stateNotifier(String userID);
    ```

- **turnOn**
  - **Description**
    - Turn on/off `userID` microphone, if `userID` is empty, then it refers to local user.
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
    - Switch `userID` microphone state, if `userID` is empty, then it refers to local user.
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
    - Camera state of `userID`.
  - **Prototype**
    ```dart
    bool state(String userID);
    ```

- **stateNotifier**
  - **Description**
    - Camera state notifier of `userID`.
  - **Prototype**
    ```dart
    ValueNotifier<bool> stateNotifier(String userID);
    ```

- **turnOn**
  - **Description**
    - Turn on/off `userID` camera, if `userID` is empty, then it refers to local user.
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
    - Switch `userID` camera state, if `userID` is empty, then it refers to local user.
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

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | message | Unknown | `String` | `Optional` |
    | type | Unknown | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().message.send("Hello");
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | message | Unknown | `String` | `Optional` |
    | type | Unknown | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |


- **list**
  - **Description**
    - Get message list.
  - **Prototype**
    ```dart
    List<ZegoInRoomMessage> list({ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | type | Message type | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().message.list();
    ```

- **stream**
  - **Description**
    - Get message stream.
  - **Prototype**
    ```dart
    Stream<List<ZegoInRoomMessage>> stream({required String targetRoomID, bool includeFakeMessage = true, ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | targetRoomID | Target room ID | `String` | `Required` |
    | includeFakeMessage | Whether to include fake message | `bool` | `true` |
    | type | Message type | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |


- **delete**
  - **Description**
    - Delete message.
  - **Prototype**
    ```dart
    Future<void> delete(int messageID)
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | message | Unknown | `String` | `Optional` |
    | type | Unknown | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().message.delete(123);
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | message | Unknown | `String` | `Optional` |
    | type | Unknown | `ZegoInRoomMessageType` | `ZegoInRoomMessageType.broadcastMessage` |


---

### PIP

**ZegoLiveStreamingControllerPIP**

- **status**
  - **Description**
    - Get current PIP status.
  - **Prototype**
    ```dart
    Future<ZegoPiPStatus> get status
    ```

- **available**
  - **Description**
    - Check if PIP is available.
  - **Prototype**
    ```dart
    Future<bool> get available
    ```

- **enable**
  - **Description**
    - Enable Picture-in-Picture.
  - **Prototype**
    ```dart
    Future<ZegoPiPStatus> enable({int aspectWidth = 9, int aspectHeight = 16})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | aspectWidth | Unknown | `int` | `9` |
    | aspectHeight | Unknown | `int` | `16` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pip.enable();
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | aspectWidth | Unknown | `int` | `9` |
    | aspectHeight | Unknown | `int` | `16` |


- **enableWhenBackground**
  - **Description**
    - Enable Picture-in-Picture when app goes to background.
  - **Prototype**
    ```dart
    Future<ZegoPiPStatus> enableWhenBackground({int aspectWidth = 9, int aspectHeight = 16})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | aspectWidth | Unknown | `int` | `9` |
    | aspectHeight | Unknown | `int` | `16` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pip.enableWhenBackground();
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | aspectWidth | Unknown | `int` | `9` |
    | aspectHeight | Unknown | `int` | `16` |


- **cancelBackground**
  - **Description**
    - Cancel background Picture-in-Picture.
  - **Prototype**
    ```dart
    Future<void> cancelBackground()
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | aspectWidth | Unknown | `int` | `9` |
    | aspectHeight | Unknown | `int` | `16` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().pip.cancelBackground();
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | aspectWidth | Unknown | `int` | `9` |
    | aspectHeight | Unknown | `int` | `16` |


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
  - **Note**
    - This method is available in `ZegoUIKitPrebuiltLiveStreamingController`, not in Room controller.

- **queryProperties**
  - **Description**
    - Query room properties.
  - **Prototype**
    ```dart
    Future<Map<String, String>> queryProperties({required String roomID})
    ```

- **sendCommand**
  - **Description**
    - Send room command.
  - **Prototype**
    ```dart
    Future<bool> sendCommand({required String roomID, required Uint8List command})
    ```

- **commandReceivedStream**
  - **Description**
    - Room command stream notify.
  - **Prototype**
    ```dart
    Stream<ZegoSignalingPluginInRoomCommandMessageReceivedEvent> commandReceivedStream()
    ```

- **propertiesStream**
  - **Description**
    - Room properties stream notify.
  - **Prototype**
    ```dart
    Stream<ZegoSignalingPluginRoomPropertiesUpdatedEvent> propertiesStream()
    ```

- **renewToken**
  - **Description**
    - Renew room token.
  - **Prototype**
    ```dart
    Future<void> renewToken(String token)
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | token | The new token | `String` | `Required` |


- **updateProperty**
  - **Description**
    - Update a room property.
  - **Prototype**
    ```dart
    Future<bool> updateProperty({required String roomID, required String key, required String value, bool isForce = false, bool isDeleteAfterOwnerLeft = false, bool isUpdateOwner = false})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | context | Unknown | `BuildContext` | `Optional` |
    | showConfirmation | Unknown | `bool` | `false` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().room.updateProperty(roomID: "123", key: "test", value: "1");
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | context | Unknown | `BuildContext` | `Optional` |
    | showConfirmation | Unknown | `bool` | `false` |


- **updateProperties**
  - **Description**
    - Update multiple room properties.
  - **Prototype**
    ```dart
    Future<bool> updateProperties({required String roomID, required Map<String, String> roomProperties, bool isForce = false, bool isDeleteAfterOwnerLeft = false, bool isUpdateOwner = false})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | context | Unknown | `BuildContext` | `Optional` |
    | showConfirmation | Unknown | `bool` | `false` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().room.updateProperties(roomID: "123", roomProperties: {"test": "1"});
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | context | Unknown | `BuildContext` | `Optional` |
    | showConfirmation | Unknown | `bool` | `false` |


- **deleteProperties**
  - **Description**
    - Delete room properties.
  - **Prototype**
    ```dart
    Future<bool> deleteProperties({required String roomID, required List<String> keys, bool isForce = false})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | context | Unknown | `BuildContext` | `Optional` |
    | showConfirmation | Unknown | `bool` | `false` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().room.deleteProperties(roomID: "123", keys: ["test"]);
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | context | Unknown | `BuildContext` | `Optional` |
    | showConfirmation | Unknown | `bool` | `false` |


- **renewToken**
  - **Description**
    - Renew room token.
  - **Prototype**
    ```dart
    Future<bool> renewToken({required String token})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | context | Unknown | `BuildContext` | `Optional` |
    | showConfirmation | Unknown | `bool` | `false` |


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
    ZegoUIKitPrebuiltLiveStreamingController().user.remove(`"user1"`);
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
    - Host invite `audience` to be a co-host.
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
    - Host approve the co-host request made by `audience`.
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
    - Host reject the co-host request made by `audience`.
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
    - Host remove the co-host, make `coHost` to be an audience.
  - **Prototype**
    ```dart
    Future<bool> removeCoHost(ZegoUIKitUser coHost, {String customData = ''})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().coHost.removeCoHost(coHost);
    ```

---

### Log

**ZegoLiveStreamingControllerLog**

- **exportLogs**
  - **Description**
    - Export logs.
  - **Prototype**
    ```dart
    Future<bool> exportLogs({String? title, String? content, String? fileName, List<ZegoLogExporterFileType> fileTypes = const `ZegoLogExporterFileType.txt, ZegoLogExporterFileType.log, ZegoLogExporterFileType.zip`, List<ZegoLogExporterDirectoryType> directories = const [ZegoLogExporterDirectoryType.zegoUIKits, ZegoLogExporterDirectoryType.zimAudioLog, ZegoLogExporterDirectoryType.zimLogs, ZegoLogExporterDirectoryType.zefLogs, ZegoLogExporterDirectoryType.zegoLogs], void Function(double progress)? onProgress})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | title | Unknown | `String?` | `Optional` |
    | content | Unknown | `String?` | `Optional` |
    | fileName | Unknown | `String?` | `Optional` |
    | fileTypes | Unknown | `List<ZegoLogExporterFileType>` | `const [ZegoLogExporterFileType.txt` |
    | directories | Unknown | `List<ZegoLogExporterDirectoryType>` | `const [ZegoLogExporterDirectoryType.zegoUIKits` |
    | Function | Unknown | `void` | `Optional` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().log.exportLogs();
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | title | Unknown | `String?` | `Optional` |
    | content | Unknown | `String?` | `Optional` |
    | fileName | Unknown | `String?` | `Optional` |
    | fileTypes | Unknown | `List<ZegoLogExporterFileType>` | `const [ZegoLogExporterFileType.txt` |
    | directories | Unknown | `List<ZegoLogExporterDirectoryType>` | `const [ZegoLogExporterDirectoryType.zegoUIKits` |
    | Function | Unknown | `void` | `Optional` |


---

### Media

**ZegoLiveStreamingControllerMedia**

- **defaultPlayer**
  - **Description**
    - Default player controller.
  - **Prototype**
    ```dart
    ZegoLiveStreamingControllerMediaDefaultPlayer get defaultPlayer
    ```

- **volume**
  - **Description**
    - Volume of current media.
  - **Prototype**
    ```dart
    int get volume
    ```

- **totalDuration**
  - **Description**
    - The total progress (millisecond) of current media resources.
  - **Prototype**
    ```dart
    int get totalDuration
    ```

- **currentProgress**
  - **Description**
    - Current playing progress of current media.
  - **Prototype**
    ```dart
    int get currentProgress
    ```

- **type**
  - **Description**
    - Media type of current media.
  - **Prototype**
    ```dart
    ZegoUIKitMediaType get type
    ```

- **volumeNotifier**
  - **Description**
    - Volume notifier of current media.
  - **Prototype**
    ```dart
    ValueNotifier<int> get volumeNotifier
    ```

- **currentProgressNotifier**
  - **Description**
    - Current progress notifier of current media.
  - **Prototype**
    ```dart
    ValueNotifier<int> get currentProgressNotifier
    ```

- **playStateNotifier**
  - **Description**
    - Play state notifier of current media.
  - **Prototype**
    ```dart
    ValueNotifier<ZegoUIKitMediaPlayState> get playStateNotifier
    ```

- **typeNotifier**
  - **Description**
    - Type notifier of current media.
  - **Prototype**
    ```dart
    ValueNotifier<ZegoUIKitMediaType> get typeNotifier
    ```

- **muteNotifier**
  - **Description**
    - Mute state notifier of current media.
  - **Prototype**
    ```dart
    ValueNotifier<bool> get muteNotifier
    ```

- **info**
  - **Description**
    - Info of current media.
  - **Prototype**
    ```dart
    ZegoUIKitMediaInfo get info
    ```

- **play**
  - **Description**
    - Start play media.
  - **Prototype**
    ```dart
    Future<ZegoUIKitMediaPlayResult> play({required String filePathOrURL, bool enableRepeat = false, bool autoStart = true})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.play(filePathOrURL: "http://test.com/a.mp4");
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |


- **destroy**
  - **Description**
    - Destroy current media.
  - **Prototype**
    ```dart
    Future<void> destroy()
    ```

- **pickPureAudioFile**
  - **Description**
    - Pick pure audio media file.
  - **Prototype**
    ```dart
    Future<List<ZegoUIKitPlatformFile>> pickPureAudioFile()
    ```

- **pickVideoFile**
  - **Description**
    - Pick video media file.
  - **Prototype**
    ```dart
    Future<List<ZegoUIKitPlatformFile>> pickVideoFile()
    ```

- **pickFile**
  - **Description**
    - Pick media file.
  - **Prototype**
    ```dart
    Future<List<ZegoUIKitPlatformFile>> pickFile({List<String>? allowedExtensions})
    ```


- **stop**
  - **Description**
    - Stop play media.
  - **Prototype**
    ```dart
    Future<void> stop()
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.stop();
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |


- **pause**
  - **Description**
    - Pause media.
  - **Prototype**
    ```dart
    Future<void> pause()
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.pause();
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |


- **resume**
  - **Description**
    - Resume media.
  - **Prototype**
    ```dart
    Future<void> resume()
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.resume();
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |


- **seekTo**
  - **Description**
    - Seek to specified position.
  - **Prototype**
    ```dart
    Future<ZegoUIKitMediaSeekToResult> seekTo(int millisecond)
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.seekTo(1000);
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |


- **setVolume**
  - **Description**
    - Set media volume.
  - **Prototype**
    ```dart
    Future<void> setVolume(int volume, {bool isSyncToRemote = false})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.setVolume(50);
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |


- **muteLocal**
  - **Description**
    - Mute local playback.
  - **Prototype**
    ```dart
    Future<void> muteLocal(bool mute)
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.muteLocal(true);
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |


- **pickFile**
  - **Description**
    - Pick media file.
  - **Prototype**
    ```dart
    Future<List<ZegoUIKitPlatformFile>> pickFile({List<String>? allowedExtensions})
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |

  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().media.pickFile();
    ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | filePathOrURL | Unknown | `String` | `Required` |
    | enableRepeat | Unknown | `bool` | `false` |
    | autoStart | Unknown | `bool` | `true` |


---
