# Configs

- [ZegoUIKitPrebuiltLiveStreamingConfig](#zegouikitprebuiltlivestreamingconfig)
- [ZegoLiveStreamingAudioVideoViewConfig](#zegolivestreamingaudiovideoviewconfig)
- [ZegoLiveStreamingTopMenuBarConfig](#zegolivestreamingtopmenubarconfig)
- [ZegoLiveStreamingBottomMenuBarConfig](#zegolivestreamingbottommenubarconfig)
- [ZegoLiveStreamingMemberButtonConfig](#zegolivestreamingmemberbuttonconfig)
- [ZegoLiveStreamingMemberListConfig](#zegolivestreamingmemberlistconfig)
- [ZegoLiveStreamingInRoomMessageConfig](#zegolivestreaminginroommessageconfig)
- [ZegoLiveStreamingEffectConfig](#zegolivestreamingeffectconfig)
- [ZegoLiveStreamingPKBattleConfig](#zegolivestreamingpkbattleconfig)
- [ZegoLiveStreamingPreviewConfig](#zegolivestreamingpreviewconfig)
- [ZegoLiveStreamingHallConfig](#zegolivestreaminghallconfig)
- [ZegoLiveStreamingSwipingConfig](#zegolivestreamingswipingconfig)
- [ZegoLiveStreamingDurationConfig](#zegolivestreamingdurationconfig)
- [ZegoLiveStreamingSignalingPluginConfig](#zegolivestreamingsignalingpluginconfig)
- [ZegoLiveStreamingScreenSharingConfig](#zegolivestreamingscreensharingconfig)
- [ZegoLiveStreamingMediaPlayerConfig](#zegolivestreamingmediaplayerconfig)
- [ZegoLiveStreamingPIPConfig](#zegolivestreamingpipconfig)
- [ZegoLiveStreamingCoHostConfig](#zegolivestreamingcohostconfig)
- [ZegoLiveStreamingMenuBarExtendButton](#zegolivestreamingmenubarextendbutton)
- [ZegoLiveStreamingBottomMenuBarButtonStyle](#zegolivestreamingbottommenubarbuttonstyle)

---

## ZegoUIKitPrebuiltLiveStreamingConfig

Configuration for initializing the Live Streaming.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| video | Configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate. | `ZegoUIKitVideoConfig` | `ZegoVideoConfigExtension.preset360P()` |
| audioVideoView | Configuration options for audio/video views. | `ZegoLiveStreamingAudioVideoViewConfig` | |
| mediaPlayer | Configuration options for media player. | `ZegoLiveStreamingMediaPlayerConfig` | |
| screenSharing | Screen sharing configuration. | `ZegoLiveStreamingScreenSharingConfig` | |
| pip | Picture-in-Picture (PIP) configuration. | `ZegoLiveStreamingPIPConfig` | |
| topMenuBar | Configuration options for the top menu bar (toolbar). | `ZegoLiveStreamingTopMenuBarConfig` | |
| bottomMenuBar | Configuration options for the bottom menu bar (toolbar). | `ZegoLiveStreamingBottomMenuBarConfig` | |
| memberButton | Configuration related to the top member button. | `ZegoLiveStreamingMemberButtonConfig` | |
| memberList | Configuration related to the member list. | `ZegoLiveStreamingMemberListConfig` | |
| inRoomMessage | Control options for the bottom-left message list. | `ZegoLiveStreamingInRoomMessageConfig` | |
| effect | Configuration options for voice changer, beauty effects and reverberation effects. | `ZegoLiveStreamingEffectConfig` | |
| preview | Used to configure the parameters related to the preview of the live streaming. | `ZegoLiveStreamingPreviewConfig` | |
| hall | Configuration for Hall. | `ZegoLiveStreamingHallConfig` | |
| swiping | Configuration for Swiping. | `ZegoLiveStreamingSwipingConfig?` | `null` |
| pkBattle | Configuration for PK Battle. | `ZegoLiveStreamingPKBattleConfig` | |
| duration | Configuration for Duration. | `ZegoLiveStreamingDurationConfig` | |
| signalingPlugin | Configuration for Signaling Plugin. | `ZegoLiveStreamingSignalingPluginConfig` | |
| beauty | Configuration for Beauty. | `ZegoBeautyPluginConfig?` | `null` |
| coHost | Configuration for CoHost. | `ZegoLiveStreamingCoHostConfig` | |
| role | Role of the user. | `ZegoLiveStreamingRole` | `ZegoLiveStreamingRole.audience` |
| plugins | Plugins, currently supports signaling, beauty. | `List<IZegoUIKitPlugin>` | `[]` |
| turnOnCameraWhenJoining | Whether to turn on camera when joining. | `bool` | `true` |
| useFrontFacingCamera | Whether to use front facing camera. | `bool` | `true` |
| turnOnMicrophoneWhenJoining | Whether to turn on microphone when joining. | `bool` | `true` |
| useSpeakerWhenJoining | Whether to use speaker when joining. | `bool` | `true` |
| confirmDialogInfo | Confirm dialog info. | `ZegoLiveStreamingDialogInfo?` | `null` |
| innerText | Inner text configuration. | `ZegoUIKitPrebuiltLiveStreamingInnerText` | |
| layout | Layout configuration. | `ZegoLayout?` | `null` |
| rootNavigator | Whether to use root navigator. | `bool` | `false` |
| avatarBuilder | Avatar builder. | `ZegoAvatarBuilder?` | `null` |
| markAsLargeRoom | Mark is large room or not. | `bool` | `false` |
| slideSurfaceToHide | Set whether the surface can be slid to hide. | `bool` | `true` |
| foreground | The foreground of the live streaming. | `Widget?` | `null` |
| background | The background of the live streaming. | `Widget?` | `null` |
| showBackgroundTips | Show background tips of live or not. | `bool` | `false` |
| advanceConfigs | Set advanced engine configuration. | `Map<String, String>` | `{}` |
| audienceAudioVideoResourceMode | Audio video resource mode for audience. | `ZegoUIKitStreamResourceMode?` | `null` |
| showToast | Whether to show toast. | `bool` | `false` |

---

## ZegoLiveStreamingAudioVideoViewConfig

Configuration options for audio/video views.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| visible | Show target user's audio video view or not. | `bool Function(ZegoUIKitUser localUser, ZegoLiveStreamingRole localRole, ZegoUIKitUser targetUser, ZegoLiveStreamingRole targetUserRole)?` | `null` |
| playCoHostAudio | Whether to play audio of the specified co-host. | `ZegoPlayCoHostAudioVideoCallback?` | `null` |
| playCoHostVideo | Whether to play video of the specified co-host. | `ZegoPlayCoHostAudioVideoCallback?` | `null` |
| isVideoMirror | Whether to mirror the video. | `bool` | `true` |
| showMicrophoneStateOnView | Whether to display the microphone state on the audio/video view. | `bool` | `true` |
| showUserNameOnView | Whether to display the username on the audio/video view. | `bool` | `true` |
| useVideoViewAspectFill | Whether to use AspectFill for video view. | `bool` | `true` |
| showAvatarInAudioMode | Whether to show avatar in audio mode. | `bool` | `true` |
| showSoundWavesInAudioMode | Whether to show sound waves in audio mode. | `bool` | `true` |
| containerBuilder | Custom audio/video view container builder. | `ZegoLiveStreamingAudioVideoContainerBuilder?` | `null` |
| containerRect | Custom container rect. | `Rect Function()?` | `null` |
| foregroundBuilder | Custom foreground builder. | `ZegoAudioVideoViewForegroundBuilder?` | `null` |
| backgroundBuilder | Custom background builder. | `ZegoAudioVideoViewBackgroundBuilder?` | `null` |

---

## ZegoLiveStreamingTopMenuBarConfig

Configuration options for the top menu bar (toolbar).

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| buttons | Buttons displayed on the menu bar. | `List<ZegoLiveStreamingMenuBarButtonName>` | `[]` |
| padding | Padding. | `EdgeInsetsGeometry?` | `null` |
| margin | Margin. | `EdgeInsetsGeometry?` | `null` |
| backgroundColor | Background color. | `Color?` | `null` |
| height | Height. | `double?` | `null` |
| hostAvatarBuilder | Custom host avatar builder. | `Widget Function(ZegoUIKitUser host)?` | `null` |
| showCloseButton | Whether to show the close button. | `bool` | `true` |

---

## ZegoLiveStreamingBottomMenuBarConfig

Configuration options for the bottom menu bar (toolbar).

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| showInRoomMessageButton | Whether to display the room message button. | `bool` | `true` |
| hostButtons | Buttons for host. | `List<ZegoLiveStreamingMenuBarButtonName>` | |
| coHostButtons | Buttons for co-host. | `List<ZegoLiveStreamingMenuBarButtonName>` | |
| audienceButtons | Buttons for audience. | `List<ZegoLiveStreamingMenuBarButtonName>` | `[]` |
| hostExtendButtons | Extension buttons for host. | `List<ZegoLiveStreamingMenuBarExtendButton>` | `[]` |
| coHostExtendButtons | Extension buttons for co-host. | `List<ZegoLiveStreamingMenuBarExtendButton>` | `[]` |
| audienceExtendButtons | Extension buttons for audience. | `List<ZegoLiveStreamingMenuBarExtendButton>` | `[]` |
| maxCount | Maximum number of buttons to be displayed. | `int` | `5` |
| buttonStyle | Button style. | `ZegoLiveStreamingBottomMenuBarButtonStyle?` | `null` |
| padding | Padding. | `EdgeInsetsGeometry?` | `null` |
| margin | Margin. | `EdgeInsetsGeometry?` | `null` |
| backgroundColor | Background color. | `Color?` | `null` |
| height | Height. | `double?` | `null` |

---

## ZegoLiveStreamingMemberButtonConfig

Configuration related to the top member button.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| builder | Custom builder. | `ZegoLiveStreamingMemberButtonBuilder?` | `null` |
| icon | Icon. | `Widget?` | `null` |
| backgroundColor | Background color. | `Color?` | `null` |

---

## ZegoLiveStreamingMemberListConfig

Configuration related to the member list.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| itemBuilder | Custom member list item builder. | `ZegoMemberListItemBuilder?` | `null` |
| showFakeUser | Whether to show fake user. | `bool` | `true` |

---

## ZegoLiveStreamingInRoomMessageConfig

Control options for the bottom-left message list.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| visible | Whether the message list is visible. | `bool` | `true` |
| notifyUserJoin | Whether to notify user join. | `bool` | `false` |
| notifyUserLeave | Whether to notify user leave. | `bool` | `false` |
| attributes | Message attributes. | `Map<String, String> Function()?` | `null` |
| width | Width. | `double?` | `null` |
| height | Height. | `double?` | `null` |
| bottomLeft | Bottom-left position. | `Offset?` | `null` |
| itemBuilder | Custom item builder. | `ZegoInRoomMessageItemBuilder?` | `null` |
| avatarLeadingBuilder | Custom avatar leading builder. | `ZegoInRoomMessageItemBuilder?` | `null` |
| avatarTailingBuilder | Custom avatar tailing builder. | `ZegoInRoomMessageItemBuilder?` | `null` |
| nameLeadingBuilder | Custom name leading builder. | `ZegoInRoomMessageItemBuilder?` | `null` |
| nameTailingBuilder | Custom name tailing builder. | `ZegoInRoomMessageItemBuilder?` | `null` |
| textLeadingBuilder | Custom text leading builder. | `ZegoInRoomMessageItemBuilder?` | `null` |
| textTailingBuilder | Custom text tailing builder. | `ZegoInRoomMessageItemBuilder?` | `null` |
| opacity | Opacity. | `double` | `0.5` |
| maxLines | Max lines. | `int?` | `null` |
| nameTextStyle | Name text style. | `TextStyle?` | `null` |
| messageTextStyle | Message text style. | `TextStyle?` | `null` |
| backgroundColor | Background color. | `Color?` | `null` |
| borderRadius | Border radius. | `BorderRadiusGeometry?` | `null` |
| paddings | Paddings. | `EdgeInsetsGeometry?` | `null` |
| resendIcon | Resend icon. | `Widget?` | `null` |
| background | Background widget. | `Widget?` | `null` |
| showName | Whether to show name. | `bool` | `true` |
| showAvatar | Whether to show avatar. | `bool` | `true` |
| showFakeMessage | Whether to show fake message. | `bool` | `true` |

---

## ZegoLiveStreamingEffectConfig

Configuration options for voice changer, beauty effects and reverberation effects.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| beautyEffects | Beauty effects. | `List<BeautyEffectType>` | |
| voiceChangeEffect | Voice change effects. | `List<VoiceChangerType>` | |
| reverbEffect | Reverb effects. | `List<ReverbType>` | |
| backgroundColor | Background color. | `Color?` | `null` |
| headerTitleTextStyle | Header title text style. | `TextStyle?` | `null` |
| backIcon | Back icon. | `Widget?` | `null` |
| resetIcon | Reset icon. | `Widget?` | `null` |
| normalIconColor | Normal icon color. | `Color?` | `null` |
| selectedIconColor | Selected icon color. | `Color?` | `null` |
| normalIconBorderColor | Normal icon border color. | `Color?` | `null` |
| selectedIconBorderColor | Selected icon border color. | `Color?` | `null` |
| selectedTextStyle | Selected text style. | `TextStyle?` | `null` |
| normalTextStyle | Normal text style. | `TextStyle?` | `null` |
| sliderTextStyle | Slider text style. | `TextStyle?` | `null` |
| sliderTextBackgroundColor | Slider text background color. | `Color?` | `null` |
| sliderActiveTrackColor | Slider active track color. | `Color?` | `null` |
| sliderInactiveTrackColor | Slider inactive track color. | `Color?` | `null` |
| sliderThumbColor | Slider thumb color. | `Color?` | `null` |
| sliderThumbRadius | Slider thumb radius. | `double?` | `null` |

---

## ZegoLiveStreamingPKBattleConfig

Configuration for PK Battle.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| userReconnectingSecond | User reconnecting second. | `int` | `5` |
| userDisconnectedSecond | User disconnected second. | `int` | `90` |
| mixerLayout | Mixer layout. | `ZegoLiveStreamingPKMixerLayout?` | `null` |
| hostReconnectingBuilder | Host reconnecting builder. | `ZegoLiveStreamingPKBattleHostReconnectingBuilder?` | `null` |
| topPadding | PK battle view top padding. | `double?` | `null` |
| containerRect | Custom container rect. | `Rect Function()?` | `null` |
| foregroundBuilder | Custom foreground builder. | `ZegoLiveStreamingPKBattleViewBuilder?` | `null` |
| topBuilder | Custom top builder. | `ZegoLiveStreamingPKBattleViewBuilder?` | `null` |
| bottomBuilder | Custom bottom builder. | `ZegoLiveStreamingPKBattleViewBuilder?` | `null` |
| hostResumePKConfirmDialogInfo | Host resume PK confirm dialog info. | `ZegoLiveStreamingDialogInfo?` | `null` |

---

## ZegoLiveStreamingPreviewConfig

Used to configure the parameters related to the preview of the live streaming.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| showPreviewForHost | Whether to show preview for host. | `bool` | `true` |
| pageBackIcon | Page back icon. | `Widget?` | `null` |
| beautyEffectIcon | Beauty effect icon. | `Widget?` | `null` |
| switchCameraIcon | Switch camera icon. | `Widget?` | `null` |
| startLiveButtonBuilder | Custom start live button builder. | `ZegoLiveStreamingStartLiveButtonBuilder?` | `null` |
| topBar | Top bar config. | `ZegoLiveStreamingPreviewTopBarConfig` | |
| bottomBar | Bottom bar config. | `ZegoLiveStreamingPreviewBottomBarConfig` | |

### ZegoLiveStreamingPreviewTopBarConfig

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| isVisible | Whether visible. | `bool` | `true` |

### ZegoLiveStreamingPreviewBottomBarConfig

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| isVisible | Whether visible. | `bool` | `true` |
| showBeautyEffectButton | Whether to show beauty effect button. | `bool` | `true` |

---

## ZegoLiveStreamingHallConfig

Configuration for Hall.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| fromHall | Whether it is entered from the hall. | `bool` | `false` |
| loadingBuilder | Custom loading builder. | `Widget? Function(BuildContext context)?` | `null` |

---

## ZegoLiveStreamingSwipingConfig

Configuration for Swiping.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| streamMode | Stream mode. | `ZegoLiveStreamingStreamMode` | `ZegoLiveStreamingStreamMode.preloaded` |
| model | Swiping model. | `ZegoLiveStreamingSwipingModel?` | `null` |
| modelDelegate | Swiping model delegate. | `ZegoLiveStreamingSwipingModelDelegate?` | `null` |

---

## ZegoLiveStreamingDurationConfig

Configuration for Duration.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| isVisible | Whether to show duration. | `bool` | `true` |

---

## ZegoLiveStreamingSignalingPluginConfig

Configuration for Signaling Plugin.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| leaveRoomOnDispose | Whether to leave room on dispose. | `bool` | `true` |
| uninitOnDispose | Whether to uninit on dispose. | `bool` | `true` |

---

## ZegoLiveStreamingScreenSharingConfig

Screen sharing configuration.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| autoStop | Auto stop configuration. | `ZegoLiveStreamingScreenSharingAutoStopConfig` | |
| defaultFullScreen | Whether to automatically be full screen when there is screen sharing display. | `bool` | `false` |

### ZegoLiveStreamingScreenSharingAutoStopConfig

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| invalidCount | Count of the check fails before automatically end the screen sharing. | `int` | `3` |
| canEnd | Determines whether to end. | `bool Function()?` | `null` |

---

## ZegoLiveStreamingMediaPlayerConfig

Configuration options for media player.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| supportTransparent | Whether to support transparency (iOS only). | `bool` | `false` |
| defaultPlayer | Default player configuration. | `ZegoLiveStreamingMediaPlayerDefaultPlayerConfig` | |

### ZegoLiveStreamingMediaPlayerDefaultPlayerConfig

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| support | Whether to support default player. | `bool` | `false` |
| rolesCanControl | Roles that can control the media player. | `List<ZegoLiveStreamingRole>` | `[ZegoLiveStreamingRole.host]` |
| topLeftQuery | Top-left position query. | `Point<double> Function(ZegoLiveStreamingMediaPlayerQueryParameter)?` | `null` |
| rectQuery | Rect query. | `Rect Function(ZegoLiveStreamingMediaPlayerQueryParameter)?` | `null` |
| configQuery | Config query. | `ZegoUIKitMediaPlayerConfig? Function(ZegoLiveStreamingMediaPlayerQueryParameter)?` | `null` |
| styleQuery | Style query. | `ZegoUIKitMediaPlayerStyle? Function(ZegoLiveStreamingMediaPlayerQueryParameter)?` | `null` |

---

## ZegoLiveStreamingPIPConfig

Picture-in-Picture (PIP) configuration.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| aspectWidth | Aspect width. | `int` | `9` |
| aspectHeight | Aspect height. | `int` | `16` |
| enableWhenBackground | Whether to enable PIP when background. | `bool` | `true` |
| android | Android specific configuration. | `ZegoLiveStreamingPIPAndroidConfig` | |
| iOS | iOS specific configuration. | `ZegoLiveStreamingPIPIOSConfig` | |

### ZegoLiveStreamingPIPAndroidConfig

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| background | Background widget. | `Widget?` | `null` |

### ZegoLiveStreamingPIPIOSConfig

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| support | Whether to support PIP on iOS. | `bool` | `true` |

---

## ZegoLiveStreamingCoHostConfig

Configuration for CoHost.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| turnOnCameraWhenCohosted | Whether to turn on camera when co-host. | `bool Function()?` | `null` |
| stopCoHostingWhenMicCameraOff | Whether to stop co-hosting when mic and camera are off. | `bool` | `false` |
| disableCoHostInvitationReceivedDialog | Whether to disable co-host invitation received dialog. | `bool` | `false` |
| maxCoHostCount | Max co-host count. | `int` | `12` |
| inviteTimeoutSecond | Invite timeout second. | `int` | `60` |

---

## ZegoLiveStreamingMenuBarExtendButton

Extension buttons for the bottom toolbar.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| index | Index of buttons within the entire bottom toolbar. | `int` | `-1` |
| child | Button widget. | `Widget` | |

---

## ZegoLiveStreamingBottomMenuBarButtonStyle

Button style for the bottom toolbar.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| chatEnabledButtonIcon | Icon for enabling chat. | `Widget?` | `null` |
| chatDisabledButtonIcon | Icon for disabling chat. | `Widget?` | `null` |
| toggleMicrophoneOnButtonIcon | Icon for toggling microphone on. | `Widget?` | `null` |
| toggleMicrophoneOffButtonIcon | Icon for toggling microphone off. | `Widget?` | `null` |
| toggleCameraOnButtonIcon | Icon for toggling camera on. | `Widget?` | `null` |
| toggleCameraOffButtonIcon | Icon for toggling camera off. | `Widget?` | `null` |
| switchCameraButtonIcon | Icon for switching camera. | `Widget?` | `null` |
| switchAudioOutputToSpeakerButtonIcon | Icon for switching audio output to speaker. | `Widget?` | `null` |
| switchAudioOutputToHeadphoneButtonIcon | Icon for switching audio output to headphone. | `Widget?` | `null` |
| switchAudioOutputToBluetoothButtonIcon | Icon for switching audio output to Bluetooth. | `Widget?` | `null` |
| leaveButtonIcon | Icon for leaving the room. | `Widget?` | `null` |
| requestCoHostButtonIcon | Icon for requesting co-host status. | `Widget?` | `null` |
| requestCoHostButtonText | Text for requesting co-host status button. | `String?` | `null` |
| cancelRequestCoHostButtonIcon | Icon for canceling co-host request. | `Widget?` | `null` |
| cancelRequestCoHostButtonText | Text for canceling co-host request button. | `String?` | `null` |
| endCoHostButtonIcon | Icon for ending co-host status. | `Widget?` | `null` |
| endCoHostButtonText | Text for ending co-host status button. | `String?` | `null` |
| beautyEffectButtonIcon | Icon for beauty effect. | `Widget?` | `null` |
| soundEffectButtonIcon | Icon for sound effect. | `Widget?` | `null` |
| enableChatButtonIcon | Icon for enabling chat. | `Widget?` | `null` |
| disableChatButtonIcon | Icon for disabling chat. | `Widget?` | `null` |
| toggleScreenSharingOnButtonIcon | Icon for toggling screen sharing on. | `Widget?` | `null` |
| toggleScreenSharingOffButtonIcon | Icon for toggling screen sharing off. | `Widget?` | `null` |

