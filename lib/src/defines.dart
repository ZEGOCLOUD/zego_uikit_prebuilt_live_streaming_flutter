// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// Live streaming roles.
enum ZegoLiveStreamingRole {
  /// Host
  host,

  /// Co-host, will become an audience after cancelling co-hosting.
  coHost,

  /// Audience, can become a co-host through co-hosting.
  audience,
}

/// Live streaming state
///
/// - When the live streaming is in preview mode, the [ZegoLiveStreamingState] is [idle].
/// - When the live streaming is ongoing, the [ZegoLiveStreamingState] becomes [living].
/// - When the live streaming is in PK mode, the [ZegoLiveStreamingState] becomes [inPKBattle].
/// - When the live streaming is ended, the [ZegoLiveStreamingState] becomes [ended], and after the [ended] state, the [ZegoLiveStreamingState] immediately becomes [idle] (ended means the live streaming has [ended], [idle] means either not started or already ended).
///
///```
///           ┌─→ PK ───┐
///           │         ↓
/// idle ─> living ─> ended ⌍
///  ↑                  │
///  └──────────────────┘
/// ```
enum ZegoLiveStreamingState {
  /// Idle state, live streaming not started or ended
  idle,

  /// Live streaming in progress
  living,

  /// In PK battle
  inPKBattle,

  /// Live streaming ended
  ended,
}

/// This enum type is used in [ZegoUIKitPrebuiltLiveStreamingConfig.bottomMenuBarConfig].
///
/// Please note that these buttons are not role-specific and can be added to anyone's toolbar.
/// The Live Streaming SDK simply defaults to defining which buttons can be displayed on the corresponding role's toolbar.
///
/// For example, if you don't want co-hosts to control their own microphone, you can exclude the toggleMicrophoneButton from [ZegoBottomMenuBarConfig.coHostButtons].
enum ZegoMenuBarButtonName {
  /// Button for controlling the camera switch.
  toggleCameraButton,

  /// Button for controlling the microphone switch.
  toggleMicrophoneButton,

  /// Button for switching between front and rear cameras.
  switchCameraButton,

  ///
  switchAudioOutputButton,

  ///
  leaveButton,

  ///
  coHostControlButton,

  /// Button for controlling the display or hiding of the beauty effect adjustment panel.
  ///
  /// Typically, only the host and co-hosts will be open the camera, so this button is usually displayed on their toolbars.
  beautyEffectButton,

  /// Button for controlling the display or hiding of the sound effect adjustment panel.
  ///
  /// Typically, only the host and co-hosts will be speaking, so this button is usually displayed on their toolbars.
  soundEffectButton,

  /// Button to disable/enable chat in the live streaming.
  ///
  /// This will apply to everyone in the room except the host.
  enableChatButton,

  /// Button for toggling screen sharing.
  toggleScreenSharingButton,

  /// Button to open/hide the chat UI.
  chatButton,

  /// Button for minimizing the current [ZegoUIKitPrebuiltLiveStreaming] widget within the app.
  ///
  /// When clicked, the [ZegoUIKitPrebuiltLiveStreaming] widget will shrink into a small draggable widget within the app.
  ///
  /// If you need to nest some widgets in [ZegoUIKitPrebuiltLiveStreaming], please use [foreground] nesting,
  /// otherwise these widgets will be lost when you minimize and restore the [ZegoUIKitPrebuiltLiveStreaming]
  minimizingButton,

  /// Used in toolbar layout, similar to the [Expanded] widget in Flutter.
  ///
  /// It is used to expand the spacing between buttons.
  /// Please note that if you are using [index] with [ZegoMenuBarExtendButton], this [expanding] also occupies a position.
  expanding,
}

/// Dialog information.
/// Used to control whether certain features display a dialog, such as whether to show a confirmation dialog when request camera permission.
///
/// This class is used for setting some text in ZegoInnerText.
class ZegoDialogInfo {
  /// Dialog title
  final String title;

  /// Dialog text content
  final String message;

  /// Text content on the cancel button. Default value is 'Cancel'.
  String cancelButtonName;

  /// Text content on the confirm button. Default value is 'OK'.
  String confirmButtonName;

  ZegoDialogInfo({
    required this.title,
    required this.message,
    this.cancelButtonName = 'Cancel',
    this.confirmButtonName = 'OK',
  });
}

/// only for audience or co-host, connection state
enum ZegoLiveStreamingAudienceConnectState {
  ///
  idle,

  /// requesting to be a co-host, wait response from host
  connecting,

  /// be a co-host now, host agree the co-host request
  connected,
}

/// A callback function for customizing the start live button
/// It should return a Widget that represents the custom start live button.
typedef ZegoStartLiveButtonBuilder = Widget Function(
  BuildContext context,

  /// **must be called** to transition from the preview page to the live page
  VoidCallback startLive,
);

/// This function should return a Widget that is used to customize the UI displayed when the host reconnects in a PK battle.
///
/// You can use this callback to customize the UI content to be displayed.
///
/// - [context] is the BuildContext object.
/// - [host] is an optional parameter that represents the information of the current host. If there is no host currently, it will be null.
/// - [extraInfo] is a Map object that contains custom information for the PK battle.
/// - Return a Widget object that represents the custom component for the PK Battle View.
typedef ZegoLiveStreamingPKBattleHostReconnectingBuilder = Widget Function(
  BuildContext context,
  ZegoUIKitUser? host,
  Map<String, dynamic> extraInfo,
);

/// This typedef defines a callback function for building custom components for the PK Battle view.
///
/// - [context] is a BuildContext object.
/// - [hosts] is a list of ZegoUIKitUser objects representing all the hosts in the PK Battle. Each ZegoUIKitUser object represents a host in the PK Battle.
/// - [extraInfo] is a Map object containing custom information for the PK Battle.
/// - Return a Widget object representing the custom component for the PK Battle view.
typedef ZegoLiveStreamingPKBattleViewBuilder = Widget Function(
  BuildContext context,
  List<ZegoUIKitUser?> hosts,
  Map<String, dynamic> extraInfo,
);
