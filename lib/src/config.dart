// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/layout/layout.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/config.dart';

/// Configuration for initializing the Live Streaming
///
/// This class is used as the [ZegoUIKitPrebuiltLiveStreaming.config] parameter for the constructor of [ZegoUIKitPrebuiltLiveStreaming].
class ZegoUIKitPrebuiltLiveStreamingConfig {
  static const defaultMaxCoHostCount = 12;

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
        stopCoHostingWhenMicCameraOff = false,
        disableCoHostInvitationReceivedDialog = false,
        markAsLargeRoom = false,
        slideSurfaceToHide = true,
        rootNavigator = false,
        videoConfig = ZegoPrebuiltVideoConfig(),
        maxCoHostCount = defaultMaxCoHostCount,
        showBackgroundTips = false,
        advanceConfigs = {},
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
        memberButtonConfig = ZegoMemberButtonConfig(),
        memberListConfig = ZegoMemberListConfig(),
        inRoomMessageConfig = ZegoInRoomMessageConfig(),
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
        pkBattleV2Config = ZegoLiveStreamingPKBattleV2Config(),
        durationConfig = ZegoLiveDurationConfig();

  /// Default initialization parameters for the audience.
  ///
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
        stopCoHostingWhenMicCameraOff = false,
        disableCoHostInvitationReceivedDialog = false,
        markAsLargeRoom = false,
        slideSurfaceToHide = true,
        rootNavigator = false,
        videoConfig = ZegoPrebuiltVideoConfig(),
        maxCoHostCount = defaultMaxCoHostCount,
        showBackgroundTips = false,
        advanceConfigs = {},
        audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
          showSoundWavesInAudioMode: true,
        ),
        topMenuBarConfig = ZegoTopMenuBarConfig(),
        bottomMenuBarConfig = ZegoBottomMenuBarConfig(
          audienceButtons: plugins?.isEmpty ?? true
              ? []
              : const [ZegoMenuBarButtonName.coHostControlButton],
        ),
        memberButtonConfig = ZegoMemberButtonConfig(),
        memberListConfig = ZegoMemberListConfig(),
        inRoomMessageConfig = ZegoInRoomMessageConfig(),
        effectConfig = ZegoEffectConfig(),
        innerText = ZegoInnerText(),
        previewConfig = ZegoLiveStreamingPreviewConfig(),
        pkBattleConfig = ZegoLiveStreamingPKBattleConfig(),
        pkBattleV2Config = ZegoLiveStreamingPKBattleV2Config(),
        pkBattleEvents = ZegoLiveStreamingPKBattleEvents(),
        durationConfig = ZegoLiveDurationConfig();

  ZegoUIKitPrebuiltLiveStreamingConfig({
    this.turnOnCameraWhenJoining = true,
    this.turnOnMicrophoneWhenJoining = true,
    this.useSpeakerWhenJoining = true,
    this.turnOnCameraWhenCohosted = true,
    this.stopCoHostingWhenMicCameraOff = false,
    this.disableCoHostInvitationReceivedDialog = false,
    this.markAsLargeRoom = false,
    this.slideSurfaceToHide = true,
    this.rootNavigator = false,
    this.maxCoHostCount = defaultMaxCoHostCount,
    this.showBackgroundTips = false,
    this.advanceConfigs = const {},
    this.layout,
    this.foreground,
    this.background,
    this.confirmDialogInfo,
    this.beautyConfig,
    this.swipingConfig,
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
    ZegoMemberButtonConfig? memberButtonConfig,
    ZegoLiveDurationConfig? durationConfig,
    ZegoPrebuiltVideoConfig? videoConfig,
    ZegoInRoomMessageConfig? messageConfig,
    ZegoTopMenuBarConfig? topMenuBarConfig,
    ZegoBottomMenuBarConfig? bottomMenuBarConfig,
    ZegoLiveStreamingPreviewConfig? previewConfig,
    ZegoLiveStreamingPKBattleConfig? pkBattleConfig,
    ZegoLiveStreamingPKBattleV2Config? pkBattleV2Config,
    ZegoLiveStreamingPKBattleEvents? pkBattleEvents,
    ZegoPrebuiltAudioVideoViewConfig? audioVideoViewConfig,
  })  : audioVideoViewConfig =
            audioVideoViewConfig ?? ZegoPrebuiltAudioVideoViewConfig(),
        topMenuBarConfig = topMenuBarConfig ?? ZegoTopMenuBarConfig(),
        bottomMenuBarConfig = bottomMenuBarConfig ?? ZegoBottomMenuBarConfig(),
        memberListConfig = memberListConfig ?? ZegoMemberListConfig(),
        memberButtonConfig = memberButtonConfig ?? ZegoMemberButtonConfig(),
        inRoomMessageConfig = messageConfig ?? ZegoInRoomMessageConfig(),
        effectConfig = effectConfig ?? ZegoEffectConfig(),
        innerText = translationText ?? ZegoInnerText(),
        videoConfig = videoConfig ?? ZegoPrebuiltVideoConfig(),
        previewConfig = previewConfig ?? ZegoLiveStreamingPreviewConfig(),
        pkBattleConfig = pkBattleConfig ?? ZegoLiveStreamingPKBattleConfig(),
        pkBattleV2Config =
            pkBattleV2Config ?? ZegoLiveStreamingPKBattleV2Config(),
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
  ///
  /// The default value is `true`.
  /// If this value is set to `false`, the system's default playback device, such as the earpiece or Bluetooth headset, will be used for audio playback.
  bool useSpeakerWhenJoining;

  /// whether to enable the camera by default when you be co-host, the default value is true
  bool turnOnCameraWhenCohosted;

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

  /// configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
  ZegoPrebuiltVideoConfig videoConfig;

  /// Configuration options for audio/video views.
  ZegoPrebuiltAudioVideoViewConfig audioVideoViewConfig;

  /// Configuration options for the top menu bar (toolbar).
  ///
  /// You can use these options to customize the appearance and behavior of the top menu bar.
  ZegoTopMenuBarConfig topMenuBarConfig;

  /// Configuration options for the bottom menu bar (toolbar).
  ///
  /// You can use these options to customize the appearance and behavior of the bottom menu bar.
  ZegoBottomMenuBarConfig bottomMenuBarConfig;

  /// Configuration related to the top member button
  ZegoMemberButtonConfig memberButtonConfig;

  /// Configuration related to the bottom member list, including displaying the member list, member list styles, and more.
  ZegoMemberListConfig memberListConfig;

  /// configs about message
  ZegoInRoomMessageConfig inRoomMessageConfig;

  @Deprecated('Since 2.10.7, please use inRoomMessageConfig instead')
  ZegoInRoomMessageViewConfig get inRoomMessageViewConfig =>
      inRoomMessageConfig;

  @Deprecated('Since 2.10.7, please use inRoomMessageConfig instead')
  set inRoomMessageViewConfig(ZegoInRoomMessageViewConfig config) =>
      inRoomMessageConfig = config;

  /// You can use it to modify your voice, apply beauty effects, and control reverb.
  ZegoEffectConfig effectConfig;

  /// Confirmation dialog information when leaving the live streaming.
  ///
  /// If not set, clicking the exit button will directly exit the live streaming.
  ///
  /// If set, a confirmation dialog will be displayed when clicking the exit button, and you will need to confirm the exit before actually exiting.
  ///
  /// Sample Code:
  ///
  /// ```dart
  ///  ..confirmDialogInfo = ZegoDialogInfo(
  ///    title: 'Leave confirm',
  ///    message: 'Do you want to end?',
  ///    cancelButtonName: 'Cancel',
  ///    confirmButtonName: 'Confirm',
  ///  )
  /// ```
  ///<img src="https://doc.oa.zego.im/Pics/ZegoUIKit/live/live_confirm.gif" width=50%/>
  ZegoDialogInfo? confirmDialogInfo;

  /// Configuration options for modifying all text content on the UI.
  ///
  /// All visible text content on the UI can be modified using this single property.
  ZegoInnerText innerText;

  @Deprecated('Since 2.5.8, please use innerText instead')
  ZegoInnerText get translationText => innerText;

  /// Layout-related configuration. You can choose your layout here. such as [layout = ZegoLayout.gallery()]
  ZegoLayout? layout;

  /// same as Flutter's Navigator's param
  ///
  /// If `rootNavigator` is set to true, the state from the furthest instance of this class is given instead.
  /// Useful for pushing contents above all subsequent instances of [Navigator].
  bool rootNavigator;

  /// Use this to customize the avatar, and replace the default avatar with it.
  ///
  /// Example：
  ///
  /// ```dart
  ///  // eg:
  ///  avatarBuilder: (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
  ///    return user != null
  ///        ? Container(
  ///            decoration: BoxDecoration(
  ///              shape: BoxShape.circle,
  ///              image: DecorationImage(
  ///                image: NetworkImage(
  ///                  'https://robohash.org/01.png',
  ///                ),
  ///              ),
  ///            ),
  ///          )
  ///        : const SizedBox();
  ///  },
  /// ```
  /// <img src="https://storage.zego.im/sdk-doc/Pics/zegocloud/api/flutter/live/avatar_builder.png" width=50%/>
  ZegoAvatarBuilder? avatarBuilder;

  ///  Mark is large room or not
  ///
  ///  sendInRoomCommand will sending to everyone in the room if true
  ///  that mean [toUserIDs] of [sendInRoomCommand] function is disabled if true
  bool markAsLargeRoom;

  /// set whether the surface can be slid to hide, including the top toolbar, bottom toolbar, message list, and foreground
  bool slideSurfaceToHide;

  /// The foreground of the live streaming.
  ///
  /// If you need to nest some widgets in [ZegoUIKitPrebuiltLiveStreaming], please use [foreground] nesting, otherwise these widgets will be lost when you minimize and restore the [ZegoUIKitPrebuiltLiveStreaming]
  Widget? foreground;

  /// The background of the live streaming.
  ///
  /// You can use any Widget as the background of the live streaming, such as a video, a GIF animation, an image, a web page, etc.
  /// If you need to dynamically change the background content, you will need to implement the logic for dynamic modification within the Widget you return.
  ///
  /// ```dart
  /// ..background = Container(
  ///     decoration: const BoxDecoration(
  ///       image: DecorationImage(
  ///         fit: BoxFit.fitHeight,
  ///         image: ,
  ///       )));
  /// ```
  Widget? background;

  /// Customize your start call button
  /// you MUST call startLive function on your custom button
  ///
  ///```dart
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
  /// ```
  /// todo@v3.0.0 move to [ZegoLiveStreamingPreviewConfig]
  ZegoStartLiveButtonBuilder? startLiveButtonBuilder;

  /// preview config
  ZegoLiveStreamingPreviewConfig previewConfig;

  /// cross room pk events(pk version 1)
  ///
  /// Please refer to our [documentation](https://docs.zegocloud.com/article/15580) and [sample code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_live_streaming_example_flutter/tree/master/live_streaming_with_pkbattles) for usage instructions.
  @Deprecated(
      'Since 2.23.0,Please use [ZegoUIKitPrebuiltLiveStreamingController.pkV2], '
      '[ZegoUIKitPrebuiltLiveStreamingEvents.pkV2Events], '
      '[ZegoLiveStreamingPKBattleV2Config] instead')
  ZegoLiveStreamingPKBattleEvents pkBattleEvents;

  /// pk version 1's config
  @Deprecated(
      'Since 2.23.0,Please use [ZegoUIKitPrebuiltLiveStreamingController.pkV2], '
      '[ZegoUIKitPrebuiltLiveStreamingEvents.pkV2Events], '
      '[ZegoLiveStreamingPKBattleV2Config] instead')
  ZegoLiveStreamingPKBattleConfig pkBattleConfig;

  /// pk version 2's config,
  /// if you want to listen event, please refer [ZegoUIKitPrebuiltLiveStreamingEvents.pkV2Events]
  ZegoLiveStreamingPKBattleV2Config pkBattleV2Config;

  /// Live Streaming timing configuration.
  ///
  /// To calculate the livestream duration, do the following:
  /// 1. Set the [ZegoLiveDurationConfig.isVisible] property of [ZegoLiveDurationConfig] to display the current timer. (It is displayed by default)
  /// 2. Assuming that the livestream duration is 5 minutes, the livestream will automatically end when the time is up (refer to the following code). You will be notified of the end of the livestream duration through [ZegoLiveDurationConfig.onDurationUpdate]. To end the livestream, you can call the [ZegoUIKitPrebuiltLiveStreamingController.leave()] method.
  ///
  /// ```dart
  ///  ..durationConfig.isVisible = true
  ///  ..durationConfig.onDurationUpdate = (Duration duration) {
  ///    if (duration.inSeconds >= 5 * 60) {
  ///      liveController?.leave(context);
  ///    }
  ///  }
  /// ```
  ///<img src = "https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/live/live_duration.jpeg" width=50% />
  ZegoLiveDurationConfig durationConfig;

  /// advance beauty config
  ZegoBeautyPluginConfig? beautyConfig;

  /// Maximum number of co-hosts.
  ///
  /// If exceeded, other audience members cannot become co-hosts.
  /// The default value is 12.
  int maxCoHostCount;

  /// show background tips of live or not, default tips is 'No host is online.'
  bool showBackgroundTips;

  /// swiping config, if you wish to use swiping, please configure this config.
  /// if it is null, this swiping will not be enabled.
  /// the [liveID] will be the initial live id of swiping
  ZegoLiveStreamingSwipingConfig? swipingConfig;

  /// Set advanced engine configuration, Used to enable advanced functions.
  /// For details, please consult ZEGO technical support.
  Map<String, String> advanceConfigs;

  /// Confirmation callback method before leaving the live streaming.
  ///
  /// If you want to perform more complex business logic before exiting the live streaming, such as updating some records to the backend, you can use the [onLeaveConfirmation] parameter to set it.
  ///
  /// This parameter requires you to provide a callback method that returns an asynchronous result.
  ///
  /// If you return true in the callback, the prebuilt page will quit and return to your previous page, otherwise it will be ignored.
  ///
  /// Sample Code:
  ///
  /// ```dart
  /// ..onLeaveConfirmation = (context) async {
  ///   return await showDialog(
  ///     context: context,
  ///     barrierDismissible: false,
  ///     builder: (BuildContext context) {
  ///       return AlertDialog(
  ///         backgroundColor: Colors.blue[900]!.withOpacity(0.9),
  ///         title: const Text('This is your custom dialog',
  ///             style: TextStyle(color: Colors.white70)),
  ///         content: const Text('You can customize this dialog as you like',
  ///             style: TextStyle(color: Colors.white70)),
  ///         actions: [
  ///           ElevatedButton(
  ///             child: const Text('Cancel',
  ///                 style: TextStyle(color: Colors.white70)),
  ///             onPressed: () => Navigator.of(context).pop(false),
  ///           ),
  ///           ElevatedButton(
  ///             child: const Text('Exit'),
  ///             onPressed: () => Navigator.of(context).pop(true),
  ///           ),
  ///         ],
  ///       );
  ///     },
  ///   );
  /// }
  /// ```
  /// <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/live/live_custom_confirm.gif" width=40%/>
  Future<bool> Function(BuildContext context)? onLeaveConfirmation;

  /// This callback is triggered when local user removed from live streaming
  ///
  /// The default behavior is to return to the previous page.
  ///
  /// If you override this callback, you must perform the page navigation
  /// yourself to return to the previous page!!!
  /// otherwise the user will remain on the current live streaming page !!!!!
  ///
  /// You can perform business-related prompts or other actions in this callback.
  /// For example, you can perform custom logic during the hang-up operation, such as recording log information, stopping recording, etc.
  Future<void> Function(String)? onMeRemovedFromRoom;

  /// This callback is triggered after leaving the live streaming(host would not trigger this callback!!!).
  ///
  /// You can perform business-related prompts or other actions in this callback.
  ///
  /// The default behavior is to return to the previous page.
  ///
  /// If you override this callback, you must perform the page navigation
  /// yourself to return to the previous page!!!
  /// otherwise the user will remain on the current live streaming page !!!!!
  ///
  /// The [isFromMinimizing] it means that the user left the chat room while it was in a minimized state.
  /// You **can not** return to the previous page while it was **in a minimized state**!!!
  /// On the other hand, if the value of the parameter is false, it means that the user left the chat room while it was in a normal state (i.e., not minimized).
  void Function(bool isFromMinimizing)? onLeaveLiveStreaming;

  /// This callback method is called when live streaming ended(all users in live streaming will received).
  ///
  /// The default behavior of host is return to the previous page(only host!!).
  /// If you override this callback, you must perform the page navigation yourself while it was in a normal state,
  /// otherwise the user will remain on the live streaming page.
  ///
  /// The [isFromMinimizing] it means that the user left the chat room while it was in a minimized state.
  /// You **can not** return to the previous page while it was **in a minimized state**!!!
  /// On the other hand, if the value of the parameter is false, it means that the user left the chat room while it was in a normal state (i.e., not minimized).
  void Function(bool isFromMinimizing)? onLiveStreamingEnded;

  /// This callback method is called when live streaming state update.
  void Function(ZegoLiveStreamingState state)? onLiveStreamingStateUpdate;

  /// This callback method is called when someone requests to open your camera, typically when the host wants to open your camera.
  ///
  /// This method requires returning an asynchronous result.
  ///
  /// You can display a dialog in this callback to confirm whether to open the camera.
  ///
  /// Alternatively, you can return `true` without any processing, indicating that when someone requests to open your camera, it can be directly opened.
  ///
  /// By default, this method does nothing and returns `false`, indicating that others cannot open your camera.
  ///
  /// Example：
  ///
  /// ```dart
  ///
  ///  // eg:
  /// ..onCameraTurnOnByOthersConfirmation =
  ///     (BuildContext context) async {
  ///   const textStyle = TextStyle(
  ///     fontSize: 10,
  ///     color: Colors.white70,
  ///   );
  ///
  ///   return await showDialog(
  ///     context: context,
  ///     barrierDismissible: false,
  ///     builder: (BuildContext context) {
  ///       return AlertDialog(
  ///         backgroundColor: Colors.blue[900]!.withOpacity(0.9),
  ///         title: const Text(
  ///           'You have a request to turn on your camera',
  ///           style: textStyle,
  ///         ),
  ///         content: const Text(
  ///           'Do you agree to turn on the camera?',
  ///           style: textStyle,
  ///         ),
  ///         actions: [
  ///           ElevatedButton(
  ///             child: const Text('Cancel', style: textStyle),
  ///             onPressed: () => Navigator.of(context).pop(false),
  ///           ),
  ///           ElevatedButton(
  ///             child: const Text('OK', style: textStyle),
  ///             onPressed: () {
  ///               Navigator.of(context).pop(true);
  ///             },
  ///           ),
  ///         ],
  ///       );
  ///     },
  ///   );
  /// },
  /// ```
  Future<bool> Function(BuildContext context)?
      onCameraTurnOnByOthersConfirmation;

  /// This callback method is called when someone requests to open your microphone, typically when the host wants to open your microphone.
  ///
  /// This method requires returning an asynchronous result.
  ///
  /// You can display a dialog in this callback to confirm whether to open the microphone.
  ///
  /// Alternatively, you can return `true` without any processing, indicating that when someone requests to open your microphone, it can be directly opened.
  ///
  /// By default, this method does nothing and returns `false`, indicating that others cannot open your microphone.
  ///
  /// Example：
  ///
  /// ```dart
  ///
  ///  // eg:
  /// ..onMicrophoneTurnOnByOthersConfirmation =
  ///     (BuildContext context) async {
  ///   const textStyle = TextStyle(
  ///     fontSize: 10,
  ///     color: Colors.white70,
  ///   );
  ///
  ///   return await showDialog(
  ///     context: context,
  ///     barrierDismissible: false,
  ///     builder: (BuildContext context) {
  ///       return AlertDialog(
  ///         backgroundColor: Colors.blue[900]!.withOpacity(0.9),
  ///         title: const Text(
  ///           'You have a request to turn on your microphone',
  ///           style: textStyle,
  ///         ),
  ///         content: const Text(
  ///           'Do you agree to turn on the microphone?',
  ///           style: textStyle,
  ///         ),
  ///         actions: [
  ///           ElevatedButton(
  ///             child: const Text('Cancel', style: textStyle),
  ///             onPressed: () => Navigator.of(context).pop(false),
  ///           ),
  ///           ElevatedButton(
  ///             child: const Text('OK', style: textStyle),
  ///             onPressed: () {
  ///               Navigator.of(context).pop(true);
  ///             },
  ///           ),
  ///         ],
  ///       );
  ///     },
  ///   );
  /// },
  /// ```
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

