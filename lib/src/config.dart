// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'config.defines.dart';
import 'defines.dart';
import 'deprecated/v3/v3.dart';
import 'inner_text.dart';
import 'modules/pk/layout/layout.dart';
import 'modules/swiping/defines.dart';

/// Configuration for initializing the Live Streaming
///
/// This class is used as the [ZegoUIKitPrebuiltLiveStreaming.config] parameter for the constructor of [ZegoUIKitPrebuiltLiveStreaming].
class ZegoUIKitPrebuiltLiveStreamingConfig {
  /// configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
  ZegoUIKitVideoConfig video;

  /// Configuration options for audio/video views.
  ZegoLiveStreamingAudioVideoViewConfig audioVideoView;

  /// Configuration options for media player.
  ZegoLiveStreamingMediaPlayerConfig mediaPlayer;

  /// screen sharing
  ZegoLiveStreamingScreenSharingConfig screenSharing;

  /// pip
  ZegoLiveStreamingPIPConfig pip;

  /// Configuration options for the top menu bar (toolbar).
  ///
  /// You can use these options to customize the appearance and behavior of the top menu bar.
  ZegoLiveStreamingTopMenuBarConfig topMenuBar;

  /// Configuration options for the bottom menu bar (toolbar).
  ///
  /// You can use these options to customize the appearance and behavior of the bottom menu bar.
  ZegoLiveStreamingBottomMenuBarConfig bottomMenuBar;

  /// Configuration related to the top member button
  ZegoLiveStreamingMemberButtonConfig memberButton;

  /// Configuration related to the bottom member list, including displaying the member list, member list styles, and more.
  ZegoLiveStreamingMemberListConfig memberList;

  /// Control options for the bottom-left message list.
  ZegoLiveStreamingInRoomMessageConfig inRoomMessage;

  /// Configuration options for voice changer, beauty effects and reverberation effects.
  ZegoLiveStreamingEffectConfig effect;

  /// Used to configure the parameters related to the preview of the live streaming.
  ZegoLiveStreamingPreviewConfig preview;

  /// the live hall, which is displayed outside and does not belong to the
  /// [ZegoUIKitPrebuiltLiveStreaming]
  /// Used to configure the parameters related to the preview list of the live streaming.
  ///
  /// you can see [Document](https://www.zegocloud.com/docs/uikit/live.streaming.kit-flutter/enhance-the-livestream/live-list) here
  ZegoLiveStreamingHallConfig hall;

  /// swiping config, if you wish to use swiping, please configure this config.
  /// if it is null, this swiping will not be enabled.
  /// the `liveID` will be the initial live id of swiping
  ZegoLiveStreamingSwipingConfig? swiping;

  /// Used to configure the parameters related to PK battles
  /// if you want to listen event, please refer [ZegoUIKitPrebuiltLiveStreamingEvents.pk]
  ///
  /// you can see [Document](https://www.zegocloud.com/docs/uikit/live.streaming.kit-flutter/enhance-the-livestream/pk-battles) here
  ZegoLiveStreamingPKBattleConfig pkBattle;

  /// Live Streaming timing configuration.
  ///
  /// To calculate the livestream duration, do the following:
  /// 1. Set the [ZegoLiveStreamingDurationConfig.isVisible] property of [ZegoLiveStreamingDurationConfig] to display the current timer. (It is displayed by default)
  /// 2. Assuming that the livestream duration is 5 minutes, the livestream will automatically end when the time is up (refer to the following code). You will be notified of the end of the livestream duration through [ZegoLiveStreamingDurationEvents.onUpdated]. To end the livestream, you can call the [ZegoUIKitPrebuiltLiveStreamingController.leave()] method.
  ///
  /// ```dart
  ///  ..duration.isVisible = true
  /// ```
  ///
  /// you can see [Document](https://www.zegocloud.com/docs/uikit/live.streaming.kit-flutter/customize-the-livestream/calculate-live-duration) here
  ///
  ///<img src = "https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/live/live_duration.jpeg" width=200 />
  ZegoLiveStreamingDurationConfig duration;

  ZegoLiveStreamingSignalingPluginConfig signalingPlugin;

  /// advance beauty config
  ///
  /// you can see [Document](https://www.zegocloud.com/docs/uikit/live.streaming.kit-flutter/enhance-the-livestream/advanced-beauty-effects) here
  ZegoBeautyPluginConfig? beauty;

  /// co-cohost config
  ZegoLiveStreamingCoHostConfig coHost;

  /// Specifies the initial role when joining the live streaming.
  /// The role change after joining is not constrained by this property.
  ZegoLiveStreamingRole role = ZegoLiveStreamingRole.audience;

  /// Plugins, currently supports signaling, beauty.
  /// if you need cohost function, you need to install `ZegoUIKitSignalingPlugin`
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

  /// if you want to join the live streaming with your front camera, set this value to true.
  /// The default value is `true`.
  bool useFrontFacingCamera;

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
  ZegoLiveStreamingDialogInfo? confirmDialogInfo;

  /// Configuration options for modifying all text content on the UI.
  ///
  /// All visible text content on the UI can be modified using this single property.
  ZegoUIKitPrebuiltLiveStreamingInnerText innerText;

  /// Layout-related configuration. You can choose your layout here. such as `ZegoLayout.gallery()`
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
  ///  that mean `toUserIDs` of sendInRoomCommand function is disabled if true
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

  /// show background tips of live or not, default tips is 'No host is online.'
  bool showBackgroundTips;

  /// Set advanced engine configuration, Used to enable advanced functions.
  /// For details, please consult ZEGO technical support.
  Map<String, String> advanceConfigs;

  /// audio video resource mode for audience
  ZegoUIKitStreamResourceMode? audienceAudioVideoResourceMode;

