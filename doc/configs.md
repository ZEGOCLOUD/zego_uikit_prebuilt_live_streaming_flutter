

# [ZegoUIKitPrebuiltLiveStreamingConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig-class.html)

# construtors
- [`host`](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/ZegoUIKitPrebuiltLiveStreamingConfig.host.html): Default initialization parameters for the group video call.
- [`audience`](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/ZegoUIKitPrebuiltLiveStreamingConfig.audience.html): Default initialization parameters for the group voice call.

# parameters

## [ZegoUIKitVideoConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoUIKitVideoConfig-class.html) video

>
>
> configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate.
> you can set by **video = ZegoUIKitVideoConfig.presetXX()**

- parameters:
  - int `fps`: frame rate, control the frame rate of the camera and the frame rate of the encoder.
  - int `bitrate`: bit rate in kbps.
  - int `width`: resolution width, control the image width of camera image acquisition or encoder when publishing stream.
  - int `height`: resolution height, control the image height of camera image acquisition or encoder when publishing stream.

- construtors:
  - `preset180P`
  - `preset270P`
  - `preset360P`
  - `preset540P`
  - `preset720P`
  - `preset1080P`
  - `preset2K`
  - `preset4K`


## [ZegoLiveStreamingAudioVideoViewConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingAudioVideoViewConfig-class.html) audioVideoView

>
>  Configuration options for audio/video views.
>
>  This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.audioVideoView] property.
>
>  These options allow you to customize the display effects of the audio/video views, such as showing microphone status and usernames.
>
>  If you need to customize the foreground or background of the audio/video view, you can use [foregroundBuilder] and [backgroundBuilder].
>
>  If you want to hide user avatars or sound waveforms in audio mode, you can set [showAvatarInAudioMode] and [showSoundWavesInAudioMode] to false.


- bool Function(
  ZegoUIKitUser localUser,
  ZegoLiveStreamingRole localRole,
  ZegoUIKitUser targetUser,
  ZegoLiveStreamingRole targetUserRole,
  )? `visible`:
>
>  show target user's audio video view or not
>  return false if you don't want to show target user's audio video view.
>
>  when the stream list changes (specifically, when the co-hosts change),
>  it will dynamically read this configuration to determine whether to show the target user view.

- ZegoPlayCoHostAudioVideoCallback? `playCoHostAudio`:
>
>  Whether to the play audio of the specified co-host?
>  The default behavior is play.
>  return false if you don't want to play target user's audio.
>
>  when the stream list changes (specifically, when the co-hosts change),
>  it will dynamically read this configuration to determine whether to fetch the audio.(muteUserAudio)

- ZegoPlayCoHostAudioVideoCallback? `playCoHostVideo`:
>
>  Whether to the play video of the specified co-host?
>  The default behavior is play.
>  return false if you don't want to play target user's video.
>
>  when the stream list changes (specifically, when the co-hosts change),
>  it will dynamically read this configuration to determine whether to fetch the video.(muteUserVideo)

- bool `isVideoMirror`:
>
>  Whether to mirror the displayed video captured by the camera.
>
>  This mirroring effect only applies to the front-facing camera.
>  Set it to true to enable mirroring, which flips the image horizontally.

- bool `showUserNameOnView`:
>
>  Whether to display the username on the audio/video view.
>
>  Set it to false if you don't want to show the username on the audio/video view.

- bool `useVideoViewAspectFill`:
>
>  Video view mode.
>
>  Set it to true if you want the video view to scale proportionally to fill the entire view, potentially resulting in partial cropping.
>
>  Set it to false if you want the video view to scale proportionally, potentially resulting in black borders.

- bool `showAvatarInAudioMode`:
>
>  Whether to display user avatars in audio mode.
>
>  Set it to false if you don't want to show user avatars in audio mode.

- bool `showSoundWavesInAudioMode`:
>
>  Whether to display sound waveforms in audio mode.
>
>  Set it to false if you don't want to show sound waveforms in audio mode.

- ZegoLiveStreamingAudioVideoContainerBuilder? `containerBuilder`:
>
> Custom audio/video view. ( not for PK!! )
>
> If you don't want to use the default view components, you can pass a custom component through this parameter.
>
> and if return null, will be display the default view