typedef ZegoPlayCoHostAudioVideoCallback = bool Function(
  ZegoUIKitUser localUser,
  ZegoLiveStreamingRole localRole,
  ZegoUIKitUser coHost,
);

/// Configuration options for audio/video views.
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.audioVideoViewConfig] property.
///
/// These options allow you to customize the display effects of the audio/video views, such as showing microphone status and usernames.
///
/// If you need to customize the foreground or background of the audio/video view, you can use foregroundBuilder and backgroundBuilder.
///
/// If you want to hide user avatars or sound waveforms in audio mode, you can set showAvatarInAudioMode and showSoundWavesInAudioMode to false.
class ZegoPrebuiltAudioVideoViewConfig {
  /// show target user's audio video view or not
  /// return false if you don't want to show target user's audio video view.
  ///
  /// when the stream list changes (specifically, when the co-hosts change),
  /// it will dynamically read this configuration to determine whether to show the target user view.
  bool Function(
    ZegoUIKitUser localUser,
    ZegoLiveStreamingRole localRole,
    ZegoUIKitUser targetUser,
    ZegoLiveStreamingRole targetUserRole,
  )? visible;

  /// Whether to the play audio of the specified co-host?
  /// The default behavior is play.
  /// return false if you don't want to play target user's audio.
  ///
  /// when the stream list changes (specifically, when the co-hosts change),
  /// it will dynamically read this configuration to determine whether to fetch the audio.(muteUserAudio)
  ZegoPlayCoHostAudioVideoCallback? playCoHostAudio;