  bool showToast;

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
        useFrontFacingCamera = true,
        turnOnMicrophoneWhenJoining = true,
        useSpeakerWhenJoining = true,
        markAsLargeRoom = false,
        slideSurfaceToHide = true,
        rootNavigator = false,
        showBackgroundTips = false,
        advanceConfigs = {},
        showToast = false,
        mediaPlayer = ZegoLiveStreamingMediaPlayerConfig(),
        screenSharing = ZegoLiveStreamingScreenSharingConfig(),
        pip = ZegoLiveStreamingPIPConfig(),
        video = ZegoVideoConfigExtension.preset360P(),
        audioVideoView = ZegoLiveStreamingAudioVideoViewConfig(
          showSoundWavesInAudioMode: true,
        ),
        topMenuBar = ZegoLiveStreamingTopMenuBarConfig(),
        bottomMenuBar = ZegoLiveStreamingBottomMenuBarConfig(
          audienceButtons: plugins?.isEmpty ?? true
              ? []
              //  host maybe change to be an audience
              : const [ZegoLiveStreamingMenuBarButtonName.coHostControlButton],
        ),
        memberButton = ZegoLiveStreamingMemberButtonConfig(),
        memberList = ZegoLiveStreamingMemberListConfig(),
        inRoomMessage = ZegoLiveStreamingInRoomMessageConfig(),
        effect = ZegoLiveStreamingEffectConfig(),
        innerText = ZegoUIKitPrebuiltLiveStreamingInnerText(),
        confirmDialogInfo = ZegoLiveStreamingDialogInfo(
          title: 'Stop the live',
          message: 'Are you sure to stop the live?',
          cancelButtonName: 'Cancel',
          confirmButtonName: 'Stop it',
        ),
        preview = ZegoLiveStreamingPreviewConfig(),
        hall = ZegoLiveStreamingHallConfig(),
        pkBattle = ZegoLiveStreamingPKBattleConfig(),
        duration = ZegoLiveStreamingDurationConfig(),
        signalingPlugin = ZegoLiveStreamingSignalingPluginConfig(),
        coHost = ZegoLiveStreamingCoHostConfig(
          stopCoHostingWhenMicCameraOff: false,
          disableCoHostInvitationReceivedDialog: false,
        ) {
    coHost.turnOnCameraWhenCohosted = () {
      return true;
    };
  }

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
  ZegoUIKitPrebuiltLiveStreamingConfig.audience({
    List<IZegoUIKitPlugin>? plugins,
  })  : role = ZegoLiveStreamingRole.audience,
        plugins = plugins ?? [],
        turnOnCameraWhenJoining = false,
        useFrontFacingCamera = true,
        turnOnMicrophoneWhenJoining = false,
        useSpeakerWhenJoining = true,
        markAsLargeRoom = false,
        slideSurfaceToHide = true,
        rootNavigator = false,
        showBackgroundTips = false,
        advanceConfigs = {},
        showToast = false,
        mediaPlayer = ZegoLiveStreamingMediaPlayerConfig(),
        screenSharing = ZegoLiveStreamingScreenSharingConfig(),
        pip = ZegoLiveStreamingPIPConfig(),
        video = ZegoVideoConfigExtension.preset360P(),
        audioVideoView = ZegoLiveStreamingAudioVideoViewConfig(
          showSoundWavesInAudioMode: true,
        ),
        topMenuBar = ZegoLiveStreamingTopMenuBarConfig(),
        bottomMenuBar = ZegoLiveStreamingBottomMenuBarConfig(
          audienceButtons: plugins?.isEmpty ?? true
              ? []
              : const [ZegoLiveStreamingMenuBarButtonName.coHostControlButton],
        ),
        memberButton = ZegoLiveStreamingMemberButtonConfig(),
        memberList = ZegoLiveStreamingMemberListConfig(),
        inRoomMessage = ZegoLiveStreamingInRoomMessageConfig(),
        effect = ZegoLiveStreamingEffectConfig(),
        innerText = ZegoUIKitPrebuiltLiveStreamingInnerText(),
        preview = ZegoLiveStreamingPreviewConfig(),
        hall = ZegoLiveStreamingHallConfig(),
        pkBattle = ZegoLiveStreamingPKBattleConfig(),
        duration = ZegoLiveStreamingDurationConfig(),
        signalingPlugin = ZegoLiveStreamingSignalingPluginConfig(),
        coHost = ZegoLiveStreamingCoHostConfig(
          stopCoHostingWhenMicCameraOff: false,
          disableCoHostInvitationReceivedDialog: false,
        ) {
    coHost.turnOnCameraWhenCohosted = () {
      return true;
    };
  }

