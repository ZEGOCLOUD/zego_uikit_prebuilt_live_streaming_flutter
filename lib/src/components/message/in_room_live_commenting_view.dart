// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'in_room_live_commenting_view_item.dart';

class ZegoInRoomLiveCommentingView extends StatefulWidget {
  final ZegoInRoomMessageItemBuilder? itemBuilder;

  const ZegoInRoomLiveCommentingView({
    Key? key,
    this.itemBuilder,
  }) : super(key: key);

  @override
  State<ZegoInRoomLiveCommentingView> createState() =>
      _ZegoInRoomLiveCommentingViewState();
}

class _ZegoInRoomLiveCommentingViewState
    extends State<ZegoInRoomLiveCommentingView> {
  @override
  Widget build(BuildContext context) {
    return ZegoInRoomMessageView(
      historyMessages: ZegoUIKit().getInRoomMessages(),
      stream: ZegoUIKit().getInRoomMessageListStream(),
      itemBuilder: widget.itemBuilder ??
          (BuildContext context, ZegoInRoomMessage message, _) {
            return ZegoInRoomLiveCommentingViewItem(
              user: message.user,
              message: message.message,
            );
          },
    );
  }
}
