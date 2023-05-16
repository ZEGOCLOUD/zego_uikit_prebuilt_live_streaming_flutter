// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/in_room_live_commenting_view_item.dart';

/// @nodoc
class ZegoInRoomLiveCommentingView extends StatefulWidget {
  final ZegoInRoomMessageItemBuilder? itemBuilder;
  final double opacity;

  const ZegoInRoomLiveCommentingView({
    Key? key,
    this.itemBuilder,
    this.opacity = 0.5,
  }) : super(key: key);

  @override
  State<ZegoInRoomLiveCommentingView> createState() =>
      _ZegoInRoomLiveCommentingViewState();
}

/// @nodoc
class _ZegoInRoomLiveCommentingViewState
    extends State<ZegoInRoomLiveCommentingView> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ZegoInRoomMessageView(
        historyMessages: ZegoUIKit().getInRoomMessages(),
        stream: ZegoUIKit().getInRoomMessageListStream(),
        itemBuilder: widget.itemBuilder ??
            (BuildContext context, ZegoInRoomMessage message, _) {
              return ZegoInRoomLiveCommentingViewItem(
                user: message.user,
                message: message.message,
                opacity: widget.opacity,
              );
            },
      ),
    );
  }
}