  ZegoUIKitPrebuiltLiveStreamingConfig({
    this.turnOnCameraWhenJoining = true,
    this.useFrontFacingCamera = true,
    this.turnOnMicrophoneWhenJoining = true,
    this.useSpeakerWhenJoining = true,
    this.markAsLargeRoom = false,
    this.slideSurfaceToHide = true,
    this.rootNavigator = false,
    this.showBackgroundTips = false,
    this.advanceConfigs = const {},
    this.layout,
    this.foreground,
    this.background,
    this.confirmDialogInfo,
    this.beauty,
    this.swiping,
    this.avatarBuilder,
    this.audienceAudioVideoResourceMode,
    this.showToast = false,
    @Deprecated('Use coHost.maxCoHostCount instead$deprecatedTipsV340')
    int? maxCoHostCount,
    @Deprecated(
        'Use coHost.stopCoHostingWhenMicCameraOff instead$deprecatedTipsV340')
    bool? stopCoHostingWhenMicCameraOff,
    @Deprecated(
        'Use coHost.disableCoHostInvitationReceivedDialog instead$deprecatedTipsV340')
    bool? disableCoHostInvitationReceivedDialog,
    @Deprecated(
        'Use coHost.turnOnCameraWhenCohosted instead$deprecatedTipsV340')
    bool Function()? turnOnCameraWhenCohosted,
    ZegoUIKitPrebuiltLiveStreamingInnerText? translationText,
    ZegoUIKitVideoConfig? video,
    ZegoLiveStreamingAudioVideoViewConfig? audioVideoView,
    ZegoLiveStreamingEffectConfig? effect,
    ZegoLiveStreamingMemberListConfig? memberList,
    ZegoLiveStreamingMemberButtonConfig? memberButton,
    ZegoLiveStreamingDurationConfig? duration,
    ZegoLiveStreamingSignalingPluginConfig? signalingPlugin,
    ZegoLiveStreamingInRoomMessageConfig? message,
    ZegoLiveStreamingTopMenuBarConfig? topMenuBar,
    ZegoLiveStreamingBottomMenuBarConfig? bottomMenuBar,
    ZegoLiveStreamingPreviewConfig? preview,
    ZegoLiveStreamingHallConfig? hall,
    ZegoLiveStreamingPKBattleConfig? pkBattle,
    ZegoLiveStreamingMediaPlayerConfig? media,
    ZegoLiveStreamingScreenSharingConfig? screenSharing,
    ZegoLiveStreamingPIPConfig? pip,
    ZegoLiveStreamingCoHostConfig? coHost,
  })  : mediaPlayer = media ?? ZegoLiveStreamingMediaPlayerConfig(),
        screenSharing = screenSharing ?? ZegoLiveStreamingScreenSharingConfig(),
        pip = pip ?? ZegoLiveStreamingPIPConfig(),
        video = video ?? ZegoVideoConfigExtension.preset360P(),
        audioVideoView =
            audioVideoView ?? ZegoLiveStreamingAudioVideoViewConfig(),
        topMenuBar = topMenuBar ?? ZegoLiveStreamingTopMenuBarConfig(),
        bottomMenuBar = bottomMenuBar ?? ZegoLiveStreamingBottomMenuBarConfig(),
        memberList = memberList ?? ZegoLiveStreamingMemberListConfig(),
        memberButton = memberButton ?? ZegoLiveStreamingMemberButtonConfig(),
        inRoomMessage = message ?? ZegoLiveStreamingInRoomMessageConfig(),
        effect = effect ?? ZegoLiveStreamingEffectConfig(),
        innerText =
            translationText ?? ZegoUIKitPrebuiltLiveStreamingInnerText(),
        preview = preview ?? ZegoLiveStreamingPreviewConfig(),
        hall = hall ?? ZegoLiveStreamingHallConfig(),
        pkBattle = pkBattle ?? ZegoLiveStreamingPKBattleConfig(),
        duration = duration ?? ZegoLiveStreamingDurationConfig(),
        signalingPlugin =
            signalingPlugin ?? ZegoLiveStreamingSignalingPluginConfig(),
        coHost = coHost ?? ZegoLiveStreamingCoHostConfig() {
    this.coHost.turnOnCameraWhenCohosted = turnOnCameraWhenCohosted ??
        () {
          return true;
        };
    if (null != maxCoHostCount) {
      this.coHost.maxCoHostCount = maxCoHostCount;
    }
    if (null != stopCoHostingWhenMicCameraOff) {
      this.coHost.stopCoHostingWhenMicCameraOff = stopCoHostingWhenMicCameraOff;
    }
    if (null != disableCoHostInvitationReceivedDialog) {
      this.coHost.disableCoHostInvitationReceivedDialog =
          disableCoHostInvitationReceivedDialog;
    }

    layout ??= ZegoLayout.pictureInPicture();
  }

  @override
  String toString() {
    return '{'
        'video:$video, '
        'audioVideoView:$audioVideoView, '
        'mediaPlayer:$mediaPlayer, '
        'screenSharing:$screenSharing, '
        'pip:$pip, '
        'topMenuBar:$topMenuBar, '
        'bottomMenuBar:$bottomMenuBar, '
        'memberButton:$memberButton, '
        'memberList:$memberList, '
        'inRoomMessage:$inRoomMessage, '
        'effect:$effect, '
        'preview:$preview, '
        'hall:$hall, '
        'pkBattle:$pkBattle, '
        'duration:$duration, '
        'signalingPlugin:$signalingPlugin, '
        'swiping:$swiping, '
        'coHost:$coHost, '
        'role:$role, '
        'plugins:$plugins, '
        'turnOnCameraWhenJoining:$turnOnCameraWhenJoining, '
        'useFrontFacingCamera:$useFrontFacingCamera, '
        'turnOnMicrophoneWhenJoining:$turnOnMicrophoneWhenJoining, '
        'useSpeakerWhenJoining:$useSpeakerWhenJoining, '
        'innerText:$innerText, '
        'rootNavigator:$rootNavigator, '
        'markAsLargeRoom:$markAsLargeRoom, '
        'slideSurfaceToHide:$slideSurfaceToHide, '
        'showBackgroundTips:$showBackgroundTips, '
        'advanceConfigs:$advanceConfigs, '
        'showToast:$showToast, '
        'beauty:${beauty != null}, '
        'confirmDialogInfo:${confirmDialogInfo != null}, '
        'layout:${layout != null}, '
        'avatarBuilder:${avatarBuilder != null}, '
        'foreground:${foreground != null}, '
        'background:${background != null}, '
        'audienceAudioVideoResourceMode:${audienceAudioVideoResourceMode != null}, '
        '}';
  }
}

/// Configuration options for audio/video views.
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.audioVideoView] property.
///
/// These options allow you to customize the display effects of the audio/video views, such as showing microphone status and usernames.
///
/// If you need to customize the foreground or background of the audio/video view, you can use [foregroundBuilder] and [backgroundBuilder].
///
/// If you want to hide user avatars or sound waveforms in audio mode, you can set [showAvatarInAudioMode] and [showSoundWavesInAudioMode] to false.
class ZegoLiveStreamingAudioVideoViewConfig {
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

  /// Whether to display the microphone state on the audio/video view when closed.
  ///
  /// Set it to false if you don't want to show on the audio/video view.
  bool showMicrophoneStateOnView;

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

  /// Custom audio/video view. ( not for PK!! )
  /// If you don't want to use the default view components, you can pass a custom component through this parameter.
  /// and if return null, will be display the default view
  ZegoLiveStreamingAudioVideoContainerBuilder? containerBuilder;

  /// Specify the rect of the audio & video container.
  /// If not specified, it defaults to display full.
  Rect Function()? containerRect;

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

