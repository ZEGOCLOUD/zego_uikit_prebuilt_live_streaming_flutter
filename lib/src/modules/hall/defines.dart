// Flutter imports:
import 'package:flutter/cupertino.dart';
// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// Typedef for the hall list item style.
/// See [ZegoUIKitHallRoomListItemStyle] for details.
typedef ZegoLiveStreamingHallListItemStyle = ZegoUIKitHallRoomListItemStyle;

/// Typedef for the hall list configuration.
/// See [ZegoUIKitHallRoomListConfig] for details.
typedef ZegoLiveStreamingHallListConfig = ZegoUIKitHallRoomListConfig;

/// Typedef for the hall list model.
/// See [ZegoUIKitHallRoomListModel] for details.
typedef ZegoLiveStreamingHallListModel = ZegoUIKitHallRoomListModel;

/// Typedef for the hall host (stream user).
/// See [ZegoUIKitHallRoomListStreamUser] for details.
typedef ZegoLiveStreamingHallHost = ZegoUIKitHallRoomListStreamUser;

/// Typedef for the hall list model delegate.
/// See [ZegoUIKitHallRoomListModelDelegate] for details.
typedef ZegoLiveStreamingHallListModelDelegate
    = ZegoUIKitHallRoomListModelDelegate;

/// Typedef for the slide context in hall list.
/// See [ZegoUIKitHallRoomListSlideContext] for details.
typedef ZegoLiveStreamingHallListSlideContext
    = ZegoUIKitHallRoomListSlideContext;

/// View style for the live hall list.
///
/// This class provides styling configuration for the live streaming hall list,
/// which displays a list of available live streaming rooms.
class ZegoLiveStreamingHallListStyle {
  /// Loading builder, return [Container()] if you want hide it.
  final Widget? Function(BuildContext context)? loadingBuilder;

  /// Item style for the hall list.
  final ZegoLiveStreamingHallListItemStyle item;

  /// Foreground style for the hall list items.
  final ZegoLiveStreamingHallListForegroundStyle foreground;

  /// Creates a hall list style with the given configuration.
  ///
  /// - [loadingBuilder] is a callback to build a custom loading widget.
  /// - [item] is the item style for list items.
  /// - [foreground] is the foreground style for the items.
  const ZegoLiveStreamingHallListStyle({
    this.loadingBuilder,
    this.item = const ZegoUIKitHallRoomListItemStyle(),
    this.foreground = const ZegoLiveStreamingHallListForegroundStyle(),
  });
}

/// Foreground style for the live hall list items.
///
/// This class defines what elements to show in the foreground of each
/// hall list item (user info, living flag, close button).
class ZegoLiveStreamingHallListForegroundStyle {
  /// Creates a foreground style configuration.
  ///
  /// - [showUserInfo] whether to show user information.
  /// - [showLivingFlag] whether to show the living indicator.
  /// - [showCloseButton] whether to show the close button.
  const ZegoLiveStreamingHallListForegroundStyle({
    this.showUserInfo = true,
    this.showLivingFlag = true,
    this.showCloseButton = true,
  });

  /// Whether to show user information.
  final bool showUserInfo;

  /// Whether to show the living indicator flag.
  final bool showLivingFlag;

  /// Whether to show the close button.
  final bool showCloseButton;
}