  /// Whether to the play video of the specified co-host?
  /// The default behavior is play.
  /// return false if you don't want to play target user's video.
  ///
  /// when the stream list changes (specifically, when the co-hosts change),
  /// it will dynamically read this configuration to determine whether to fetch the video.(muteUserVideo)
  ZegoPlayCoHostAudioVideoCallback? playCoHostVideo;

  /// Whether to mirror the displayed video captured by the camera.
  ///
  /// This mirroring effect only applies to the front-facing camera.
  /// Set it to true to enable mirroring, which flips the image horizontally.
  bool isVideoMirror;

  /// Whether to display the username on the audio/video view.
  ///
  /// Set it to false if you don't want to show the username on the audio/video view.
  bool showUserNameOnView;

  /// Video view mode.
  ///
  /// Set it to true if you want the video view to scale proportionally to fill the entire view, potentially resulting in partial cropping.
  ///
  /// Set it to false if you want the video view to scale proportionally, potentially resulting in black borders.
  bool useVideoViewAspectFill;

  /// Whether to display user avatars in audio mode.
  ///
  /// Set it to false if you don't want to show user avatars in audio mode.
  bool showAvatarInAudioMode;

  /// Whether to display sound waveforms in audio mode.
  ///
  /// Set it to false if you don't want to show sound waveforms in audio mode.
  bool showSoundWavesInAudioMode;