  ZegoLiveStreamingAudioVideoViewConfig({
    this.isVideoMirror = true,
    this.showMicrophoneStateOnView = true,
    this.showUserNameOnView = true,
    this.showAvatarInAudioMode = true,
    this.showSoundWavesInAudioMode = true,
    this.useVideoViewAspectFill = true,
    this.visible,
    this.playCoHostAudio,
    this.playCoHostVideo,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.containerBuilder,
    this.containerRect,
  });

  @override
  String toString() {
    return '{'
        'visible:${visible != null}, '
        'playCoHostAudio:${playCoHostAudio != null}, '
        'playCoHostVideo:${playCoHostVideo != null}, '
        'isVideoMirror:$isVideoMirror, '
        'showMicrophoneStateOnView:$showMicrophoneStateOnView, '
        'showUserNameOnView:$showUserNameOnView, '
        'useVideoViewAspectFill:$useVideoViewAspectFill, '
        'showAvatarInAudioMode:$showAvatarInAudioMode, '
        'showSoundWavesInAudioMode:$showSoundWavesInAudioMode, '
        'containerBuilder:${containerBuilder != null}, '
        'containerRect:${containerRect != null}, '
        'foregroundBuilder:${foregroundBuilder != null}, '
        'backgroundBuilder:${backgroundBuilder != null}, '
        '}';
  }
}

/// Configuration options for the top menu bar (toolbar).
class ZegoLiveStreamingTopMenuBarConfig {
  /// These buttons will displayed on the menu bar, order by the list
  /// only support `ZegoLiveStreamingMenuBarButtonName.minimizingButton` right now
  List<ZegoLiveStreamingMenuBarButtonName> buttons;

  /// padding for the top menu bar.
  EdgeInsetsGeometry? padding;

  /// margin for the top menu bar.
  EdgeInsetsGeometry? margin;

  /// background color for the top menu bar.
  Color? backgroundColor;

  /// height for the top menu bar.
  double? height;

  /// You can customize the host icon widget in the top-left corner.
  /// If you don't want to display it, return Container().
  Widget Function(ZegoUIKitUser host)? hostAvatarBuilder;

  /// set false if you want to hide the close (exit the live streaming room) button.
  bool showCloseButton;

  ZegoLiveStreamingTopMenuBarConfig({
    this.buttons = const [],
    this.padding,
    this.margin,
    this.backgroundColor,
    this.height,
    this.hostAvatarBuilder,
    this.showCloseButton = true,
  });

  @override
  String toString() {
    return '{'
        'buttons:$buttons, '
        'padding:$padding, '
        'margin:$margin, '
        'backgroundColor:$backgroundColor, '
        'height:$height, '
        'hostAvatarBuilder:${hostAvatarBuilder != null}, '
        'showCloseButton:$showCloseButton, '
        '}';
  }
}

/// Configuration options for the bottom menu bar (toolbar).
///
/// You can use the [ZegoUIKitPrebuiltLiveStreamingConfig.bottomMenuBar] property to set the properties inside this class.
class ZegoLiveStreamingBottomMenuBarConfig {
  /// Whether to display the room message button.
  bool showInRoomMessageButton;

  /// The list of predefined buttons to be displayed when the user role is set to host.
  List<ZegoLiveStreamingMenuBarButtonName> hostButtons = [];

  /// The list of predefined buttons to be displayed when the user role is set to co-host.
  List<ZegoLiveStreamingMenuBarButtonName> coHostButtons = [];

  /// The list of predefined buttons to be displayed when the user role is set to audience.
  List<ZegoLiveStreamingMenuBarButtonName> audienceButtons = [];

  /// List of extension buttons for the host.
  /// These buttons will be added to the menu bar in the specified order and automatically added to the overflow menu when the [maxCount] limit is exceeded.
  ///
  /// If you want to place the extension buttons before the built-in buttons, you can achieve this by setting the index parameter of the ZegoMenuBarExtendButton.
  /// For example, if you want to place an extension button at the very beginning of the built-in buttons, you can set the index of that extension button to 0.
  /// Please refer to the definition of ZegoMenuBarExtendButton for implementation details.
  List<ZegoLiveStreamingMenuBarExtendButton> hostExtendButtons = [];

  /// List of extension buttons for the co-hosts.
  /// These buttons will be added in the same way as the hostExtendButtons.
  List<ZegoLiveStreamingMenuBarExtendButton> coHostExtendButtons = [];

  /// List of extension buttons for the audience.
  /// These buttons will be added in the same way as the hostExtendButtons.
  List<ZegoLiveStreamingMenuBarExtendButton> audienceExtendButtons = [];

  /// Controls the maximum number of buttons (including predefined and custom buttons) to be displayed in the menu bar (toolbar).
  /// When the number of buttons exceeds the `maxCount` limit, a "More" button will appear.
  /// Clicking on it will display a panel showing other buttons that cannot be displayed in the menu bar (toolbar).
  int maxCount;

  /// Button style for the bottom menu bar.
  ZegoLiveStreamingBottomMenuBarButtonStyle? buttonStyle;

  /// padding for the bottom menu bar.
  EdgeInsetsGeometry? padding;

  /// margin for the bottom menu bar.
  EdgeInsetsGeometry? margin;

  /// background color for the bottom menu bar.
  Color? backgroundColor;

  /// height for the bottom menu bar.
  double? height;

