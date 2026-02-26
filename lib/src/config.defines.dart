// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';

/// A callback function for customizing the member button in the top bar.
///
/// - [count] is the number of members in the live streaming room.
/// - [liveID] is the ID of the current live streaming room.
///
/// Returns a [Widget] that represents the custom member button.
typedef ZegoLiveStreamingMemberButtonBuilder = Widget Function(
  int count,
  String liveID,
);

/// A callback function to determine whether to play the audio of a specific co-host.
///
/// - [localUser] is the current local user.
/// - [localRole] is the role of the local user in the live streaming.
/// - [coHost] is the co-host user whose audio playback is being determined.
///
/// Returns true to play the co-host's audio, false to mute.
typedef ZegoPlayCoHostAudioVideoCallback = bool Function(
  ZegoUIKitUser localUser,
  ZegoLiveStreamingRole localRole,
  ZegoUIKitUser coHost,
);

/// A callback function for building a custom audio/video container.
///
/// - [context] is the [BuildContext] of the widget.
/// - [allUsers] is the list of all users in the live streaming room.
/// - [audioVideoUsers] is the list of users who have audio/video streams.
/// - [audioVideoViewCreator] is the default audio-video view creator.
///
/// Returns a custom [Widget] for the audio/video container, or null to use the default.
typedef ZegoLiveStreamingAudioVideoContainerBuilder = Widget? Function(
  BuildContext context,
  List<ZegoUIKitUser> allUsers,
  List<ZegoUIKitUser> audioVideoUsers,

  /// The default audio-video view creator, you can also use [ZegoAudioVideoView] as a child control to continue encapsulating
  ZegoAudioVideoView Function(ZegoUIKitUser) audioVideoViewCreator,
);

/// Extension buttons for the bottom toolbar.
///
/// If the built-in buttons do not meet your requirements, you can define your own button to implement custom functionality.
///
/// For example:
///
/// In this example, an IconButton with a "+" icon is defined as an extension button.
/// Its index is set to 2, indicating that it will be inserted after the built-in buttons and previous extension buttons in the bottom toolbar.
/// When the button is clicked, the callback function will be triggered.
///
///```dart
/// hostExtendButtons = [
///   ZegoMenuBarExtendButton(
///    index: 2,
///    child: IconButton(
///      icon: Icon(Icons.add),
///      onPressed: () {
///        // Callback when the extension button is clicked
///      },
///    ),
///  ),
/// ]
/// ```
class ZegoLiveStreamingMenuBarExtendButton extends StatelessWidget {
  /// Index of buttons within the entire bottom toolbar, including both built-in buttons and extension buttons.
  ///
  /// For example, if it's for the host, the index refers to the array index of [hostButtons] + [hostExtendButtons].
  ///
  /// If this index is set, the corresponding button will be placed at the specified position in the array of buttons for the corresponding role.
  ///
  /// If this index is not set, the button will be placed after the built-in buttons.
  ///
  /// The index starts from 0, and -1 indicates that the button will be placed after the built-in buttons by default.
  ///
  /// Definition of built-in buttons: an array of type List<[ZegoLiveStreamingMenuBarButtonName]>.
  ///
  /// Definition of extension buttons: an array of type List<[ZegoLiveStreamingMenuBarExtendButton]>.
  final int index;

  /// button widget
  final Widget child;

  const ZegoLiveStreamingMenuBarExtendButton({
    super.key,
    required this.child,
    this.index = -1,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '{'
        'index:$index, '
        'child:$child, '
        '}';
  }
}

/// Button style for the bottom toolbar, allowing customization of button icons or text.
///
/// You can use the [ZegoUIKitPrebuiltLiveStreamingConfig.bottomMenuBarConfig] -> [ZegoLiveStreamingBottomMenuBarConfig.buttonStyle] property to set the properties inside this class.
///
/// Example:
/// ```dart
/// ZegoBottomMenuBarButtonStyle(
///   // Customize the enabled chat button icon
///   chatEnabledButtonIcon: const Icon(Icons.chat),
///   // Customize the disabled chat button icon
///   chatDisabledButtonIcon: const Icon(Icons.chat_disabled),
///   // Customize other button icons...
/// );
/// ```
class ZegoLiveStreamingBottomMenuBarButtonStyle {
  /// Icon for enabling chat.
  Widget? chatEnabledButtonIcon;

