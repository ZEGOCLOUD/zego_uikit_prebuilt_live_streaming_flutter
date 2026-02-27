// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// Controller for the live streaming hall list.
///
/// This class is used to control the [ZegoUIKitLiveStreamingHallList] widget.
/// You can use it to get the current room ID and perform other operations.
class ZegoLiveStreamingHallListController {
  /// Do not call, for uikit internal use
  ZegoUIKitHallRoomListController private;

  ZegoLiveStreamingHallListController()
      : private = ZegoUIKitHallRoomListController();

  String get roomID => private.roomID;
}
