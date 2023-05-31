// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/defines.dart';

/// Configuration for initializing the Live Streaming
/// This class is used as the [config] parameter for the constructor of [ZegoUIKitPrebuiltLiveStreaming].
class ZegoUIKitPrebuiltLiveStreamingConfig {
  /// Default initialization parameters for the host.
  /// If a configuration item does not meet your expectations, you can directly override its value.
  ///
  /// Example:
  ///
  /// ```dart
  /// ZegoUIKitPrebuiltLiveStreamingConfig.host()
  /// ..turnOnMicrophoneWhenJoining = false
  /// ```
  ZegoUIKitPrebuiltLiveStreamingConfig.host({List<IZegoUIKitPlugin>? plugins})
      : role = ZegoLiveStreamingRole.host,
        plugins = plugins ?? [],
        turnOnCameraWhenJoining = true,
        turnOnMicrophoneWhenJoining = true,
        useSpeakerWhenJoining = true,
        turnOnCameraWhenCohosted = true,
        markAsLargeRoom = false,
        rootNavigator = false,
        videoConfig = ZegoPrebuiltVideoConfig(),
        maxCoHostCount = 12,
        audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
          showSoundWavesInAudioMode: true,
        ),
        topMenuBarConfig = ZegoTopMenuBarConfig(),
        bottomMenuBarConfig = ZegoBottomMenuBarConfig(
          audienceButtons: plugins?.isEmpty ?? true
              ? []
              //  host maybe change to be an audience
              : const [ZegoMenuBarButtonName.coHostControlButton],
        ),
        memberListConfig = ZegoMemberListConfig(),
        inRoomMessageViewConfig = ZegoInRoomMessageViewConfig(),
        effectConfig = ZegoEffectConfig(),
        innerText = ZegoInnerText(),
        confirmDialogInfo = ZegoDialogInfo(
          title: 'Stop the live',
          message: 'Are you sure to stop the live?',
          cancelButtonName: 'Cancel',
          confirmButtonName: 'Stop it',
        ),
        previewConfig = ZegoLiveStreamingPreviewConfig(),
        pkBattleConfig = ZegoLiveStreamingPKBattleConfig(),
        pkBattleEvents = ZegoLiveStreamingPKBattleEvents(),
        durationConfig = ZegoLiveDurationConfig();

  /// Default initialization parameters for the audience.
  /// If a configuration item does not meet your expectations, you can directly override its value.
  ///
  /// Example:
  ///
  /// ```dart
  /// ZegoUIKitPrebuiltLiveStreamingConfig.audience()
  /// ..turnOnMicrophoneWhenJoining = false
  /// ```
  ZegoUIKitPrebuiltLiveStreamingConfig.audience(
      {List<IZegoUIKitPlugin>? plugins})
      : role = ZegoLiveStreamingRole.audience,
        plugins = plugins ?? [],
        turnOnCameraWhenJoining = false,
        turnOnMicrophoneWhenJoining = false,
        useSpeakerWhenJoining = true,
        turnOnCameraWhenCohosted = true,
        markAsLargeRoom = false,
        rootNavigator = false,
        videoConfig = ZegoPrebuiltVideoConfig(),
        maxCoHostCount = 12,
        audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
          showSoundWavesInAudioMode: true,
        ),
        topMenuBarConfig = ZegoTopMenuBarConfig(),
        bottomMenuBarConfig = ZegoBottomMenuBarConfig(
          audienceButtons: plugins?.isEmpty ?? true
              ? []
              : const [ZegoMenuBarButtonName.coHostControlButton],
        ),
        memberListConfig = ZegoMemberListConfig(),
        inRoomMessageViewConfig = ZegoInRoomMessageViewConfig(),
        effectConfig = ZegoEffectConfig(),
        innerText = ZegoInnerText(),
        previewConfig = ZegoLiveStreamingPreviewConfig(),
        pkBattleConfig = ZegoLiveStreamingPKBattleConfig(),
        pkBattleEvents = ZegoLiveStreamingPKBattleEvents(),
        durationConfig = ZegoLiveDurationConfig();

  ZegoUIKitPrebuiltLiveStreamingConfig({
    this.turnOnCameraWhenJoining = true,
    this.turnOnMicrophoneWhenJoining = true,
    this.useSpeakerWhenJoining = true,
    this.turnOnCameraWhenCohosted = true,
    this.markAsLargeRoom = false,
    this.rootNavigator = false,
    this.maxCoHostCount = 12,
    this.layout,
    this.foreground,
    this.background,
    this.confirmDialogInfo,
    this.beautyConfig,
    this.avatarBuilder,
    this.startLiveButtonBuilder,
    this.onMaxCoHostReached,
    this.onLeaveConfirmation,
    this.onLeaveLiveStreaming,
    this.onLiveStreamingEnded,
    this.onCameraTurnOnByOthersConfirmation,
    this.onMicrophoneTurnOnByOthersConfirmation,
    ZegoInnerText? translationText,
    ZegoEffectConfig? effectConfig,
    ZegoMemberListConfig? memberListConfig,
    ZegoLiveDurationConfig? durationConfig,
    ZegoPrebuiltVideoConfig? videoConfig,
    ZegoInRoomMessageViewConfig? messageConfig,
    ZegoTopMenuBarConfig? topMenuBarConfig,
    ZegoBottomMenuBarConfig? bottomMenuBarConfig,
    ZegoLiveStreamingPreviewConfig? previewConfig,
    ZegoLiveStreamingPKBattleConfig? pkBattleConfig,
    ZegoLiveStreamingPKBattleEvents? pkBattleEvents,
    ZegoPrebuiltAudioVideoViewConfig? audioVideoViewConfig,
  })  : audioVideoViewConfig =
            audioVideoViewConfig ?? ZegoPrebuiltAudioVideoViewConfig(),
        topMenuBarConfig = topMenuBarConfig ?? ZegoTopMenuBarConfig(),
        bottomMenuBarConfig = bottomMenuBarConfig ?? ZegoBottomMenuBarConfig(),
        memberListConfig = memberListConfig ?? ZegoMemberListConfig(),
        inRoomMessageViewConfig =
            messageConfig ?? ZegoInRoomMessageViewConfig(),
        effectConfig = effectConfig ?? ZegoEffectConfig(),
        innerText = translationText ?? ZegoInnerText(),
        videoConfig = videoConfig ?? ZegoPrebuiltVideoConfig(),
        previewConfig = previewConfig ?? ZegoLiveStreamingPreviewConfig(),
        pkBattleConfig = pkBattleConfig ?? ZegoLiveStreamingPKBattleConfig(),
        pkBattleEvents = pkBattleEvents ?? ZegoLiveStreamingPKBattleEvents(),
        durationConfig = durationConfig ?? ZegoLiveDurationConfig() {
    layout ??= ZegoLayout.pictureInPicture();
  }

  /// Specifies the initial role when joining the live streaming.
  /// The role change after joining is not constrained by this property.
  ZegoLiveStreamingRole role = ZegoLiveStreamingRole.audience;

  List<IZegoUIKitPlugin> plugins = [];

  /// Whether to open the camera when joining the live streaming.
  ///
  /// If you want to join the live streaming with your camera closed, set this value to false;
  /// if you want to join the live streaming with your camera open, set this value to true.
  /// The default value is `true`.
  ///
  /// Note that this parameter is independent of the user's role.
  /// Even if the user is an audience, they can set this value to true, but in general, if the role is an audience, this value should be set to false.
  bool turnOnCameraWhenJoining;

  /// Whether to open the microphone when joining the live streaming.
  ///
  /// If you want to join the live streaming with your microphone closed, set this value to false;
  /// if you want to join the live streaming with your microphone open, set this value to true.
  /// The default value is `true`.
  ///
  /// Note that this parameter is independent of the user's role.
  /// Even if the user is an audience, they can set this value to true, and they can start chatting with others through voice after joining the room.
  /// Therefore, in general, if the role is an audience, this value should be set to false.
  bool turnOnMicrophoneWhenJoining;

  /// Whether to use the speaker to play audio when joining the live streaming.
  /// The default value is `true`.
  /// If this value is set to `false`, the system's default playback device, such as the earpiece or Bluetooth headset, will be used for audio playback.
  bool useSpeakerWhenJoining;

  /// whether to enable the camera by default when you be co-host, the default value is true
  bool turnOnCameraWhenCohosted;

  /// configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
  ZegoPrebuiltVideoConfig videoConfig;

  /// Configuration options for audio/video views.
  ZegoPrebuiltAudioVideoViewConfig audioVideoViewConfig;

  /// Configuration options for the top menu bar (toolbar).
  /// You can use these options to customize the appearance and behavior of the top menu bar.
  ZegoTopMenuBarConfig topMenuBarConfig;

  /// Configuration options for the bottom menu bar (toolbar).
  /// You can use these options to customize the appearance and behavior of the bottom menu bar.
  ZegoBottomMenuBarConfig bottomMenuBarConfig;

  /// Configuration related to the bottom member list, including displaying the member list, member list styles, and more.
  ZegoMemberListConfig memberListConfig;

  /// configs about message view
  ZegoInRoomMessageViewConfig inRoomMessageViewConfig;

  /// You can use it to modify your voice, apply beauty effects, and control reverb.
  ZegoEffectConfig effectConfig;

  /// Confirmation dialog information when leaving the live streaming.
  /// If not set, clicking the exit button will directly exit the live streaming.
  /// If set, a confirmation dialog will be displayed when clicking the exit button, and you will need to confirm the exit before actually exiting.
  ZegoDialogInfo? confirmDialogInfo;

  /// Configuration options for modifying all text content on the UI.
  /// All visible text content on the UI can be modified using this single property.
  ZegoInnerText innerText;

  @Deprecated('Since 2.5.8, please use innerText instead')
  ZegoInnerText get translationText => innerText;

  /// Layout-related configuration. You can choose your layout here.
  ZegoLayout? layout;

  /// same as Flutter's Navigator's param
  /// If `rootNavigator` is set to true, the state from the furthest instance of
  /// this class is given instead. Useful for pushing contents above all
  /// subsequent instances of [Navigator].
  bool rootNavigator;

  /// Use this to customize the avatar, and replace the default avatar with it.
  ///
  /// Example：
  ///
  /// ```dart
  ///
  ///  // eg:
  ///  avatarBuilder: (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
  ///    return user != null
  ///        ? Container(
  ///            decoration: BoxDecoration(
  ///              shape: BoxShape.circle,
  ///              image: DecorationImage(
  ///                image: NetworkImage(
  ///                  'https://your_server/app/avatar/${user.id}.png',
  ///                ),
  ///              ),
  ///            ),
  ///          )
  ///        : const SizedBox();
  ///  },
  ///
  /// ```
  ///
  ZegoAvatarBuilder? avatarBuilder;

  /// customize your start call button
  /// you MUST call startLive function on your custom button
  ///
  /// ..startLiveButtonBuilder =
  ///   (BuildContext context, VoidCallback startLive) {
  ///     return ElevatedButton(
  ///       onPressed: () {
  ///         //  do whatever you want
  ///         startLive();  //  MUST call this function to skip to target page!!!
  ///       },
  ///       child: Text("START"),
  ///     );
  ///   }
  ZegoStartLiveButtonBuilder? startLiveButtonBuilder;

  ///  mark is large room or not
  ///  sendInRoomCommand will sending to everyone in the room if true
  ///  that mean [toUserIDs] of [sendInRoomCommand] function is disabled if true
  bool markAsLargeRoom;

  /// The foreground of the live streaming.
  /// If you need to nest some widgets in [ZegoUIKitPrebuiltLiveStreaming], please use [foreground] nesting, otherwise these widgets will be lost when you minimize and restore the [ZegoUIKitPrebuiltLiveStreaming]
  Widget? foreground;

  /// The background of the live streaming.
  ///
  /// You can use any Widget as the background of the live streaming, such as a video, a GIF animation, an image, a web page, etc.
  /// If you need to dynamically change the background content, you will need to implement the logic for dynamic modification within the Widget you return.
  ///
  /// ```dart
  ///
  ///  // eg:
  /// ..background = Container(
  ///     decoration: const BoxDecoration(
  ///       image: DecorationImage(
  ///         fit: BoxFit.fitHeight,
  ///         image: ,
  ///       )));
  /// ```
  Widget? background;

  /// preview config
  ZegoLiveStreamingPreviewConfig previewConfig;

  /// cross room pk events
  /// Please refer to our [documentation](https://docs.zegocloud.com/article/15580) and [sample code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_live_streaming_example_flutter/tree/master/live_streaming_with_pkbattles) for usage instructions.
  ZegoLiveStreamingPKBattleEvents pkBattleEvents;
  ZegoLiveStreamingPKBattleConfig pkBattleConfig;

  /// Live Streaming timing configuration.
  ZegoLiveDurationConfig durationConfig;

  /// advance beauty config
  ZegoBeautyPluginConfig? beautyConfig;

  /// Maximum number of co-hosts.
  /// If exceeded, other audience members cannot become co-hosts.
  /// The default value is 12.
  int maxCoHostCount;

  /// Confirmation callback method before leaving the live streaming.
  ///
  /// If you want to perform more complex business logic before exiting the live streaming, such as updating some records to the backend, you can use the [onLeaveConfirmation] parameter to set it.
  /// This parameter requires you to provide a callback method that returns an asynchronous result.
  /// If you return true in the callback, the prebuilt page will quit and return to your previous page, otherwise it will be ignored.
  Future<bool> Function(BuildContext context)? onLeaveConfirmation;

  /// customize handling me removed from room
  Future<void> Function(String)? onMeRemovedFromRoom;

  /// This callback is triggered after leaving the live streaming.
  /// You can perform business-related prompts or other actions in this callback.
  VoidCallback? onLeaveLiveStreaming;

  /// customize handling after end live streaming
  VoidCallback? onLiveStreamingEnded;

  void Function(ZegoLiveStreamingState state)? onLiveStreamingStateUpdate;

  /// This callback method is called when someone requests to open your camera, typically when the host wants to open your camera.
  /// This method requires returning an asynchronous result.
  /// You can display a dialog in this callback to confirm whether to open the camera.
  /// Alternatively, you can return `true` without any processing, indicating that when someone requests to open your camera, it can be directly opened.
  /// By default, this method does nothing and returns `false`, indicating that others cannot open your camera.
  Future<bool> Function(BuildContext context)?
      onCameraTurnOnByOthersConfirmation;

  /// This callback method is called when someone requests to open your microphone, typically when the host wants to open your microphone.
  /// This method requires returning an asynchronous result.
  /// You can display a dialog in this callback to confirm whether to open the microphone.
  /// Alternatively, you can return `true` without any processing, indicating that when someone requests to open your microphone, it can be directly opened.
  /// By default, this method does nothing and returns `false`, indicating that others cannot open your microphone.
  Future<bool> Function(BuildContext context)?
      onMicrophoneTurnOnByOthersConfirmation;

  /// This callback is triggered when the maximum number of co-hosts is reached.
  void Function(int)? onMaxCoHostReached;
}

