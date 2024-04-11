// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';

/// @nodoc
class ZegoLiveStreamingInRoomLiveMessageView extends StatefulWidget {
  final ZegoLiveStreamingInRoomMessageConfig? config;
  final ZegoLiveStreamingInRoomMessageEvents? events;
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoUIKitPrebuiltLiveStreamingInnerText innerText;
  final Stream<ZegoInRoomMessage>? pseudoStream;

  const ZegoLiveStreamingInRoomLiveMessageView({
    Key? key,
    required this.innerText,
    required this.config,
    required this.events,
    this.pseudoStream,
    this.avatarBuilder,
  }) : super(key: key);

  @override
  State<ZegoLiveStreamingInRoomLiveMessageView> createState() =>
      _ZegoLiveStreamingInRoomLiveMessageViewState();
}

/// @nodoc
class _ZegoLiveStreamingInRoomLiveMessageViewState
    extends State<ZegoLiveStreamingInRoomLiveMessageView> {
  List<ZegoInRoomMessage> messageList = [];
  late StreamController<List<ZegoInRoomMessage>> streamControllerMessageList;
  List<StreamSubscription<dynamic>?> subscriptions = [];

  @override
  void initState() {
    super.initState();

    messageList = List<ZegoInRoomMessage>.from(ZegoUIKit().getInRoomMessages());

    streamControllerMessageList =
        StreamController<List<ZegoInRoomMessage>>.broadcast();

    subscriptions
      ..add(ZegoUIKit().getInRoomMessageStream().listen(onKitMessageUpdated))
      ..add(ZegoUIKit()
          .getInRoomLocalMessageStream()
          .listen(onKitLocalMessageUpdated))
      ..add(widget.pseudoStream?.listen(onPseudoMessageUpdated));
  }

  @override
  void dispose() {
    super.dispose();

    streamControllerMessageList.close();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

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
            stream: streamControllerMessageList.stream,
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
                    onItemClick: widget.events?.onClicked,
                    onItemLongPress: widget.events?.onLongPress,
                  );
                },
          ),
        ],
      ),
    );
  }

  void sortMessages() {
    messageList.sort((left, right) {
      return left.timestamp.compareTo(right.timestamp);
    });
  }

  void onKitMessageUpdated(ZegoInRoomMessage message) {
    messageList.add(message);
    sortMessages();

    streamControllerMessageList.add(List<ZegoInRoomMessage>.from(messageList));
  }

  void onKitLocalMessageUpdated(ZegoInRoomMessage message) {
    messageList.add(message);
    sortMessages();

    streamControllerMessageList.add(List<ZegoInRoomMessage>.from(messageList));
  }

  void onPseudoMessageUpdated(ZegoInRoomMessage message) {
    messageList.add(message);
    sortMessages();

    streamControllerMessageList.add(List<ZegoInRoomMessage>.from(messageList));
  }
}
