// Package imports:
import 'package:flutter/cupertino.dart';
import 'package:zego_uikit/zego_uikit.dart';

typedef ZegoLiveStreamingHallListItemStyle = ZegoUIKitHallRoomListItemStyle;
typedef ZegoLiveStreamingHallListConfig = ZegoUIKitHallRoomListConfig;

typedef ZegoLiveStreamingHallListModel = ZegoUIKitHallRoomListModel;
typedef ZegoLiveStreamingHallHost = ZegoUIKitHallRoomListStreamUser;
typedef ZegoLiveStreamingHallListModelDelegate
    = ZegoUIKitHallRoomListModelDelegate;
typedef LiveStreamingHallListSlideContext = ZegoUIKitHallRoomListSlideContext;

/// view style
class ZegoLiveStreamingHallListStyle {
  /// loading builder, return Container() if you want hide it
  final Widget? Function(BuildContext context)? loadingBuilder;

  ///  item style
  final ZegoLiveStreamingHallListItemStyle item;

  final ZegoLiveStreamingHallListForegroundStyle foreground;

  const ZegoLiveStreamingHallListStyle({
    this.loadingBuilder,
    this.item = const ZegoUIKitHallRoomListItemStyle(),
    this.foreground = const ZegoLiveStreamingHallListForegroundStyle(),
  });
}

class ZegoLiveStreamingHallListForegroundStyle {
  const ZegoLiveStreamingHallListForegroundStyle({
    this.showUserInfo = true,
    this.showLivingFlag = true,
    this.showCloseButton = true,
  });

  final bool showUserInfo;
  final bool showLivingFlag;
  final bool showCloseButton;
}
