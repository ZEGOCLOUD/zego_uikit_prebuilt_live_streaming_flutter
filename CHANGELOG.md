## 2.25.0

- payload attribute by message, add **attributes** in **ZegoInRoomMessageConfig**, that's message attributes of local user, which will be appended to the message body. if set, [userAttributes] 
  will be sent along with the message body.
- builder in message，add more leading/tailing builder for customizing the widget in **ZegoInRoomMessageConfig**.
  for avatar, name or text part in default message display，all have the builder on leading or tailing.
  Please note that if you use [itemBuilder], this granular builder will be ignored.

## 2.24.2

- Update dependency.

## 2.24.1

- Fix the issue of video shaking caused by chat input.

## 2.24.0

- Add a host notifier, which allows you to monitor change in host from here.

## 2.23.1

- Fixed an issue where the co-host invitation feature was still being displayed at host member list even when coHostControlButton was not set in bottomMenuBarConfig.audienceButtons.

## 2.23.0

- Support multiplayer PK.

## 2.22.4

- Update dependency.

## 2.22.3

- Compatible with AppLifecycleState.hidden in flutter 3.13.0

## 2.22.2

- Optimization warnings from analysis

## 2.22.1

- Optimization warnings from analysis

## 2.22.0

- Support listening for errors in the beauty and signaling plugins and uikit library.

## 2.21.3

- Fix the issue of losing the host window when manually calling the ZegoUIKit().**turnMicrophoneOn**(false, muteMode:true) API to mute host after configuring **audioVideoViewConfig.playCoHostAudio**.

## 2.21.2

- update dart dependency

## 2.21.1

- Update dependency.

## 2.21.0

- Fixed an issue where swiping was not functioning when the signaling plugin was not installed.
- Fixed an issue where viewers were unable to successfully initiate a co-hosting request after rejoining the same live broadcast following their previous exit.
- PIP Layout now supports scrolling by default. You can disable scrolling by setting the **isSmallViewsScrollable** parameter in **ZegoLayout.pictureInPicture()**.
- PIP Layout now allows configuring the number of visible items. You can specify the number of visible items by setting the **visibleSmallViewsCount** parameter in **ZegoLayout.pictureInPicture()**.
  The default value is 3.
- Gallery Layout now supports setting margins. You can set by the **margin** parameter in **ZegoLayout.gallery()**, after setting the margins, the content
  will be centered, allowing you to display your own widgets in the surrounding empty space.

## 2.20.1

- remove http library dependency.

## 2.20.0

- Added a new configuration option **slideSurfaceToHide** to the config. This option controls whether the surface can be slid to hide, including the top toolbar, bottom toolbar,
  message list, and foreground.

## 2.19.1

- Accommodate the failure to enter the room caused by the returned room ID being empty in the config when slide live streaming.

## 2.19.0

- Added a new configuration option **ZegoTopMenuBarConfig.showCloseButton**.

## 2.18.1

- Update dependency.

## 2.18.0

- Fixed an issue where the events events.audienceEvents.onActionAcceptCoHostInvitation and events.audienceEvents.onActionRefuseCoHostInvitation were not triggered after calling the methods
  audienceAgreeCoHostInvitation and audienceRejectCoHostInvitation in the controller.
- Added a new configuration option **disableCoHostInvitationReceivedDialog** to the config. This option controls whether the audience is prompted with a co-host invitation dialog when receiving a
  co-host invitation from the host.

## 2.17.1

- Update dependency.

## 2.17.0

- Add a series of co-hosting event callbacks, you can register the callbacks using **ZegoUIKitPrebuiltLiveStreamingEvents**.
- Fix the issue where the co-host window in the host disappears when co-host turns off the camera and microphone, caused by using **ZegoPrebuiltAudioVideoViewConfig.visible**.

## 2.16.0

- Add **advanceConfigs** config, which to set advanced engine configuration

## 2.15.5

- Fix the issue where the co-host window in the host disappears when co-host turns off the camera and microphone, when the configuration **stopCoHostingWhenMicCameraOff** is set to false.

## 2.15.4

- fix pk-battle auto start issue

## 2.15.3

- update dependency

## 2.15.2

- update dependency

## 2.15.1

- Hide background tips by default. If you want to show them, they can be configured through **ZegoUIKitPrebuiltLiveStreamingConfig.showBackgroundTips**.
- Add liveID in **ZegoLiveStreamingSwipingConfig.loadingBuilder**

## 2.15.0

- Supports up and down swiping during live streaming through configuration of **ZegoUIKitPrebuiltLiveStreamingConfig.swipingConfig**.

## 2.14.3

- Optimizing code for chat widget

## 2.14.2

- Added connect-invitation-related APIs in the **ZegoUIKitPrebuiltLiveStreamingController**, which can be called through **ZegoUIKitPrebuiltLiveStreamingController.connectInvite**.