  /// You can customize the foreground of the audio/video view, which refers to the widget positioned on top of the view.
  ///
  /// You can return any widget, and we will place it at the top of the audio/video view.
  ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// Background for the audio/video windows in a Live Streaming.
  ///
  /// You can use any widget as the background for the audio/video windows. This can be a video, a GIF animation, an image, a web page, or any other widget.
  ///
  /// If you need to dynamically change the background content, you should implement the logic for dynamic modification within the widget you return.
  ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  ZegoPrebuiltAudioVideoViewConfig({
    this.isVideoMirror = true,
    this.showUserNameOnView = true,
    this.showAvatarInAudioMode = true,
    this.showSoundWavesInAudioMode = true,
    this.useVideoViewAspectFill = true,
    this.visible,
    this.playCoHostAudio,
    this.playCoHostVideo,
    this.foregroundBuilder,
    this.backgroundBuilder,
  });
}

/// Configuration options for the top menu bar (toolbar).
class ZegoTopMenuBarConfig {
  /// These buttons will displayed on the menu bar, order by the list
  /// only support [minimizingButton] right now
  List<ZegoMenuBarButtonName> buttons;

  /// padding for the top menu bar.
  EdgeInsetsGeometry? padding;

  /// margin for the top menu bar.
  EdgeInsetsGeometry? margin;