///  configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
class ZegoPrebuiltVideoConfig {
  /// Video configuration resolution and bitrate preset enumeration.
  ZegoPresetResolution preset;

  /// Frame rate, control the frame rate of the camera and the frame rate of the encoder.
  int? fps;

  /// Bit rate in kbps.
  int? bitrate;

  ZegoPrebuiltVideoConfig({
    this.preset = ZegoPresetResolution.Preset360P,
    this.bitrate,
    this.fps,
  });
}

/// Configuration options for audio/video views.
/// This class is used for the [audioVideoViewConfig] property of [ZegoUIKitPrebuiltLiveStreamingConfig].
///
/// These options allow you to customize the display effects of the audio/video views, such as showing microphone status and usernames.
/// If you need to customize the foreground or background of the audio/video view, you can use foregroundBuilder and backgroundBuilder.
/// If you want to hide user avatars or sound waveforms in audio mode, you can set showAvatarInAudioMode and showSoundWavesInAudioMode to false.
class ZegoPrebuiltAudioVideoViewConfig {
  /// Whether to mirror the displayed video captured by the camera.
  /// This mirroring effect only applies to the front-facing camera.
  /// Set it to true to enable mirroring, which flips the image horizontally.
  bool isVideoMirror;

  /// Whether to display the username on the audio/video view.
  /// Set it to false if you don't want to show the username on the audio/video view.
  bool showUserNameOnView;