## 2.14.1

- Optimized the notification events form for the audience request co-host, removed **registerCoHostEventsForHost**, and split it into **onRequestCoHostEvent**, **onCancelCoHostEvent**, and
  **onRequestCoHostTimeoutEvent**.

## 2.14.0

- Added connection-related APIs in the **ZegoUIKitPrebuiltLiveStreamingController**, which can be called through **ZegoUIKitPrebuiltLiveStreamingController.connect**.
- Added notifications for click and long-press events in the chat message, which can be monitored through **ZegoInRoomMessageConfig.onMessageClick** and **ZegoInRoomMessageConfig.onMessageLongPress**.
- Support set chat background by **ZegoInRoomMessageConfig.background**.
- Support customization of member button by **ZegoMemberButtonConfig**.
- Support customization of the host avatar in the top left corner by **ZegoTopMenuBarConfig.hostAvatarBuilder**.

## 2.13.0

- Added message sending and receiving API to the controller.
- Added handling for local message sending failures. When a local message fails to send, it can be retried by clicking the icon. The icon can be customized through **
  ZegoInRoomMessageConfig.resendIcon**.
- Added avatar display to messages by default. If avatars are not desired, they can be hidden through **ZegoInRoomMessageConfig.showAvatar**.
- Adjusted the message display to default to showing the entire content. If not all content needs to be displayed, the maximum number of displayed lines can be modified through
  **ZegoInRoomMessageConfig.maxLines**. When the maximum number of lines is exceeded, the message will automatically collapse.
- Supported customizing the location of the message display container. The offset value of the bottom left corner can be set through **ZegoInRoomMessageConfig.bottomLeft** to adjust the position.
- Supported dynamically configuring whether the audio/video data of each co-host plays. This can be customized through **ZegoPrebuiltAudioVideoViewConfig.playCoHostVideo** and **
  ZegoPrebuiltAudioVideoViewConfig.playCoHostAudio**.
- Supported dynamically configuring the display and hiding of each co-host window. This can be customized through **ZegoPrebuiltAudioVideoViewConfig.visible**.

## 2.12.9

- Fixed the issue of not receiving calls when prebuilt_call is used in conjunction with prebuilt_live_streaming.

## 2.12.8

- update dependency

## 2.12.7

- Update dependencies

## 2.12.6

- update dependency

## 2.12.5

- Update dependencies

## 2.12.4

- Fixed the issue where the bottom toolbar margin setting was not taking effect.

## 2.12.3

- Fixed an issue where co-host would be stop co-hosting when the host turned off their microphone.
- Changed the default behavior for co-host to not stop co-hosting when turning off their camera or microphone.

## 2.12.2

- Support for calling the leave method of the controller to exit the live stream while in-app minimization.

## 2.12.1

- Optimizing timing function.

## 2.12.0

- Support auto start pk when hosts invite each other

## 2.11.3

- Fix the issue of the beauty effect not working

## 2.11.2

- compatible with `inRoomMessageViewConfig`

## 2.11.1

- Update comments

## 2.11.0

- Support local message sending callback, you can listen by using `onLocalMessageSend` in `inRoomMessageConfig`.

## 2.10.7

- Fixed the issue where users were kicked out when both camera and microphone permissions were not denied but the permission dialog could not be dismissed.
- Custom styles for the top and bottom toolbars now support margin.

## 2.10.6

- Support for setting the style of the top and bottom toolbars by allowing customization of padding, background color, and height.

## 2.10.4

- Support custom color of solid color icon in basic beauty.

## 2.10.3

- Update dependencies

## 2.10.2

- Update dependencies

## 2.10.1

- Update dependencies

## 2.10.0

- Support controls whether to automatically stop co-hosting when both the camera and microphone are turned off by `stopCoHostingWhenMicCameraOff`.

## 2.9.1

- Update dependencies

## 2.9.0

- Support custom in-room message style, which can be set using `ZegoInRoomMessageViewConfig`.
- Support custom basic beauty style, which can be set using `ZegoEffectConfig`.

## 2.8.5

- Support to enter the livestream as a co-host.

## 2.8.4

- Added click event to the host avatar which at the top left corner.
- Added click event to the item of member list.

## 2.8.3

- Support config view size for message list.
- Update dependencies.

## 2.8.2

- Fix the issue of conflict with extension key of the `flutter_screenutil` package.

## 2.8.1

- Fix some user login status issues when used `zego_uikit_prebuilt_live_streaming` with `zego_zimkit`

## 2.8.0

- Add a "removeCoHost" method to the controller that allows the host remove a co-host.
- Add a "makeAudienceCoHost" method to the controller that allows the host invite an audience to be a co-host.
- Supports PK in-app minimization.
- Support foreground in config，if you need to nest some widgets in **ZegoUIKitPrebuiltLiveStreaming**, please use **foreground** nesting, otherwise these widgets will be lost when you minimize and
  restore the **ZegoUIKitPrebuiltLiveStreaming**