  /// background color for the top menu bar.
  Color? backgroundColor;

  /// height for the top menu bar.
  double? height;

  /// You can listen to the event of clicking on the host information in the top left corner.
  /// For example, if you want to display a popup or dialog with host information after it is clicked.
  ///
  /// ```dart
  /// ..topMenuBarConfig.onHostAvatarClicked = (host) {
  ///   // do your own things.
  ///
  /// }
  /// ```
  void Function(ZegoUIKitUser host)? onHostAvatarClicked;

  /// You can customize the host icon widget in the top-left corner.
  /// If you don't want to display it, return Container().
  Widget Function(ZegoUIKitUser host)? hostAvatarBuilder;

  /// set false if you want to hide the close (exit the live streaming room) button.
  bool showCloseButton;

  ZegoTopMenuBarConfig({
    this.buttons = const [],
    this.padding,
    this.margin,
    this.backgroundColor,
    this.height,
    this.onHostAvatarClicked,
    this.hostAvatarBuilder,
    this.showCloseButton = true,
  });
}

/// Configuration options for the bottom menu bar (toolbar).
///
/// You can use the [ZegoUIKitPrebuiltLiveStreamingConfig.bottomMenuBarConfig] property to set the properties inside this class.
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

  /// padding for the bottom menu bar.
  EdgeInsetsGeometry? padding;

  /// margin for the bottom menu bar.
  EdgeInsetsGeometry? margin;

  /// background color for the bottom menu bar.
  Color? backgroundColor;

  /// height for the bottom menu bar.
  double? height;

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
    this.padding,
    this.margin,
    this.backgroundColor,
    this.height,
  });
}

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
class ZegoMenuBarExtendButton extends StatelessWidget {
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
  /// Definition of built-in buttons: an array of type List<[ZegoMenuBarButtonName]>.
  ///
  /// Definition of extension buttons: an array of type List<[ZegoMenuBarExtendButton]>.
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
///
/// You can use the [ZegoUIKitPrebuiltLiveStreamingConfig.bottomMenuBarConfig] -> [ZegoBottomMenuBarConfig.buttonStyle] property to set the properties inside this class.
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

/// Configuration for the member button of top bar.
class ZegoMemberButtonConfig {
  /// If you want to redefine the entire button, you can return your own Widget through [builder].
  Widget Function(int memberCount)? builder;