  /// Video view mode.
  /// Set it to true if you want the video view to scale proportionally to fill the entire view, potentially resulting in partial cropping.
  /// Set it to false if you want the video view to scale proportionally, potentially resulting in black borders.
  bool useVideoViewAspectFill;

  /// Whether to display user avatars in audio mode.
  /// Set it to false if you don't want to show user avatars in audio mode.
  bool showAvatarInAudioMode;

  /// Whether to display sound waveforms in audio mode.
  /// Set it to false if you don't want to show sound waveforms in audio mode.
  bool showSoundWavesInAudioMode;

  /// You can customize the foreground of the audio/video view, which refers to the widget positioned on top of the view.
  /// You can return any widget, and we will place it at the top of the audio/video view.
  ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// Background for the audio/video windows in a Live Streaming.
  /// You can use any widget as the background for the audio/video windows. This can be a video, a GIF animation, an image, a web page, or any other widget.
  /// If you need to dynamically change the background content, you should implement the logic for dynamic modification within the widget you return.
  ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  ZegoPrebuiltAudioVideoViewConfig({
    this.isVideoMirror = true,
    this.showUserNameOnView = true,
    this.showAvatarInAudioMode = true,
    this.showSoundWavesInAudioMode = true,
    this.useVideoViewAspectFill = true,
    this.foregroundBuilder,
    this.backgroundBuilder,
  });
}