- Rect Function()? `containerRect`:
>
> Specify the rect of the audio & video container.
>
> if not specified, it defaults to display full.

- ZegoAudioVideoViewForegroundBuilder? `foregroundBuilder`:
>
>  You can customize the foreground of the audio/video view, which refers to the widget positioned on top of the view.
>
>  You can return any widget, and we will place it at the top of the audio/video view.

- ZegoAudioVideoViewBackgroundBuilder? `backgroundBuilder`:
>
>  Background for the audio/video windows in a Live Streaming.
>
>  You can use any widget as the background for the audio/video windows. This can be a video, a GIF animation, an image, a web page, or any other widget.
>
>  If you need to dynamically change the background content, you should implement the logic for dynamic modification within the widget you return.

## [ZegoLiveStreamingMediaPlayerConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingMediaPlayerConfig-class.html) mediaPlayer


>
>  Configuration options for media player.

- bool `supportTransparent`: in iOS, to achieve transparency for a video using a platform view, you need to set [supportTransparent] to true.

## [ZegoLiveStreamingTopMenuBarConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingTopMenuBarConfig-class.html) topMenuBar

>
>  Configuration options for the top menu bar (toolbar).
>
>  You can use these options to customize the appearance and behavior of the top menu bar.

- List\<[ZegoLiveStreamingMenuBarButtonName](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingMenuBarButtonName.html)\> `buttons`: these buttons will displayed on the menu bar, order by the list, only support [minimizingButton] right now

- EdgeInsetsGeometry? `padding`: padding for the top menu bar.

- EdgeInsetsGeometry? `margin`: margin for the top menu bar.

- Color? `backgroundColor`: background color for the top menu bar.

- double? `height`: height for the top menu bar.

- Widget Function(ZegoUIKitUser host)? `hostAvatarBuilder`: you can customize the host icon widget in the top-left corner. if you don't want to display it, return Container().

- bool `showCloseButton`: set false if you want to hide the close (exit the live streaming room) button.

## [ZegoLiveStreamingBottomMenuBarConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingBottomMenuBarConfig-class.html) bottomMenuBar

>
>  Configuration options for the bottom menu bar (toolbar).
>
>  You can use these options to customize the appearance and behavior of the bottom menu bar.


- bool `showInRoomMessageButton`: whether to display the room message button.

- List\<[ZegoLiveStreamingMenuBarButtonName](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingMenuBarButtonName.html)\> `hostButtons`: the list of predefined buttons to be displayed when the user role is set to host.

- List\<[ZegoLiveStreamingMenuBarButtonName](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingMenuBarButtonName.html)\> `coHostButtons`: the list of predefined buttons to be displayed when the user role is set to co-host.

- List\<[ZegoLiveStreamingMenuBarButtonName](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingMenuBarButtonName.html)\> `audienceButtons`: the list of predefined buttons to be displayed when the user role is set to audience.

- List\<[ZegoLiveStreamingMenuBarExtendButton](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingMenuBarExtendButton-class.html)\> `hostExtendButtons`:
>
>  List of extension buttons for the host.
>  These buttons will be added to the menu bar in the specified order and automatically added to the overflow menu when the [maxCount] limit is exceeded.
>
>  If you want to place the extension buttons before the built-in buttons, you can achieve this by setting the index parameter of the ZegoMenuBarExtendButton.
>  For example, if you want to place an extension button at the very beginning of the built-in buttons, you can set the index of that extension button to 0.
>  Please refer to the definition of ZegoMenuBarExtendButton for implementation details.

- List\<[ZegoLiveStreamingMenuBarExtendButton](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingMenuBarExtendButton-class.html)\> `coHostExtendButtons`:
>
>  List of extension buttons for the co-hosts.
>  These buttons will be added in the same way as the hostExtendButtons.

- List\<[ZegoLiveStreamingMenuBarExtendButton](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingMenuBarExtendButton-class.html)\> `audienceExtendButtons`:
>
>  List of extension buttons for the audience.
>  These buttons will be added in the same way as the hostExtendButtons.