  /// Customize the icon through [icon], with Icons.person being the default if not set.
  Widget? icon;

  /// Customize the background color through [backgroundColor]
  Color? backgroundColor;

  ZegoMemberButtonConfig({
    this.builder,
    this.icon,
    this.backgroundColor,
  });
}

/// Configuration for the member list.
///
/// You can use the [ZegoUIKitPrebuiltLiveStreamingConfig.memberListConfig] property to set the properties inside this class.
///
/// If you want to use a custom member list item view, you can set the [ZegoMemberListConfig.itemBuilder] property, and pass your custom view's builder function to it.
///
/// For example, suppose you have implemented a `CustomMemberListItem` component that can render a member list item view based on the user information. You can set it up like this:
///
///```dart
/// ZegoMemberListConfig(
///   itemBuilder: (BuildContext context, Size size, ZegoUIKitUser user, Map<String, dynamic> extraInfo) {
///     return CustomMemberListItem(user: user);
///   },
/// );
///```
///
/// In this example, we pass the builder function of the custom view, `CustomMemberListItem`, to the [itemBuilder] property so that the member list item will be rendered using the custom component.
///
/// In addition, you can listen for item click events through [onClicked].
class ZegoMemberListConfig {
  /// Whether to show the microphone state of the member. Defaults to true, which means it will be shown.
  @Deprecated('Since 2.10.2, not support')
  bool showMicrophoneState;

  /// Whether to show the camera state of the member. Defaults to true, which means it will be shown.
  @Deprecated('Since 2.10.2, not support')
  bool showCameraState;

  /// Custom member list item view.
  ZegoMemberListItemBuilder? itemBuilder;

  /// You can listen to the user click event on the member list,
  /// for example, if you want to display specific information about a member after they are clicked.
  void Function(ZegoUIKitUser user)? onClicked;

  ZegoMemberListConfig({
    @Deprecated('Since 2.10.2, not support') this.showMicrophoneState = true,
    @Deprecated('Since 2.10.2, not support') this.showCameraState = true,
    this.itemBuilder,
    this.onClicked,
  });
}

/// Control options for the bottom-left message list.
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.inRoomMessageConfig] property.
///
/// If you want to customize chat messages, you can specify the [ZegoInRoomMessageConfig.itemBuilder].
///
/// Example:
/// ```dart
/// ZegoInRoomMessageConfig(
///   itemBuilder: (BuildContext context, ZegoRoomMessage message) {
///     return ListTile(
///       title: Text(message.message),
///       subtitle: Text(message.user.id),
///     );
///   },
///   opacity: 0.8,
/// );
///```
/// Of course, we also provide a range of styles for you to customize, such as display size, background color, font style, and so on.
class ZegoInRoomMessageConfig {
  /// Local message sending callback, This callback method is called when a message is sent successfully or fails to send.
  void Function(ZegoInRoomMessage message)? onLocalMessageSend;

  /// Triggered when has click on the message item
  ZegoInRoomMessageViewItemPressEvent? onMessageClick;

  /// Triggered when a pointer has remained in contact with the message item at
  /// the same location for a long period of time.
  ZegoInRoomMessageViewItemPressEvent? onMessageLongPress;

  /// Use this to customize the style and content of each chat message list item.
  /// For example, you can modify the background color, opacity, border radius, or add additional information like the sender's level or role.
  ZegoInRoomMessageItemBuilder? itemBuilder;

  /// A more granular builder for customizing the widget on the leading of the avatar part, default is empty.
  /// default message display widget = avatar + name + text
  /// Please note that if you use [itemBuilder], this builder will be ignored.
  ZegoInRoomMessageItemBuilder? avatarLeadingBuilder;

  /// A more granular builder for customizing the widget on the tailing of the avatar part, default is empty.
  /// default message display widget = avatar + name + text
  /// Please note that if you use [itemBuilder], this builder will be ignored.
  ZegoInRoomMessageItemBuilder? avatarTailingBuilder;

  /// A more granular builder for customizing the widget on the leading of the name part, default is empty.
  /// default message display widget = avatar + name + text
  /// Please note that if you use [itemBuilder], this builder will be ignored.
  ZegoInRoomMessageItemBuilder? nameLeadingBuilder;

  /// A more granular builder for customizing the widget on the tailing of the name part, default is empty.
  /// default message display widget = avatar + name + text
  /// Please note that if you use [itemBuilder], this builder will be ignored.
  ZegoInRoomMessageItemBuilder? nameTailingBuilder;