/// Configuration options for the top menu bar (toolbar).
class ZegoTopMenuBarConfig {
  /// These buttons will displayed on the menu bar, order by the list
  /// only support [minimizingButton] right now
  List<ZegoMenuBarButtonName> buttons;

  /// You can listen to the event of clicking on the host information in the top left corner.
  /// for example, if you want to display a popup or dialog with host information after it is clicked.
  void Function(ZegoUIKitUser host)? onHostAvatarClicked;

  ZegoTopMenuBarConfig({
    this.buttons = const [],
    this.onHostAvatarClicked,
  });
}

/// Configuration options for the bottom menu bar (toolbar).
/// You can use the [ZegoUIKitPrebuiltLiveStreamingConfig].[bottomMenuBarConfig] property to set the properties inside this class.
class ZegoBottomMenuBarConfig {
  /// Whether to display the room message button.
  bool showInRoomMessageButton;

  /// The list of predefined buttons to be displayed when the user role is set to host.
  List<ZegoMenuBarButtonName> hostButtons = [];

  /// The list of predefined buttons to be displayed when the user role is set to co-host.
  List<ZegoMenuBarButtonName> coHostButtons = [];

  /// The list of predefined buttons to be displayed when the user role is set to audience.
  List<ZegoMenuBarButtonName> audienceButtons = [];