- int `maxCount`:
>
>  Controls the maximum number of buttons (including predefined and custom buttons) to be displayed in the menu bar (toolbar).
>  When the number of buttons exceeds the `maxCount` limit, a "More" button will appear.
>  Clicking on it will display a panel showing other buttons that cannot be displayed in the menu bar (toolbar).

- [ZegoLiveStreamingBottomMenuBarButtonStyle](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingBottomMenuBarButtonStyle-class.html)? `buttonStyle`: button style for the bottom menu bar.
    
    - Widget? `chatEnabledButtonIcon`: Icon for enabling chat.

    - Widget? `chatDisabledButtonIcon`: Icon for disabling chat.

    - Widget? `toggleMicrophoneOnButtonIcon`: Icon for toggling microphone on.

    - Widget? `toggleMicrophoneOffButtonIcon`: Icon for toggling microphone off.

    - Widget? `toggleCameraOnButtonIcon`: Icon for toggling camera on.

    - Widget? `toggleCameraOffButtonIcon`: Icon for toggling camera off.

    - Widget? `switchCameraButtonIcon`: Icon for switching camera.

    - Widget? `switchAudioOutputToSpeakerButtonIcon`: Icon for switching audio output to speaker.

    - Widget? `switchAudioOutputToHeadphoneButtonIcon`: Icon for switching audio output to headphone.

    - Widget? `switchAudioOutputToBluetoothButtonIcon`: Icon for switching audio output to Bluetooth.

    - Widget? `leaveButtonIcon`: Icon for leaving the room.

    - Widget? `requestCoHostButtonIcon`: Icon for requesting co-host status.

    - String? `requestCoHostButtonText`: Text for requesting co-host status button.

    - Widget? `cancelRequestCoHostButtonIcon`: Icon for canceling co-host request.

    - String? `cancelRequestCoHostButtonText`: Text for canceling co-host request button.

    - Widget? `endCoHostButtonIcon`: Icon for ending co-host status.

    - String? `endCoHostButtonText`: Text for ending co-host status button.

    - Widget? `beautyEffectButtonIcon`: Icon for beauty effect.

    - Widget? `soundEffectButtonIcon`: Icon for sound effect.

    - Widget? `enableChatButtonIcon`: Icon for enabling chat.

    - Widget? `disableChatButtonIcon`: Icon for disabling chat.

    - Widget? `toggleScreenSharingOnButtonIcon`: Icon for toggling screen sharing on.

    - Widget? `toggleScreenSharingOffButtonIcon`: Icon for toggling screen sharing off.

- EdgeInsetsGeometry? `padding`: padding for the bottom menu bar.

- EdgeInsetsGeometry? `margin`: margin for the bottom menu bar.

- Color? `backgroundColor`: background color for the bottom menu bar.

- double? `height`: height for the bottom menu bar.

## [ZegoLiveStreamingMemberButtonConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingMemberButtonConfig-class.html) memberButton

>
>  Configuration related to the top member button

- Widget Function(int memberCount)? `builder`: if you want to redefine the entire button, you can return your own Widget through [builder].

- Widget? `icon`: customize the icon through [icon], with Icons.person being the default if not set.

- Color? `backgroundColor`: customize the background color through [backgroundColor]

## [ZegoLiveStreamingMemberListConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingMemberListConfig-class.html) memberList

>
>  Configuration related to the bottom member list, including displaying the member list, member list styles, and more.

- [ZegoMemberListItemBuilder](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoMemberListItemBuilder.html)? `itemBuilder`:
>
>  Custom member list item view.
>
>  If you want to use a custom member list item view, you can set the [ZegoLiveStreamingMemberListConfig.itemBuilder] property, and pass your custom view's builder function to it.
>
>  For example, suppose you have implemented a `CustomMemberListItem` component that can render a member list item view based on the user information. You can set it up like this:
>``` dart
>ZegoMemberListConfig(
>  itemBuilder: (BuildContext context, Size size, ZegoUIKitUser user, Map<String, dynamic> extraInfo) {
>    return CustomMemberListItem(user: user);
>  },
>);
>
>```
>
>  In this example, we pass the builder function of the custom view, `CustomMemberListItem`, to the [itemBuilder] property so that the member list item will be rendered using the custom component.

## [ZegoLiveStreamingInRoomMessageConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingInRoomMessageConfig-class.html) inRoomMessage

>
>
>  Control options for the bottom-left message list.
>
>  This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.message] property.
>
>  Of course, we also provide a range of styles for you to customize, such as display size, background color, font style, and so on.

- [ZegoInRoomMessageItemBuilder](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoInRoomMessageItemBuilder.html)? `itemBuilder`:
>
>  Use this to customize the style and content of each chat message list item.
>  For example, you can modify the background color, opacity, border radius, or add additional information like the sender's level or role.
>
>  If you want to customize chat messages, you can specify the [ZegoLiveStreamingInRoomMessageConfig.itemBuilder].
>
>  Example:
>```dart
>ZegoInRoomMessageConfig(
>  itemBuilder: (BuildContext context, ZegoRoomMessage message) {
>    return ListTile(title: Text(message.message), subtitle: Text(message.user.id),);
>  },
>  opacity: 0.8,
>);
>```
>

- [ZegoInRoomMessageItemBuilder](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoInRoomMessageItemBuilder.html)? `avatarLeadingBuilder`:
>
>  A more granular builder for customizing the widget on the leading of the avatar part, default is empty.
>  default message display widget = avatar + name + text
>  Please note that if you use [itemBuilder], this builder will be ignored.

- [ZegoInRoomMessageItemBuilder](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoInRoomMessageItemBuilder.html)? `avatarTailingBuilder`:
>
>  A more granular builder for customizing the widget on the tailing of the avatar part, default is empty.
>  default message display widget = avatar + name + text
>  Please note that if you use [itemBuilder], this builder will be ignored.

- [ZegoInRoomMessageItemBuilder](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoInRoomMessageItemBuilder.html)? `nameLeadingBuilder`:
>
>  A more granular builder for customizing the widget on the leading of the name part, default is empty.
>  default message display widget = avatar + name + text
>  Please note that if you use [itemBuilder], this builder will be ignored.

- [ZegoInRoomMessageItemBuilder](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoInRoomMessageItemBuilder.html)? `nameTailingBuilder`:
>
>  A more granular builder for customizing the widget on the tailing of the name part, default is empty.
>  default message display widget = avatar + name + text
>  Please note that if you use [itemBuilder], this builder will be ignored.

- [ZegoInRoomMessageItemBuilder](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoInRoomMessageItemBuilder.html)? `textLeadingBuilder`:
>
>  A more granular builder for customizing the widget on the leading of the text part, default is empty.
>  default message display widget = avatar + name + text
>  Please note that if you use [itemBuilder], this builder will be ignored.

- [ZegoInRoomMessageItemBuilder](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoInRoomMessageItemBuilder.html)? `textTailingBuilder`:
>
>  A more granular builder for customizing the widget on the tailing of the text part, default is empty.
>  default message display widget = avatar + name + text
>  Please note that if you use [itemBuilder], this builder will be ignored.

- bool `notifyUserJoin`: whether to display user join messages, default is not displayed

- bool `notifyUserLeave`: whether to display user leave messages, default is not displayed

- Map<String, String> Function()? `attributes`:
>
>  message attributes of local user, which will be appended to the message body.
>
>  if set, [attributes] will be sent along with the message body.
>
>``` dart
> message.attributes = {'k':'v'};
> message.itemBuilder = (
>   BuildContext context,
>   ZegoInRoomMessage message,
>   Map<String, dynamic> extraInfo,
> ) {
>  final attributes = message.attributes;
>  return YouCustomMessageItem();
> }
>```

- Widget? `background`: background

- bool `visible`: display chat message list view or not

- bool `showName`: display user name in message list view or not

- bool `showAvatar`: display user avatar in message list view or not

- double? `width`: the width of chat message list view

- double? `height`: the height of chat message list view

- Offset? `bottomLeft`: the offset of chat message list view bottom-left position

- double `opacity`:
>
>  The opacity of the background color for chat message list items, default value of 0.5.
>  If you set the [backgroundColor], the [opacity] setting will be overridden.

