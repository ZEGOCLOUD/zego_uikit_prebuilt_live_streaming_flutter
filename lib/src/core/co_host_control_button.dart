// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/core.dart';

/// @nodoc
class ZegoLiveStreamingCoHostControlButton extends StatefulWidget {
  const ZegoLiveStreamingCoHostControlButton({
    super.key,
    required this.liveID,
    required this.translationText,
    this.requestCoHostButtonIcon,
    this.cancelRequestCoHostButtonIcon,
    this.endCoHostButtonIcon,
    this.requestCoHostButtonText,
    this.cancelRequestCoHostButtonText,
    this.endCoHostButtonText,
  });

  final String liveID;

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
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .hostManager
          .notifier
          .value
          ?.id
          .isNotEmpty ??
      false;

  bool get isLiving =>
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .liveStatusManager
          .notifier
          .value ==
      LiveStatus.living;

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
          ZegoUIKitPrebuiltLiveStreamingPK.instance.combineNotifier.state,
      builder: (context, _isInPK, _) {
        final isInPK =
            ZegoUIKitPrebuiltLiveStreamingPK.instance.liveID == widget.liveID &&
                _isInPK;
        if (isInPK) {
          return const SizedBox.shrink();
        } else {
          return ValueListenableBuilder<ZegoLiveStreamingAudienceConnectState>(
            valueListenable: ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .connectManager
                .audienceLocalConnectStateNotifier,
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
      invitees: [
        ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .hostManager
                .notifier
                .value
                ?.id ??
            ''
      ],
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
              ZegoLiveStreamingReporter.eventKeyRoomID: widget.liveID,
            },
          );

          ZegoLiveStreamingPageLifeCycle()
              .currentManagers
              .connectManager
              .events
              ?.coHost
              .audience
              .onRequestSent
              ?.call();

          ZegoLiveStreamingPageLifeCycle()
              .currentManagers
              .connectManager
              .updateAudienceConnectState(
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
      invitees: [
        ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .hostManager
                .notifier
                .value
                ?.id ??
            ''
      ],
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

        ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .connectManager
            .events
            ?.coHost
            .audience
            .onActionCancelRequest
            ?.call();

        ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .connectManager
            .updateAudienceConnectState(
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
      onPressed: ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .connectManager
          .coHostRequestToEnd,
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
