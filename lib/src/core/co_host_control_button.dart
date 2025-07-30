// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/reporter.dart';

/// @nodoc
class ZegoLiveStreamingCoHostControlButton extends StatefulWidget {
  const ZegoLiveStreamingCoHostControlButton({
    Key? key,
    required this.hostManager,
    required this.connectManager,
    required this.translationText,
    this.requestCoHostButtonIcon,
    this.cancelRequestCoHostButtonIcon,
    this.endCoHostButtonIcon,
    this.requestCoHostButtonText,
    this.cancelRequestCoHostButtonText,
    this.endCoHostButtonText,
  }) : super(key: key);

  final ZegoLiveStreamingHostManager hostManager;
  final ZegoLiveStreamingConnectManager connectManager;
  final ZegoUIKitPrebuiltLiveStreamingInnerText translationText;

  final ButtonIcon? requestCoHostButtonIcon;
  final ButtonIcon? cancelRequestCoHostButtonIcon;
  final ButtonIcon? endCoHostButtonIcon;
  final String? requestCoHostButtonText;
  final String? cancelRequestCoHostButtonText;
  final String? endCoHostButtonText;

  @override
  State<ZegoLiveStreamingCoHostControlButton> createState() =>
      _ZegoLiveStreamingCoHostControlButtonState();
}

/// @nodoc
class _ZegoLiveStreamingCoHostControlButtonState
    extends State<ZegoLiveStreamingCoHostControlButton> {
  bool get hostExist =>
      widget.hostManager.notifier.value?.id.isNotEmpty ?? false;

  bool get isLiving =>
      widget.connectManager.liveStatusNotifier.value == LiveStatus.living;

  ButtonIcon get buttonIcon => ButtonIcon(
        icon: ZegoLiveStreamingImage.asset(
            ZegoLiveStreamingIconUrls.toolbarCoHost),
        backgroundColor: Colors.transparent,
      );

  TextStyle get buttonTextStyle => TextStyle(
        color: Colors.white,
        fontSize: 26.zR,
        fontWeight: FontWeight.w500,
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state,
      builder: (context, isInPK, _) {
        if (isInPK) {
          return const SizedBox.shrink();
        } else {
          return ValueListenableBuilder<ZegoLiveStreamingAudienceConnectState>(
            valueListenable:
                widget.connectManager.audienceLocalConnectStateNotifier,
            builder: (context, connectState, _) {
              switch (connectState) {
                case ZegoLiveStreamingAudienceConnectState.idle:
                  return requestCoHostButton();
                case ZegoLiveStreamingAudienceConnectState.connecting:
                  return cancelRequestCoHostButton();
                case ZegoLiveStreamingAudienceConnectState.connected:
                  return endCoHostButton();
              }
            },
          );
        }
      },
    );
  }

  Widget requestCoHostButton() {
    return ZegoStartInvitationButton(
      invitationType: ZegoLiveStreamingInvitationType.requestCoHost.value,
      invitees: [widget.hostManager.notifier.value?.id ?? ''],
      data: '',
      icon: null != widget.requestCoHostButtonIcon?.icon
          ? widget.requestCoHostButtonIcon
          : buttonIcon,
      buttonSize: Size(330.zR, 72.zR),
      iconSize: Size(48.zR, 48.zR),
      iconTextSpacing: 12.zR,
      text: widget.requestCoHostButtonText ??
          widget.translationText.requestCoHostButton,
      textStyle: buttonTextStyle,
      verticalLayout: false,
      onWillPressed: () async {
        return checkHostExist() && checkLiving();
      },
      onPressed: (ZegoStartInvitationButtonResult result) {
        if (result.code.isNotEmpty) {
          showError('${widget.translationText.requestCoHostFailedToast}, '
              '${result.code} ${result.message}');
        } else {
          showSuccess(widget.translationText.sendRequestCoHostToast);

          ZegoLiveStreamingReporter().report(
            event: ZegoLiveStreamingReporter.eventCoHostAudienceInvite,
            params: {
              ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
              ZegoLiveStreamingReporter.eventKeyRoomID:
                  ZegoUIKit().getRoom().id,
            },
          );

          widget.connectManager.events.coHost.audience.onRequestSent?.call();

          widget.connectManager.updateAudienceConnectState(
            ZegoLiveStreamingAudienceConnectState.connecting,
          );
        }
      },
      clickableTextColor: Colors.white,
      clickableBackgroundColor: const Color(0xff1E2740).withValues(alpha: 0.4),
    );
  }

  Widget cancelRequestCoHostButton() {
    return ZegoCancelInvitationButton(
      invitees: [widget.hostManager.notifier.value?.id ?? ''],
      icon: null != widget.cancelRequestCoHostButtonIcon?.icon
          ? widget.cancelRequestCoHostButtonIcon
          : buttonIcon,
      buttonSize: Size(330.zR, 72.zR),
      iconSize: Size(48.zR, 48.zR),
      iconTextSpacing: 12.zR,
      text: widget.cancelRequestCoHostButtonText ??
          widget.translationText.cancelRequestCoHostButton,
      textStyle: buttonTextStyle,
      verticalLayout: false,
      onPressed: (ZegoCancelInvitationButtonResult result) {
        ZegoLiveStreamingReporter().report(
          event: ZegoLiveStreamingReporter.eventCoHostAudienceRespond,
          params: {
            ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
            ZegoLiveStreamingReporter.eventKeyAction:
                ZegoLiveStreamingReporter.eventKeyActionCancel,
          },
        );

        widget.connectManager.events.coHost.audience.onActionCancelRequest
            ?.call();

        widget.connectManager.updateAudienceConnectState(
          ZegoLiveStreamingAudienceConnectState.idle,
        );
      },
      clickableTextColor: Colors.white,
      clickableBackgroundColor: const Color(0xff1E2740).withValues(alpha: 0.4),
    );
  }

  Widget endCoHostButton() {
    return ZegoTextIconButton(
      icon: null != widget.endCoHostButtonIcon?.icon
          ? widget.endCoHostButtonIcon
          : buttonIcon,
      borderRadius: 72.zR / 2,
      buttonSize: Size(168.zR, 72.zR),
      iconSize: Size(48.zR, 48.zR),
      iconTextSpacing: 12.zR,
      text:
          widget.endCoHostButtonText ?? widget.translationText.endCoHostButton,
      textStyle: buttonTextStyle,
      verticalLayout: false,
      onPressed: widget.connectManager.coHostRequestToEnd,
      clickableTextColor: Colors.white,
      clickableBackgroundColor: const Color(0xffFF0D23).withValues(alpha: 0.6),
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
