
>
> This document aims to help users understand the APIs changes and feature improvements, and provide a migration guide for the upgrade process.
>
> <br />
>
> It is an `incompatible change` if marked with `breaking changes`.
> All remaining changes is compatible and uses the deprecated prompt. Of course, it will also be completely abandoned in the version after a certain period of time.
>
> <br />
>
> You can run this command in `the root directory of your project` to output warnings and partial error prompts to assist you in finding deprecated parameters/functions or errors after upgrading.
> ```shell
> dart analyze | grep zego
> ```


<br />
<br />

# Versions

- [3.8.4](#384)  **(💥 breaking changes)**
- [3.8.3](#383)
- [3.8.0](#380)
- [3.5.3](#353)
- [3.5.0](#350)
- [3.4.0](#340)
- [3.3.0](#330)
- [3.1.7](#317)
- [3.1.2](#312)  **(💥 breaking changes)**
- [3.1.0](#310)
- [3.0.3](#303)
- [3.0.2](#302)
- [3.0](#30)  **(💥 breaking changes)**


<br />
<br />

# 3.8.4
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.8.3 to the latest 3.8.4 version.

# Major Interface Changes

- ZegoInRoomMessage: The type of `messageID` is changed from **int** to **String**.

<br />
<br />

# 3.8.3
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.8.2 to the latest 3.8.3 version.

## Major Interface Changes
    - rename **ZegoInvitationType** to `ZegoLiveStreamingInvitationType`


<br />
<br />

# 3.8.0
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.7.+ to the latest 3.8.0 version.

## Major Interface Changes

- ZegoUIKitPrebuiltLiveStreamingEvents
  - ZegoLiveStreamingCoHostEvents
    - ZegoLiveStreamingCoHostHostEvents
        - onRequestReceived
        - onRequestCanceled
        - onRequestTimeout
        - onInvitationSent
        - onInvitationTimeout
        - onInvitationAccepted
        - onInvitationRefused
    - ZegoLiveStreamingCoHostAudienceEvents
      - onRequestAccepted
      - onRequestRefused
      - onInvitationReceived

>
> Modify your code based on the following guidelines to make it compatible with version 3.8.0:
>
> 3.7.+ Version Code:
>
>```dart
>/// Example code in version 3.7.+
>
> ZegoUIKitPrebuiltLiveStreamingEvents(
>   coHost: ZegoLiveStreamingCoHostEvents(
>     host: ZegoLiveStreamingCoHostHostEvents(
>       onRequestReceived: (ZegoUIKitUser audience) {},
>       onRequestCanceled: (ZegoUIKitUser audience) {},
>       onRequestTimeout: (ZegoUIKitUser audience) {},
>       onInvitationSent: (ZegoUIKitUser audience) {},
>       onInvitationTimeout: (ZegoUIKitUser audience) {},
>       onInvitationAccepted: (ZegoUIKitUser audience) {},
>       onInvitationRefused: (ZegoUIKitUser audience) {},
>     ),
>     audience: ZegoLiveStreamingCoHostAudienceEvents(
>       onRequestAccepted: () {},
>       onRequestRefused: () {},
>       onInvitationReceived: (ZegoUIKitUser host) {},
>     ),
>   ),
> );
>```
>
>3.8.0 Version Code:
>
>```dart
>/// Example code in version 3.8.0
>
> ZegoUIKitPrebuiltLiveStreamingEvents(
>   coHost: ZegoLiveStreamingCoHostEvents(
>     host: ZegoLiveStreamingCoHostHostEvents(
>       onRequestReceived: (
>         ZegoLiveStreamingCoHostHostEventRequestReceivedData data,
>       ) {},
>       onRequestCanceled: (
>         ZegoLiveStreamingCoHostHostEventRequestCanceledData data,
>       ) {},
>       onRequestTimeout: (
>         ZegoLiveStreamingCoHostHostEventRequestTimeoutData data,
>       ) {},
>       onInvitationSent: (
>         ZegoLiveStreamingCoHostHostEventInvitationSentData data,
>       ) {},
>       onInvitationTimeout: (
>         ZegoLiveStreamingCoHostHostEventInvitationTimeoutData data,
>       ) {},
>       onInvitationAccepted: (
>         ZegoLiveStreamingCoHostHostEventInvitationAcceptedData data,
>       ) {},
>       onInvitationRefused: (
>         ZegoLiveStreamingCoHostHostEventInvitationRefusedData data,
>       ) {},
>     ),
>     audience: ZegoLiveStreamingCoHostAudienceEvents(
>       onRequestAccepted: (
>         ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData data,
>       ) {},
>       onRequestRefused: (
>         ZegoLiveStreamingCoHostAudienceEventRequestRefusedData data,
>       ) {},
>       onInvitationReceived: (
>         ZegoLiveStreamingCoHostAudienceEventRequestReceivedData data,
>       ) {},
>     ),
>   ),
> );
>```

<br />
<br />

# 3.5.3
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.5.2 to the latest 3.5.3 version.

## Major Interface Changes

- ZegoUIKitPrebuiltLiveStreamingController
    - rename **user.addFake** to `user.addFakeUser`
    - rename **user.removeFake** to `user.removeFakeUser`

<br />
<br />


# 3.5.0
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.4.+ to the latest 3.5.0 version.

## Major Interface Changes

- ZegoUIKitPrebuiltLiveStreamingController
    - move **room.addFakeUser** to `user.addFake`
    - move **room.removeFakeUser** to `user.removeFake`

<br />
<br />

# 3.4.0
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.3.0 to the latest 3.4.0 version.

## Major Interface Changes

- ZegoUIKitPrebuiltLiveStreamingConfig
    - move **maxCoHostCount** to `coHost.maxCoHostCount`
    - move **stopCoHostingWhenMicCameraOff** to `coHost.stopCoHostingWhenMicCameraOff`
    - move **disableCoHostInvitationReceivedDialog** to `coHost.disableCoHostInvitationReceivedDialog`
    - move **turnOnCameraWhenCohosted** to `coHost.turnOnCameraWhenCohosted`


# 3.3.0
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.2.0 to the latest 3.3.0 version.

## Major Interface Changes

- ZegoLiveStreamingPKBattleConfig
  - rename **pKBattleViewTopPadding** to `topPadding`
  - rename **pkBattleViewTopBuilder** to `topBuilder`
  - rename **pkBattleViewBottomBuilder** to `bottomBuilder`
  - rename **pkBattleViewForegroundBuilder** to `foregroundBuilder`

<br />
<br />
<br />



# 3.1.7
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.1.6 to the latest 3.1.7 version.

## Major Interface Changes

- rename **ZegoInnerText** to `ZegoUIKitPrebuiltLiveStreamingInnerText`
- rename **ZegoMenuBarButtonName** to `ZegoLiveStreamingMenuBarButtonName`
- rename **ZegoDialogInfo** to `ZegoLiveStreamingDialogInfo`
- rename **ZegoStartLiveButtonBuilder** to `ZegoLiveStreamingStartLiveButtonBuilder`
- rename **ZegoIncomingPKBattleRequestTimeoutEvent** to `ZegoLiveStreamingIncomingPKBattleRequestTimeoutEvent`
- rename **ZegoIncomingPKBattleRequestCancelledEvent** to `ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent`
- rename **ZegoOutgoingPKBattleRequestAcceptedEvent** to `ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent`
- rename **ZegoOutgoingPKBattleRequestRejectedEvent** to `ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent`
- rename **ZegoOutgoingPKBattleRequestTimeoutEvent** to `ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent`
- rename **ZegoPKBattleEndedEvent** to `ZegoLiveStreamingPKBattleEndedEvent`
- rename **ZegoPKBattleUserOfflineEvent** to `ZegoLiveStreamingPKBattleUserOfflineEvent`
- rename **ZegoPKBattleUserQuitEvent** to `ZegoLiveStreamingPKBattleUserQuitEvent`

<br />
<br />
<br />
<br />
<br />


# 3.1.2
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.1.1 to the latest 3.1.2 version.

## Major Interface Changes

- ZegoUIKitPrebuiltLiveStreamingConfig  **(💥 breaking changes)**

type of `turnOnCameraWhenCohosted`, change from **bool** to `bool Function()?`.

>
> - function prototype:
>```dart
>bool Function()? turnOnCameraWhenCohosted;
>```

>
> Modify your code based on the following guidelines to make it compatible with version 3.1.2:
>
> 3.1.1 Version Code:
>
>```dart
>/// Example code in version 3.1.1
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    config: ZegoUIKitPrebuiltLiveStreamingConfig(
>      turnOnCameraWhenCohosted: true,
>    ),
>    ...
>  );
>```
>
>3.1.2 Version Code:
>
>```dart
>/// Example code in version 3.1.2
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    config: ZegoUIKitPrebuiltLiveStreamingConfig(
>      turnOnCameraWhenCohosted: (){
>        return true;
>      },
>    ),
>    ...
>  );
>```

<br />
<br />
<br />
<br />
<br />

# 3.1.0
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.0.3 to the latest 3.1.0 version.

## Major Interface Changes

- rename **ZegoLiveStreamingPKController** to `ZegoLiveStreamingControllerPKImpl`

<br />
<br />
<br />
<br />
<br />

# 3.0.3
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.0.2 to the latest 3.0.3 version.

## Major Interface Changes

- ZegoLiveStreamingDurationEvents
    - rename **onUpdate** to `onUpdated`

<br />
<br />
<br />
<br />
<br />

# 3.0.2
---

## Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.0.1 to the latest 3.0.2 version.

## Major Interface Changes

- rename **ZegoPKMixerLayout** to `ZegoLiveStreamingPKMixerLayout`
- rename **ZegoPKMixerDefaultLayout** to `ZegoLiveStreamingPKMixerDefaultLayout`
- rename **zegoPK2MixerCanvasWidth** to `zegoLiveStreamingPKMixerCanvasWidth`
- rename **zegoPK2MixerCanvasHeight** to `zegoLiveStreamingPKMixerCanvasHeight`

<br />
<br />
<br />
<br />
<br />

# 3.0
---

>
> The 3.0 version has standardized and optimized the [API](APIs-topic.html) and [Event](Events-topic.html), simplifying the usage of most APIs.
>
> Most of the changes involve modifications to the calling path, such as:
> - Changing from `ZegoUIKitPrebuiltLiveStreamingController().isMinimizing()` to `ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing`.
> - Move the event callback in the **ZegoUIKitPrebuiltLiveStreamingConfig** to the [Event](Events-topic.html).
>
> After upgrading the live streaming kit, you can refer to the directory index to see how specific APIs from the old version can be migrated to the new version.


---

- [ZegoUIKitPrebuiltLiveStreamingController](#zegouikitprebuiltlivestreamingcontroller)

- ZegoUIKitPrebuiltLiveStreaming
    - [controller](#zegouikitprebuiltlivestreamingcontroller)

- ZegoUIKitPrebuiltLiveStreamingSwiping
    - [controller](#zegouikitprebuiltlivestreamingcontroller)

- [ZegoUIKitPrebuiltLiveStreamingEvents](#zegouikitprebuiltlivestreamingevents)
    - [coHost](#cohost)

- [ZegoUIKitPrebuiltLiveStreamingConfig](#zegouikitprebuiltlivestreamingconfig)
    - [startLiveButtonBuilder](#startlivebuttonbuilder)
    - [Unified class prefix as "ZegoLiveStreaming"](#unified-class-prefix-as-zegolivestreaming)
    - [Remove "Config" suffix from the variable names](#removed-config-suffix-from-the-variable-names)
    - [Move event to ZegoUIKitPrebuiltLiveStreamingEvents](#move-event-to-zegouikitprebuiltlivestreamingevents)
        - [onLeaveConfirmation](#onleaveconfirmation)
        - [onLeaveLiveStreaming/onLiveStreamingEnded/onMeRemovedFromRoom](#onleavelivestreamingonlivestreamingendedonmeremovedfromroom)

- [PK](#pk)
    - [ZegoUIKitPrebuiltLiveStreamingPKService](#zegouikitprebuiltlivestreamingpkservice)

- [ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine](#zegouikitprebuiltlivestreamingminioverlaymachine)
    - rename **PrebuiltLiveStreamingMiniOverlayPageState** to `ZegoLiveStreamingMiniOverlayPageState`

- Deprecated Removed
    - ZegoUIKitPrebuiltLiveStreaming
        - remove **onDispose**
        - remove **appDesignSize**
    - ZegoUIKitPrebuiltLiveStreamingController
        - move **showScreenSharingViewInFullscreenMode** to `screen.showViewInFullscreenMode`
        - move **removeCoHost** to `coHost.removeCoHost`
        - move **makeAudienceCoHost** to `coHost.hostSendCoHostInvitationToAudience`
    - ZegoUIKitPrebuiltLiveStreamingConfig
        - rename **inRoomMessageViewConfig** to `inRoomMessageConfig`
        - rename **translationText** to `innerText`
        - rename **ZegoInRoomMessageViewConfig** to `ZegoInRoomMessageConfig`
        - ZegoMemberListConfig
            - remove **showMicrophoneState**
            - remove **showCameraState**
    - ZegoUIKitPrebuiltLiveStreamingConfig
        - remove **ZegoLiveStreamingPKBattleEvents(PK V1)**
    - rename **ZegoMiniOverlayPage** to `ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage`
    - rename **ZegoTranslationText** to `ZegoInnerText`

## Introduction

> In this migration guide, we will explain how to upgrade from version 2.x to the latest 3.0 version.
>
> This document aims to help users understand the interface changes and feature improvements, and provide a migration guide for the upgrade process.

## Major Interface Changes

### ZegoUIKitPrebuiltLiveStreamingController

> In version 2.x, the ZegoUIKitPrebuiltLiveStreamingController required declaring the variable and passing to ZegoUIKitPrebuiltLiveStreaming to be initialized.
>
> However, in version 3.0, the ZegoUIKitPrebuiltLiveStreamingController has been `changed to a singleton pattern`.
>
> This means that you no longer need to declare a separate variable and pass parameters.
>
> Instead, you can directly access the singleton instance and make calls to it.

<details>
<summary>Migrate Guide</summary>

>
> Modify your code based on the following guidelines to make it compatible with version 3.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 2.x
>/// ...
>ZegoUIKitPrebuiltLiveStreamingController controller;
>
>/// assign controller to ZegoUIKitPrebuiltLiveStreaming
>ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    controller:controller,
>    ...
>)
>
>controller.xxx(...);
>```
>
>3.0 Version Code:
>
>```dart
>/// Example code in version 3.0
>/// ...
>ZegoUIKitPrebuiltLiveStreamingController().xxx(...);
>```

</details>

- move API in **connect** to `coHost`
- move API in **connectInvite** to `coHost`

<details>
<summary>Compatibility Guide</summary>
<pre><code>

>
> Modify your code based on the following guidelines to make it compatible with version 3.0:
>
> 2.x Version Code:
>
>```dart
>/// Example code in version 2.x
> 
>ZegoUIKitPrebuiltLiveStreamingController().connect.functionName();
>ZegoUIKitPrebuiltLiveStreamingController().connectInvite.functionName();
>```
>
> 3.0 Version Code:
>
>```dart
>/// Example code in version 3.0
>
>ZegoUIKitPrebuiltLiveStreamingController().coHost.functionName();
>ZegoUIKitPrebuiltLiveStreamingController().coHost.functionName();
>```

</code></pre>

</details>

### ZegoUIKitPrebuiltLiveStreamingConfig

#### startLiveButtonBuilder

>
>- move `startLiveButtonBuilder` from **ZegoUIKitPrebuiltLiveStreamingConfig** to `ZegoLiveStreamingPreviewConfig`

<details>
<summary>Compatibility Guide</summary>
<pre><code>

>
> Modify your code based on the following guidelines to make it compatible with version 3.0:
>
> 2.x Version Code:
>
>```dart
>/// Example code in version 2.x
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    config: ZegoUIKitPrebuiltLiveStreamingConfig(
>      startLiveButtonBuilder: (context){
> 
>      },
>    ),
>    ...
>  );
>```
>
> 3.0 Version Code:
>
>```dart
>/// Example code in version 3.0
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    config: ZegoUIKitPrebuiltLiveStreamingConfig(
>      previewConfig: ZegoLiveStreamingPreviewConfig(
>        startLiveButtonBuilder: (context){
>          ...
>        },
>      ),
>    ),
>    ...
>  );
>```

</code></pre>

</details>

#### Unified class prefix as "ZegoLiveStreaming"

>
> - rename **ZegoPrebuiltAudioVideoViewConfig** to `ZegoLiveStreamingAudioVideoViewConfig`
> - rename **ZegoTopMenuBarConfig** to `ZegoLiveStreamingTopMenuBarConfig`
> - rename **ZegoBottomMenuBarConfig** to `ZegoLiveStreamingBottomMenuBarConfig`
> - rename **ZegoMenuBarExtendButton** to `ZegoLiveStreamingMenuBarExtendButton`
> - rename **ZegoBottomMenuBarButtonStyle** to `ZegoLiveStreamingBottomMenuBarButtonStyle`
> - rename **ZegoMemberButtonConfig** to `ZegoLiveStreamingMemberButtonConfig`
> - rename **ZegoMemberListConfig** to `ZegoLiveStreamingMemberListConfig`
> - rename **ZegoInRoomMessageConfig** to `ZegoLiveStreamingInRoomMessageConfig`
> - rename **ZegoEffectConfig** to `ZegoLiveStreamingEffectConfig`
> - rename **ZegoLiveDurationConfig** to `ZegoLiveStreamingDurationConfig`
> - rename **ZegoMediaPlayerConfig** to `ZegoLiveStreamingMediaPlayerConfig`

#### Removed "Config" suffix from the variable names

>
>- rename **mediaPlayerConfig** to `mediaPlayer`
>- rename **videoConfig** to `video`
>- rename **audioVideoViewConfig** to `audioVideoView`
>- rename **topMenuBarConfig** to `topMenuBar`
>- rename **bottomMenuBarConfig** to `bottomMenuBar`
>- rename **memberButtonConfig** to `memberButton`
>- rename **memberListConfig** to `memberList`
>- rename **inRoomMessageConfig** to `inRoomMessage`
>- rename **effectConfig** to `effect`
>- rename **beautyConfig** to `beauty`
>- rename **previewConfig** to `preview`
>- rename **pkBattleConfig** to `pkBattle`
>- rename **durationConfig** to `duration`

#### move event to ZegoUIKitPrebuiltLiveStreamingEvents  **(💥 breaking changes)**

>
> - move **onLiveStreamingStateUpdate** from **ZegoUIKitPrebuiltLiveStreamingConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents` and rename to `onStateUpdate`
> - move **onCameraTurnOnByOthersConfirmation** from **ZegoUIKitPrebuiltLiveStreamingConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.audioVideo`
> - move **onMicrophoneTurnOnByOthersConfirmation** from **ZegoUIKitPrebuiltLiveStreamingConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.audioVideo`
> 
> - move **onHostAvatarClicked** from **ZegoTopMenuBarConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.topMenuBar`
> - move **onClicked** from **ZegoMemberListConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.memberList`
> - move **onLocalMessageSend** from **ZegoInRoomMessageConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.inRoomMessage.onLocalSend`
> - move **onMessageClick** from **ZegoInRoomMessageConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.inRoomMessage.onClicked`
> - move **onMessageLongPress** from **ZegoInRoomMessageConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.inRoomMessage.onLongPress`
> - move **onDurationUpdate** from **ZegoLiveDurationConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.duration.onUpdate`



<details>
<summary>Compatibility Guide</summary>
<pre><code>

>
> Modify your code based on the following guidelines to make it compatible with version 3.0:
>
> 2.x Version Code:
>
>```dart
>/// Example code in version 2.x
>
>ZegoUIKitPrebuiltLiveStreaming(
>  ...
>  config: ZegoUIKitPrebuiltLiveStreamingConfig()
>    ..onCameraTurnOnByOthersConfirmation = (context) async {
>      return true;
>    }
>    ..onMicrophoneTurnOnByOthersConfirmation = (context) async {
>      return true;
>    }
>    ..onLiveStreamingStateUpdate = (state) {
>      //
>    }
>    ..topMenuBarConfig.onHostAvatarClicked = (host) {
>      //
>    }
>    ..memberListConfig.onClicked = (user) {
>      //
>    }
>    ..inRoomMessageConfig.onMessageClick = (message) {
>      //
>    }
>    ..inRoomMessageConfig.onMessageLongPress = (message) {
>      //
>    }
>    ..inRoomMessageConfig.onLocalMessageSend = (message) {
>      //
>    }
>    ..durationConfig.onDurationUpdate = (duration) {
>      //
>    },
>  ...
>);
>
>```
>
>3.0 Version Code:
>
>```dart
>/// Example code in version 3.0
>
>
>ZegoUIKitPrebuiltLiveStreaming(
>    events: ZegoUIKitPrebuiltLiveStreamingEvents(
>      onStateUpdate: (state){
>
>      },
>      audioVideo: ZegoLiveStreamingAudioVideoEvents(
>        onCameraTurnOnByOthersConfirmation: (context){
>
>        },
>        onMicrophoneTurnOnByOthersConfirmation: (context){
>
>        },
>      ),
>      topMenuBar: ZegoLiveStreamingTopMenuBarEvents(
>        onHostAvatarClicked: (host){
>
>        },
>      ),
>      memberList: ZegoLiveStreamingMemberListEvents(
>        onClicked: (user){
>
>        },
>      ),
>      inRoomMessage: ZegoLiveStreamingInRoomMessageEvents(
>        onClicked: (message){
>
>        },
>        onLocalSend: (message){
>
>        },
>        onLongPress: (message){
>
>        },
>      ),
>      duration: ZegoLiveStreamingDurationEvents(
>        onUpdated: (duration){
>
>        },
>      ),
>    ),
>    ...
>);
>```

</code></pre>

</details>

##### onLeaveConfirmation  **(💥 breaking changes)**

>
> You can use defaultAction.call() to perform the internal default action, which returns to the previous page.
>
>- move `onLeaveConfirmation` from **ZegoUIKitPrebuiltLiveStreamingConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents`
>- add `defaultAction` and `event` in `onLeaveConfirmation`

<details>
<summary>Defines</summary>
<pre><code>

>
>```dart
> Future<bool> Function(
>   ZegoLiveStreamingLeaveConfirmationEvent event,
>
>   /// defaultAction to return to the previous page
>   Future<bool> Function() defaultAction,
> )? onLeaveConfirmation
>
>
> class ZegoLiveStreamingLeaveConfirmationEvent {
>   BuildContext context;
> }
>```

</code></pre>

</details>

<details>
<summary>Compatibility Guide</summary>
<pre><code>

>
> Modify your code based on the following guidelines to make it compatible with version 3.0:
>
> 2.x Version Code:
>
>```dart
>/// Example code in version 2.x
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    config: ZegoUIKitPrebuiltLiveStreamingConfig(
>      onLeaveConfirmation: (context){
>        debugPrint('onLeaveConfirmation, do whatever you want');
>      
>        back to the previous page...
>      },
>    ),
>    ...
>  );
>```
>
>3.0 Version Code:
>
>```dart
>/// Example code in version 3.0
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    events: ZegoUIKitPrebuiltLiveStreamingEvents(
>      onLeaveConfirmation: (
>          ZegoLiveStreamingLeaveConfirmationEvent event,
>          /// defaultAction to return to the previous page
>          Future<bool> Function() defaultAction,
>      ) {
>        debugPrint('onLeaveConfirmation, do whatever you want');
>      
>        /// you can call this defaultAction to return to the previous page,
>        return defaultAction.call();
>      },
>    ),
>    ...
>  );
>```

</code></pre>

</details>

##### onLeaveLiveStreaming/onLiveStreamingEnded/onMeRemovedFromRoom  **(💥 breaking changes)**

>
> Due to the fact that all three events indicate the end of a live streaming, they will be consolidated into `ZegoUIKitPrebuiltLiveStreamingEvents.onEnded` and differentiated by
> the `ZegoLiveStreamingEndEvent.reason`.
>
>And you can use `defaultAction.call()` to perform the internal default action, which returns to the previous page.
>
>- move **onLeaveLiveStreaming** from **ZegoUIKitPrebuiltLiveStreamingConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.onEnded`(ZegoLiveStreamingEndEvent(reason:
   ZegoLiveStreamingEndReason.`localLeave`), defaultAction)
>- move **onLiveStreamingEnded** from **ZegoUIKitPrebuiltLiveStreamingConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.onEnded`(ZegoLiveStreamingEndEvent(reason:ZegoLiveStreamingEndReason.`hostEnd`),
   defaultAction)
>- move **onMeRemovedFromRoom** from **ZegoUIKitPrebuiltLiveStreamingConfig** to `ZegoUIKitPrebuiltLiveStreamingEvents.onEnded`(ZegoLiveStreamingEndEvent(reason:ZegoLiveStreamingEndReason.`kickOut`),
   defaultAction)


<details>
<summary>Defines</summary>

>
>```dart
>void Function(
>  ZegoLiveStreamingEndEvent event,
>  VoidCallback defaultAction,
>)? onEnded
>
>class ZegoLiveStreamingEndEvent {
>  /// the user ID of who kick you out
>  String? kickerUserID;
>
>  /// end reason
>  ZegoLiveStreamingEndReason reason;
>
>  /// The [isFromMinimizing] it means that the user left the live streaming
>  /// while it was in a minimized state.
>  ///
>  /// You **can not** return to the previous page while it was **in a minimized state**!!!
>  /// just hide the minimize page by [ZegoUIKitPrebuiltLiveStreamingController().minimize.hide()]
>  ///
>  /// On the other hand, if the value of the parameter is false, it means
>  /// that the user left the live streaming while it was not minimized.
>  bool isFromMinimizing;
>  }
>}
>
>/// The default behavior is to return to the previous page.
>///
>/// If you override this callback, you must perform the page navigation
>/// yourself to return to the previous page!!!
>/// otherwise the user will remain on the current call page !!!!!
>enum ZegoLiveStreamingEndReason {
>  /// the call ended due to a local hang-up
>  hostEnd,
>
>  /// the call ended when the remote user hung up, leaving only one local user in the call
>  localLeave,
>
>  /// the call ended due to being kicked out
>  kickOut,
>}
>```

</details>


<details>
<summary>Compatibility Guide</summary>
<pre><code>

>
> Modify your code based on the following guidelines to make it compatible with version 3.0:
>
> 2.x Version Code:
>
>```dart
>/// Example code in version 2.x
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    config: ZegoUIKitPrebuiltLiveStreamingConfig(
>      onLeaveLiveStreaming = (isFromMinimizing){
> 
>      },
>      onLiveStreamingEnded = (isFromMinimizing){
> 
>      },
>      onMeRemovedFromRoom = (fromUserID){
> 
>      },
>    ),
>    ...
>  );
>```
>
>3.0 Version Code:
>
>```dart
>/// Example code in version 3.0
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    events: ZegoUIKitPrebuiltLiveStreamingEvents(
>      onEnded: (event, defaultAction){
>        debugPrint('onEnd by ${event.reason}, do whatever you want');
>        
>        switch(event.reason) {
>            case ZegoLiveStreamingEndReason.hostEnd:
>              final isFromMinimizing = event.isFromMinimizing;
>              // TODO: Handle this case.
>              break;
>            case ZegoLiveStreamingEndReason.localLeave:
>              final isFromMinimizing = event.isFromMinimizing;
>              // TODO: Handle this case.
>              break;
>            case ZegoLiveStreamingEndReason.kickOut:
>              final fromUserID = event.kickerUserID ?? '';
>              break;
>        }
>        
>        /// you can call this defaultAction to return to the previous page
>        defaultAction.call();
>      },
>    ),
>    ...
>  );
>```

</code></pre>

</details>

### ZegoUIKitPrebuiltLiveStreamingEvents

#### coHost

>
>- rename **onMaxCoHostReached** to `coHost.onMaxCountReached`
>- reanme **onCoHostsUpdated** to `coHost.onUpdate`
>- rename **hostEvents** to `coHost.host`
>- rename **audienceEvents** to `coHost.audience`
>- rename **ZegoUIKitPrebuiltLiveStreamingHostEvents** to `ZegoLiveStreamingCoHostHostEvents`
>- rename **ZegoUIKitPrebuiltLiveStreamingAudienceEvents** to `ZegoLiveStreamingCoHostAudienceEvents`
>- host
>   - rename **onCoHostRequestReceived** to `onRequestReceived`
>   - rename **onCoHostRequestCanceled** to `onRequestCanceled`
>   - rename **onCoHostRequestTimeout** to `onRequestTimeout` 
>   - rename **onActionAcceptCoHostRequest** to `onActionAcceptRequest`
>   - rename **onActionRefuseCoHostRequest** to `onActionRefuseRequest`
>   - rename **onCoHostInvitationSent** to `onInvitationSent`
>   - rename **onCoHostInvitationTimeout** to `onInvitationTimeout`
>   - rename **onCoHostInvitationAccepted** to `onInvitationAccepted`
>   - rename **onCoHostInvitationRefused** to `onInvitationRefused`
>- audience
>   - rename **onCoHostRequestSent** to `onRequestSent`
>   - rename **onActionCancelCoHostRequest** to `onActionCancelRequest`
>   - rename **onCoHostRequestTimeout** to `onRequestTimeout`
>   - rename **onCoHostRequestAccepted** to `onRequestAccepted`
>   - rename **onCoHostRequestRefused** to `onRequestRefused`
>   - rename **onCoHostInvitationReceived** to `onInvitationReceived`
>   - rename **onCoHostInvitationTimeout** to `onInvitationTimeout`
>   - rename **onActionAcceptCoHostInvitation** to `onActionAcceptInvitation`
>   - rename **onActionRefuseCoHostInvitation** to `onActionRefuseInvitation`
>
>
><details>
><summary>Compatibility Guide</summary>
><pre><code>
>
>
> Modify your code based on the following guidelines to make it compatible with version 3.0:
>
> 2.x Version Code:
>
>```dart
>/// Example code in version 2.x
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    events: ZegoUIKitPrebuiltLiveStreamingEvents(
>      onMaxCoHostReached: (maxCoHostCount){
>
>      },
>      onCoHostsUpdated: (List<ZegoUIKitUser> coHosts){
>
>      },
>      hostEvents: ZegoUIKitPrebuiltLiveStreamingHostEvents(
>
>      ),
>      audienceEvents: ZegoUIKitPrebuiltLiveStreamingAudienceEvents(
>
>      ),
>    ),
>    ...
>  );
>```
>
>3.0 Version Code:
>
>```dart
>/// Example code in version 3.0
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    events: ZegoUIKitPrebuiltLiveStreamingEvents(
>      coHost: ZegoLiveStreamingCoHostEvents(
>        onMaxCountReached: (count){
>
>        },
>        onUpdated: (List<ZegoUIKitUser> coHosts){
>
>        },
>        host: ZegoLiveStreamingCoHostHostEvents(
>  
>        ),
>        audience: ZegoLiveStreamingCoHostAudienceEvents(
>  
>        ),
>      ),  
>    ),
>    ...
>  );
>```
>
></code></pre>
>
></details>

### PK

>
>In version 2.x, there are two versions of PK.
>
>The old version of PK only supports two participants, while the new version of PK supports multiple participants.
>
>In version 3.0, we have deprecated the old version of PK that supports only two participants, and **removed the "V2" suffix** from the name of the previous new version of PK.

>
>- rename **ZegoLiveStreamingPKBattleStateV2** to `ZegoLiveStreamingPKBattleState`
>
>- ZegoUIKitPrebuiltLiveStreamingConfig
>    - rename **ZegoLiveStreamingPKBattleV2Config** to  `ZegoLiveStreamingPKBattleConfig`
>    - rename **pkBattleV2Config** to `pkBattle`
>
>- ZegoUIKitPrebuiltLiveStreamingEvents
>    - rename **pkV2Events** -> `pk`
>    - **ZegoUIKitPrebuiltLiveStreamingPKV2Events** -> `ZegoLiveStreamingPKEvents`
>        - **onIncomingPKBattleRequestReceived** -> `onIncomingRequestReceived`
>        - **onIncomingPKBattleRequestCancelled** -> `onIncomingRequestCancelled`
>        - **onIncomingPKBattleRequestTimeout** -> `onIncomingRequestTimeout`
>        - **onOutgoingPKBattleRequestAccepted** -> `onOutgoingRequestAccepted`
>        - **onOutgoingPKBattleRequestRejected** -> `onOutgoingRequestRejected`
>        - **onOutgoingPKBattleRequestTimeout** -> `onOutgoingRequestTimeout`
>        - **onPKBattleEnded** -> `onEnded`
>        - **ZegoIncomingPKBattleRequestReceivedEventV2** -> `ZegoIncomingPKBattleRequestReceivedEvent`
>        - **ZegoIncomingPKBattleRequestCancelledEventV2** -> `ZegoIncomingPKBattleRequestCancelledEvent`
>        - **ZegoIncomingPKBattleRequestTimeoutEventV2** -> `ZegoIncomingPKBattleRequestTimeoutEvent`
>        - **ZegoOutgoingPKBattleRequestAcceptedEventV2** -> `ZegoOutgoingPKBattleRequestAcceptedEvent`
>        - **ZegoOutgoingPKBattleRequestRejectedEventV2** -> `ZegoOutgoingPKBattleRequestRejectedEvent`
>        - **ZegoOutgoingPKBattleRequestTimeoutEventV2** -> `ZegoOutgoingPKBattleRequestTimeoutEvent`
>        - **ZegoPKBattleEndedEventV2** -> `ZegoPKBattleEndedEvent`
>        - **ZegoPKBattleUserOfflineEventV2** -> `ZegoPKBattleUserOfflineEvent`
>        - **ZegoPKBattleUserQuitEventV2** -> `ZegoPKBattleUserQuitEvent`


<details>
<summary>Compatibility Guide</summary>
<pre><code>

>
> Modify your code based on the following guidelines to make it compatible with version 3.0:
>
> 2.x Version Code:
>
>```dart
>/// Example code in version 2.x
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    config: ZegoUIKitPrebuiltLiveStreamingConfig(
>      pkBattleV2Config: ZegoLiveStreamingPKBattleV2Config(
>        
>      ),
>    ),
>    events: ZegoUIKitPrebuiltLiveStreamingEvents(
>      pkEvents: ZegoUIKitPrebuiltLiveStreamingPKV2Events(
>        xx: onXXX() {}
>      ),
>    ),
>    ...
>  );
>```
>
>3.0 Version Code:
>
>```dart
>/// Example code in version 3.0
>
>  ZegoUIKitPrebuiltLiveStreaming(
>    ...
>    config: ZegoLiveStreamingPKBattleConfig(
>      pkBattle: ZegoLiveStreamingPKBattleV2Config(
>        
>      ),
>    ),
>    events: ZegoUIKitPrebuiltLiveStreamingEvents(
>      pk: ZegoLiveStreamingPKEvents(
>        xx: onXXX() {}
>      ),
>    ),
>    ...
>  );
>```

</code></pre>

</details>

#### ZegoUIKitPrebuiltLiveStreamingPKService

>
> - rename **ZegoUIKitPrebuiltLiveStreamingPKUser** -> `ZegoLiveStreamingPKUser`
>
>
>If you migrate below version **v2.23**, which will migrate from the old version of two-player PK to the new version of multiplayer PK, please refer to the following:
>
>- APIs
>
>The methods in **ZegoUIKitPrebuiltLiveStreamingPKService** can be replaced with the methods
> in [`ZegoUIKitPrebuiltLiveStreamingController().pk`](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKController-class.html)
> .
>
>| ZegoUIKitPrebuiltLiveStreamingPKService |ZegoUIKitPrebuiltLiveStreamingController().pk| description |
> |-|-|-|
> |sendPKBattleRequest|[sendRequest](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKController/sendRequest.html)|The
> requestID is the ID of the current PK session.|
> |cancelPKBattleRequest|[cancelRequest](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKController/cancelRequest.html)||
>
|acceptIncomingPKBattleRequest|[acceptRequest](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKController/acceptRequest.html)
|The requestID is the event.requestID that you received in the onIncomingRequestReceived event. |
>
|rejectIncomingPKBattleRequest|[rejectRequest](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKController/rejectRequest.html)
|The requestID is the same as the event.requestID that you received in the onIncomingRequestReceived event.|
> |stopPKBattle|[stop](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKController/stop.html)|The requestID is the
> result.requestID returned by the sendRequest function.|
> |muteAnotherHostAudio|[muteAudios](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKController/muteAudios.html)||
> |startPKBattleWith|none|After accepting the PK invitation, the interface will automatically switch to the PK screen, and no further action is required.<br><br>If you want the other party to directly
> enter the PK after the invitation is sent, you can set the isAutoAccept parameter to true in the sendRequest function.|
>
> For example, if you previously used **ZegoUIKitPrebuiltLiveStreamingService().sendPKBattleRequest(hostUserID)** to send a PK invitation, now you should use **
> ZegoUIKitPrebuiltLiveStreamingController().pk.sendRequest([hostUserID])**.
>
>- Events
>
>The events in **ZegoUIKitPrebuiltLiveStreamingConfig.pkBattleEvents** can be replaced with the events in **ZegoUIKitPrebuiltLiveStreamingEvents.pk**.
>
>| ZegoUIKitPrebuiltLiveStreamingConfig.pkBattleEvents |ZegoUIKitPrebuiltLiveStreamingEvents.pk | description |
> |-|-|-|
>
|onIncomingRequestReceived|[onIncomingRequestReceived](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKEvents/onIncomingRequestReceived.html)
|The requestID parameter from the event will be required when using the acceptRequest or rejectRequest functions.|
>
|onIncomingRequestCancelled|[onIncomingRequestCancelled](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKEvents/onIncomingRequestCancelled.html)
||
>
|onIncomingRequestTimeout|[onIncomingRequestTimeout](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKEvents/onIncomingRequestTimeout.html)
||
>
|onOutgoingRequestAccepted|[onOutgoingRequestAccepted](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKEvents/onOutgoingRequestAccepted.html)
||
>
|onOutgoingRequestRejected|[onOutgoingRequestRejected](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKEvents/onOutgoingRequestRejected.html)
||
>
|onOutgoingRequestTimeout|[onOutgoingRequestTimeout](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKEvents/onOutgoingRequestTimeout.html)
||
> |onPKBattleEndedByAnotherHost|[onEnded](https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/zego_uikit_prebuilt_live_streaming/ZegoLiveStreamingPKEvents/onEnded.html)||

### ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine

>
>In 3.0, the entire **ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine** has been deprecated, and the public APIs have been moved to `ZegoUIKitPrebuiltLiveStreamingController().minimize`.
>
>- move **state** to `ZegoUIKitPrebuiltLiveStreamingController().minimize.state`
>- move **isMinimizing** to `ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing`
>- move **restoreFromMinimize** to `ZegoUIKitPrebuiltLiveStreamingController().minimize.restore()`
>- move **toMinimize** to `ZegoUIKitPrebuiltLiveStreamingController().minimize.minimize()`
>- move **resetInLiving** to `ZegoUIKitPrebuiltLiveStreamingController().minimize.hide()`

<details>
<summary>Compatibility Guide</summary>
<pre><code>

>
> Modify your code based on the following guidelines to make it compatible with version 3.0:
>
> 2.x Version Code:
>
>```dart
>/// Example code in version 2.x
>
>  final minimizeState = ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().state;
>
>  final isMinimizing = ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().isMinimizing;
>
>  ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().restoreFromMinimize();
>
>  ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().toMinimize();
>
>  ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().resetInLiving();
>
>```
>
>3.0 Version Code:
>
>```dart
>/// Example code in version 3.0
>
>  final minimizeState = ZegoUIKitPrebuiltLiveStreamingController().minimize.state;
>
>  final isMinimizing = ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing;
>
>  ZegoUIKitPrebuiltLiveStreamingController().minimize.restore();
>
>  ZegoUIKitPrebuiltLiveStreamingController().minimize.minimize();
>
>  ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
>
>```

</code></pre>

</details>

---

<br />
<br />
<br />
<br />
<br />

# Feedback Channels

If you encounter any issues or have any questions during the migration process, please provide feedback through the following channels:

- GitHub Issues: [Link to the project's issue page](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_flutter/issues)
- Forum: [Link to the forum page](https://www.zegocloud.com/)

We appreciate your feedback and are here to help you successfully complete the migration process.