  ZegoLiveStreamingBottomMenuBarConfig({
    this.showInRoomMessageButton = true,
    this.hostButtons = const [
      ZegoLiveStreamingMenuBarButtonName.beautyEffectButton,
      ZegoLiveStreamingMenuBarButtonName.soundEffectButton,
      ZegoLiveStreamingMenuBarButtonName.switchCameraButton,
      ZegoLiveStreamingMenuBarButtonName.toggleCameraButton,
      ZegoLiveStreamingMenuBarButtonName.toggleMicrophoneButton,
    ],
    this.coHostButtons = const [
      ZegoLiveStreamingMenuBarButtonName.switchCameraButton,
      ZegoLiveStreamingMenuBarButtonName.toggleCameraButton,
      ZegoLiveStreamingMenuBarButtonName.toggleMicrophoneButton,
      ZegoLiveStreamingMenuBarButtonName.coHostControlButton,
      ZegoLiveStreamingMenuBarButtonName.beautyEffectButton,
      ZegoLiveStreamingMenuBarButtonName.soundEffectButton,
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

  @override
  String toString() {
    return '{'
        'showInRoomMessageButton:$showInRoomMessageButton, '
        'hostButtons:$hostButtons, '
        'coHostButtons:$coHostButtons, '
        'audienceButtons:$audienceButtons, '
        'hostExtendButtons:$hostExtendButtons, '
        'coHostExtendButtons:$coHostExtendButtons, '
        'audienceExtendButtons:$audienceExtendButtons, '
        'maxCount:$maxCount, '
        'buttonStyle:$buttonStyle, '
        'padding:$padding, '
        'margin:$margin, '
        'backgroundColor:$backgroundColor, '
        'height:$height, '
        '}';
  }
}

/// Configuration for the member button of top bar.
class ZegoLiveStreamingMemberButtonConfig {
  /// If you want to redefine the entire button, you can return your own Widget through [builder].
  ZegoLiveStreamingMemberButtonBuilder? builder;

  /// Customize the icon through [icon], with Icons.person being the default if not set.
  Widget? icon;

  /// Customize the background color through [backgroundColor]
  Color? backgroundColor;

  ZegoLiveStreamingMemberButtonConfig({
    this.builder,
    this.icon,
    this.backgroundColor,
  });

  @override
  String toString() {
    return '{'
        'builder:${builder != null}, '
        'icon:${icon != null}, '
        'backgroundColor:$backgroundColor, '
        '}';
  }
}

/// Configuration for the member list.
///
/// You can use the [ZegoUIKitPrebuiltLiveStreamingConfig.memberList] property to set the properties inside this class.
///
/// In addition, you can listen for item click events through [ZegoUIKitPrebuiltLiveStreamingEvents.memberList] callback.
class ZegoLiveStreamingMemberListConfig {
  /// Custom member list item view.
  ///
  /// If you want to use a custom member list item view, you can set the [ZegoLiveStreamingMemberListConfig.itemBuilder] property, and pass your custom view's builder function to it.
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
  ZegoMemberListItemBuilder? itemBuilder;

  ///  show fake user or not
  ///
  ///  `ZegoUIKitPrebuiltLiveStreamingController().user.addFake()`
  ///  `ZegoUIKitPrebuiltLiveStreamingController().user.removeFake()`
  bool showFakeUser;

  ZegoLiveStreamingMemberListConfig({
    this.itemBuilder,
    this.showFakeUser = true,
  });

  @override
  String toString() {
    return '{'
        'itemBuilder:${itemBuilder != null}, '
        'showFakeUser:$showFakeUser, '
        '}';
  }
}

/// Control options for the bottom-left message list.
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.message] property.
///
/// Of course, we also provide a range of styles for you to customize, such as display size, background color, font style, and so on.
class ZegoLiveStreamingInRoomMessageConfig {
  /// Use this to customize the style and content of each chat message list item.
  /// For example, you can modify the background color, opacity, border radius, or add additional information like the sender's level or role.
  ///
  /// If you want to customize chat messages, you can specify the [ZegoLiveStreamingInRoomMessageConfig.itemBuilder].
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
  ///  message.attributes = {'k':'v'};
  ///  message.itemBuilder = (
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

  /// resend button icon
  Widget? resendIcon;

  /// show fake message or not
  ///
  ///  `ZegoUIKitPrebuiltLiveStreamingController().message.sendFakeMessage()`
  bool showFakeMessage;

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
  /// You can use `backgroundColor.withValues(alpha: 0.5)` to set the opacity of the background color.
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

  ZegoLiveStreamingInRoomMessageConfig({
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
    this.showName = true,
    this.showAvatar = true,
    this.showFakeMessage = true,
  });

  @override
  String toString() {
    return '{'
        'itemBuilder:${itemBuilder != null}, '
        'avatarLeadingBuilder:${avatarLeadingBuilder != null}, '
        'avatarTailingBuilder:${avatarTailingBuilder != null}, '
        'nameLeadingBuilder:${nameLeadingBuilder != null}, '
        'nameTailingBuilder:${nameTailingBuilder != null}, '
        'textLeadingBuilder:${textLeadingBuilder != null}, '
        'textTailingBuilder:${textTailingBuilder != null}, '
        'notifyUserJoin:$notifyUserJoin, '
        'notifyUserLeave:$notifyUserLeave, '
        'attributes:${attributes != null}, '
        'background:${background != null}, '
        'visible:$visible, '
        'resendIcon:${resendIcon != null}, '
        'showFakeMessage:$showFakeMessage, '
        'showName:$showName, '
        'showAvatar:$showAvatar, '
        'width:$width, '
        'height:$height, '
        'bottomLeft:$bottomLeft, '
        'opacity:$opacity, '
        'backgroundColor:$backgroundColor, '
        'maxLines:$maxLines, '
        'nameTextStyle:$nameTextStyle, '
        'messageTextStyle:$messageTextStyle, '
        'borderRadius:$borderRadius, '
        'paddings:$paddings, '
        '}';
  }
}

/// Configuration options for voice changer, beauty effects and reverberation effects.
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.effect] property.
///
/// If you want to replace icons and colors to sheet or slider, some of our widgets also provide modification options.
///
/// Example:
///
/// ```dart
/// ZegoEffectConfig(
///   backgroundColor: Colors.black.withValues(alpha: 0.5),
///   backIcon: Icon(Icons.arrow_back),
///   sliderTextBackgroundColor: Colors.black.withValues(alpha: 0.5),
/// );
/// ```
class ZegoLiveStreamingEffectConfig {
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

