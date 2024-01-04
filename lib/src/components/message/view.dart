// Flutter imports:
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';

/// @nodoc
class ZegoInRoomLiveMessageView extends StatefulWidget {
  final ZegoInRoomMessageConfig? config;
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoInnerText innerText;

  const ZegoInRoomLiveMessageView({
    Key? key,
    required this.innerText,
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
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: widget.config?.background ?? Container(),
          ),
          ZegoInRoomMessageView(
            historyMessages: ZegoUIKit().getInRoomMessages(),
            stream: ZegoUIKit().getInRoomMessageListStream(),
            itemBuilder: widget.config?.itemBuilder ??
                (BuildContext context, ZegoInRoomMessage message, _) {
                  return ZegoInRoomMessageViewItem(
                    message: message,
                    avatarLeadingBuilder: widget.config?.avatarLeadingBuilder,
                    avatarTailingBuilder: widget.config?.avatarTailingBuilder,
                    nameLeadingBuilder: widget.config?.nameLeadingBuilder,
                    nameTailingBuilder: widget.config?.nameTailingBuilder,
                    textLeadingBuilder: widget.config?.textLeadingBuilder,
                    textTailingBuilder: widget.config?.textTailingBuilder,
                    avatarBuilder: widget.avatarBuilder,
                    showName: widget.config?.showName ?? true,
                    showAvatar: widget.config?.showAvatar ?? true,
                    resendIcon: widget.config?.resendIcon,
                    borderRadius: widget.config?.borderRadius,
                    paddings: widget.config?.paddings,
                    opacity: widget.config?.opacity,
                    backgroundColor: widget.config?.backgroundColor,
                    maxLines: widget.config?.maxLines,
                    nameTextStyle: widget.config?.nameTextStyle,
                    messageTextStyle: widget.config?.messageTextStyle,
                    onItemClick: widget.config?.onMessageClick,
                    onItemLongPress: widget.config?.onMessageLongPress,
                  );
                },
          ),
        ],
      ),
    );
  }
}
