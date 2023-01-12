// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'defines.dart';
import 'in_room_message_input_board.dart';

class ZegoInRoomMessageButton extends StatefulWidget {
  final ZegoLiveHostManager hostManager;
  final Size? iconSize;
  final Size? buttonSize;

  const ZegoInRoomMessageButton({
    Key? key,
    required this.hostManager,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  @override
  State<ZegoInRoomMessageButton> createState() =>
      _ZegoInRoomMessageButtonState();
}

class _ZegoInRoomMessageButtonState extends State<ZegoInRoomMessageButton> {
  var isMessageInputting = false;
  var chatEnableNotifier = ValueNotifier<bool>(true);
  List<StreamSubscription<dynamic>?> subscriptions = [];

  @override
  void initState() {
    super.initState();

    subscriptions.add(
        ZegoUIKit().getRoomPropertiesStream().listen(onRoomPropertiesUpdated));
  }

  @override
  void dispose() {
    super.dispose();

    for (var subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: chatEnableNotifier,
      builder: (context, isChatEnabled, _) {
        var chatLocalEnabled = true;
        if (!widget.hostManager.isHost) {
          chatLocalEnabled = isChatEnabled;
        }
        return ZegoTextIconButton(
          onPressed: chatLocalEnabled
              ? () {
                  isMessageInputting = true;
                  Navigator.of(context)
                      .push(ZegoInRoomMessageInputBoard())
                      .then((value) {
                    isMessageInputting = false;
                  });
                }
              : null,
          icon: ButtonIcon(
            icon: PrebuiltLiveStreamingImage.asset(chatLocalEnabled
                ? PrebuiltLiveStreamingIconUrls.im
                : PrebuiltLiveStreamingIconUrls.imDisabled),
          ),
          iconSize: widget.iconSize ?? Size(72.r, 72.r),
          buttonSize: widget.buttonSize ?? Size(96.r, 96.r),
        );
      },
    );
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    if (!updatedProperties.containsKey(disableChatRoomPropertyKey)) {
      return;
    }

    ZegoLoggerService.logInfo(
      "chat enabled property changed to "
      "${updatedProperties[disableChatRoomPropertyKey]!.value}",
      tag: "live streaming",
      subTag: "message button",
    );
    chatEnableNotifier.value =
        toBoolean(updatedProperties[disableChatRoomPropertyKey]!.value);
    if (!chatEnableNotifier.value && isMessageInputting) {
      ZegoLoggerService.logInfo(
        "message inputting, close it",
        tag: "live streaming",
        subTag: "message button",
      );
      Navigator.of(context).pop();
    }
  }

  bool toBoolean(String str) {
    return str != '0' && str != 'false' && str != '';
  }
}