  /// Icon for disabling chat.
  Widget? chatDisabledButtonIcon;

  /// Icon for toggling microphone on.
  Widget? toggleMicrophoneOnButtonIcon;

  /// Icon for toggling microphone off.
  Widget? toggleMicrophoneOffButtonIcon;

  /// Icon for toggling camera on.
  Widget? toggleCameraOnButtonIcon;

  /// Icon for toggling camera off.
  Widget? toggleCameraOffButtonIcon;

  /// Icon for switching camera.
  Widget? switchCameraButtonIcon;

  /// Icon for switching audio output to speaker.
  Widget? switchAudioOutputToSpeakerButtonIcon;

  /// Icon for switching audio output to headphone.
  Widget? switchAudioOutputToHeadphoneButtonIcon;

  /// Icon for switching audio output to Bluetooth.
  Widget? switchAudioOutputToBluetoothButtonIcon;

  /// Icon for leaving the room.
  Widget? leaveButtonIcon;

  /// Icon for requesting co-host status.
  Widget? requestCoHostButtonIcon;

  /// Text for requesting co-host status button.
  String? requestCoHostButtonText;

  /// Icon for canceling co-host request.
  Widget? cancelRequestCoHostButtonIcon;

  /// Text for canceling co-host request button.
  String? cancelRequestCoHostButtonText;

  /// Icon for ending co-host status.
  Widget? endCoHostButtonIcon;

  /// Text for ending co-host status button.
  String? endCoHostButtonText;

  /// Icon for beauty effect.
  Widget? beautyEffectButtonIcon;

  /// Icon for sound effect.
  Widget? soundEffectButtonIcon;

  /// Icon for enabling chat.
  Widget? enableChatButtonIcon;

  /// Icon for disabling chat.
  Widget? disableChatButtonIcon;

  /// Icon for toggling screen sharing on.
  Widget? toggleScreenSharingOnButtonIcon;

  /// Icon for toggling screen sharing off.
  Widget? toggleScreenSharingOffButtonIcon;

  ZegoLiveStreamingBottomMenuBarButtonStyle({
    this.chatEnabledButtonIcon,
    this.chatDisabledButtonIcon,
    this.toggleMicrophoneOnButtonIcon,
    this.toggleMicrophoneOffButtonIcon,
    this.toggleCameraOnButtonIcon,
    this.toggleCameraOffButtonIcon,
    this.switchCameraButtonIcon,
    this.switchAudioOutputToSpeakerButtonIcon,
    this.switchAudioOutputToHeadphoneButtonIcon,
    this.switchAudioOutputToBluetoothButtonIcon,
    this.leaveButtonIcon,
    this.requestCoHostButtonIcon,
    this.requestCoHostButtonText,
    this.cancelRequestCoHostButtonIcon,
    this.cancelRequestCoHostButtonText,
    this.endCoHostButtonIcon,
    this.endCoHostButtonText,
    this.beautyEffectButtonIcon,
    this.soundEffectButtonIcon,
    this.enableChatButtonIcon,
    this.disableChatButtonIcon,
    this.toggleScreenSharingOnButtonIcon,
    this.toggleScreenSharingOffButtonIcon,
  });