  ZegoLiveStreamingEffectConfig({
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

  ZegoLiveStreamingEffectConfig.none({
    this.beautyEffects = const [],
    this.voiceChangeEffect = const [],
    this.reverbEffect = const [],
  });

  bool get isSupportBeauty => beautyEffects.isNotEmpty;

  bool get isSupportVoiceChange => voiceChangeEffect.isNotEmpty;

  bool get isSupportReverb => reverbEffect.isNotEmpty;

  @override
  String toString() {
    return '{'
        'beautyEffects:$beautyEffects, '
        'voiceChangeEffect:$voiceChangeEffect, '
        'reverbEffect:$reverbEffect, '
        'backgroundColor:$backgroundColor, '
        'headerTitleTextStyle:$headerTitleTextStyle, '
        'backIcon:${backIcon != null}, '
        'resetIcon:${resetIcon != null}, '
        'normalIconColor:$normalIconColor, '
        'selectedIconColor:$selectedIconColor, '
        'normalIconBorderColor:$normalIconBorderColor, '
        'selectedIconBorderColor:$selectedIconBorderColor, '
        'selectedTextStyle:$selectedTextStyle, '
        'normalTextStyle:$normalTextStyle, '
        'sliderTextStyle:$sliderTextStyle, '
        'sliderTextBackgroundColor:$sliderTextBackgroundColor, '
        'sliderActiveTrackColor:$sliderActiveTrackColor, '
        'sliderInactiveTrackColor:$sliderInactiveTrackColor, '
        'sliderThumbColor:$sliderThumbColor, '
        'sliderThumbRadius:$sliderThumbRadius, '
        '}';
  }
}

/// Used to configure the parameters related to PK battles
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.pkBattle] property.
class ZegoLiveStreamingPKBattleConfig {
  /// If the connection with a PK user is lost for a `userReconnectingSecond` period of time,
  /// it will trigger [hostReconnectingBuilder], which waits for the user to reconnect.
  ///
  /// default value is 5 seconds.
  ///
  /// `ZegoUIKitPrebuiltLiveStreamingPKEvents.onUserReconnecting` will be triggered
  int userReconnectingSecond;

  /// When a PK user loses connection for more than `userDisconnectedSecond`,
  /// they will be automatically kicked out of the PK.
  ///
  /// default value is 90 seconds.
  ///
  /// `ZegoUIKitPrebuiltLiveStreamingPKEvents.onUserDisconnected` will be triggered
  int userDisconnectedSecond;

  /// you can custom coordinates and modify the PK layout.
  ZegoLiveStreamingPKMixerLayout? mixerLayout;

  /// When the connected host gets offline due to exceptions, SDK defaults to show "Host is reconnecting".
  /// To customize the content that displays when the connected host gets offline.
  ZegoLiveStreamingPKBattleHostReconnectingBuilder? hostReconnectingBuilder;

  /// The distance that the top edge is inset from the top of the stack.
  /// If [containerRect] is set, then [topPadding] will be invalid
  double? topPadding;

  /// view rect, default is full
  Rect Function()? containerRect;

  /// To overlay custom components on the PKBattleView.
  ZegoLiveStreamingPKBattleViewBuilder? foregroundBuilder;

  /// To add custom components on the top edge of the PKBattleView.
  ZegoLiveStreamingPKBattleViewBuilder? topBuilder;

  /// To add custom components on the bottom edge of the PKBattleView.
  ZegoLiveStreamingPKBattleViewBuilder? bottomBuilder;

  ZegoLiveStreamingDialogInfo? hostResumePKConfirmDialogInfo;

  /// internal config, should not be set by user
  ZegoLiveStreamingPKBattleInternalConfig? internal;

  ZegoLiveStreamingPKBattleConfig({
    this.userReconnectingSecond = 5,
    this.userDisconnectedSecond = 90,
    this.mixerLayout,
    this.containerRect,
    this.topPadding,
    this.hostReconnectingBuilder,
    this.foregroundBuilder,
    this.topBuilder,
    this.bottomBuilder,
    this.hostResumePKConfirmDialogInfo,
    @Deprecated('Use topPadding instead$deprecatedTipsV330')
    double? pKBattleViewTopPadding,
    @Deprecated('Use foregroundBuilder instead$deprecatedTipsV330')
    ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewForegroundBuilder,
    @Deprecated('Use topBuilder instead$deprecatedTipsV330')
    ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewTopBuilder,
    @Deprecated('Use bottomBuilder instead$deprecatedTipsV330')
    ZegoLiveStreamingPKBattleViewBuilder? pkBattleViewBottomBuilder,
  }) {
    topPadding ??= pKBattleViewTopPadding;
    foregroundBuilder ??= pkBattleViewForegroundBuilder;
    topBuilder ??= pkBattleViewTopBuilder;
    bottomBuilder ??= pkBattleViewBottomBuilder;
  }

  @override
  String toString() {
    return '{'
        'userReconnectingSecond:$userReconnectingSecond, '
        'userDisconnectedSecond:$userDisconnectedSecond, '
        'mixerLayout:$mixerLayout, '
        'containerRect:${containerRect != null}, '
        'topPadding:$topPadding, '
        'hostReconnectingBuilder:${hostReconnectingBuilder != null}, '
        'foregroundBuilder:${foregroundBuilder != null}, '
        'topBuilder:${topBuilder != null}, '
        'bottomBuilder:${bottomBuilder != null}, '
        '}';
  }
}

/// Internal configuration for PK battle.
///
/// This class is used for internal PK battle configuration.
/// It is not recommended for external use.
class ZegoLiveStreamingPKBattleInternalConfig {
  /// Whether the live streaming is in PK mode when entering the room.
  ///
  /// If the value is true, the PK view will be displayed immediately when entering the room.
  /// If the value is false, the PK view will be displayed after the room attributes are synchronized.
  bool? isDefaultInPK;

  /// Whether the live streaming is in PK mode when entering the room.
  ///
  /// If the value is true, the PK view will be displayed immediately when entering the room.
  /// If the value is false, the PK view will be displayed after the room attributes are synchronized.
  bool Function(String roomID)? checkIfDefaultInPK;