- Color? `backgroundColor`:
>
>  The background of chat message list items
>  If you set the [backgroundColor], the [opacity] setting will be overridden.
>  You can use `backgroundColor.withOpacity(0.5)` to set the opacity of the background color.

- int? `maxLines`: the max lines of chat message list items, default value is not limit.
  ``
- TextStyle? `nameTextStyle`: the name text style of chat message list items

- TextStyle? `messageTextStyle`: the message text style of chat message list items

- BorderRadiusGeometry? `borderRadius`: the border radius of chat message list items

- EdgeInsetsGeometry? `paddings`: the paddings of chat message list items

- Widget? `resendIcon`: resend button icon

## [ZegoLiveStreamingEffectConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingEffectConfig-class.html) effect

>
>  Configuration options for voice changer, beauty effects and reverberation effects.
>
>  This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.effect] property.
>
>  If you want to replace icons and colors to sheet or slider, some of our widgets also provide modification options.
>
>  Example:
>
>```dart
>ZegoEffectConfig(
>  backgroundColor: Colors.black.withOpacity(0.5),
>  backIcon: Icon(Icons.arrow_back),
>  sliderTextBackgroundColor: Colors.black.withOpacity(0.5),
>);
>```

- List\<[BeautyEffectType](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/BeautyEffectType.html)\> `beautyEffects`: list of beauty effects types. if you don't want a certain effect, simply remove it from the list.

- List\<[VoiceChangerType](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/VoiceChangerType.html)\> `voiceChangeEffect`: list of voice changer effects. if you don't want a certain 
  effect, simply remove it from the list.

- List\<[ReverbType](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ReverbType.html)\> `reverbEffect`: list of revert effects types, if you don't want a certain effect, simply 
  remove it from the list.

- Color? `backgroundColor`: the background color of the sheet.

- TextStyle? `headerTitleTextStyle`: the text style of the head title sheet.

- Widget? `backIcon`: back button icon on the left side of the title.

- Widget? `resetIcon`: reset button icon on the right side of the title.

- Color? `normalIconColor`: color of the icons in the normal (unselected) state.

- Color? `selectedIconColor`: color of the icons in the highlighted (selected) state.

- Color? `normalIconBorderColor`: border color of the icons in the normal (unselected) state.

- Color? `selectedIconBorderColor`: border color of the icons in the highlighted (selected) state.

- TextStyle? `selectedTextStyle`: text-style of buttons in the highlighted (selected) state.

- TextStyle? `normalTextStyle`: text-style of buttons in the normal (unselected) state.

- TextStyle? `sliderTextStyle`: the style of the text displayed on the Slider's thumb

- Color? `sliderTextBackgroundColor`: the background color of the text displayed on the Slider's thumb.

- Color? `sliderActiveTrackColor`: the color of the track that is active when sliding the Slider.

- Color? `sliderInactiveTrackColor`: the color of the track that is inactive when sliding the Slider.

- Color? `sliderThumbColor`: the color of the Slider's thumb.

- double? `sliderThumbRadius`: the radius of the Slider's thumb.


## [ZegoLiveStreamingPreviewConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPreviewConfig-class.html) preview

>
>  Used to configure the parameters related to the preview of the live streaming.


- bool `showPreviewForHost`: whether to show the preview page for the host. The default value is true.

- Widget? `pageBackIcon`:
>
>  The icon for the page back button.
>
>  You can customize the icon for the page back button as shown in the example below:
>```dart
>ZegoLiveStreamingPreviewConfig(
>  pageBackIcon: Icon(Icons.arrow_back),
>);
>```

- Widget? `beautyEffectIcon`:
>
>  The icon for the beauty effect button.
>
>  You can customize the icon for the beauty effect button as shown in the example below:
>```dart
>ZegoLiveStreamingPreviewConfig(
>  beautyEffectIcon: Icon(Icons.face),
>);
>```

- Widget? `switchCameraIcon`:
>
>  The icon for the switch camera button.
>
>  You can customize the icon for the switch camera button as shown in the example below:
>```dart
>ZegoLiveStreamingPreviewConfig(
>  switchCameraIcon: Icon(Icons.switch_camera),
>);
>```

