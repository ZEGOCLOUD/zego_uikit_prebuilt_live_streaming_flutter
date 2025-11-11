// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoLiveStreamingHallListController {
  /// Do not call, for uikit internal use
  ZegoUIKitHallRoomListController private;

  ZegoLiveStreamingHallListController()
      : private = ZegoUIKitHallRoomListController();

  String get roomID => private.roomID;
}
