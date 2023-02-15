// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_translation.dart';

class ZegoCoHostControlButton extends StatefulWidget {
  const ZegoCoHostControlButton({
    Key? key,
    required this.hostManager,
    required this.connectManager,
    required this.translationText,
  }) : super(key: key);
  final ZegoLiveHostManager hostManager;
  final ZegoLiveConnectManager connectManager;
  final ZegoTranslationText translationText;

  @override
  State<ZegoCoHostControlButton> createState() =>
      _ZegoCoHostControlButtonState();
}

class _ZegoCoHostControlButtonState extends State<ZegoCoHostControlButton> {
  bool get hostExist =>
      widget.hostManager.notifier.value?.id.isNotEmpty ?? false;

  bool get isLiving =>
      widget.connectManager.liveStatusNotifier.value == LiveStatus.living;

  ButtonIcon get buttonIcon => ButtonIcon(
        icon: PrebuiltLiveStreamingImage.asset(
            PrebuiltLiveStreamingIconUrls.toolbarCoHost),
        backgroundColor: Colors.transparent,
      );

  TextStyle get buttonTextStyle => TextStyle(
        color: Colors.white,
        fontSize: 26.r,
        fontWeight: FontWeight.w500,
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConnectState>(
      valueListenable: widget.connectManager.audienceLocalConnectStateNotifier,
      builder: (context, connectState, _) {
        switch (connectState) {
          case ConnectState.idle:
            return requestCoHostButton();
          case ConnectState.connecting:
            return cancelRequestCoHostButton();
          case ConnectState.connected:
            return endCoHostButton();
        }
      },
    );
  }

  Widget requestCoHostButton() {
    return ZegoStartInvitationButton(
      invitationType: ZegoInvitationType.requestCoHost.value,
      invitees: [widget.hostManager.notifier.value?.id ?? ''],
      data: '',
      icon: buttonIcon,
      buttonSize: Size(330.r, 72.r),
      iconSize: Size(48.r, 48.r),
      iconTextSpacing: 12.r,
      text: widget.translationText.requestCoHostButton,
      textStyle: buttonTextStyle,
      verticalLayout: false,
      onWillPressed: () {
        return checkHostExist() && checkLiving();
      },
      onPressed: (
        String code,
        String message,
        String invitationID,
        List<String> errorInvitees,
      ) {
        if (code.isNotEmpty) {
          showError('${widget.translationText.requestCoHostFailedToast}, '
              '$code $message');
        } else {
          showSuccess(widget.translationText.sendRequestCoHostToast);
        }

        widget.connectManager
            .updateAudienceConnectState(ConnectState.connecting);
        //
      },
      clickableTextColor: Colors.white,
      clickableBackgroundColor: const Color(0xff1E2740).withOpacity(0.4),
    );
  }

  Widget cancelRequestCoHostButton() {
    return ZegoCancelInvitationButton(
      invitees: [widget.hostManager.notifier.value?.id ?? ''],
      icon: buttonIcon,
      buttonSize: Size(330.r, 72.r),
      iconSize: Size(48.r, 48.r),
      iconTextSpacing: 12.r,
      text: widget.translationText.cancelRequestCoHostButton,
      textStyle: buttonTextStyle,
      verticalLayout: false,
      onPressed: (String code, String message, List<String> errorInvitees) {
        widget.connectManager.updateAudienceConnectState(ConnectState.idle);
        //
      },
      clickableTextColor: Colors.white,
      clickableBackgroundColor: const Color(0xff1E2740).withOpacity(0.4),
    );
  }

  Widget endCoHostButton() {
    return ZegoTextIconButton(
      icon: buttonIcon,
      buttonRadius: 72.r / 2,
      buttonSize: Size(168.r, 72.r),
      iconSize: Size(48.r, 48.r),
      iconTextSpacing: 12.r,
      text: widget.translationText.endCoHostButton,
      textStyle: buttonTextStyle,
      verticalLayout: false,
      onPressed: widget.connectManager.coHostRequestToEnd,
      clickableTextColor: Colors.white,
      clickableBackgroundColor: const Color(0xffFF0D23).withOpacity(0.6),
    );
  }

  bool checkHostExist({bool withToast = true}) {
    if (!hostExist) {
      if (withToast) {
        showError(widget.translationText.requestCoHostFailedToast);
      }
      return false;
    }

    return true;
  }

  bool checkLiving({bool withToast = true}) {
    if (!isLiving) {
      if (withToast) {
        showError(widget.translationText.requestCoHostFailedToast);
      }
      return false;
    }

    return true;
  }
}
