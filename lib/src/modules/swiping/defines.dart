// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

typedef ZegoLiveStreamingStreamMode = ZegoUIKitHallRoomStreamMode;
typedef ZegoLiveStreamingSwipingModel = ZegoUIKitHallRoomListModel;
typedef ZegoLiveStreamingSwipingHost = ZegoUIKitHallRoomListStreamUser;

/// Swiping model delegate
///
/// If you want to manage data yourself, please refer to [ZegoLiveStreamingSwipingModel],
/// then cancel the setting of the `model` property, and then set `modelDelegate`
///
/// Example usage:
/// ```dart
/// final modelDelegate = ZegoLiveStreamingSwipingModelDelegate(
///   activeRoom: ZegoLiveStreamingSwipingHost(
///     userID: 'user_001',
///     userName: 'Host 1',
///     liveID: 'live_001',
///     streamID: 'stream_001',
///   ),
///   activeContext: ZegoLiveStreamingSwipingSlideContext(
///     previous: ZegoLiveStreamingSwipingHost(
///       userID: 'user_000',
///       userName: 'Host 0',
///       liveID: 'live_000',
///       streamID: 'stream_000',
///     ),
///     next: ZegoLiveStreamingSwipingHost(
///       userID: 'user_002',
///       userName: 'Host 2',
///       liveID: 'live_002',
///       streamID: 'stream_002',
///     ),
///   ),
///   delegate: (bool toNext) {
///     // Implement your own data fetching logic here
///     // toNext: true means swipe to next room, false means swipe to previous room
///     return ZegoLiveStreamingSwipingSlideContext(
///       previous: ZegoLiveStreamingSwipingHost(
///         userID: 'user_new_prev',
///         userName: 'New Previous Host',
///         liveID: 'live_new_prev',
///         streamID: 'stream_new_prev',
///       ),
///       next: ZegoLiveStreamingSwipingHost(
///         userID: 'user_new_next',
///         userName: 'New Next Host',
///         liveID: 'live_new_next',
///         streamID: 'stream_new_next',
///       ),
///     );
///   },
/// );
/// ```
typedef ZegoLiveStreamingSwipingModelDelegate
    = ZegoUIKitHallRoomListModelDelegate;
typedef ZegoLiveStreamingSwipingSlideContext
    = ZegoUIKitHallRoomListSlideContext;
