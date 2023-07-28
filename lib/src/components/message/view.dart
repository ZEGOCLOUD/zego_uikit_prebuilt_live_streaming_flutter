// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/view_item.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

/// @nodoc
class ZegoInRoomLiveMessageView extends StatefulWidget {
  final ZegoInRoomMessageViewConfig? config;
  final ZegoAvatarBuilder? avatarBuilder;

  const ZegoInRoomLiveMessageView({
    Key? key,
    this.config,
    this.avatarBuilder,
  }) : super(key: key);

  @override
  State<ZegoInRoomLiveMessageView> createState() =>
      _ZegoInRoomLiveMessageViewState();
}

/// @nodoc
class _ZegoInRoomLiveMessageViewState extends State<ZegoInRoomLiveMessageView> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ZegoInRoomMessageView(
        historyMessages: ZegoUIKit().getInRoomMessages(),
        stream: ZegoUIKit().getInRoomMessageListStream(),
        itemBuilder: widget.config?.itemBuilder ??
            (BuildContext context, ZegoInRoomMessage message, _) {
              return ZegoInRoomLiveMessageViewItem(
                message: message,
                config: widget.config,
                avatarBuilder: widget.avatarBuilder,
                showName: widget.config?.showName ?? true,
                showAvatar: widget.config?.showAvatar ?? true,
              );
            },
      ),
    );
  }
}
