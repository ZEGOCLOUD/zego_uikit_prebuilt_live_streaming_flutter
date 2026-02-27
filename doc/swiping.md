# Swiping

This feature allows viewers to browse through different live streaming rooms by swiping left or right, similar to popular short-video platforms. Viewers can effortlessly explore multiple live streams without leaving the current interface.

---

- [Usage Scenarios](#usage-scenarios)
  - [Live Stream Browsing](#live-stream-browsing)
- [ZegoLiveStreamingSwipingConfig](#zegolivestreamingswipingconfig)
- [ZegoLiveStreamingSwipingStyle](#zegolivestreamingswipingstyle)
- [ZegoLiveStreamingSwipingModel](#zegolivestreamingswipingmodel)
- [ZegoLiveStreamingSwipingHost](#zegolivestreamingswipinghost)
- [ZegoLiveStreamingSwipingModelDelegate](#zegolivestreamingswipingmodeldelegate)
- [ZegoLiveStreamingSwipingSlideContext](#zegolivestreamingswipingslidecontext)
- [ZegoLiveStreamingStreamMode](#zegolivestreamingstreammode)

## Usage Scenarios

### Live Stream Browsing

- **Scenario**: Viewers can swipe horizontally to browse and switch between different live streaming rooms
- **Implementation**:

  - Configure `ZegoLiveStreamingSwipingConfig` in the `ZegoUIKitPrebuiltLiveStreamingConfig`
  - Provide the list of available live rooms using `ZegoUIKitHallRoomListModel`
  - Set the stream mode via `ZegoLiveStreamingSwipingConfig.streamMode`
- **Key Configuration**:
  - `model`: The data model containing the list of live rooms, Use when you have a **fixed** room list upfront (static data)
  - `modelDelegate`: Delegate to handle user interactions with the swiping interface, Use when you need to **dynamically** fetch room data (e.g., from server on-demand)
    - `activeRoom`: The currently active room
    - `activeContext`: Adjacent room context (previous/next)
    - `delegate`: Callback triggered when swiping to fetch new adjacent rooms
  - `streamMode`: Set to `ZegoUIKitHallRoomStreamMode.liveStreaming` for live streaming mode
- **Complete Example**:

  ```dart
  // Entry point - configure swiping when joining as audience
  void joinSwipingPage() {
    final user = getCurrentUser(); // Get your user info

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZegoLiveStreamingPage(
          appID: appID,
          appSign: appSign,
          token: token,
          userID: user.id,
          userName: user.name,
          liveID: initialLiveID, // Start from this live room
          isHost: false, // Audience mode
          configQuery: (config) {
            // Configure swiping feature
            config.swiping = ZegoLiveStreamingSwipingConfig(
              // Set stream mode for live streaming
              streamMode:ZegoLiveStreamingStreamMode.preloaded,

              // Provide the list of live rooms to browse
              model: ZegoUIKitHallRoomListModel.fromActiveStreamUsers(
                activeStreamUsers: [
                  ZegoLiveStreamingHallHost(
                    user: ZegoUIKitUser(
                      id: "host_1",
                      name: "Host 1",
                      isAnotherRoomUser: true,
                    ),
                    roomID: "live_1",
                  ),
                  ZegoLiveStreamingHallHost(
                    user: ZegoUIKitUser(
                      id: "host_2", 
                      name: "Host 2",
                      isAnotherRoomUser: true,
                    ),
                    roomID: "live_2",
                  ),
                  ZegoLiveStreamingHallHost(
                    user: ZegoUIKitUser(
                      id: "host_3",
                      name: "Host 3", 
                      isAnotherRoomUser: true,
                    ),
                    roomID: "live_3",
                  ),
                ],
              ),
            );

            // Optional: Customize swiping style
            config.swipingStyle = ZegoLiveStreamingSwipingStyle();

            return config;
          },
        ),
      ),
    );
  }
  ```

### Custom Data Management with modelDelegate

If you need to dynamically manage room data yourself (e.g., fetching from your server in real-time), use `modelDelegate` instead of `model`.

- **Scenario**: Dynamic room list from server, custom caching, or real-time data updates
- **Implementation**:
  - Set `model` to `null`
  - Provide `modelDelegate` with initial data and a delegate callback

- **Example**:

  ```dart
  // Entry point - using modelDelegate for custom data management
  void joinSwipingPageWithDelegate() {
    final user = getCurrentUser();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZegoLiveStreamingPage(
          appID: appID,
          appSign: appSign,
          token: token,
          userID: user.id,
          userName: user.name,
          liveID: initialLiveID,
          isHost: false,
          configQuery: (config) {
            // Use modelDelegate to manage data yourself
            config.swiping = ZegoLiveStreamingSwipingConfig(
              streamMode: ZegoLiveStreamingStreamMode.preloaded,

              // Don't set 'model', set 'modelDelegate' instead
              modelDelegate: ZegoLiveStreamingSwipingModelDelegate(
                // Initial active room (current room being viewed)
                activeRoom: ZegoLiveStreamingSwipingHost(
                  userID: 'host_001',
                  userName: 'Host 1',
                  liveID: 'live_001',
                  streamID: 'stream_001',
                ),

                // Initial adjacent room context
                activeContext: ZegoLiveStreamingSwipingSlideContext(
                  previous: ZegoLiveStreamingSwipingHost(
                    userID: 'host_000',
                    userName: 'Host 0',
                    liveID: 'live_000',
                    streamID: 'stream_000',
                  ),
                  next: ZegoLiveStreamingSwipingHost(
                    userID: 'host_002',
                    userName: 'Host 2',
                    liveID: 'live_002',
                    streamID: 'stream_002',
                  ),
                ),

                // Delegate callback - called when user swipes to fetch new rooms
                delegate: (bool toNext) {
                  // toNext: true means swipe to next room, false means swipe to previous room
                  // Implement your own logic to fetch adjacent rooms
                  // This could be from your server, local cache, etc.

                  // Example: Fetch from your server
                  final newContext = fetchAdjacentRooms(
                    currentLiveID: toNext ? 'live_002' : 'live_000',
                    direction: toNext ? 'next' : 'previous',
                  );

                  return newContext;
                },
              ),
            );

            return config;
          },
        ),
      ),
    );
  }

  // Example: Custom fetch function (implement your own logic)
  ZegoLiveStreamingSwipingSlideContext fetchAdjacentRooms({
    required String currentLiveID,
    required String direction,
  }) {
    // TODO: Replace with your actual server API call
    // This is just a placeholder demonstrating the return type
    return ZegoLiveStreamingSwipingSlideContext(
      previous: ZegoLiveStreamingSwipingHost(
        userID: 'host_prev',
        userName: 'Previous Host',
        liveID: 'live_prev',
        streamID: 'stream_prev',
      ),
      next: ZegoLiveStreamingSwipingHost(
        userID: 'host_next',
        userName: 'Next Host',
        liveID: 'live_next',
        streamID: 'stream_next',
      ),
    );
  }
  ```

---

## ZegoLiveStreamingSwipingConfig

Configuration for Swiping.

- **Properties**

| Name          | Description             | Type                                       | Default Value |
| :------------ | :---------------------- | :----------------------------------------- | :------------ |
| model         | Swiping model.          | `ZegoLiveStreamingSwipingModel?`         | `null`      |
| modelDelegate | Swiping model delegate. | `ZegoLiveStreamingSwipingModelDelegate?` | `null`      |

---

## ZegoLiveStreamingSwipingStyle

Live Streaming swiping configuration.

- **Description**

  - This class provides styling configuration for the swiping feature,
  - which allows users to swipe between different live streaming rooms.
- **Prototype**

  ```dart
  ZegoLiveStreamingSwipingStyle()
  ```

---

## ZegoLiveStreamingSwipingModel

Swiping model for managing the hall room list and sliding interactions.

- **Description**
  - This class manages the state of rooms in the hall, including the currently active room and its adjacent rooms (previous and next). It provides functionality for sliding between rooms in the hall list, supporting vertical/horizontal sliding scenarios where users can switch between different rooms seamlessly.
  - The model maintains an internal list of all available stream users and tracks the current position/index. When sliding occurs, it automatically calculates the previous and next rooms based on the current position, with circular navigation support (wrapping around at the beginning and end of the list).
- **Properties**

| Name           | Description                                                                      | Type                                     |
| :------------- | :-------------------------------------------------------------------------------- | :--------------------------------------- |
| activeRoom     | The currently active/selected room in the hall                                  | `ZegoLiveStreamingSwipingHost?`        |
| activeContext  | Adjacent room data context relative to `activeRoom`                             | `ZegoLiveStreamingSwipingSlideContext?` |

- **Constructor**
  - `fromActiveStreamUsers(activeStreamUsers)`: Creates a model with a list of stream users
  - `fromActiveRoomAndContext(activeRoom, activeContext)`: Creates a model with specific active room and context
- **Methods**
  - `updateStreamUsers(streamUsers)`: Updates the list of stream users
  - `next()`: Gets the context for sliding to the next room
  - `previous()`: Gets the context for sliding to the previous room

- **Example**

  ```dart
  final model = ZegoLiveStreamingSwipingModel.fromActiveStreamUsers(
    activeStreamUsers: [
      ZegoLiveStreamingSwipingHost(
        user: ZegoUIKitUser(id: 'host_1', name: 'Host 1'),
        roomID: 'live_1',
      ),
      ZegoLiveStreamingSwipingHost(
        user: ZegoUIKitUser(id: 'host_2', name: 'Host 2'),
        roomID: 'live_2',
      ),
    ],
  );

  // Slide to next room
  final nextContext = model.next();

  // Slide to previous room
  final prevContext = model.previous();
  ```

---

## ZegoLiveStreamingSwipingHost

Swiping host (stream user) information.

- **Description**
  - Represents a stream user in the hall room list, containing user information and room ID.
- **Properties**

| Name       | Description                        | Type                |
| :--------- | :---------------------------------- | :------------------ |
| user       | The user information               | `ZegoUIKitUser`    |
| roomID     | The room ID                        | `String`           |
| isPlayed   | Whether the stream has been played | `bool`             |
| isPlaying  | Whether the stream is playing       | `bool`             |
| streamType | The stream type                    | `ZegoStreamType`   |

---

## ZegoLiveStreamingSwipingModelDelegate

Delegate for managing room data yourself.

- **Description**
  - Use this delegate when you need to dynamically fetch room data (e.g., from server on-demand) instead of using a fixed room list. It provides callbacks for fetching adjacent rooms when the user swipes.
- **Properties**

| Name          | Description                                                                      | Type                                       |
| :------------ | :-------------------------------------------------------------------------------- | :----------------------------------------- |
| activeRoom    | The currently active/selected room in the hall                                  | `ZegoLiveStreamingSwipingHost`            |
| activeContext | Adjacent room data context relative to `activeRoom`                             | `ZegoLiveStreamingSwipingSlideContext`    |
| delegate      | Callback triggered when swiping to fetch new adjacent rooms                     | `Function(bool toNext)?`                  |

- **Parameters**
  - `delegate(toNext)`: 
    - `toNext`: `true` means swipe to next room, `false` means swipe to previous room
    - Returns: `ZegoLiveStreamingSwipingSlideContext` containing the new adjacent rooms

---

## ZegoLiveStreamingSwipingSlideContext

Context for adjacent room data in room sliding scenarios.

- **Description**
  - Encapsulates information about the "previous" and "next" rooms adjacent to the current room when sliding to switch between rooms.
- **Properties**

| Name     | Description                                           | Type                        |
| :------- | :----------------------------------------------------- | :-------------------------- |
| previous | Information of the previous room relative to active   | `ZegoLiveStreamingSwipingHost` |
| next     | Information of the next room relative to active       | `ZegoLiveStreamingSwipingHost` |

---

## ZegoLiveStreamingStreamMode

Stream mode for live streaming.

- **Description**
  - Defines how streams are managed when switching between rooms.
- **Values**

| Name       | Description                                                                                      |
| :--------- | :----------------------------------------------------------------------------------------------- |
| preloaded  | Pre-pull streams and mute/unmute for smooth switching. More smooth experience but costs extra for two additional streams (previous/next). |
| economy    | Stop/start streams when switching. No extra stream costs, but may have brief video/audio rendering delays, black screen, or stuttering during switching. |

- **Example**

  ```dart
  // Use preloaded mode for smoother experience
  config.swiping = ZegoLiveStreamingSwipingConfig(
    streamMode: ZegoLiveStreamingStreamMode.preloaded,
    model: model,
  );

  // Use economy mode to save bandwidth
  config.swiping = ZegoLiveStreamingSwipingConfig(
    streamMode: ZegoLiveStreamingStreamMode.economy,
    model: model,
  );
  ```
