// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/enable_property.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/input_board.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

/// @nodoc
class ZegoInRoomMessageInputBoardButton extends StatefulWidget {
  final ZegoLiveHostManager hostManager;
  final ButtonIcon? enabledIcon;
  final ButtonIcon? disabledIcon;
  final Size? iconSize;
  final Size? buttonSize;
  final Function(int)? onSheetPopUp;
  final Function(int)? onSheetPop;
  final ZegoInnerText translationText;

  const ZegoInRoomMessageInputBoardButton({
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
  State<ZegoInRoomMessageInputBoardButton> createState() =>
      _ZegoInRoomMessageInputBoardButtonState();
}

/// @nodoc
class _ZegoInRoomMessageInputBoardButtonState
    extends State<ZegoInRoomMessageInputBoardButton> {
  var isMessageInputting = false;
  final _enableProperty = ZegoInRoomMessageEnableProperty();

  @override
  void initState() {
    super.initState();

    _enableProperty.notifier.addListener(onEnablePropertyUpdated);
  }

  @override
  void dispose() {
    super.dispose();

    _enableProperty.notifier.removeListener(onEnablePropertyUpdated);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _enableProperty.notifier,
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
                      .push(
                    ZegoInRoomMessageInputBoard(
                      translationText: widget.translationText,
                      payloadAttributes: widget
                          .hostManager.config.inRoomMessageConfig.attributes
                          ?.call(),
                      rootNavigator: widget.hostManager.config.rootNavigator,
                    ),
                  )
                      .then(
                    (value) {
                      isMessageInputting = false;
                      widget.onSheetPop?.call(key);
                    },
                  );
                }
              : null,
          icon: buttonIcon,
          iconSize: widget.iconSize ?? Size(72.zR, 72.zR),
          buttonSize: widget.buttonSize ?? Size(96.zR, 96.zR),
        );
      },
    );
  }

  void onEnablePropertyUpdated() {
    if (!_enableProperty.value && isMessageInputting) {
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
}