  /// The default host of the PK battle.
  ZegoUIKitUser? defaultHost;

  /// The default host of the PK battle.
  ZegoUIKitUser? Function(String roomID)? getDefaultHost;

  ZegoLiveStreamingPKBattleInternalConfig({
    this.isDefaultInPK,
    this.checkIfDefaultInPK,
    this.defaultHost,
    this.getDefaultHost,
  });
}

/// Used to configure the parameters related to the preview of the live streaming.
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.preview] property.
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
  ZegoLiveStreamingStartLiveButtonBuilder? startLiveButtonBuilder;

  ZegoLiveStreamingPreviewTopBarConfig topBar;
  ZegoLiveStreamingPreviewBottomBarConfig bottomBar;

  ZegoLiveStreamingPreviewConfig({
    this.showPreviewForHost = true,
    this.pageBackIcon,
    this.beautyEffectIcon,
    this.switchCameraIcon,
    this.startLiveButtonBuilder,
    ZegoLiveStreamingPreviewTopBarConfig? topBar,
    ZegoLiveStreamingPreviewBottomBarConfig? bottomBar,
  })  : topBar = topBar ?? ZegoLiveStreamingPreviewTopBarConfig(),
        bottomBar = bottomBar ?? ZegoLiveStreamingPreviewBottomBarConfig();

  @override
  String toString() {
    return '{'
        'showPreviewForHost:$showPreviewForHost, '
        'pageBackIcon:${pageBackIcon != null}, '
        'beautyEffectIcon:${beautyEffectIcon != null}, '
        'switchCameraIcon:${switchCameraIcon != null}, '
        'startLiveButtonBuilder:${startLiveButtonBuilder != null}, '
        'topBar:$topBar, '
        'bottomBar:$bottomBar, '
        '}';
  }
}

/// Configuration options for the preview page top bar.
///
/// This class is used for the [ZegoLiveStreamingPreviewConfig.topBar] property.
class ZegoLiveStreamingPreviewTopBarConfig {
  /// Whether to show the top bar on the preview page.
  bool isVisible;

  ZegoLiveStreamingPreviewTopBarConfig({
    this.isVisible = true,
  });

  @override
  String toString() {
    return '{'
        'isVisible:$isVisible, '
        '}';
  }
}

/// Configuration options for the preview page bottom bar.
///
/// This class is used for the [ZegoLiveStreamingPreviewConfig.bottomBar] property.
class ZegoLiveStreamingPreviewBottomBarConfig {
  /// Whether to show the bottom bar on the preview page.
  bool isVisible;

  /// Whether to show the beauty effect button on the bottom bar.
  bool showBeautyEffectButton;

  ZegoLiveStreamingPreviewBottomBarConfig({
    this.isVisible = true,
    this.showBeautyEffectButton = true,
  });

  @override
  String toString() {
    return '{'
        'isVisible:$isVisible, '
        'showBeautyEffectButton:$showBeautyEffectButton, '
        '}';
  }
}

///
/// If you use **ZegoLiveStreamingHallList**, this setting will be invalid because **ZegoLiveStreamingHallList** will reset it
class ZegoLiveStreamingHallConfig {
  /// If the current live room is entered through the hall, special internal processing is required when exiting the live stream.
  /// Please ensure this variable is assigned the correct value.
  bool fromHall;

  /// loading builder, return Container() if you want hide it
  final Widget? Function(
    BuildContext context,
  )? loadingBuilder;

  ZegoLiveStreamingHallConfig({
    this.fromHall = false,
    this.loadingBuilder,
  });

  @override
  String toString() {
    return '{'
        'fromHall:$fromHall, '
        'loadingBuilder:${loadingBuilder != null}, '
        '}';
  }
}

/// swiping config, if you wish to use swiping, please configure this config.
/// if it is null, this swiping will not be enabled.
/// the `liveID` will be the initial live id of swiping
///
/// If you use **ZegoLiveStreamingHallList**, this setting will be invalid because **ZegoLiveStreamingHallList** will reset it
class ZegoLiveStreamingSwipingConfig {
  ZegoLiveStreamingStreamMode streamMode;

  /// swiping model
  /// list of `live id`
  /// When swiping up or down, the corresponding LIVE ID will be returned via this `model`
  final ZegoLiveStreamingSwipingModel? model;

  /// If you want to manage data yourself, please refer to [ZegoLiveStreamingSwipingModel],
  /// then cancel the setting of `model`, and then set `modelDelegate`
  final ZegoLiveStreamingSwipingModelDelegate? modelDelegate;

  ZegoLiveStreamingSwipingConfig({
    this.streamMode = ZegoLiveStreamingStreamMode.preloaded,
    this.model,
    this.modelDelegate,
  });

  @override
  String toString() {
    return '{'
        'model:$model, '
        'model delegate:$modelDelegate, '
        'streamMode:$streamMode, '
        '}';
  }
}

/// Live Streaming timing configuration.
class ZegoLiveStreamingDurationConfig {
  /// Whether to display Live Streaming timing.
  bool isVisible;

  ZegoLiveStreamingDurationConfig({
    this.isVisible = true,
  });

  @override
  String toString() {
    return '{'
        'isVisible:$isVisible, '
        '}';
  }
}

/// Configuration for the signaling plugin.
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.signalingPlugin] property.
class ZegoLiveStreamingSignalingPluginConfig {
  /// Whether to leave the room when the signaling plugin is disposed.
  bool leaveRoomOnDispose;

  /// Whether to uninitialize the signaling plugin when disposed.
  bool uninitOnDispose;

  ZegoLiveStreamingSignalingPluginConfig({
    this.leaveRoomOnDispose = true,
    this.uninitOnDispose = true,
  });

  @override
  String toString() {
    return '{'
        'leaveRoomOnDispose:$leaveRoomOnDispose, '
        'uninitOnDispose:$uninitOnDispose, '
        '}';
  }
}

/// screen sharing
class ZegoLiveStreamingScreenSharingConfig {
  /// when ending screen sharing from a non-app,
  /// the automatic check end mechanism will be triggered.
  ZegoLiveStreamingScreenSharingAutoStopConfig autoStop;