  /// List of extension buttons for the host.
  /// These buttons will be added to the menu bar in the specified order and automatically added to the overflow menu when the [maxCount] limit is exceeded.
  ///
  /// If you want to place the extension buttons before the built-in buttons, you can achieve this by setting the index parameter of the ZegoMenuBarExtendButton.
  /// For example, if you want to place an extension button at the very beginning of the built-in buttons, you can set the index of that extension button to 0.
  /// Please refer to the definition of ZegoMenuBarExtendButton for implementation details.
  List<ZegoMenuBarExtendButton> hostExtendButtons = [];

  /// List of extension buttons for the co-hosts.
  /// These buttons will be added in the same way as the hostExtendButtons.
  List<ZegoMenuBarExtendButton> coHostExtendButtons = [];

  /// List of extension buttons for the audience.
  /// These buttons will be added in the same way as the hostExtendButtons.
  List<ZegoMenuBarExtendButton> audienceExtendButtons = [];

  /// Controls the maximum number of buttons (including predefined and custom buttons) to be displayed in the menu bar (toolbar).
  /// When the number of buttons exceeds the `maxCount` limit, a "More" button will appear.
  /// Clicking on it will display a panel showing other buttons that cannot be displayed in the menu bar (toolbar).
  int maxCount;

  /// Button style for the bottom menu bar.
  ZegoBottomMenuBarButtonStyle? buttonStyle;