  /// A more granular builder for customizing the widget on the leading of the text part, default is empty.
  /// default message display widget = avatar + name + text
  /// Please note that if you use [itemBuilder], this builder will be ignored.
  ZegoInRoomMessageItemBuilder? textLeadingBuilder;

  /// A more granular builder for customizing the widget on the tailing of the text part, default is empty.
  /// default message display widget = avatar + name + text
  /// Please note that if you use [itemBuilder], this builder will be ignored.
  ZegoInRoomMessageItemBuilder? textTailingBuilder;

  /// Whether to display user join messages, default is not displayed
  bool notifyUserJoin;

  /// Whether to display user leave messages, default is not displayed
  bool notifyUserLeave;

  /// message attributes of local user, which will be appended to the message body.
  ///
  /// if set, [attributes] will be sent along with the message body.
  ///
  /// ``` dart
  ///  inRoomMessageConfig.attributes = {'k':'v'};
  ///  inRoomMessageConfig.itemBuilder = (
  ///    BuildContext context,
  ///    ZegoInRoomMessage message,
  ///    Map<String, dynamic> extraInfo,
  ///  ) {
  ///   final attributes = message.attributes;
  ///   return YouCustomMessageItem();
  ///  }
  /// ```
  Map<String, String> Function()? attributes;

  /// background
  Widget? background;

  /// display chat message list view or not
  bool visible;

  /// display user name in message list view or not
  bool showName;

  /// display user avatar in message list view or not
  bool showAvatar;

  /// The width of chat message list view
  double? width;

  /// The height of chat message list view
  double? height;

  /// The offset of chat message list view bottom-left position
  Offset? bottomLeft;

  /// The opacity of the background color for chat message list items, default value of 0.5.
  /// If you set the [backgroundColor], the [opacity] setting will be overridden.
  double opacity;

  /// The background of chat message list items
  /// If you set the [backgroundColor], the [opacity] setting will be overridden.
  /// You can use `backgroundColor.withOpacity(0.5)` to set the opacity of the background color.
  Color? backgroundColor;

  /// The max lines of chat message list items, default value is not limit.
  int? maxLines;

  /// The name text style of chat message list items
  TextStyle? nameTextStyle;

  /// The message text style of chat message list items
  TextStyle? messageTextStyle;

  /// The border radius of chat message list items
  BorderRadiusGeometry? borderRadius;

  /// The paddings of chat message list items
  EdgeInsetsGeometry? paddings;

  /// resend button icon
  Widget? resendIcon;

  ZegoInRoomMessageConfig({
    this.visible = true,
    this.notifyUserJoin = false,
    this.notifyUserLeave = false,
    this.attributes,
    this.width,
    this.height,
    this.bottomLeft,
    this.itemBuilder,
    this.avatarLeadingBuilder,
    this.avatarTailingBuilder,
    this.nameLeadingBuilder,
    this.nameTailingBuilder,
    this.textLeadingBuilder,
    this.textTailingBuilder,
    this.opacity = 0.5,
    this.maxLines,
    this.nameTextStyle,
    this.messageTextStyle,
    this.backgroundColor,
    this.borderRadius,
    this.paddings,
    this.resendIcon,
    this.background,
    this.onLocalMessageSend,
    this.onMessageClick,
    this.onMessageLongPress,
    this.showName = true,
    this.showAvatar = true,
  });
}

@Deprecated('Since 2.10.7, please use ZegoInRoomMessageConfig instead')
typedef ZegoInRoomMessageViewConfig = ZegoInRoomMessageConfig;

/// Configuration options for voice changer, beauty effects and reverberation effects.
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.effectConfig] property.
///
/// If you want to replace icons and colors to sheet or slider, some of our widgets also provide modification options.
///
/// Example:
///
/// ```dart
/// ZegoEffectConfig(
///   backgroundColor: Colors.black.withOpacity(0.5),
///   backIcon: Icon(Icons.arrow_back),
///   sliderTextBackgroundColor: Colors.black.withOpacity(0.5),
/// );
/// ```
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

  /// the background color of the sheet.
  Color? backgroundColor;

  /// the text style of the head title sheet.
  TextStyle? headerTitleTextStyle;

  /// back button icon on the left side of the title.
  Widget? backIcon;

  /// reset button icon on the right side of the title.
  Widget? resetIcon;

  /// color of the icons in the normal (unselected) state.
  Color? normalIconColor;

  /// color of the icons in the highlighted (selected) state.
  Color? selectedIconColor;

  /// border color of the icons in the normal (unselected) state.
  Color? normalIconBorderColor;

  /// border color of the icons in the highlighted (selected) state.
  Color? selectedIconBorderColor;

  /// text-style of buttons in the highlighted (selected) state.
  TextStyle? selectedTextStyle;

  /// text-style of buttons in the normal (unselected) state.
  TextStyle? normalTextStyle;

  /// the style of the text displayed on the Slider's thumb
  TextStyle? sliderTextStyle;

  /// the background color of the text displayed on the Slider's thumb.
  Color? sliderTextBackgroundColor;

  ///  the color of the track that is active when sliding the Slider.
  Color? sliderActiveTrackColor;

  /// the color of the track that is inactive when sliding the Slider.
  Color? sliderInactiveTrackColor;

  /// the color of the Slider's thumb.
  Color? sliderThumbColor;

  /// the radius of the Slider's thumb.
  double? sliderThumbRadius;

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
    this.backgroundColor,
    this.headerTitleTextStyle,
    this.backIcon,
    this.resetIcon,
    this.selectedIconBorderColor,
    this.normalIconBorderColor,
    this.selectedTextStyle,
    this.normalTextStyle,
    this.sliderTextStyle,
    this.sliderTextBackgroundColor,
    this.sliderActiveTrackColor,
    this.sliderInactiveTrackColor,
    this.sliderThumbColor,
    this.sliderThumbRadius,
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