  /// If true, then when there is screen sharing display, it will automatically be full screen
  /// default is false
  bool defaultFullScreen;

  ZegoLiveStreamingScreenSharingConfig({
    ZegoLiveStreamingScreenSharingAutoStopConfig? autoStop,
    this.defaultFullScreen = false,
  }) : autoStop = autoStop ?? ZegoLiveStreamingScreenSharingAutoStopConfig();

  @override
  String toString() {
    return '{'
        'autoStop:$autoStop, '
        'defaultFullScreen:$defaultFullScreen, '
        '}';
  }
}

/// when ending screen sharing from a non-app,
/// the automatic check end mechanism will be triggered.
class ZegoLiveStreamingScreenSharingAutoStopConfig {
  /// Count of the check fails before automatically end the screen sharing
  int invalidCount;

  /// Determines whether to end;
  /// returns false if you don't want to end
  bool Function()? canEnd;

  ZegoLiveStreamingScreenSharingAutoStopConfig({
    this.invalidCount = 3,
    this.canEnd,
  });

  @override
  String toString() {
    return '{'
        'invalidCount:$invalidCount, '
        'canEnd:${canEnd != null}, '
        '}';
  }
}

/// media player config
class ZegoLiveStreamingMediaPlayerConfig {
  /// In iOS, to achieve transparency for a video using a platform view, you need to set [supportTransparent] to true.
  bool supportTransparent;

  /// default player
  ZegoLiveStreamingMediaPlayerDefaultPlayerConfig defaultPlayer;

  ZegoLiveStreamingMediaPlayerConfig({
    this.supportTransparent = false,
    ZegoLiveStreamingMediaPlayerDefaultPlayerConfig? defaultPlayer,
  }) : defaultPlayer =
            defaultPlayer ?? ZegoLiveStreamingMediaPlayerDefaultPlayerConfig();

  @override
  String toString() {
    return '{'
        'supportTransparent:$supportTransparent, '
        'defaultPlayer:$defaultPlayer, '
        '}';
  }
}

/// default media player query parameter
class ZegoLiveStreamingMediaPlayerQueryParameter {
  ZegoLiveStreamingRole localRole;

  ZegoLiveStreamingMediaPlayerQueryParameter({
    required this.localRole,
  });

  @override
  String toString() {
    return '{'
        'localRole:$localRole, '
        '}';
  }
}

/// default media player config
class ZegoLiveStreamingMediaPlayerDefaultPlayerConfig {
  /// support or not
  bool support;

  /// roles can control(pick/start/stop)
  List<ZegoLiveStreamingRole> rolesCanControl;

  /// top-left position
  Point<double> Function(ZegoLiveStreamingMediaPlayerQueryParameter)?
      topLeftQuery;

  /// rect query
  Rect Function(ZegoLiveStreamingMediaPlayerQueryParameter)? rectQuery;

  /// config
  ZegoUIKitMediaPlayerConfig? Function(
    ZegoLiveStreamingMediaPlayerQueryParameter,
  )? configQuery;

  /// style
  ZegoUIKitMediaPlayerStyle? Function(
    ZegoLiveStreamingMediaPlayerQueryParameter,
  )? styleQuery;

  ZegoLiveStreamingMediaPlayerDefaultPlayerConfig({
    this.support = false,
    this.rolesCanControl = const [
      ZegoLiveStreamingRole.host,
    ],
    this.topLeftQuery,
    this.rectQuery,
    this.configQuery,
    this.styleQuery,
  });

  @override
  String toString() {
    return '{'
        'support:$support, '
        'rolesCanControl:$rolesCanControl, '
        'topLeftQuery:${topLeftQuery != null}, '
        'rectQuery:${rectQuery != null}, '
        'configQuery:${configQuery != null}, '
        'styleQuery:${styleQuery != null}, '
        '}';
  }
}

/// pip config
class ZegoLiveStreamingPIPConfig {
  ZegoLiveStreamingPIPConfig({
    this.aspectWidth = 9,
    this.aspectHeight = 16,
    this.enableWhenBackground = true,
    ZegoLiveStreamingPIPAndroidConfig? android,
    ZegoLiveStreamingPIPIOSConfig? iOS,
  })  : android = android ?? ZegoLiveStreamingPIPAndroidConfig(),
        iOS = iOS ?? ZegoLiveStreamingPIPIOSConfig();

  /// android config
  ZegoLiveStreamingPIPAndroidConfig android;

  /// ios config
  ZegoLiveStreamingPIPIOSConfig iOS;

  /// aspect width
  int aspectWidth;

  /// aspect height
  int aspectHeight;

  /// android: only available on SDK higher than 31(>=31), Android 12
  ///
  /// Add android:supportsPictureInPicture="true" line to the activity tag in android/src/main/AndroidManifest.xml:
  ///
  /// manifest
  ///    application
  ///         activity
  ///             android:name=".MainActivity"
  ///             android:supportsPictureInPicture="true"
  ///             ...
  ///
  /// iOS: SDK higher than 15(>=15), only play remote user
  bool enableWhenBackground;

  @override
  String toString() {
    return '{'
        'android:$android, '
        'iOS:$iOS, '
        'aspectWidth:$aspectWidth, '
        'aspectHeight:$aspectHeight, '
        'enableWhenBackground:$enableWhenBackground, '
        '}';
  }
}

/// android pip
/// only available on SDK higher than 26(>=26)
class ZegoLiveStreamingPIPAndroidConfig {
  ZegoLiveStreamingPIPAndroidConfig({
    this.background,
  });

  /// default is a background image
  Widget? background;

  @override
  String toString() {
    return '{'
        'background:${background != null}, '
        '}';
  }
}

/// iOS pip
/// only available on 15.0
class ZegoLiveStreamingPIPIOSConfig {
  ZegoLiveStreamingPIPIOSConfig({
    this.support = true,
  });

  bool support;

  @override
  String toString() {
    return '{'
        'support:$support, '
        '}';
  }
}