  @override
  String toString() {
    return '{'
        'chatEnabledButtonIcon:${chatEnabledButtonIcon != null}, '
        'chatDisabledButtonIcon:${chatDisabledButtonIcon != null}, '
        'toggleMicrophoneOnButtonIcon:${toggleMicrophoneOnButtonIcon != null}, '
        'toggleMicrophoneOffButtonIcon:${toggleMicrophoneOffButtonIcon != null}, '
        'toggleCameraOnButtonIcon:${toggleCameraOnButtonIcon != null}, '
        'toggleCameraOffButtonIcon:${toggleCameraOffButtonIcon != null}, '
        'switchCameraButtonIcon:${switchCameraButtonIcon != null}, '
        'switchAudioOutputToSpeakerButtonIcon:${switchAudioOutputToSpeakerButtonIcon != null}, '
        'switchAudioOutputToHeadphoneButtonIcon:${switchAudioOutputToHeadphoneButtonIcon != null}, '
        'switchAudioOutputToBluetoothButtonIcon:${switchAudioOutputToBluetoothButtonIcon != null}, '
        'leaveButtonIcon:${leaveButtonIcon != null}, '
        'requestCoHostButtonIcon:${requestCoHostButtonIcon != null}, '
        'requestCoHostButtonText:$requestCoHostButtonText, '
        'cancelRequestCoHostButtonIcon:${cancelRequestCoHostButtonIcon != null}, '
        'cancelRequestCoHostButtonText:$cancelRequestCoHostButtonText, '
        'endCoHostButtonIcon:${endCoHostButtonIcon != null}, '
        'endCoHostButtonText:$endCoHostButtonText, '
        'beautyEffectButtonIcon:${beautyEffectButtonIcon != null}, '
        'soundEffectButtonIcon:${soundEffectButtonIcon != null}, '
        'enableChatButtonIcon:${enableChatButtonIcon != null}, '
        'disableChatButtonIcon:${disableChatButtonIcon != null}, '
        'toggleScreenSharingOnButtonIcon:${toggleScreenSharingOnButtonIcon != null}, '
        'toggleScreenSharingOffButtonIcon:${toggleScreenSharingOffButtonIcon != null}, '
        '}';
  }
}

class ZegoLiveStreamingCoHostConfig {
  static const defaultMaxCoHostCount = 12;

  /// whether to enable the camera by default when you be co-host, the default value is true
  /// Every time you become a co-host again, it will re-read this configuration to check if enable the camera
  bool Function()? turnOnCameraWhenCohosted;

  /// controls whether to automatically stop co-hosting when both the camera and microphone are turned off, the default value is false.
  ///
  /// If the value is set to true, the user will stop co-hosting automatically when both camera and microphone are off.
  /// If the value is set to false, the user will keep co-hosting until manually stop co-hosting by clicking the "End" button.
  bool stopCoHostingWhenMicCameraOff;

  /// used to determine whether to display a confirmation dialog to the
  /// audience when they receive a co-host invitation, the default value is false
  ///
  /// If the value is True, the confirmation dialog will not be displayed.
  /// If the value is False, the confirmation dialog will be displayed.
  ///
  /// You can adjust and set this variable according to your specific requirements.
  bool disableCoHostInvitationReceivedDialog;

  /// Maximum number of co-hosts.
  ///
  /// If exceeded, other audience members cannot become co-hosts.
  /// The default value is 12.
  int maxCoHostCount;

  /// timeout second when invite other to co-host
  int inviteTimeoutSecond;

  ZegoLiveStreamingCoHostConfig({
    this.maxCoHostCount = defaultMaxCoHostCount,
    this.turnOnCameraWhenCohosted,
    this.inviteTimeoutSecond = 60,
    this.stopCoHostingWhenMicCameraOff = false,
    this.disableCoHostInvitationReceivedDialog = false,
  });

  @override
  String toString() {
    return '{'
        'turnOnCameraWhenCohosted:${turnOnCameraWhenCohosted != null}, '
        'stopCoHostingWhenMicCameraOff:$stopCoHostingWhenMicCameraOff, '
        'disableCoHostInvitationReceivedDialog:$disableCoHostInvitationReceivedDialog, '
        'maxCoHostCount:$maxCoHostCount, '
        'inviteTimeoutSecond:$inviteTimeoutSecond, '
        '}';
  }
}