## 2.7.0

- supports in-app minimization.

## 2.6.1

- Update comments

## 2.6.0

- Support for limiting the maximum number of co-hosts.
- Support for automatically disabling the camera for co-hosts by default.
- Support for setting the video resolution.

## 2.5.10

- Update dependencies

## 2.5.9

- Update comments

## 2.5.8

- Update dependencies

## 2.5.7

- Switch from local timing to server-based timing for the live broadcast. additionally, if the live starts again, the timer will reset.

## 2.5.6

- Deprecate flutter_screenutil_zego package

## 2.5.5

- Supports specifying extend button position in the bottom bar by an index, allowing it to be positioned before the built-in button.

## 2.5.4

- Rename style variable

## 2.5.3

- Support customizing the style of buttons (icons and text) in the bottom toolbar.

## 2.5.2

- Support close duration in config

## 2.5.1

- Add a "leave" method to the controller that allows for actively leave the current live.
- Support tracking the duration of the live locally.
- Fix some beauty bugs

## 2.5.0

- support advance beauty

## 2.4.4

- Update dependencies

## 2.4.3

- Fix some issues

## 2.4.2

- mark 'appDesignSize' as Deprecated

## 2.4.1

- Update dependencies

## 2.4.0

- To differentiate the 'appDesignSize' between the App and ZegoUIKitPrebuiltLiveStreaming, we introduced the 'flutter_screenutil_zego' library and removed the 'appDesignSize' parameter from the
  ZegoUIKitPrebuiltLiveStreaming that was previously present.

## 2.3.8

- fix the problem that the layout of configuration parameters does not working

## 2.3.7

- add a configuration option that allows the host to skip preview and start live directly
- add transparency configuration for the message list

## 2.3.6

- fixed appDesignSize for ScreenUtil that didn't work
- fixed crash in screen sharing

## 2.3.5

- add the rootNavigator parameter in config param, try to set it to true when you get stuck with navigation
- fixed an issue with the back button icon of the preview page in the RTL scenario
- add assert to key parameters to ensure prebuilt run normally

## 2.3.4

- add member list text customization

## 2.3.3

- fixed landscape not displaying full web screen sharing content
- add message and voice/beauty text customization

## 2.3.2

- fix no response to the chat button click when text direction is RTL

## 2.3.1

- fix some bugs
- update dependency

## 2.3.0

- support screen share

## 2.2.1

- remove login token
- optimizing code warnings

## 2.2.0

- support full screen for screen sharing

## 2.1.3

- Fix the issue of the re-login problem caused by onUserInfoUpdate

## 2.1.2

- Fix the issue of mixed stream view of pkBattles is sometimes not displayed due to express doesn't trigger the first frame callback.

## 2.1.1

- support rtc pkbattles

## 2.1.0

- Support PK Battles.

## 2.0.0

- Architecture upgrade based on adapter.

## 1.4.5

* downgrade flutter_screenutil to ">=5.5.3+2 <5.6.1"

## 1.4.4

* support display user name on audio video view or not

## 1.4.3

* fix bugs
* update resources
* support sdk log
* update a dependency to the latest release

## 1.4.2

* support custom background

## 1.4.1

* support custom start live button

## 1.4.0

* support view screen sharing stream of web

## 1.3.2

* update a dependency to the latest release

## 1.3.1

* fix some bugs

## 1.3.0

* support disable chat
* support mark as large-room
* support 'sendInRoomCommand',
* support kick-out user
* support open/close remote user's microphone or camera
* support CDN video stream

## 1.2.9

* fix some bugs
* update a dependency to the latest release

## 1.2.8

* fix some bugs

## 1.2.7

* update a dependency to the latest release

## 1.2.6

* fix some bugs

## 1.2.5

* fix some bugs
* update a dependency to the latest release

## 1.2.4

* fix some bugs

## 1.2.3

* fix some bugs
* update a dependency to the latest release

## 1.2.2

* fix some bugs

## 1.2.1

* update a dependency to the latest release

## 1.2.0

* support live streaming with co-host

## 1.0.3

* fix some bugs

## 1.0.2

* fix some bugs

## 1.0.1

* update a dependency to the latest release

## 1.0.0

* Congratulations!

## 0.0.9

* fix some bugs

## 0.0.8

* update a dependency to the latest release

## 0.0.7

* update readme
* update ZegoUIKitPrebuiltLiveStreamingConfig

## 0.0.6

* update readme

## 0.0.5

* update config

## 0.0.4

* fix some bugs

## 0.0.2

* fix some bugs
* update a dependency to the latest release

## 0.0.1

* Upload Initial release.
