# Defines

- [ZegoLiveStreamingState](#zegolivstreamingstate)
- [ZegoLiveStreamingRole](#zegolivstreamingrole)
- [ZegoLiveStreamingMenuBarButtonName](#zegolivstreamingmenubarbuttonname)
- [ZegoLiveStreamingAudienceConnectState](#zegolivstreamingaudienceconnectstate)
- [ZegoLiveStreamingEndReason](#zegolivstreamingendreason)
- [ZegoLiveStreamingDialogInfo](#zegolivstreamingdialoginfo)
- [ZegoLiveStreamingEndEvent](#zegolivstreamingendevent)
- [ZegoLiveStreamingLeaveConfirmationEvent](#zegolivstreamingleaveconfirmationevent)
- [ZegoLiveStreamingRoomLoginFailedEvent](#zegolivstreamingroomloginfailedevent)
- [ZegoUIKitPrebuiltLiveStreamingInnerText](#zegouikitprebuiltlivestreaminginnertext)
- [ZegoLiveStreamingMenuBarExtendButton](#zegolivstreamingmenubarextendbutton)
- [ZegoLiveStreamingBottomMenuBarButtonStyle](#zegolivstreamingbottommenubarbuttonstyle)

---

## ZegoLiveStreamingState

Live streaming state.

- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| idle | Not started or ended. | `0` |
| living | Live streaming is in progress. | `1` |
| inPKBattle | In PK battle. | `2` |
| ended | Live streaming ended. | `3` |

---

## ZegoLiveStreamingRole

Role of the user in the live streaming.

- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| host | Host of the live streaming. | `0` |
| coHost | Co-host who has connected with the host. | `1` |
| audience | Audience of the live streaming. | `2` |

---

## ZegoLiveStreamingMenuBarButtonName

Menu bar button names.

- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| toggleCameraButton | Button for controlling the camera switch. | `0` |
| toggleMicrophoneButton | Button for controlling the microphone switch. | `1` |
| switchCameraButton | Button for switching between front and rear cameras. | `2` |
| switchAudioOutputButton | Button for switching audio output. | `3` |
| leaveButton | Button for leaving the live streaming. | `4` |
| coHostControlButton | Button for co-host control. | `5` |
| beautyEffectButton | Button for beauty effect. | `6` |
| soundEffectButton | Button for sound effect. | `7` |
| enableChatButton | Button to disable/enable chat. | `8` |
| toggleScreenSharingButton | Button for toggling screen sharing. | `9` |
| chatButton | Button to open/hide the chat UI. | `10` |
| minimizingButton | Button for minimizing the live streaming. | `11` |
| pipButton | Button for PIP the live streaming. | `12` |
| expanding | Used in toolbar layout, similar to the Expanded widget. | `13` |

---

## ZegoLiveStreamingAudienceConnectState

Audience connection state.

- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| idle | Not connected. | `0` |
| connecting | Connecting to the host. | `1` |
| connected | Connected to the host. | `2` |

---


## ZegoLiveStreamingEndReason

Live streaming end reason.

- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| hostEnd | The live streaming ended due to host ended. | `hostEnd` |
| localLeave | Local user left the live streaming. | `localLeave` |
| kickOut | User was kicked out of the live streaming. | `kickOut` |

---

## ZegoLiveStreamingDialogInfo

Dialog information for confirmation dialogs.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| title | Dialog title. | `String` | |
| message | Dialog message. | `String` | |
| cancelButtonName | Cancel button text. | `String` | |
| confirmButtonName | Confirm button text. | `String` | |

---

## ZegoLiveStreamingEndEvent

Event data for live streaming end event.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| kickerUserID | The user ID of who kicked you out. | `String?` | `null` |
| reason | End reason. | `ZegoLiveStreamingEndReason` | |
| isFromMinimizing | Whether the user left from minimization state. | `bool` | |

---

## ZegoLiveStreamingLeaveConfirmationEvent

Event data for leave confirmation event.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| context | Build context. | `BuildContext` | |

---

## ZegoLiveStreamingRoomLoginFailedEvent

Event data for room login failed event.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| errorCode | Error code. | `int` | |
| message | Error message. | `String` | |

---

## ZegoUIKitPrebuiltLiveStreamingInnerText

Inner text configuration for the live streaming.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| topBarTitle | Top bar title. | `String` | `'Live Streaming'` |
| topBarLiveStatus | Top bar live status. | `String` | `'LIVE'` |
| topBarMemberCount | Top bar member count. | `String` | `'%d viewers'` |
| topBarSeatCount | Top bar seat count. | `String` | `'%d seats'` |
| chatInputPlaceholder | Chat input placeholder. | `String` | `'Say something...'` |
| bottomBarChat | Bottom bar chat button. | `String` | `'Chat'` |
| bottomBarPK | Bottom bar PK button. | `String` | `'PK'` |
| bottomBarRequestCoHost | Bottom bar request co-host button. | `String` | `'Join'` |
| bottomBarCancelRequestCoHost | Bottom bar cancel request co-host button. | `String` | `'Cancel'` |
| bottomBarEndCoHost | Bottom bar end co-host button. | `String` | `'End'` |
| bottomBarClose | Bottom bar close button. | `String` | `'Close'` |
| inviteCoHostDialogTitle | Invite co-host dialog title. | `String` | `'Invite to Co-host'` |
| inviteCoHostDialogContent | Invite co-host dialog content. | `String` | `'Invites the audience to co-host'` |
| cancelInviteCoHostDialogContent | Cancel invite co-host dialog content. | `String` | `'Cancel the co-host invitation'` |
| endCoHostDialogTitle | End co-host dialog title. | `String` | `'End Co-host'` |
| endCoHostDialogContent | End co-host dialog content. | `String` | `'Ends the co-host connection and the audience will watch the live stream alone.'` |
| removeCoHostDialogTitle | Remove co-host dialog title. | `String` | `'Remove Co-host'` |
| removeCoHostDialogContent | Remove co-host dialog content. | `String` | `'Removes the co-host from the live stream.'` |
| requestCoHostDialogTitle | Request co-host dialog title. | `String` | `'Request to Co-host'` |
| requestCoHostDialogContent | Request co-host dialog content. | `String` | `'The host will be notified of your request to co-host.'` |
| cancelRequestCoHostDialogContent | Cancel request co-host dialog content. | `String` | `'Cancels the co-host request.'` |
| rejectCoHostRequestDialogTitle | Reject co-host request dialog title. | `String` | `'Reject Co-host'` |
| rejectCoHostRequestDialogContent | Reject co-host request dialog content. | `String` | `'Rejects the co-host request.'` |
| agreeCoHostRequestDialogTitle | Agree co-host request dialog title. | `String` | `'Agree Co-host'` |
| agreeCoHostRequestDialogContent | Agree co-host request dialog content. | `String` | `'Agrees the co-host request.'` |
| startLiveStreamingButton | Start live streaming button. | `String` | `'Go Live'` |
| stopLiveStreamingButton | Stop live streaming button. | `String` | `'End Live'` |
| startLiveStreamingConfirmationDialogTitle | Start live streaming confirmation dialog title. | `String` | `'Go Live'` |
| startLiveStreamingConfirmationDialogContent | Start live streaming confirmation dialog content. | `String` | `'Are you sure you want to start the live streaming?'` |
| stopLiveStreamingConfirmationDialogTitle | Stop live streaming confirmation dialog title. | `String` | `'End Live'` |
| stopLiveStreamingConfirmationDialogContent | Stop live streaming confirmation dialog content. | `String` | `'Are you sure you want to end the live streaming?'` |
| leaveLiveStreamingConfirmationDialogTitle | Leave live streaming confirmation dialog title. | `String` | `'Leave Live'` |
| leaveLiveStreamingConfirmationDialogContent | Leave live streaming confirmation dialog content. | `String` | `'Are you sure you want to leave the live streaming?'` |
| inviteCoHostSuccessToast | Invite co-host success toast. | `String` | `'Invitation sent'` |
| inviteCoHostFailedToast | Invite co-host failed toast. | `String` | `'Failed to invite co-host'` |
| repeatInviteCoHostFailedToast | Repeat invite co-host failed toast. | `String` | `'You have sent an invitation, please wait for confirmation'` |
| sendRequestCoHostToast | Send request co-host toast. | `String` | `'Request sent'` |
| requestCoHostFailedToast | Request co-host failed toast. | `String` | `'Failed to request co-host'` |
| pkStartToast | PK start toast. | `String` | `'PK started'` |
| pkEndToast | PK end toast. | `String` | `'PK ended'` |
| pkInviteSuccessToast | PK invite success toast. | `String` | `'PK invitation sent'` |
| pkInviteFailedToast | PK invite failed toast. | `String` | `'Failed to send PK invitation'` |
| pkInviteSuccessButton | PK invite success button. | `String` | `'OK'` |
| pkInviteFailedButton | PK invite failed button. | `String` | `'OK'` |
| pkSwitchToPkMode | PK switch to PK mode. | `String` | `'Switch to PK mode'` |
| pkSwitchToPkModeConfirmationDialogTitle | PK switch to PK mode confirmation dialog title. | `String` | `'Switch to PK'` |
| pkSwitchToPkModeConfirmationDialogContent | PK switch to PK mode confirmation dialog content. | `String` | `'After the switch, the current audience will watch the PK battle.'` |
| pkStartButton | PK start button. | `String` | `'PK'` |
| pkCancelButton | PK cancel button. | `String` | `'Cancel'` |
| pkEndButton | PK end button. | `String` | `'End PK'` |
| pkStartPKButton | PK start PK button. | `String` | `'Start PK'` |
| pkQuitPKButton | PK quit PK button. | `String` | `'Quit PK'` |
| pkApplyPKInvitationReceivedContent | PK apply PK invitation received content. | `String` | `'invites you to PK'` |
| pkApplyPKInvitationReceivedConfirm | PK apply PK invitation received confirm button. | `String` | `'Join'` |
| pkApplyPKInvitationReceivedCancel | PK apply PK invitation received cancel button. | `String` | `'Cancel'` |
| pkInvitationHasBeenSentContent | PK invitation has been sent content. | `String` | `'PK invitation has been sent'` |
| pkInvitingContent | PK inviting content. | `String` | `'Inviting...'` |
| pkInviteUserConnectingContent | PK invite user connecting content. | `String` | `'Connecting...'` |
| pkInviteUserFailedContent | PK invite user failed content. | `String` | `'Failed, please try again'` |
| pkInviteUserSuccessContent | PK invite user success content. | `String` | `'Success'` |
| pkInviteUserWaitContent | PK invite user wait content. | `String` | `'Waiting for response...'` |
| pkCountDownStartContent | PK count down start content. | `String` | `'PK will start in %d seconds'` |
| pkEndContent | PK end content. | `String` | `'PK has ended'` |
| pkUserOfflineContent | PK user offline content. | `String` | `'The other host has gone offline'` |
| pkUserBackContent | PK user back content. | `String` | `'The other host is back'` |
| pkReconnectContent | PK reconnect content. | `String` | `'Reconnecting...'` |
| pkReconnectFailedContent | PK reconnect failed content. | `String` | `'Reconnection failed, the PK has ended'` |
| pkReconnectSuccessContent | PK reconnect success content. | `String` | `'Reconnected'` |
| pkSwitchToNormalModel | PK switch to normal model. | `String` | `'Back to Live'` |
| pkSwitchToNormalModelConfirmationDialogTitle | PK switch to normal model confirmation dialog title. | `String` | `'Exit PK'` |
| pkSwitchToNormalModelConfirmationDialogContent | PK switch to normal model confirmation dialog content. | `String` | `'Are you sure you want to exit PK?'` |
| pkSwitchToNormalModelButton | PK switch to normal model button. | `String` | `'Exit PK'` |
| pkExitPKByHostContent | PK exit PK by host content. | `String` | `'The host has ended the PK'` |
| beautyEffect | Beauty effect. | `String` | `'Beauty'` |
| soundEffect | Sound effect. | `String` | `'Sound'` |
| settings | Settings. | `String` | `'Settings'` |
| turnOnYourCameraToStartLiveStreaming | Turn on camera to start live streaming message. | `String` | `'Turn on your camera to start live streaming'` |
| startLiveStreamingWarning | Start live streaming warning. | `String` | `'Start live streaming warning'` |
| audioVideoResourceModeAuto | Audio video resource mode auto. | `String` | `'Auto'` |
| audioVideoResourceModeOnlyRTC | Audio video resource mode only RTC. | `String` | `'RTC'` |
| audioVideoResourceModeOnlyCDN | Audio video resource mode only CDN. | `String` | `'CDN'` |
| audioVideoResourceModeRTCAndCDN | Audio video resource mode RTC and CDN. | `String` | `'RTC+CDN'` |
| memberListTitle | Member list title. | `String` | `'Live Room (%d)'` |
| pkBattleRequestSendOutSuccess | PK battle request send out success. | `String` | `'PK request sent'` |
| pkBattleRequestAcceptedSuccess | PK battle request accepted success. | `String` | `'PK request accepted'` |
| pkBattleRequestCancelledSuccess | PK battle request cancelled success. | `String` | `'PK request cancelled'` |
| pkBattleRequestRejectedSuccess | PK battle request rejected success. | `String` | `'PK request rejected'` |
| pkBattleRequestTimeoutSuccess | PK battle request timeout success. | `String` | `'PK request timeout'` |
| pkBattleRequestError | PK battle request error. | `String` | `'PK request error'` |
| pkBattleEndSuccess | PK battle end success. | `String` | `'PK ended'` |
| pkBattleStartError | PK battle start error. | `String` | `'Failed to start PK'` |
| pkBattleRequestHostIDNotExistError | PK battle request host ID not exist error. | `String` | `'Host does not exist'` |
| pkBattleRequestTargetBusyError | PK battle request target busy error. | `String` | `'Target is busy'` |
| pkBattleRequestTargetNotLiveError | PK battle request target not live error. | `String` | `'Target is not live'` |
| pkBattleRequestTargetInPKError | PK battle request target in PK error. | `String` | `'Target is in PK'` |
| pkBattleRequestTargetRejectError | PK battle request target reject error. | `String` | `'Target rejected'` |
| pkBattleRequestTargetTimeoutError | PK battle request target timeout error. | `String` | `'Target timeout'` |
| pkBattleRequestUnknownError | PK battle request unknown error. | `String` | `'Unknown error'` |

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