  ZegoBottomMenuBarConfig({
    this.showInRoomMessageButton = true,
    this.hostButtons = const [
      ZegoMenuBarButtonName.beautyEffectButton,
      ZegoMenuBarButtonName.soundEffectButton,
      ZegoMenuBarButtonName.switchCameraButton,
      ZegoMenuBarButtonName.toggleCameraButton,
      ZegoMenuBarButtonName.toggleMicrophoneButton,
    ],
    this.coHostButtons = const [
      ZegoMenuBarButtonName.switchCameraButton,
      ZegoMenuBarButtonName.toggleCameraButton,
      ZegoMenuBarButtonName.toggleMicrophoneButton,
      ZegoMenuBarButtonName.coHostControlButton,
      ZegoMenuBarButtonName.beautyEffectButton,
      ZegoMenuBarButtonName.soundEffectButton,
    ],
    this.audienceButtons = const [],
    this.hostExtendButtons = const [],
    this.coHostExtendButtons = const [],
    this.audienceExtendButtons = const [],
    this.maxCount = 5,
    this.buttonStyle,
  });
}

/// Extension buttons for the bottom toolbar.
/// If the built-in buttons do not meet your requirements, you can define your own button to implement custom functionality.
///
/// For example:
/// In this example, an IconButton with a "+" icon is defined as an extension button.
/// Its index is set to 2, indicating that it will be inserted after the built-in buttons and previous extension buttons in the bottom toolbar.
/// When the button is clicked, the callback function will be triggered.
///
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
class ZegoMenuBarExtendButton extends StatelessWidget {
  /// Index of buttons within the entire bottom toolbar, including both built-in buttons and extension buttons.
  ///
  /// For example, if it's for the host, the index refers to the array index of [hostButtons + hostExtendButtons].
  /// If this index is set, the corresponding button will be placed at the specified position in the array of buttons for the corresponding role.
  /// If this index is not set, the button will be placed after the built-in buttons.
  /// The index starts from 0, and -1 indicates that the button will be placed after the built-in buttons by default.
  ///
  /// Definition of built-in buttons: an array of type List<ZegoMenuBarButtonName>.
  /// Definition of extension buttons: an array of type List<ZegoMenuBarExtendButton>.
  final int index;

  /// button widget
  final Widget child;

