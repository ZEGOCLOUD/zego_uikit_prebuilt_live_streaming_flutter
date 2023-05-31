// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/in_room_message_input_board.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_inner_text.dart';

/// @nodoc
class ZegoInRoomMessageButton extends StatefulWidget {
  final ZegoLiveHostManager hostManager;
  final ButtonIcon? enabledIcon;
  final ButtonIcon? disabledIcon;
  final Size? iconSize;
  final Size? buttonSize;
  final Function(int)? onSheetPopUp;
  final Function(int)? onSheetPop;
  final ZegoInnerText translationText;

  const ZegoInRoomMessageButton({
    Key? key,
    required this.hostManager,
    required this.translationText,
    this.enabledIcon,
    this.disabledIcon,
    this.iconSize,
    this.buttonSize,
    this.onSheetPopUp,
    this.onSheetPop,
  }) : super(key: key);

  @override
  State<ZegoInRoomMessageButton> createState() =>
      _ZegoInRoomMessageButtonState();
}

/// @nodoc
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

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: chatEnableNotifier,
      builder: (context, isChatEnabled, _) {
        var chatLocalEnabled = true;
        if (!widget.hostManager.isLocalHost) {
          chatLocalEnabled = isChatEnabled;
        }

        final buttonIcon =
            chatLocalEnabled ? widget.enabledIcon : widget.disabledIcon;
        buttonIcon?.icon ??= chatLocalEnabled
            ? PrebuiltLiveStreamingImage.asset(
                PrebuiltLiveStreamingIconUrls.im,
              )
            : PrebuiltLiveStreamingImage.asset(
                PrebuiltLiveStreamingIconUrls.imDisabled,
              );

        return ZegoTextIconButton(
          onPressed: chatLocalEnabled
              ? () {
                  final key = DateTime.now().millisecondsSinceEpoch;
                  widget.onSheetPopUp?.call(key);

                  isMessageInputting = true;
                  Navigator.of(
                    context,
                    rootNavigator: widget.hostManager.config.rootNavigator,
                  )
                      .push(ZegoInRoomMessageInputBoard(
                    translationText: widget.translationText,
                    rootNavigator: widget.hostManager.config.rootNavigator,
                  ))
                      .then((value) {
                    isMessageInputting = false;
                    widget.onSheetPop?.call(key);
                  });
                }
              : null,
          icon: buttonIcon,
          iconSize: widget.iconSize ?? Size(72.zR, 72.zR),
          buttonSize: widget.buttonSize ?? Size(96.zR, 96.zR),
        );
      },
    );
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    if (!updatedProperties.containsKey(disableChatRoomPropertyKey)) {
      return;
    }

    ZegoLoggerService.logInfo(
      'chat enabled property changed to '
      '${updatedProperties[disableChatRoomPropertyKey]!.value}',
      tag: 'live streaming',
      subTag: 'message button',
    );
    chatEnableNotifier.value =
        toBoolean(updatedProperties[disableChatRoomPropertyKey]!.value);
    if (!chatEnableNotifier.value && isMessageInputting) {
      ZegoLoggerService.logInfo(
        'message inputting, close it',
        tag: 'live streaming',
        subTag: 'message button',
      );
      Navigator.of(
        context,
        rootNavigator: widget.hostManager.config.rootNavigator,
      ).pop();
    }
  }

  bool toBoolean(String str) {
    return str != '0' && str != 'false' && str != '';
  }
}
