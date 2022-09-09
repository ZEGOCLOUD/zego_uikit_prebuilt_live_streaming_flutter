// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'live_streaming_defines.dart';

class ZegoUIKitPrebuiltLiveStreamingConfig {
  ZegoUIKitPrebuiltLiveStreamingConfig.host()
      : turnOnCameraWhenJoining = true,
        turnOnMicrophoneWhenJoining = true,
        useSpeakerWhenJoining = true,
        showInRoomMessageButton = true,
        audioVideoViewConfig = ZegoAudioVideoViewConfig(
          showSoundWavesInAudioMode: true,
        ),
        bottomMenuBarConfig = ZegoBottomMenuBarConfig(
          buttons: const [
            ZegoLiveMenuBarButtonName.toggleCameraButton,
            ZegoLiveMenuBarButtonName.toggleMicrophoneButton,
            ZegoLiveMenuBarButtonName.switchCameraButton,
          ],
          maxCount: 5,
        );

  ZegoUIKitPrebuiltLiveStreamingConfig.audience()
      : turnOnCameraWhenJoining = false,
        turnOnMicrophoneWhenJoining = false,
        useSpeakerWhenJoining = true,
        showInRoomMessageButton = true,
        audioVideoViewConfig = ZegoAudioVideoViewConfig(
          showSoundWavesInAudioMode: true,
        ),
        bottomMenuBarConfig = ZegoBottomMenuBarConfig(
          buttons: const [],
          maxCount: 5,
        );

  ZegoUIKitPrebuiltLiveStreamingConfig({
    this.turnOnCameraWhenJoining = true,
    this.turnOnMicrophoneWhenJoining = true,
    this.useSpeakerWhenJoining = true,
    ZegoAudioVideoViewConfig? audioVideoViewConfig,
    ZegoBottomMenuBarConfig? bottomMenuBarConfig,
    this.showInRoomMessageButton = true,
    this.confirmDialogInfo,
    this.onLeaveLiveStreamingConfirmation,
    this.onLeaveLiveStreaming,
  })  : audioVideoViewConfig =
            audioVideoViewConfig ?? ZegoAudioVideoViewConfig(),
        bottomMenuBarConfig = bottomMenuBarConfig ?? ZegoBottomMenuBarConfig();

  /// whether to enable the camera by default, the default value is true
  bool turnOnCameraWhenJoining;

  /// whether to enable the microphone by default, the default value is true
  bool turnOnMicrophoneWhenJoining;

  /// whether to use the speaker by default, the default value is true;
  bool useSpeakerWhenJoining;

  /// configs about audio video view
  ZegoAudioVideoViewConfig audioVideoViewConfig;

  /// configs about bottom menu bar
  ZegoBottomMenuBarConfig bottomMenuBarConfig;

  ///
  bool showInRoomMessageButton;

  /// alert dialog information of leave
  /// if confirm info is not null, APP will pop alert dialog when you hang up
  LiveStreamingConfirmDialogInfo? confirmDialogInfo;

  /// It is often used to customize the process before exiting the live interface.
  /// The liveback will triggered when user click hang up button or use system's return,
  /// If you need to handle custom logic, you can set this liveback to handle (such as showAlertDialog to let user determine).
  /// if you return true in the liveback, prebuilt page will quit and return to your previous page, otherwise will ignore.
  Future<bool> Function(BuildContext context)? onLeaveLiveStreamingConfirmation;

  /// customize handling after leave live streaming
  VoidCallback? onLeaveLiveStreaming;
}

class ZegoAudioVideoViewConfig {
  /// video view mode
  /// if set to true, video view will proportional zoom fills the entire View and may be partially cut
  /// if set to false, video view proportional scaling up, there may be black borders
  bool useVideoViewAspectFill;

  /// hide avatar of audio video view if set false
  bool showAvatarInAudioMode;

  /// hide sound level of audio video view if set false
  bool showSoundWavesInAudioMode;

  /// customize your foreground of audio video view, which is the top widget of stack
  /// <br><img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/_default_avatar_nowave.jpg" width="5%">
  /// you can return any widget, then we will put it on top of audio video view
  AudioVideoViewForegroundBuilder? foregroundBuilder;

  /// customize your background of audio video view, which is the bottom widget of stack
  AudioVideoViewBackgroundBuilder? backgroundBuilder;

  /// customize your user's avatar, default we use userID's first character as avatar
  /// User avatars are generally stored in your server, ZegoUIkitPrebuiltLive does not know each user's avatar, so by default, ZegoUIkitPrebuiltLive will use the first letter of the user name to draw the default user avatar, as shown in the following figure,
  ///
  /// |When the user is not speaking|When the user is speaking|
  /// |--|--|
  /// |<img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/_default_avatar_nowave.jpg" width="10%">|<img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/_default_avatar.jpg" width="10%">|
  ///
  /// If you need to display the real avatar of your user, you can use the avatarBuilder to set the user avatar builder method (set user avatar widget builder), the usage is as follows:
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
  AudioVideoViewAvatarBuilder? avatarBuilder;

  ZegoAudioVideoViewConfig({
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarBuilder,
    this.showAvatarInAudioMode = true,
    this.showSoundWavesInAudioMode = true,
    this.useVideoViewAspectFill = true,
  });
}

class ZegoBottomMenuBarConfig {
  /// these buttons will displayed on the menu bar, order by the list
  List<ZegoLiveMenuBarButtonName> buttons;

  /// limited item count display on menu bar,
  /// if this count is exceeded, More button is displayed
  int maxCount;

  /// these buttons will sequentially added to menu bar,
  /// and auto added extra buttons to the pop-up menu
  /// when the limit [maxCount] is exceeded
  List<Widget> extendButtons;

  ZegoBottomMenuBarConfig({
    this.buttons = const [],
    this.maxCount = 5,
    this.extendButtons = const [],
  });
}

class LiveStreamingConfirmDialogInfo {
  String title;
  String message;
  String cancelButtonName;
  String confirmButtonName;

  LiveStreamingConfirmDialogInfo({
    this.title = "End to confirm",
    this.message = "Do you want to end?",
    this.cancelButtonName = "Cancel",
    this.confirmButtonName = "Confirm",
  });
}