- [ZegoLiveStreamingStartLiveButtonBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingStartLiveButtonBuilder.html)?
  `startLiveButtonBuilder`:
>
>  Customize your start call button
>  you MUST call startLive function on your custom button
>
>```dart
>..startLiveButtonBuilder =
>(BuildContext context, VoidCallback startLive) {
>  return ElevatedButton(
>    onPressed: () {
>    //  do whatever you want
>    startLive();  //  MUST call this function to skip to target page!!!
>    },
>    child: Text("START"),
>  );
>}
>```

## [ZegoLiveStreamingPKBattleConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKBattleConfig-class.html) pkBattle

>
>  Used to configure the parameters related to PK battles

- int `userReconnectingSecond`:
>
>  If the connection with a PK user is lost for a [userReconnectingSecond] period of time,
>  it will trigger [hostReconnectingBuilder], which waits for the user to reconnect.
>
>  default value is 5 seconds.
>
>  [ZegoUIKitPrebuiltLiveStreamingPKEvents.onUserReconnecting] will be triggered

- int `userDisconnectedSecond`:
>
>  When a PK user loses connection for more than [userDisconnectedSecond],
>  they will be automatically kicked out of the PK.
>
>  default value is 90 seconds.
>
>  [ZegoUIKitPrebuiltLiveStreamingPKEvents.onUserDisconnected] will be triggered

- double? `pKBattleViewTopPadding`:
>
>  The distance that the top edge is inset from the top of the stack.
>  default is 164.r

- [ZegoLiveStreamingPKMixerLayout](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKMixerLayout-class.html)? `mixerLayout`: you can custom coordinates and modify the PK layout.

- [ZegoLiveStreamingPKBattleHostReconnectingBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKBattleHostReconnectingBuilder.html)? `hostReconnectingBuilder`:
>
>  When the connected host gets offline due to exceptions, SDK defaults to show "Host is reconnecting".
>  To customize the content that displays when the connected host gets offline.

- [ZegoLiveStreamingPKBattleViewBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKBattleViewBuilder.html)? `pkBattleViewForegroundBuilder`: to overlay custom components on the PKBattleView.

- [ZegoLiveStreamingPKBattleViewBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKBattleViewBuilder.html)? `pkBattleViewTopBuilder`: to add custom components on the top edge of the PKBattleView.

- [ZegoLiveStreamingPKBattleViewBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKBattleViewBuilder.html)? `pkBattleViewBottomBuilder`: to add custom components on the bottom edge of the PKBattleView.

## [ZegoLiveStreamingDurationConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingDurationConfig-class.html) duration

>
>  Live Streaming timing configuration.
>
>  To calculate the livestream duration, do the following:
>  1. Set the [ZegoLiveStreamingDurationConfig.isVisible] property of [ZegoLiveStreamingDurationConfig] to display the current timer. (It is displayed by default)
>  2. Assuming that the livestream duration is 5 minutes, the livestream will automatically end when the time is up (refer to the following code). You will be notified of the end of the livestream duration through [ZegoLiveStreamingDurationConfig.onDurationUpdate]. To end the livestream, you can call the [ZegoUIKitPrebuiltLiveStreamingController.leave()] method.
>
>  ```dart
>   ..duration.isVisible = true
>  ```
> <img src = "https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/live/live_duration.jpeg" width=50% />


- bool `isVisible`: whether to display Live Streaming timing.

## [ZegoBeautyPluginConfig](https://pub.dev/documentation/zego_plugin_adapter/latest/zego_plugin_adapter/ZegoBeautyPluginConfig-class.html)? beauty

>
>  advance beauty config