/// Used to configure the parameters related to PK battles
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.pkBattleConfig] property.
@Deprecated(
    'Since 2.23.0,Please use [ZegoUIKitPrebuiltLiveStreamingController.pkV2], '
    '[ZegoUIKitPrebuiltLiveStreamingEvents.pkV2Events], '
    '[ZegoLiveStreamingPKBattleV2Config] instead')
class ZegoLiveStreamingPKBattleConfig {
  /// The distance that the pkBattleEvents's top edge is inset from the top of the stack.
  /// default is 164.r
  double? pKBattleViewTopPadding;

  /// When the connected host gets offline due to exceptions, SDK defaults to show "Host is reconnecting".
  /// To customize the content that displays when the connected host gets offline.
  ZegoLiveStreamingPKBattleHostReconnectingBuilder? hostReconnectingBuilder;

  /// To overlay custom components on the PKBattleView.
  ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewForegroundBuilder;

  /// To add custom components on the top edge of the PKBattleView.
  ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewTopBuilder;

  /// To add custom components on the bottom edge of the PKBattleView.
  ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewBottomBuilder;
}

/// Used to configure the parameters related to PK battles
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.pkBattleV2Config] property.
class ZegoLiveStreamingPKBattleV2Config {
  /// If the connection with a PK user is lost for a [userReconnectingSecond] period of time,
  /// it will trigger [hostReconnectingBuilder], which waits for the user to reconnect.
  ///
  /// default value is 5 seconds.
  ///
  /// [ZegoUIKitPrebuiltLiveStreamingPKV2Events.onUserReconnecting] will be triggered
  int userReconnectingSecond;

  /// When a PK user loses connection for more than [userDisconnectedSecond],
  /// they will be automatically kicked out of the PK.
  ///
  /// default value is 90 seconds.
  ///
  /// [ZegoUIKitPrebuiltLiveStreamingPKV2Events.onUserDisconnected] will be triggered
  int userDisconnectedSecond;

  /// The distance that the pkBattleEvents's top edge is inset from the top of the stack.
  /// default is 164.r
  double? pKBattleViewTopPadding;

  /// you can custom coordinates and modify the PK layout.
  ZegoPKV2MixerLayout? mixerLayout;

  /// When the connected host gets offline due to exceptions, SDK defaults to show "Host is reconnecting".
  /// To customize the content that displays when the connected host gets offline.
  ZegoLiveStreamingPKBattleHostReconnectingBuilder? hostReconnectingBuilder;

  /// To overlay custom components on the PKBattleView.
  ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewForegroundBuilder;

  /// To add custom components on the top edge of the PKBattleView.
  ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewTopBuilder;

  /// To add custom components on the bottom edge of the PKBattleView.
  ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewBottomBuilder;

  ZegoLiveStreamingPKBattleV2Config({
    this.userReconnectingSecond = 5,
    this.userDisconnectedSecond = 90,
    this.mixerLayout,
    this.pKBattleViewTopPadding,
    this.hostReconnectingBuilder,
    this.pkBattleViewForegroundBuilder,
    this.pkBattleViewTopBuilder,
    this.pkBattleViewBottomBuilder,
  });
}

/// Used to configure the parameters related to the preview of the live streaming.
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.previewConfig] property.
class ZegoLiveStreamingPreviewConfig {
  /// Whether to show the preview page for the host. The default value is true.
  bool showPreviewForHost;

  /// The icon for the page back button.
  ///
  /// You can customize the icon for the page back button as shown in the example below:
  /// ```dart
  /// ZegoLiveStreamingPreviewConfig(
  ///   pageBackIcon: Icon(Icons.arrow_back),
  /// );
  /// ```
  Widget? pageBackIcon;

  /// The icon for the beauty effect button.
  ///
  /// You can customize the icon for the beauty effect button as shown in the example below:
  /// ```dart
  /// ZegoLiveStreamingPreviewConfig(
  ///   beautyEffectIcon: Icon(Icons.face),
  /// );
  /// ```
  Widget? beautyEffectIcon;

  /// The icon for the switch camera button.
  ///
  /// You can customize the icon for the switch camera button as shown in the example below:
  /// ```dart
  /// ZegoLiveStreamingPreviewConfig(
  ///   switchCameraIcon: Icon(Icons.switch_camera),
  /// );
  /// ```
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
  /// Example: Set to automatically leave after 5 minutes.
  ///```dart
  /// ..durationConfig.isVisible = true
  /// ..durationConfig.onDurationUpdate = (Duration duration) {
  ///   if (duration.inSeconds >= 5 * 60) {
  ///     liveController?.leave(context);
  ///   }
  /// }
  /// ```
  void Function(Duration)? onDurationUpdate;

  ZegoLiveDurationConfig({
    this.isVisible = true,
    this.onDurationUpdate,
  });
}
