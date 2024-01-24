# Make an interactive livestream

> 
> Check the following to make your livestream even more interactive:
> 
> - [Participate in PK battles with other hosts](https://docs.zegocloud.com/article/15580)
> - [Share your screen during live streaming](https://docs.zegocloud.com/article/15641)
> - [Send virtual gifts](https://docs.zegocloud.com/article/16201)
> - [Add advanced beauty effects like filters, face shaping, and makeup](https://docs.zegocloud.com/article/15975)


# FAQs

>  
> Here are answers to some frequently asked questions.
> 
> - [How to ensure uninterrupted audio when the app is sent to the background](https://docs.zegocloud.com/article/15815)
> - [How to make the audience leave the room automatically after ending the live stream](https://docs.zegocloud.com/article/15815)

# Debugging

> 
> Let's explore some common debugging scenarios:
> 
> - [Why does the app work fine in debug mode but crash in release mode](https://docs.zegocloud.com/article/15817)
> - [How to enable logging for UIKit](https://docs.zegocloud.com/article/15817)


# Feature map

> 
> The Live Streaming Kit (ZegoUIKitPrebuiltLiveStreaming) offers default behaviors and styles, but we also provide the flexibility to further customize or add your own business logic if the 
defaults don't fully meet your needs.
> 
> The numbers shown in the diagram correspond to the categories in the specific feature list.
> 
> <img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/live/feature_map_v1.jpeg" alt="Image" style="max-width: 800px;">
> 
> <table>
> <tbody><tr>
> <th>Category</th>
> <th>&nbsp;Feature</th>
> <th>&nbsp;Description</th>
> </tr>
> <tr>
> <th rowspan="10">1 Top View</th>
> <td><a href="https://docs.zegocloud.com/article/16307">Set user avatar</a></td>
> <td>Set the user's avatar and make it effective in the TopMenuBar, AudioVideoView, and member list.</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16335">Set user avatar onClick callback</a></td>
> <td>Perform customized operations such as displaying user details through the callback.</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16190">Add minimize button</a></td>
> <td>Minimize the livestream window within the app.</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16309">Exit Livestream confirmation callback</a></td>
> <td>Add a customized confirmation popup when the user exits the livestream</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16309">Customize exit livestream confirmation popup text</a></td>
> <td>Customize the text displayed on the popup confirmation when the user exits the livestream.</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16082">Calculate livestream duration</a></td>
> <td>Configure whether or not to display the duration of the livestream and to set a callback for the duration.</td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoTopMenuBarConfig/padding.html">Set TopMenuBar padding</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoTopMenuBarConfig/margin.html">Set TopMenuBar margin</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoTopMenuBarConfig/backgroundColor.html">Set TopMenuBar 
backgroundColor</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoTopMenuBarConfig/height.html">Set TopMenuBar height</a></td>
> <td></td>
> </tr>
> <tr>
> <th rowspan="8">2 AudioVideoView</th>
> <td><a href="https://docs.zegocloud.com/article/16307">Set user avatar</a></td>
> <td>Set the user's avatar, which will then be displayed in the TopMenuBar, AudioVideoView, and Member List.</td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoPrebuiltAudioVideoViewConfig/isVideoMirror.html">Set Video 
Mirror</a></td>
> <td>Set the video mirror effect, but only for the user's own video.</td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoPrebuiltAudioVideoViewConfig/showUserNameOnView.html">Show username on 
view</a></td>
> <td>Display the user name in the bottom right corner of the video view.</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16306">Show user avatar</a></td>
> <td>Display the user avatar, but only in audio mode.</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16306">Show sound wave</a></td>
> <td>Display the sound wave, but only in audio mode.</td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoPrebuiltAudioVideoViewConfig/useVideoViewAspectFill.html">Use video 
view aspect fill</a></td>
> <td>Set whether the video rendering should be filled, which means the video will not have black bars, but it may be cropped or scaled.</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16313">Customize foreground view</a></td>
> <td>Set a custom foreground view for the AudioVideoView.</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16311">Customize background view</a></td>
> <td>Set a custom background view for the AudioVideoView.</td>
> </tr>
> <tr>
> <th rowspan="11">3 InRoomMessageView</th>
> <td><a href="https://docs.zegocloud.com/article/16315">Set InRoomMessageView width</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16315">Set InRoomMessageView height</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16315">Set InRoomMessageView Opacity</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16315">Set InRoomMessageView maximum number of lines</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16315">Customize InRoomMessageView username text style</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16315">Customize InRoomMessageView message text style</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16315">Set InRoomMessageView background color</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16315">Set InRoomMessageView border radius</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16315">Set InRoomMessageView padding</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16315">Customize InRoomMessageView message item</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoInRoomMessageConfig/onLocalMessageSend.html">Message send status 
callback</a></td>
> <td>This callback will be triggered when the message is successfully sent or failed.</td>
> </tr>
> <tr>
> <th rowspan="14">4 Bottom Menu Bar</th>
> <td><a href="https://docs.zegocloud.com/article/16321">Customize host buttons</a></td>
> <td>Only applicable when the user's role is "host".</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16321">Customize co-host buttons</a></td>
> <td>Only applicable when the user's role is "co-host".</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16321">Customize audience buttons</a></td>
> <td>Only applicable when the user's role is "audience".</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16321">Add host extend buttons</a></td>
> <td>Only applicable when the user's role is "host".</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16321">Add co-host extend buttons</a></td>
> <td>Only applicable when the user's role is "co-host".</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16321">Add audience extend buttons</a></td>
> <td>Only applicable when the user's role is "audience".</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16321">Set whether to show message button</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16321">Limit the maximum number of bottom buttons</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16321">Customize the style of built-in buttons</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoMenuBarButtonName.html">Built-in button list</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoBottomMenuBarConfig/padding.html">Set BottomMenuBar 
padding</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoBottomMenuBarConfig/margin.html">Set BottomMenuBar margin</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoBottomMenuBarConfig/backgroundColor.html">Set BottomMenuBar 
backgroundColor</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoBottomMenuBarConfig/height.html">Set BottomMenuBar height</a></td>
> <td></td>
> </tr>
> <tr>
> <th rowspan="2">5 Member List</th>
> <td><a href="https://docs.zegocloud.com/article/16317">Customize member item</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16317">Item onClick callback</a></td>
> <td></td>
> </tr>
> <tr>
> <th rowspan="19">6 Effects</th>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/beautyEffects.html">Customize beauty effects</a></td>
> <td>Add or remove beauty effect items.</td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/voiceChangeEffect.html">Customize voice change 
effects</a></td>
> <td>Add or remove voice change effect items.</td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/reverbEffect.html">Customize reverb effects</a></td>
> <td>Add or remove reverb effect items.</td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/backgroundColor.html">Customize background 
color</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/headerTitleTextStyle.html">Customize header title text 
style</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/backIcon.html">Customize back icon</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/resetIcon.html">Customize reset icon</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/selectedIconBorderColor.html">Customize icon border color 
in selected state</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/normalIconBorderColor.html">Customize icon border color in 
normal state</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/selectedIconColor.html">Customize icon color in selected 
state</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/normalIconColor.html">Customize icon color in normal 
state</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/selectedTextStyle.html">Customize text style in selected 
state</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/normalTextStyle.html">Customize text style in normal 
state</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/sliderTextStyle.html">Customize slider text 
style</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/sliderTextBackgroundColor.html">Customize slider text 
background color</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/sliderActiveTrackColor.html">Customize slider active track 
color</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/sliderInactiveTrackColor.html">Customize slider inactive 
track color</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/sliderThumbColor.html">Customize slider thumb 
color</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoEffectConfig/sliderThumbRadius.html">Customize slider thumb 
radius</a></td>
> <td></td>
> </tr>
> <tr>
> <th rowspan="5">7 Customization before starting the live stream</th>
> <td><a href="https://docs.zegocloud.com/article/16305">Customize whether to skip the preview interface</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16305">Customize the back button</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16305">Customize the beauty effect button</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16305">Customize the switch camera button</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/startLiveButtonBuilder.html">Customize 
the "start live" button</a></td>
> <td></td>
> </tr>
> <tr>
> <th>8 Advanced beauty effects</th>
> <td><a href="https://docs.zegocloud.com/article/15975">Achieve advanced beauty  effects</a></td>
> <td>Implement advanced beauty features such as filters, face shapes, and makeup.</td>
> </tr>
> <th>9 Screen sharing</th>
> <td><a href="https://docs.zegocloud.com/article/15641">Achieve screen sharing live streaming</a></td>
> <td></td>
> </tr>
> </tr>
> <th>10 PK battles</th>
> <td><a href="https://docs.zegocloud.com/article/15580">Participate in PK battles with other hosts</a></td>
> <td></td>
> </tr>
> <tr>
> <th rowspan="7">11 Live stream callback</th>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/onMeRemovedFromRoom.html">Callback - 
user is removed from the livestream room</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/onLeaveLiveStreaming.html">Callback - 
Audience leaves the live stream room</a></td>
> <td>After implementing the callback, it is necessary to pop back to the previous page.</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16325">Live stream end callback</a></td>
> <td>After implementing the callback, it is necessary to pop back to the previous page.</td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/onLiveStreamingStateUpdate.
html">Callback - live stream state is updated</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/onCameraTurnOnByOthersConfirmation.
html">Callback for confirming camera opening by others</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/onMicrophoneTurnOnByOthersConfirmation.
html">Callback for confirming microphone opening by others</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/onMaxCoHostReached.html">Callback for 
when the maximum number of co-hosts is reached</a></td>
> <td></td>
> </tr>
> <tr>
> <th rowspan="14">12 Other</th>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/layout.html">Customize 
layouts</a></td>
> <td>Supports PictureInPicture and Gallery layout</td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16323">Set whether the host's camera is turned on by default</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/turnOnMicrophoneWhenJoining.html">Set 
whether the host's microphone is turned on by default</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/useSpeakerWhenJoining.html">Set 
whether the speaker is turned on by default when joining the livestream</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16329">Set whether the camera is turned on by default after the audience joins the livestream</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/stopCoHostingWhenMicCameraOff.
html">Set whether to stop co-hosting when both the microphone and camera are turned off</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16331">Set up video configuration for livestream</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16319">Customize UI text in the Livestream</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/foreground.html">Customize the 
foreground view in the live stream</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingConfig/background.html">Customize the 
background view in the live stream</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://docs.zegocloud.com/article/16333">Limit the Maximum Number of co-hosts</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingController/leave.html">Actively leave the 
live stream room</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingController/removeCoHost.html">Remove a 
co-host from the live stream room</a></td>
> <td></td>
> </tr>
> <tr>
> <td><a href="https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoUIKitPrebuiltLiveStreamingController/makeAudienceCoHost.html">Invite an 
audience to become a co-host</a></td>
> <td></td>
> </tr>
> </tbody></table>