- List\<[ZegoBeautyPluginEffectsType](https://pub.dev/documentation/zego_plugin_adapter/latest/zego_plugin_adapter/ZegoBeautyPluginEffectsType.html)\> `effectsTypes`

- [ZegoBeautyPluginInnerText](https://pub.dev/documentation/zego_plugin_adapter/latest/zego_plugin_adapter/ZegoBeautyPluginInnerText-class.html) `innerText`

- [ZegoBeautyPluginUIConfig](https://pub.dev/documentation/zego_plugin_adapter/latest/zego_plugin_adapter/ZegoBeautyPluginUIConfig-class.html) `uiConfig`:
  - Color? `backgroundColor`
  - Color? `selectedIconBorderColor`
  - Color? `selectedIconDotColor`
  - TextStyle? `selectedTextStyle`
  - TextStyle? `normalTextStyle`
  - TextStyle? `sliderTextStyle`
  - Color? `sliderTextBackgroundColor`
  - Color? `sliderActiveTrackColor`
  - Color? `sliderInactiveTrackColor`
  - Color? `sliderThumbColor`
  - double? `sliderThumbRadius`
  - Widget? `backIcon`
  - TextStyle? `normalHeaderTitleTextStyle`
  - TextStyle? `selectHeaderTitleTextStyle`

- String? `segmentationBackgroundImageName`: backgroundPortraitSegmentation feature need use this path.

- bool `enableFaceDetection`: if true, can use getFaceDetection to notify face detection.

- [ZegoBeautyPluginSegmentationScaleMode](https://pub.dev/documentation/zego_plugin_adapter/latest/zego_plugin_adapter/ZegoBeautyPluginSegmentationScaleMode.html) `segmentationScaleMode`

## [ZegoLiveStreamingSwipingConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingSwipingConfig-class.html)? swiping

>
>  swiping config, if you wish to use swiping, please configure this config.
>  if it is null, this swiping will not be enabled.
>  the [liveID] will be the initial live id of swiping

- String Function() `requirePreviousLiveID`: slide to the previous live streaming, you need to return the LIVE ID of the previous live streaming.

- String Function() `requireNextLiveID`: slide to the next live streaming, you need to return the LIVE ID of the next live streaming.

- Widget Function(String liveID)? `loadingBuilder`: customize room loading effects

## [ZegoLiveStreamingCoHostConfig](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingCoHostConfig-class.html)? coHost

- bool Function()? `turnOnCameraWhenCohosted`:
>
>  whether to enable the camera by default when you be co-host, the default value is true
>  Every time you become a co-host again, it will re-read this configuration to check if enable the camera

- bool `stopCoHostingWhenMicCameraOff`:
>
>  controls whether to automatically stop co-hosting when both the camera and microphone are turned off, the default value is false.
>
>  If the value is set to true, the user will stop co-hosting automatically when both camera and microphone are off.
>  If the value is set to false, the user will keep co-hosting until manually stop co-hosting by clicking the "End" button.

- bool `disableCoHostInvitationReceivedDialog`:
>
>  used to determine whether to display a confirmation dialog to the
>  audience when they receive a co-host invitation, the default value is false
>
>  If the value is True, the confirmation dialog will not be displayed.
>  If the value is False, the confirmation dialog will be displayed.
>
>  You can adjust and set this variable according to your specific requirements.

- int `maxCoHostCount`:
>
>  Maximum number of co-hosts.
>
>  If exceeded, other audience members cannot become co-hosts.
>  The default value is 12.

- int `inviteTimeoutSecond`: timeout second when invite other to co-host

## [ZegoLiveStreamingRole](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingRole.html) role

>
>  Specifies the initial role when joining the live streaming.
>
>  The role change after joining is not constrained by this property.
> ```dart
>
> /// Live streaming roles.
> enum ZegoLiveStreamingRole {
> /// Host
> host,
> 
> /// Co-host, will become an audience after cancelling co-hosting.
> coHost,
> 
> /// Audience, can become a co-host through co-hosting.
> audience,
> }
> ```


## List\<IZegoUIKitPlugin\> plugins


>
> Plugins, currently supports signaling, beauty.
> if you need cohost function, you need to install [ZegoUIKitSignalingPlugin]

## bool turnOnCameraWhenJoining

>
>  Whether to open the camera when joining the live streaming.
>
>  If you want to join the live streaming with your camera closed, set this value to false;
>  if you want to join the live streaming with your camera open, set this value to true.
>  The default value is `true`.
>
>  Note that this parameter is independent of the user's role.
>  Even if the user is an audience, they can set this value to true, but in general, if the role is an audience, this value should be set to false.

## bool turnOnMicrophoneWhenJoining

>
>  Whether to open the microphone when joining the live streaming.
>
>  If you want to join the live streaming with your microphone closed, set this value to false;
>  if you want to join the live streaming with your microphone open, set this value to true.
>  The default value is `true`.
>
>  Note that this parameter is independent of the user's role.
>  Even if the user is an audience, they can set this value to true, and they can start chatting with others through voice after joining the room.
>  Therefore, in general, if the role is an audience, this value should be set to false.

## bool useSpeakerWhenJoining

>
>  Whether to use the speaker to play audio when joining the live streaming.
>
>  The default value is `true`.
>  If this value is set to `false`, the system's default playback device, such as the earpiece or Bluetooth headset, will be used for audio playback.

## [ZegoLiveStreamingDialogInfo](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingDialogInfo-class.html)? confirmDialogInfo

>
>  Confirmation dialog information when leaving the live streaming.
>
>  If not set, clicking the exit button will directly exit the live streaming.
>
>  If set, a confirmation dialog will be displayed when clicking the exit button, and you will need to confirm the exit before actually exiting.
>
>  Sample Code:
>
>  ```dart
>   ..confirmDialogInfo = ZegoDialogInfo(
>     title: 'Leave confirm',
>     message: 'Do you want to end?',
>     cancelButtonName: 'Cancel',
>     confirmButtonName: 'Confirm',
>   )
>  ```
> <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/live/live_confirm.gif" width=50%/>

## [ZegoLayout](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoLayout-class.html)? layout

>
>  Layout-related configuration. You can choose your layout here. such as [layout = ZegoLayout.gallery()]


## [ZegoUIKitPrebuiltLiveStreamingInnerText](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingInnerText-class.html) innerText

>
> Configuration options for modifying all text content on the UI.
>
> All visible text content on the UI can be modified using this single property.

## bool rootNavigator

>
>  same as Flutter's Navigator's param
>
>  If `rootNavigator` is set to true, the state from the furthest instance of this class is given instead.
>  Useful for pushing contents above all subsequent instances of [Navigator].

## [ZegoAvatarBuilder](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoAvatarBuilder.html)? avatarBuilder

>
>  Use this to customize the avatar, and replace the default avatar with it.
>
>  Example：
>
>  ```dart
>   // eg:
>   avatarBuilder: (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
>     return user != null
>         ? Container(
>             decoration: BoxDecoration(
>               shape: BoxShape.circle,
>               image: DecorationImage(
>                 image: NetworkImage(
>                   'https://robohash.org/01.png',
>                 ),
>               ),
>             ),
>           )
>         : const SizedBox();
>   },
>  ```
>  <img src="https://storage.zego.im/sdk-doc/Pics/zegocloud/api/flutter/live/avatar_builder.png" width=50%/>

## bool markAsLargeRoom

>
>   Mark is large room or not
>
>   sendInRoomCommand will sending to everyone in the room if true
>   that mean [toUserIDs] of [sendInRoomCommand] function is disabled if true

## bool slideSurfaceToHide

>
>  set whether the surface can be slid to hide, including the top toolbar, bottom toolbar, message list, and foreground

## Widget? foreground

>
>  The foreground of the live streaming.
>
>  If you need to nest some widgets in [ZegoUIKitPrebuiltLiveStreaming], please use [foreground] nesting, otherwise these widgets will be lost when you minimize and restore the [ZegoUIKitPrebuiltLiveStreaming]

## Widget? background

>
>  The background of the live streaming.
>
>  You can use any Widget as the background of the live streaming, such as a video, a GIF animation, an image, a web page, etc.
>  If you need to dynamically change the background content, you will need to implement the logic for dynamic modification within the Widget you return.
>
>  ```dart
>  ..background = Container(
>      decoration: const BoxDecoration(
>        image: DecorationImage(
>          fit: BoxFit.fitHeight,
>          image: ,
>        )
>     )
>   );
>  ```


## bool showBackgroundTips

>
>  show background tips of live or not, default tips is 'No host is online.'

## Map<String, String> advanceConfigs

>
>  Set advanced engine configuration, Used to enable advanced functions.
>  For details, please consult ZEGO technical support.
