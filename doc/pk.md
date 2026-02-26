# PK

This feature enables multiple hosts from different live streaming rooms to interact with each other in a PK (Player Killing) session. During a PK battle, all participating hosts' video streams are combined into a single mixed stream, creating a collaborative and competitive viewing experience for the audience.


---

- [Usage Scenarios](#usage-scenarios)
- [ZegoLiveStreamingControllerPKImpl](#zegolivstreamingcontrollerpkimpl)
- [ZegoLiveStreamingPKBattleConfig](#zegolivstreamingpkbattleconfig)
- [ZegoLiveStreamingPKBattleState](#zegolivstreamingpkbattlestate)
- [ZegoLiveStreamingPKBattleRejectCode](#zegolivstreamingpkbattlerejectcode)
- [ZegoLiveStreamingPKUser](#zegolivstreamingpkuser)
- [ZegoLiveStreamingPKServiceSendRequestResult](#zegolivstreamingpkservicesendrequestresult)
- [ZegoLiveStreamingPKServiceResult](#zegolivstreamingpkserviceresult)
- [ZegoLiveStreamingPKEvents](#zegolivstreamingpkevents)

## Usage Scenarios

### Multi-Host PK Battle

- **Scenario**: Multiple hosts from different rooms engage in real-time PK interactions
- **Implementation**:

  - Use `ZegoLiveStreamingPKEvents` to handle the PK lifecycle events
  - `Hosts` can send PK requests to `other hosts` via `ZegoLiveStreamingControllerPKImpl.sendRequest()`
  - `Accept` or `Reject` incoming PK requests using `acceptRequest()` or `rejectRequest()`
  - When PK starts, the SDK automatically mixes all participating hosts' videos into one frame
  - Monitor PK state changes through `ZegoLiveStreamingPKBattleState` via `onStateUpdated` event

- **PK Flow Process**:

  ```mermaid
  sequenceDiagram
      participant Host A
      participant Host B
      participant SDK

      Note over Host A: Host A starts live streaming
      Note over Host B: Host B starts live streaming

      Host A->>SDK: sendRequest(targetHostIDs: ["B"])
      SDK->>Host B: onIncomingRequestReceived

      alt Accept PK
          Host B->>SDK: acceptRequest(requestID)
          SDK->>Host A: onOutgoingRequestAccepted
          Note over Host A: Both hosts enter PK mode
          Note over Host B: Both hosts enter PK mode
      else Reject PK
          Host B->>SDK: rejectRequest(requestID)
          SDK->>Host A: onOutgoingRequestRejected
      end

      Note over Host A,Host B: PK in progress

      alt End PK
          Host A->>SDK: quit() or stop()
          SDK->>Host B: onEnded
      else Host leaves
          Host B->>SDK: Leave room
          SDK->>Host A: onUserQuited / onUserOffline
      end
  ```

- **Key Events to Handle**:

  | Event | Description |
  | :--- | :--- |
  | `onIncomingRequestReceived` | Receive PK invitation from another host |
  | `onIncomingRequestCancelled` | The received PK invitation was cancelled |
  | `onIncomingRequestTimeout` | The received PK invitation timed out |
  | `onOutgoingRequestAccepted` | Your PK request was accepted |
  | `onOutgoingRequestRejected` | Your PK request was rejected |
  | `onOutgoingRequestTimeout` | Your PK request timed out |
  | `onEnded` | PK session has ended |
  | `onUserOffline` | PK host went offline |
  | `onUserQuited` | PK host quit the PK session |
  | `onUserJoined` | A new host joined the PK |
  | `onUserDisconnected` | PK host disconnected |
  | `onUserReconnecting` | PK host is reconnecting |
  | `onUserReconnected` | PK host reconnected |

- **Complete Example**:

  ```dart
  // 1. Configure PK in your live streaming config
  ZegoUIKitPrebuiltLiveStreamingConfig config = ZegoUIKitPrebuiltLiveStreamingConfig(
    appID: appID,
    userID: userID,
    userName: userName,
    liveID: liveID,
    isHost: true,
    configQuery: (config) {
      // Configure PK settings
      config.pkBattle = ZegoLiveStreamingPKBattleConfig(
        userReconnectingSecond: 5,
        userDisconnectedSecond: 90,
      );
      return config;
    },
    eventsQuery: (config) {
      // 2. Handle PK lifecycle events
      config.pk = ZegoLiveStreamingPKEvents(
        // Received PK invitation
        onIncomingRequestReceived: (event, defaultAction) {
          // Show custom dialog or auto-accept
          // defaultAction.call() shows the default PK dialog
          defaultAction.call();
        },

        // PK invitation cancelled
        onIncomingRequestCancelled: (event, defaultAction) {
          defaultAction.call();
        },

        // PK invitation timed out
        onIncomingRequestTimeout: (event, defaultAction) {
          defaultAction.call();
        },

        // Your PK request was accepted
        onOutgoingRequestAccepted: (event, defaultAction) {
          defaultAction.call();
          // PK started - update UI state
        },

        // Your PK request was rejected
        onOutgoingRequestRejected: (event, defaultAction) {
          defaultAction.call();
          // Handle rejection - show message to user
        },

        // Your PK request timed out
        onOutgoingRequestTimeout: (event, defaultAction) {
          defaultAction.call();
        },

        // PK ended
        onEnded: (event, defaultAction) {
          defaultAction.call();
          // Update UI - PK has ended
        },

        // PK host went offline
        onUserOffline: (event, defaultAction) {
          defaultAction.call();
        },

        // PK host quit
        onUserQuited: (event, defaultAction) {
          defaultAction.call();
        },
      );

      // 3. Monitor overall live streaming state including PK state
      config.onStateUpdated = (state) {
        // Get PK state from controller
        final pkState = ZegoUIKitPrebuiltLiveStreamingController()
            .pk
            .stateNotifier
            .value;

        switch (pkState) {
          case ZegoLiveStreamingPKBattleState.idle:
            // Not in PK
            break;
          case ZegoLiveStreamingPKBattleState.loading:
            // PK is being set up
            break;
          case ZegoLiveStreamingPKBattleState.inPK:
            // Currently in PK
            break;
        }
      };

      return config;
    },
  );

  // 4. In your host code - send PK request to other hosts
  // Get the controller after entering the live room
  final pkController = ZegoUIKitPrebuiltLiveStreamingController().pk;

  // Send PK request to multiple hosts
  pkController.sendRequest(
    targetHostIDs: ["host_2", "host_3", "host_4"],
    timeout: 60,
    customData: "Let's PK!",
  ).then((result) {
    if (result.error == null) {
      // Request sent successfully
      // result.requestId contains the PK request ID
    } else {
      // Handle error
      // result.errorUserIDs contains hosts that failed to receive request
    }
  });

  // 5. Accept incoming PK request (for hosts receiving invitation)
  pkController.acceptRequest(
    requestID: "request_id",
    targetHost: ZegoLiveStreamingPKUser(
      userInfo: ZegoUIKitUser(id: "host_id", name: "host_name"),
      liveID: "live_id",
    ),
  );

  // 6. Reject incoming PK request
  pkController.rejectRequest(
    requestID: "request_id",
    targetHostID: "host_id",
  );

  // 7. Quit PK (any participant can quit)
  pkController.quit();

  // 8. Stop PK (only the initiator can stop)
  pkController.stop();
  ```
---

## ZegoLiveStreamingControllerPKImpl

PK controller implementation.

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

## ZegoLiveStreamingPKBattleConfig

Configuration for PK Battle.

- **Properties**

| Name                          | Description                         | Type                                                  | Default Value |
| :---------------------------- | :---------------------------------- | :---------------------------------------------------- | :------------ |
| userReconnectingSecond        | User reconnecting second.           | `int`                                               | `5`         |
| userDisconnectedSecond        | User disconnected second.           | `int`                                               | `90`        |
| mixerLayout                   | Mixer layout.                       | `ZegoLiveStreamingPKMixerLayout?`                   | `null`      |
| hostReconnectingBuilder       | Host reconnecting builder.          | `ZegoLiveStreamingPKBattleHostReconnectingBuilder?` | `null`      |
| topPadding                    | PK battle view top padding.         | `double?`                                           | `null`      |
| containerRect                 | Custom container rect.              | `Rect Function()?`                                  | `null`      |
| foregroundBuilder             | Custom foreground builder.          | `ZegoLiveStreamingPKBattleViewBuilder?`             | `null`      |
| topBuilder                    | Custom top builder.                 | `ZegoLiveStreamingPKBattleViewBuilder?`             | `null`      |
| bottomBuilder                 | Custom bottom builder.              | `ZegoLiveStreamingPKBattleViewBuilder?`             | `null`      |
| hostResumePKConfirmDialogInfo | Host resume PK confirm dialog info. | `ZegoLiveStreamingDialogInfo?`                      | `null`      |

---

## ZegoLiveStreamingPKBattleState

PK battle state.

- **Enum Values**

| Name    | Description               | Value |
| :------ | :------------------------ | :---- |
| idle    | No PK battle.             | `0` |
| loading | PK battle is loading.     | `1` |
| inPK    | PK battle is in progress. | `2` |

---

## ZegoLiveStreamingPKBattleRejectCode

PK battle reject code.

- **Enum Values**

| Name           | Description                                                                                    | Value |
| :------------- | :--------------------------------------------------------------------------------------------- | :---- |
| reject         | The invited host rejects your PK request.                                                      | `0` |
| hostStateError | The invited host hasn't started their own live stream, is in a PK battle, or is being invited. | `1` |
| busy           | The host is busy with another PK battle, invitation, or request.                               | `2` |

---

## ZegoLiveStreamingPKUser

PK user information.

- **Properties**

| Name     | Description          | Type              | Default Value |
| :------- | :------------------- | :---------------- | :------------ |
| userInfo | User information.    | `ZegoUIKitUser` |               |
| liveID   | Live ID of the user. | `String`        |               |

---

## ZegoLiveStreamingPKServiceSendRequestResult

Result of sending a PK request.

- **Properties**

| Name         | Description                       | Type                   | Default Value |
| :----------- | :-------------------------------- | :--------------------- | :------------ |
| requestID    | The ID of the current PK session. | `String`             | `''`        |
| errorUserIDs | List of user IDs that had errors. | `List<String>`       | `[]`        |
| error        | Platform exception if any.        | `PlatformException?` | `null`      |

---

## ZegoLiveStreamingPKServiceResult

Result of PK service operations.

- **Properties**

| Name         | Description                       | Type                   | Default Value |
| :----------- | :-------------------------------- | :--------------------- | :------------ |
| errorUserIDs | List of user IDs that had errors. | `List<String>`       | `[]`        |
| error        | Platform exception if any.        | `PlatformException?` | `null`      |

---

## ZegoLiveStreamingPKEvents

PK related events.

The [defaultAction] is the internal default behavior (popup).
If you override the event and still require these default actions, please execute `defaultAction.call()`.

### onIncomingRequestReceived

- **Description**

  - Received a PK invitation.
  - When receiving a PK battle request, the Live Streaming Kit defaults to check whether you are accepting the PK battle request through a pop-up window.
  - You can receive callback notifications or customize your business logic by listening to or setting up this callback.
- **Prototype**

  ```dart
  void Function(
    ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent event,
    VoidCallback defaultAction,
  )?
  ```
- **Example**

  ```dart
  onIncomingRequestReceived: (event, defaultAction) {
    // Handle incoming request received
    defaultAction.call();
  }
  ```

### onIncomingRequestCancelled

- **Description**

  - The received PK invitation has been canceled by the inviting host.
- **Prototype**

  ```dart
  Function(
    ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent event,
    VoidCallback defaultAction,
  )?
  ```
- **Example**

  ```dart
  onIncomingRequestCancelled: (event, defaultAction) {
    // Handle incoming request cancelled
    defaultAction.call();
  }
  ```

### onIncomingRequestTimeout

- **Description**

  - The received PK invitation has timed out.
- **Prototype**

  ```dart
  void Function(
    ZegoLiveStreamingIncomingPKBattleRequestTimeoutEvent event,
    VoidCallback defaultAction,
  )?
  ```
- **Example**

  ```dart
  onIncomingRequestTimeout: (event, defaultAction) {
    // Handle incoming request timeout
    defaultAction.call();
  }
  ```

### onOutgoingRequestAccepted

- **Description**

  - The PK invitation has been accepted.
  - When the sent PK battle request is accepted, the Live Streaming Kit starts the PK battle by default.
- **Prototype**

  ```dart
  void Function(
    ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent event,
    VoidCallback defaultAction,
  )?
  ```
- **Example**

  ```dart
  onOutgoingRequestAccepted: (event, defaultAction) {
    // Handle outgoing request accepted
    defaultAction.call();
  }
  ```

### onOutgoingRequestRejected

- **Description**

  - The PK invitation has been rejected.
  - When the sent PK battle request is rejected, the default behaviour is notify you that the host has rejected your PK battle request through a pop-up window.
- **Prototype**

  ```dart
  void Function(
    ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent event,
    VoidCallback defaultAction,
  )?
  ```
- **Example**

  ```dart
  onOutgoingRequestRejected: (event, defaultAction) {
    // Handle outgoing request rejected
    defaultAction.call();
  }
  ```

### onOutgoingRequestTimeout

- **Description**

  - Your PK invitation has been timeout.
  - If the invited host didn't respond after the timeout duration, the PK battle request timed out by default.
- **Prototype**

  ```dart
  void Function(
    ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent event,
    VoidCallback defaultAction,
  )?
  ```
- **Example**

  ```dart
  onOutgoingRequestTimeout: (event, defaultAction) {
    // Handle outgoing request timeout
    defaultAction.call();
  }
  ```

### onEnded

- **Description**

  - PK invitation had been ended.
- **Prototype**

  ```dart
  void Function(
    ZegoLiveStreamingPKBattleEndedEvent event,
    VoidCallback defaultAction,
  )?
  ```
- **Example**

  ```dart
  onEnded: (event, defaultAction) {
    // Handle PK ended
    defaultAction.call();
  }
  ```

### onUserOffline

- **Description**

  - PK host offline.
- **Prototype**

  ```dart
  void Function(
    ZegoLiveStreamingPKBattleUserOfflineEvent event,
    VoidCallback defaultAction,
  )?
  ```
- **Example**

  ```dart
  onUserOffline: (event, defaultAction) {
    // Handle user offline
    defaultAction.call();
  }
  ```

### onUserQuited

- **Description**

  - PK host quit.
- **Prototype**

  ```dart
  void Function(
    ZegoLiveStreamingPKBattleUserQuitEvent event,
    VoidCallback defaultAction,
  )?
  ```
- **Example**

  ```dart
  onUserQuited: (event, defaultAction) {
    // Handle user quit
    defaultAction.call();
  }
  ```

### onUserJoined

- **Description**

  - pk user enter.
- **Prototype**

  ```dart
  void Function(ZegoUIKitUser user)?
  ```
- **Example**

  ```dart
  onUserJoined: (user) {
    // Handle user joined
  }
  ```

### onUserDisconnected

- **Description**

  - pk user disconnect.
- **Prototype**

  ```dart
  void Function(ZegoUIKitUser user)?
  ```
- **Example**

  ```dart
  onUserDisconnected: (user) {
    // Handle user disconnected
  }
  ```

### onUserReconnecting

- **Description**

  - pk user reconnecting.
- **Prototype**

  ```dart
  void Function(ZegoUIKitUser user)?
  ```
- **Example**

  ```dart
  onUserReconnecting: (user) {
    // Handle user reconnecting
  }
  ```

### onUserReconnected

- **Description**

  - pk user reconnected.
- **Prototype**

  ```dart
  void Function(ZegoUIKitUser user)?
  ```
- **Example**

  ```dart
  onUserReconnected: (user) {
    // Handle user reconnected
  }
  ```

---

## PK Event Definitions

### ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent

Event received when an incoming PK battle request is received.

- **Properties**

| Name                 | Description                                        | Type                                                   | Default Value |
| :------------------- | :------------------------------------------------- | :----------------------------------------------------- | :------------ |
| requestID            | The ID of the current PK session.                  | `String`                                             |               |
| fromHost             | The host who sent the PK request.                  | `ZegoUIKitUser`                                      |               |
| fromLiveID           | The live ID of the host who sent the request.      | `String`                                             |               |
| isAutoAccept         | Whether the PK request will be auto-accepted.      | `bool`                                               |               |
| customData           | Custom data attached to the request.               | `String`                                             |               |
| startTimestampSecond | Timestamp (in seconds) when the PK starts.         | `int`                                                |               |
| timeoutSecond        | Timeout duration (in seconds) for this request.    | `int`                                                |               |
| sessionHosts         | The hosts already involved in the same PK session. | `List<ZegoLiveStreamingIncomingPKBattleRequestUser>` | `[]`        |

### ZegoLiveStreamingIncomingPKBattleRequestUser

User information in an incoming PK battle request.

- **Properties**

| Name       | Description                   | Type                                       | Default Value                                      |
| :--------- | :---------------------------- | :----------------------------------------- | :------------------------------------------------- |
| id         | User ID.                      | `String`                                 | `''`                                             |
| name       | User name.                    | `String`                                 | `''`                                             |
| fromLiveID | The live ID the user is from. | `String`                                 | `''`                                             |
| state      | Invitation user state.        | `ZegoSignalingPluginInvitationUserState` | `ZegoSignalingPluginInvitationUserState.unknown` |
| customData | Custom data.                  | `String`                                 | `''`                                             |

### ZegoLiveStreamingIncomingPKBattleRequestTimeoutEvent

Event received when an incoming PK battle request times out.

- **Properties**

| Name      | Description                       | Type              | Default Value |
| :-------- | :-------------------------------- | :---------------- | :------------ |
| requestID | The ID of the current PK session. | `String`        |               |
| fromHost  | The host who sent the PK request. | `ZegoUIKitUser` |               |

### ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent

Event received when an incoming PK battle request is cancelled.

- **Properties**

| Name       | Description                               | Type              | Default Value |
| :--------- | :---------------------------------------- | :---------------- | :------------ |
| requestID  | The ID of the current PK session.         | `String`        |               |
| fromHost   | The host who sent the PK request.         | `ZegoUIKitUser` |               |
| customData | Custom data attached to the cancellation. | `String`        |               |

### ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent

Event received when an outgoing PK battle request is accepted.

- **Properties**

| Name       | Description                                       | Type              | Default Value |
| :--------- | :------------------------------------------------ | :---------------- | :------------ |
| requestID  | The ID of the current PK session.                 | `String`        |               |
| fromHost   | The host who accepted the PK request.             | `ZegoUIKitUser` |               |
| fromLiveID | The live ID of the host who accepted the request. | `String`        |               |

### ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent

Event received when an outgoing PK battle request is rejected.

- **Properties**

| Name       | Description                           | Type              | Default Value |
| :--------- | :------------------------------------ | :---------------- | :------------ |
| requestID  | The ID of the current PK session.     | `String`        |               |
| fromHost   | The host who rejected the PK request. | `ZegoUIKitUser` |               |
| refuseCode | Reject reason code.                   | `int`           |               |

### ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent

Event received when an outgoing PK battle request times out.

- **Properties**

| Name      | Description                       | Type              | Default Value |
| :-------- | :-------------------------------- | :---------------- | :------------ |
| requestID | The ID of the current PK session. | `String`        |               |
| fromHost  | The host who was invited.         | `ZegoUIKitUser` |               |

### ZegoLiveStreamingPKBattleEndedEvent

Event received when a PK battle ends.

- **Properties**

| Name               | Description                                  | Type              | Default Value |
| :----------------- | :------------------------------------------- | :---------------- | :------------ |
| requestID          | The ID of the current PK session.            | `String`        |               |
| fromHost           | The host involved in the PK.                 | `ZegoUIKitUser` |               |
| time               | End time.                                    | `int`           |               |
| code               | End reason code.                             | `int`           |               |
| isRequestFromLocal | Whether the request was from the local user. | `bool`          |               |

### ZegoLiveStreamingPKBattleUserOfflineEvent

Event received when a PK battle user goes offline.

- **Properties**

| Name      | Description                       | Type              | Default Value |
| :-------- | :-------------------------------- | :---------------- | :------------ |
| requestID | The ID of the current PK session. | `String`        |               |
| fromHost  | The host who went offline.        | `ZegoUIKitUser` |               |

### ZegoLiveStreamingPKBattleUserQuitEvent

Event received when a PK battle user quits.

- **Properties**

| Name      | Description                       | Type              | Default Value |
| :-------- | :-------------------------------- | :---------------- | :------------ |
| requestID | The ID of the current PK session. | `String`        |               |
| fromHost  | The host who quit.                | `ZegoUIKitUser` |               |

---

## PK Mixer Layout

### ZegoLiveStreamingPKMixerLayout

Abstract class for PK mixer layout.

- **Description**

  - Inheritance of the hybrid layout parent class allows you to return your custom coordinates and modify the layout of the mixed stream.
  - You can refer to [ZegoLiveStreamingPKPreferGridMixerLayout] or [ZegoPKV2GridMixerLayout].
- **Methods**

#### getResolution

- **Description**
  - The size of the mixed stream canvas.
  - Default is 810.0 x 720.0.
- **Prototype**
  ```dart
  Size getResolution()
  ```

#### getRectList

- **Description**
  - Get the coordinates of the user's video frame on the PK layout at position [hostCount].
- **Prototype**
  ```dart
  List<Rect> getRectList(
    int hostCount, {
    double scale = 1.0,
  })
  ```

### ZegoLiveStreamingPKMixerDefaultLayout

Default PK mixer layout.

- **Description**
  - This is a typedef for [ZegoLiveStreamingPKPreferGridMixerLayout].
