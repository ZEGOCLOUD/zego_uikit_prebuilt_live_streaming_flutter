# Hall

This feature provides a visual gallery where viewers can browse and discover live streaming rooms in a grid or list format. The hall view serves as an entry point for viewers to explore available live streams and join their preferred ones.


---

- [Usage Scenarios](#usage-scenarios)
- [ZegoUIKitLiveStreamingHallList](#zegouikitlivestreaminghalllist)
- [ZegoLiveStreamingHallListStyle](#zegolivstreaminghallliststyle)
- [ZegoLiveStreamingHallListForegroundStyle](#zegolivstreaminghalllistforegroundstyle)
- [ZegoLiveStreamingHallListConfig](#zegolivstreaminghalllistconfig)
- [ZegoLiveStreamingHallConfig](#zegolivstreaminghallconfig)
- [ZegoLiveStreamingHallListItemStyle](#zegolivstreaminghalllistitemstyle)
- [ZegoLiveStreamingHallListModel](#zegolivstreaminghalllistmodel)
- [ZegoLiveStreamingHallListModelDelegate](#zegolivstreaminghalllistmodeldelegate)
- [ZegoLiveStreamingHallHost](#zegolivstreaminghallhost)
- [ZegoLiveStreamingHallListSlideContext](#zegolivesstreaminghalllistslidecontext)


## Usage Scenarios

### Live Stream Discovery
- **Scenario**: Viewers can browse all available live streaming rooms in a grid/list view and select one to join
- **Implementation**:
  - Use `ZegoUIKitLiveStreamingHallList` widget to display the hall
  - Provide live room data through `ZegoLiveStreamingHallListModel`
  - Configure hall appearance via `ZegoLiveStreamingHallListStyle` and `ZegoLiveStreamingHallListConfig`
  - Handle room entry via `configsQuery` callback to customize each room's configuration

- **Key Configuration**:
  - `hallModel`: The data model containing the list of live rooms
  - `hallConfig`: Video quality and stream mode settings
  - `hallStyle`: Visual styling for the hall list items
  - `configsQuery`: Callback to customize each room's configuration when joining
  - `hallModelDelegate`: Delegate to handle hall list interactions
  - `eventsQuery`: Callback to handle events for each room

- **Complete Example**:

  ```dart
  // Import Flutter material for Locale
  import 'package:flutter/material.dart';
  import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

  // Entry point - Display the hall list
  void showHallList() {
    final user = getCurrentUser(); // Get your user info

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => hallList(
          context.locale,
          null,  // hallListModel - initial load
          null,  // hallListModelDelegate
        ),
      ),
    );
  }

  // Reusable method to build the hall list widget
  // This method can be called both for initial display and when navigating back from a live streaming page
  Widget hallList(
    Locale locale,
    ZegoLiveStreamingHallListModel? hallListModel,
    ZegoLiveStreamingHallListModelDelegate? hallListModelDelegate,
  ) {
    final user = getCurrentUser(); // Get your user info

    return ZegoUIKitLiveStreamingHallList(
      appID: appID,
      userID: user.id,
      userName: user.name,
      appSign: appSign,
      token: token,
      
      // Required: Provide config for each room when user joins
      configsQuery: (String liveID) {
        return ZegoUIKitPrebuiltLiveStreamingConfig(
          appID: appID,
          userID: user.id,
          userName: user.name,
          liveID: liveID,
          role: ZegoLiveStreamingRole.audience,
          
          // Optional: Configure room-specific settings
          configQuery: (config) {
            // Enable beauty effects for hosts
            config.beauty = ZegoUIKitBeautyConfig();
            
            // Configure audio/video settings
            config.audioVideoView = ZegoAudioVideoViewConfig(
              showSoundWave: true,
            );
            
            return config;
          },
        );
      },
      
      // Required: Handle events for each room
      // Note: hall.onPagePushReplace is REQUIRED to handle navigation when users leave a live streaming page
      eventsQuery: (String liveID) {
        return ZegoUIKitPrebuiltLiveStreamingEvents(
          // Handle navigation back to hall when user leaves the live streaming
          hall: ZegoLiveStreamingHallEvents(
            onPagePushReplace: (BuildContext context, String fromLiveID, ZegoLiveStreamingHallListModel? hallListModel, ZegoLiveStreamingHallListModelDelegate? hallListModelDelegate) {
              // Navigate back to the hall list page
              // Reuse the hallList method to build the hall list widget
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => hallList(
                    context.locale,  // Pass locale for internationalization
                    hallListModel,   // Pass hall list model to restore the list state
                    hallListModelDelegate,  // Pass delegate if using custom data source
                  ),
                ),
              );
            },
          ),
          
          // Handle room join events
          onRoomStateUpdated: (ZegoLiveStreamingState state, int errorCode, String extendedData) {
            print("Room $liveID state: $state, error: $errorCode");
          },
          
          // Handle user join/leave
          onUserJoin: (List<ZegoUIKitUser> users) {
            for (var user in users) {
              print("User joined: ${user.name}");
            }
          },
          onUserLeave: (List<ZegoUIKitUser> users) {
            for (var user in users) {
              print("User left: ${user.name}");
            }
          },
        );
      },
      
      // Optional: Provide live room data
      hallModel: ZegoLiveStreamingHallListModel.fromActiveStreamUsers(
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
        ],
      ),
      
      // Optional: Configure hall list settings
      hallConfig: ZegoLiveStreamingHallListConfig(
        // Set video quality
        video: ZegoVideoConfigExtension.preset180P(),
        // Set stream mode
        streamMode: ZegoUIKitHallRoomStreamMode.preloaded,
        // Set resource mode
        audioVideoResourceMode: ZegoUIKitStreamResourceMode.OnlyRTC,
      ),
      
      // Optional: Customize hall appearance
      hallStyle: ZegoLiveStreamingHallListStyle(
        // Custom loading widget
        loadingBuilder: (context) => CircularProgressIndicator(),
        // Item style configuration
        item: const ZegoUIKitHallRoomListItemStyle(),
        // Foreground style (user info, live badge, etc.)
        foreground: const ZegoLiveStreamingHallListForegroundStyle(
          showUserInfo: true,
          showLivingFlag: true,
          showCloseButton: false,
        ),
      ),
      
      // Optional: Controller for programmatic control
      hallController: ZegoLiveStreamingHallListController(),
    );
  }
  ```

---

## ZegoUIKitLiveStreamingHallList

The Hall List Widget.

- **Description**
  - A widget that displays a list of live streaming rooms (hall).
- **Prototype**
  ```dart
  ZegoUIKitLiveStreamingHallList({
    required int appID,
    required String userID,
    required String userName,
    required ZegoUIKitPrebuiltLiveStreamingConfig Function(String liveID) configsQuery,
    String appSign = '',
    String token = '',
    ZegoUIKitPrebuiltLiveStreamingEvents? Function(String liveID)? eventsQuery,
    ZegoLiveStreamingHallListStyle? hallStyle,
    ZegoLiveStreamingHallListConfig? hallConfig,
    ZegoLiveStreamingHallListController? hallController,
    ZegoLiveStreamingHallListModel? hallModel,
    ZegoLiveStreamingHallListModelDelegate? hallModelDelegate,
  })
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | appID | Your ZEGOCLOUD App ID. | `int` | `Required` |
    | userID | The ID of the current user. | `String` | `Required` |
    | userName | The name of the current user. | `String` | `Required` |
    | configsQuery | Callback to get the live streaming config for a given live ID. | `ZegoUIKitPrebuiltLiveStreamingConfig Function(String liveID)` | `Required` |
    | appSign | The app sign for authentication. | `String` | `''` |
    | token | The token for authentication. | `String` | `''` |
    | eventsQuery | Callback to get the events for a given live ID. <br/>**Required** when using hall: You must set [ZegoUIKitPrebuiltLiveStreamingEvents.hall.onPagePushReplace] callback to handle navigation when users leave a live streaming page. | `ZegoUIKitPrebuiltLiveStreamingEvents? Function(String liveID)?` | `Optional` |
    | hallStyle | Style configuration for the hall list. | `ZegoLiveStreamingHallListStyle?` | `Optional` |
    | hallConfig | Configuration for the hall list. | `ZegoLiveStreamingHallListConfig?` | `Optional` |
    | hallController | Controller for the hall list. | `ZegoLiveStreamingHallListController?` | `Optional` |
    | hallModel | Model for the hall list. | `ZegoLiveStreamingHallListModel?` | `Optional` |
    | hallModelDelegate | Delegate for the hall list model. | `ZegoLiveStreamingHallListModelDelegate?` | `Optional` |

- **Example**
  ```dart
  ZegoUIKitLiveStreamingHallList(
    appID: 123456789,
    userID: 'user_id',
    userName: 'user_name',
    configsQuery: (liveID) => ZegoUIKitPrebuiltLiveStreamingConfig(
      appID: 123456789,
      userID: 'user_id',
      userName: 'user_name',
      liveID: liveID,
      role: ZegoLiveStreamingRole.host,
    ),
  );
  ```

---

## ZegoLiveStreamingHallListStyle

Style configuration for the Hall List widget.

- **Prototype**
  ```dart
  ZegoLiveStreamingHallListStyle({
    Widget? Function(BuildContext context)? loadingBuilder,
    ZegoLiveStreamingHallListItemStyle item = const ZegoUIKitHallRoomListItemStyle(),
    ZegoLiveStreamingHallListForegroundStyle foreground = const ZegoLiveStreamingHallListForegroundStyle(),
  })
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | loadingBuilder | Custom loading widget builder. | `Widget? Function(BuildContext context)?` | `Optional` |
    | item | Item style for the hall list. | `ZegoLiveStreamingHallListItemStyle` | `const ZegoUIKitHallRoomListItemStyle()` |
    | foreground | Foreground style for hall list items. | `ZegoLiveStreamingHallListForegroundStyle` | `const ZegoLiveStreamingHallListForegroundStyle()` |

- **Example**
  ```dart
  ZegoLiveStreamingHallListStyle(
    loadingBuilder: (context) => CircularProgressIndicator(),
    item: const ZegoUIKitHallRoomListItemStyle(),
    foreground: const ZegoLiveStreamingHallListForegroundStyle(),
  );
  ```

---

## ZegoLiveStreamingHallListForegroundStyle

Foreground style configuration for Hall List items.

- **Prototype**
  ```dart
  ZegoLiveStreamingHallListForegroundStyle({
    bool showUserInfo = true,
    bool showLivingFlag = true,
    bool showCloseButton = true,
  })
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | showUserInfo | Whether to show user information. | `bool` | `true` |
    | showLivingFlag | Whether to show the living indicator. | `bool` | `true` |
    | showCloseButton | Whether to show the close button. | `bool` | `true` |

- **Example**
  ```dart
  const ZegoLiveStreamingHallListForegroundStyle(
    showUserInfo: true,
    showLivingFlag: true,
    showCloseButton: true,
  );
  ```

---

## ZegoLiveStreamingHallListConfig

Configuration for the Hall List.

- **Prototype**
  ```dart
  ZegoLiveStreamingHallListConfig({
    ZegoUIKitVideoConfig? video,
    ZegoUIKitHallRoomStreamMode? streamMode,
    ZegoUIKitStreamResourceMode? audioVideoResourceMode,
  })
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | video | Video configuration. | `ZegoUIKitVideoConfig?` | `Optional` |
    | streamMode | Stream mode for the hall list. | `ZegoUIKitHallRoomStreamMode?` | `Optional` |
    | audioVideoResourceMode | Audio/video resource mode. | `ZegoUIKitStreamResourceMode?` | `Optional` |

- **Example**
  ```dart
  ZegoLiveStreamingHallListConfig(
    video: ZegoUIKitVideoConfig.preset1080P(),
    streamMode: ZegoUIKitHallRoomStreamMode.liveStreaming,
  );
  ```

---

## ZegoLiveStreamingHallConfig

Configuration for Hall.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| fromHall | Whether it is entered from the hall. | `bool` | `false` |

---

## ZegoLiveStreamingHallListItemStyle

Hall list item style for customizing the appearance of each item in the hall list.

- **Description**
  - This class provides styling configuration for individual items in the hall list. It allows customization of the foreground, background, loading state, and avatar for each item.
- **Properties**

| Name              | Description                                                                 | Type                              |
| :---------------- | :-------------------------------------------------------------------------- | :-------------------------------- |
| foregroundBuilder | Widget builder for foreground, always displayed on top of the view        | `Widget Function(...)?`          |
| backgroundBuilder | Widget builder for background, displayed when user closes camera          | `Widget Function(...)?`           |
| loadingBuilder    | Widget builder for loading state, return `Container()` to hide it          | `Widget Function(...)?`           |
| avatar            | Custom avatar configuration                                                 | `ZegoAvatarConfig?`              |

- **Example**

  ```dart
  final itemStyle = ZegoLiveStreamingHallListItemStyle(
    backgroundBuilder: (context, size, user, roomID) {
      return Container(
        color: Colors.black,
        child: user != null
            ? ZegoRemoteView(userID: user.id, roomID: roomID)
            : const Center(child: Icon(Icons.videocam_off)),
      );
    },
    foregroundBuilder: (context, size, user, roomID) {
      return Positioned(
        bottom: 10,
        left: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.name ?? 'Unknown'),
            const Chip(label: Text('LIVE')),
          ],
        ),
      );
    },
    loadingBuilder: (context, user, roomID) {
      return const CircularProgressIndicator();
    },
  );
  ```

---

## ZegoLiveStreamingHallListModel

Hall list model for managing the hall room list and interactions.

- **Description**
  - This class manages the state of rooms in the hall, including the currently active room and its adjacent rooms (previous and next). It provides functionality for sliding between rooms in the hall list, supporting vertical/horizontal sliding scenarios where users can switch between different rooms seamlessly.
  - The model maintains an internal list of all available stream users and tracks the current position/index. When sliding occurs, it automatically calculates the previous and next rooms based on the current position, with circular navigation support (wrapping around at the beginning and end of the list).
- **Properties**

| Name           | Description                                                                      | Type                                      |
| :------------- | :-------------------------------------------------------------------------------- | :---------------------------------------- |
| activeRoom     | The currently active/selected room in the hall                                  | `ZegoLiveStreamingHallHost?`            |
| activeContext  | Adjacent room data context relative to [activeRoom]                             | `ZegoLiveStreamingHallListSlideContext?`    |

- **Constructor**
  - `fromActiveStreamUsers(activeStreamUsers)`: Creates a model with a list of stream users
  - `fromActiveRoomAndContext(activeRoom, activeContext)`: Creates a model with specific active room and context
- **Methods**
  - `updateStreamUsers(streamUsers)`: Updates the list of stream users
  - `next()`: Gets the context for sliding to the next room
  - `previous()`: Gets the context for sliding to the previous room

- **Example**

  ```dart
  final model = ZegoLiveStreamingHallListModel.fromActiveStreamUsers(
    activeStreamUsers: [
      ZegoLiveStreamingHallHost(
        user: ZegoUIKitUser(id: 'host_1', name: 'Host 1'),
        roomID: 'live_1',
      ),
      ZegoLiveStreamingHallHost(
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

## ZegoLiveStreamingHallListModelDelegate

Delegate for managing hall room data yourself.

- **Description**
  - Use this delegate when you need to dynamically fetch room data (e.g., from server on-demand) instead of using a fixed room list. It provides callbacks for fetching adjacent rooms when the user swipes.
- **Properties**

| Name          | Description                                                                      | Type                                      |
| :------------ | :-------------------------------------------------------------------------------- | :---------------------------------------- |
| activeRoom    | The currently active/selected room in the hall                                  | `ZegoLiveStreamingHallHost`              |
| activeContext | Adjacent room data context relative to [activeRoom]                             | `ZegoLiveStreamingHallListSlideContext`      |
| delegate      | Callback triggered when swiping to fetch new adjacent rooms                     | `Function(bool toNext)?`                 |

- **Parameters**
  - `delegate(toNext)`: 
    - `toNext`: `true` means swipe to next room, `false` means swipe to previous room
    - Returns: `ZegoLiveStreamingHallListSlideContext` containing the new adjacent rooms

---

## ZegoLiveStreamingHallHost

Hall host (stream user) information for the hall list.

- **Description**
  - Represents a live streaming host in the hall list. Contains user information, room ID, and stream playback state.
- **Prototype**
  ```dart
  typedef ZegoLiveStreamingHallHost = ZegoUIKitHallRoomListStreamUser;
  ```

- **Properties**

| Name | Description | Type |
| :--- | :--- | :--- |
| user | The user information of the host | `ZegoUIKitUser` |
| roomID | The room ID of the live streaming | `String` |
| isPlayed | Whether the stream has been played | `bool` |
| isPlaying | Whether the stream is currently playing | `bool` |
| streamType | The stream type (main or aux). Use `aux` for PK scenarios | `ZegoStreamType` |

- **Example**
  ```dart
  ZegoLiveStreamingHallHost(
    user: ZegoUIKitUser(
      id: "host_1",
      name: "Host 1",
      isAnotherRoomUser: true,
    ),
    roomID: "live_1",
  );
  ```

---

## ZegoLiveStreamingHallListSlideContext

Slide context for adjacent room data in hall list sliding scenarios.

- **Description**
  - Encapsulates information about the "previous" and "next" rooms adjacent to the current room when sliding to switch between rooms. Works with the current room to form a "previous-current-next" data chain for smooth sliding.
- **Prototype**
  ```dart
  typedef ZegoLiveStreamingHallListSlideContext = ZegoUIKitHallRoomListSlideContext;
  ```

- **Properties**

| Name | Description | Type |
| :--- | :--- | :--- |
| previous | Information of the previous room relative to the active room | `ZegoLiveStreamingHallHost` |
| next | Information of the next room relative to the active room | `ZegoLiveStreamingHallHost` |

- **Example**
  ```dart
  // Get slide context from hall list model
  final model = ZegoLiveStreamingHallListModel.fromActiveStreamUsers(
    activeStreamUsers: [...],
  );
  
  // Slide to next room
  final nextContext = model.next();
  print('Next room: ${nextContext.next.roomID}');
  
  // Slide to previous room
  final prevContext = model.previous();
  print('Previous room: ${prevContext.previous.roomID}');
  ```