  const ZegoMenuBarExtendButton({
    Key? key,
    required this.child,
    this.index = -1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Button style for the bottom toolbar, allowing customization of button icons or text.
/// You can use the [ZegoUIKitPrebuiltLiveStreamingConfig].[bottomMenuBarConfig].[buttonStyle] property to set the properties inside this class.
///
/// Example
/// ZegoBottomMenuBarButtonStyle(
///   chatEnabledButtonIcon: Icon(Icons.chat), // Customize the enabled chat button icon
///   chatDisabledButtonIcon: Icon(Icons.chat_disabled), // Customize the disabled chat button icon
///   // Customize other button icons...
/// );
class ZegoBottomMenuBarButtonStyle {
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

  ZegoBottomMenuBarButtonStyle({
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
}

/// Configuration for the member list.
/// You can use the [ZegoUIKitPrebuiltLiveStreamingConfig].[memberListConfig] property to set the properties inside this class.
///
/// If you want to use a custom member list item view, you can set the `itemBuilder` property in `ZegoMemberListConfig`
/// and pass your custom view's builder function to it.
/// For example, suppose you have implemented a `CustomMemberListItem` component that can render a member list item view based on the user information. You can set it up like this:
///
/// ZegoMemberListConfig(
///   showMicrophoneState: true,
///   showCameraState: false,
///   itemBuilder: (BuildContext context, Size size, ZegoUIKitUser user, Map<String, dynamic> extraInfo) {
///     return CustomMemberListItem(user: user);
///   },
/// );
///
/// In this example, we set `showMicrophoneState` to true, so the microphone state will be displayed in the member list item.
/// `showCameraState` is set to false, so the camera state will not be displayed.
/// Finally, we pass the builder function of the custom view, `CustomMemberListItem`, to the `itemBuilder` property so that the member list item will be rendered using the custom component.
class ZegoMemberListConfig {
  /// Whether to show the microphone state of the member. Defaults to true, which means it will be shown.
  bool showMicrophoneState;

  /// Whether to show the camera state of the member. Defaults to true, which means it will be shown.
  bool showCameraState;

  /// Custom member list item view.
  ZegoMemberListItemBuilder? itemBuilder;

  /// You can listen to the user click event on the member list,
  /// for example, if you want to display specific information about a member after they are clicked.
  void Function(ZegoUIKitUser user)? onClicked;

  ZegoMemberListConfig({
    this.showMicrophoneState = true,
    this.showCameraState = true,
    this.itemBuilder,
    this.onClicked,
  });
}

/// Control options for the bottom-left message list.
/// This class is used for the [inRoomMessageViewConfig] property of [ZegoUIKitPrebuiltLiveStreamingConfig].
///
/// If you want to customize chat messages, you can specify the [itemBuilder] in [ZegoInRoomMessageViewConfig].
///
/// Example:
///
/// ZegoInRoomMessageViewConfig(
///   itemBuilder: (BuildContext context, ZegoRoomMessage message) {
///     return ListTile(
///       title: Text(message.message),
///       subtitle: Text(message.user.id),
///     );
///   },
///   opacity: 0.8,
/// );
class ZegoInRoomMessageViewConfig {
  /// The opacity of chat message list items, default value is 0.5.
  double opacity;

  /// The width of chat message list view
  double? width;

  /// The height of chat message list view
  double? height;

  /// Use this to customize the style and content of each chat message list item.
  /// For example, you can modify the background color, opacity, border radius, or add additional information like the sender's level or role.
  ZegoInRoomMessageItemBuilder? itemBuilder;

  ZegoInRoomMessageViewConfig({
    this.itemBuilder,
    this.width,
    this.height,
    this.opacity = 0.5,
  });
}

/// Configuration options for voice changer, beauty effects and reverberation effects.
/// This class is used for the [effectConfig] property in [ZegoUIKitPrebuiltLiveAudioRoomConfig].
class ZegoEffectConfig {
  /// List of beauty effects types.
  /// If you don't want a certain effect, simply remove it from the list.
  List<BeautyEffectType> beautyEffects;

  /// List of voice changer effects.
  /// If you don't want a certain effect, simply remove it from the list.
  List<VoiceChangerType> voiceChangeEffect;

  /// List of revert effects types.
  /// If you don't want a certain effect, simply remove it from the list.
  List<ReverbType> reverbEffect;

  ZegoEffectConfig({
    this.beautyEffects = const [
      BeautyEffectType.whiten,
      BeautyEffectType.rosy,
      BeautyEffectType.smooth,
      BeautyEffectType.sharpen,
    ],
    this.voiceChangeEffect = const [
      VoiceChangerType.littleGirl,
      VoiceChangerType.deep,
      VoiceChangerType.robot,
      VoiceChangerType.ethereal,
      VoiceChangerType.littleBoy,
      VoiceChangerType.female,
      VoiceChangerType.male,
      VoiceChangerType.optimusPrime,
      VoiceChangerType.crystalClear,
      VoiceChangerType.cMajor,
      VoiceChangerType.aMajor,
      VoiceChangerType.harmonicMinor,
    ],
    this.reverbEffect = const [
      ReverbType.ktv,
      ReverbType.hall,
      ReverbType.concert,
      ReverbType.rock,
      ReverbType.smallRoom,
      ReverbType.largeRoom,
      ReverbType.valley,
      ReverbType.recordingStudio,
      ReverbType.basement,
      ReverbType.popular,
      ReverbType.gramophone,
    ],
  });

  /// @nodoc
  ZegoEffectConfig.none({
    this.beautyEffects = const [],
    this.voiceChangeEffect = const [],
    this.reverbEffect = const [],
  });

  /// @nodoc
  bool get isSupportBeauty => beautyEffects.isNotEmpty;

  /// @nodoc
  bool get isSupportVoiceChange => voiceChangeEffect.isNotEmpty;

  /// @nodoc
  bool get isSupportReverb => reverbEffect.isNotEmpty;
}

/// used to configure the parameters related to PK battles
/// This class is used for the [pkBattleConfig] property of [ZegoUIKitPrebuiltLiveStreamingConfig].
class ZegoLiveStreamingPKBattleConfig {
  /// The distance that the pkBattleEvents's top edge is inset from the top of the stack.
  /// default is 164.r
  double? pKBattleViewTopPadding;

  /// When the connected host gets offline due to exceptions, SDK defaults to show "Host is reconnecting".
  /// To customize the content that displays when the connected host gets offline, use the [hostReconnectingBuilder].
  ZegoLiveStreamingPKBattleHostReconnectingBuilder? hostReconnectingBuilder;

  /// To overlay custom components on the PKBattleView, use the [pkBattleViewForegroundBuilder].
  ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewForegroundBuilder;

  /// To add custom components on the top edge of the PKBattleView, use the [pkBattleViewTopBuilder].
  ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewTopBuilder;

  /// To add custom components on the bottom edge of the PKBattleView, use the [pkBattleViewBottomBuilder].
  ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewBottomBuilder;
}

/// used to configure the parameters related to the preview of the live streaming.
/// This class is used for the [previewConfig] property of [ZegoUIKitPrebuiltLiveStreamingConfig].
class ZegoLiveStreamingPreviewConfig {
  /// Whether to show the preview page for the host. The default value is true.
  bool showPreviewForHost;

  /// The icon for the page back button.
  ///
  /// You can customize the icon for the page back button as shown in the example below:
  /// ZegoLiveStreamingPreviewConfig(
  ///   pageBackIcon: Icon(Icons.arrow_back),
  /// );
  Widget? pageBackIcon;

  /// The icon for the beauty effect button.
  ///
  /// You can customize the icon for the beauty effect button as shown in the example below:
  /// ZegoLiveStreamingPreviewConfig(
  ///   beautyEffectIcon: Icon(Icons.face),
  /// );
  Widget? beautyEffectIcon;

  /// The icon for the switch camera button.
  ///
  /// You can customize the icon for the switch camera button as shown in the example below:
  /// ZegoLiveStreamingPreviewConfig(
  ///   switchCameraIcon: Icon(Icons.switch_camera),
  /// );
  Widget? switchCameraIcon;

  ZegoLiveStreamingPreviewConfig({
    this.showPreviewForHost = true,
    this.pageBackIcon,
    this.beautyEffectIcon,
    this.switchCameraIcon,
  });
}

/// Live Streaming timing configuration.
class ZegoLiveDurationConfig {
  /// Whether to display Live Streaming timing.
  bool isVisible;

  /// Call timing callback function, called every second.
  ///
  /// Example: Set to automatically hang up after 5 minutes.
  /// ..durationConfig.isVisible = true
  /// ..durationConfig.onDurationUpdate = (Duration duration) {
  ///   if (duration.inSeconds >= 5 * 60) {
  ///     liveController?.leave(context);
  ///   }
  /// }
  void Function(Duration)? onDurationUpdate;

  ZegoLiveDurationConfig({
    this.isVisible = true,
    this.onDurationUpdate,
  });
}
