# Components

- [ZegoUIKitPrebuiltLiveStreaming](#zegouikitprebuiltlivestreaming)
- [ZegoLiveStreamingBottomBar](#zegolivestreamingbottombar)
- [ZegoLiveStreamingTopBar](#zegolivestreamingtopbar)
- [ZegoLiveStreamingMemberButton](#zegolivestreamingmemberbutton)

---

## ZegoUIKitPrebuiltLiveStreaming

Live Streaming Widget.

You can embed this widget into any page of your project to integrate the functionality of a live streaming.

- **Parameters**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| appID | You can create a project and obtain an appID from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com). | `int` | |
| appSign | log in by using [appID] + [appSign]. You can create a project and obtain an appSign from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com). | `String` | `''` |
| token | log in by using [appID] + [token]. The token issued by the developer's business server is used to ensure security. | `String` | `''` |
| userID | The ID of the currently logged-in user. | `String` | |
| userName | The name of the currently logged-in user. | `String` | |
| liveID | You can customize the live ID arbitrarily, just need to know: users who use the same live ID can talk with each other. | `String` | |
| config | Initialize the configuration for the live-streaming. See [ZegoUIKitPrebuiltLiveStreamingConfig](configs.md#zegouikitprebuiltlivestreamingconfig). | `ZegoUIKitPrebuiltLiveStreamingConfig` | |
| events | You can listen to events that you are interested in here. See [ZegoUIKitPrebuiltLiveStreamingEvents](events.md#zegouikitprebuiltlivestreamingevents). | `ZegoUIKitPrebuiltLiveStreamingEvents?` | `null` |

---

## ZegoLiveStreamingBottomBar

The bottom navigation bar of the live streaming.

- **Parameters**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| liveID | The ID of the live streaming. | `String` | |
| config | The configuration of the live streaming. | `ZegoUIKitPrebuiltLiveStreamingConfig` | |
| events | The events of the live streaming. | `ZegoUIKitPrebuiltLiveStreamingEvents` | |
| defaultEndAction | The default action when the live streaming ends. | `VoidCallback` | |
| defaultLeaveConfirmationAction | The default action when leaving the live streaming. | `Future<bool> Function()` | |
| buttonSize | The size of the buttons. | `Size` | |
| popUpManager | The popup manager. | `ZegoLiveStreamingPopUpManager` | |
| isLeaveRequestingNotifier | The notifier for the leave request status. | `ValueNotifier<bool>?` | `null` |

---

## ZegoLiveStreamingTopBar

The top navigation bar of the live streaming.

- **Parameters**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| liveID | The ID of the live streaming. | `String` | |
| isCoHostEnabled | Whether the co-host function is enabled. | `bool` | |
| config | The configuration of the live streaming. | `ZegoUIKitPrebuiltLiveStreamingConfig` | |
| events | The events of the live streaming. | `ZegoUIKitPrebuiltLiveStreamingEvents` | |
| defaultEndAction | The default action when the live streaming ends. | `VoidCallback` | |
| defaultLeaveConfirmationAction | The default action when leaving the live streaming. | `Future<bool> Function()` | |
| popUpManager | The popup manager. | `ZegoLiveStreamingPopUpManager` | |
| translationText | The translation text. | `ZegoUIKitPrebuiltLiveStreamingInnerText` | |
| isLeaveRequestingNotifier | The notifier for the leave request status. | `ValueNotifier<bool>?` | `null` |

---

## ZegoLiveStreamingMemberButton

The button to display the member list.

- **Parameters**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| builder | Custom builder for the button. | `Widget Function(int count, String liveID)?` | `null` |
| icon | Custom icon for the button. | `Widget?` | `null` |
| backgroundColor | Background color of the button. | `Color?` | `null` |
| liveID | The ID of the live streaming. | `String` | |
| isCoHostEnabled | Whether the co-host function is enabled. | `bool` | |
| avatarBuilder | Custom builder for the avatar. | `ZegoAvatarBuilder?` | `null` |
| itemBuilder | Custom builder for the member list item. | `ZegoMemberListItemBuilder?` | `null` |
| popUpManager | The popup manager. | `ZegoLiveStreamingPopUpManager` | |
| translationText | The translation text. | `ZegoUIKitPrebuiltLiveStreamingInnerText` | |
| config | The configuration of the live streaming. | `ZegoUIKitPrebuiltLiveStreamingConfig` | |
| events | The events of the live streaming. | `ZegoUIKitPrebuiltLiveStreamingEvents` | |
| liveConfig | The live configuration. | `ZegoLiveStreamingConfig` | |

