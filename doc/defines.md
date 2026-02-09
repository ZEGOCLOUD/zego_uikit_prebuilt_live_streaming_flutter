# Defines

- [ZegoLiveStreamingState](#zegolivestreamingstate)
- [ZegoLiveStreamingRole](#zegolivestreamingrole)
- [ZegoLiveStreamingMenuBarButtonName](#zegolivestreamingmenubarbuttonname)
- [ZegoLiveStreamingAudienceConnectState](#zegolivestreamingaudienceconnectstate)
- [ZegoLiveStreamingPKBattleState](#zegolivestreamingpkbattlestate)
- [ZegoLiveStreamingPKBattleRejectCode](#zegolivestreamingpkbattlerejectcode)
- [ZegoLiveStreamingPKUser](#zegolivestreamingpkuser)
- [ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent](#zegolivestreamingincomingpkbattlerequestreceivedevent)
- [ZegoLiveStreamingIncomingPKBattleRequestUser](#zegolivestreamingincomingpkbattlerequestuser)
- [ZegoLiveStreamingIncomingPKBattleRequestTimeoutEvent](#zegolivestreamingincomingpkbattlerequesttimeoutevent)
- [ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent](#zegolivestreamingincomingpkbattlerequestcancelledevent)
- [ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent](#zegolivestreamingoutgoingpkbattlerequestacceptedevent)
- [ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent](#zegolivestreamingoutgoingpkbattlerequestrejectedevent)
- [ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent](#zegolivestreamingoutgoingpkbattlerequesttimeoutevent)
- [ZegoLiveStreamingPKBattleEndedEvent](#zegolivestreamingpkbattleendedevent)
- [ZegoLiveStreamingPKBattleUserOfflineEvent](#zegolivestreamingpkbattleuserofflineevent)
- [ZegoLiveStreamingPKBattleUserQuitEvent](#zegolivestreamingpkbattleuserquitevent)
- [ZegoLiveStreamingPKServiceSendRequestResult](#zegolivestreamingpkservicesendrequestresult)
- [ZegoLiveStreamingPKServiceResult](#zegolivestreamingpkserviceresult)
- [ZegoLiveStreamingPKMixinLayoutType](#zegolivestreamingpkmixinlayouttype)
- [ZegoLiveStreamingMiniOverlayPageState](#zegolivestreamingminioverlaypagestate)
- [ZegoLiveStreamingHallListStyle](#zegolivestreaminghallliststyle)
- [ZegoLiveStreamingHallListForegroundStyle](#zegolivestreaminghalllistforegroundstyle)
- [ZegoLiveStreamingDialogInfo](#zegolivestreamingdialoginfo)
- [ZegoUIKitPrebuiltLiveStreamingInnerText](#zegouikitprebuiltlivestreaminginnertext)

---

## ZegoLiveStreamingState

Live streaming state.

- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| idle | Not started or ended. | `0` |
| living | Live streaming is in progress. | `1` |

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
| chat | Chat button. | `0` |
| toggleMicrophone | Toggle microphone button. | `1` |
| toggleCamera | Toggle camera button. | `2` |
| switchCamera | Switch camera button. | `3` |
| switchAudioOutput | Switch audio output button. | `4` |
| leave | Leave button. | `5` |
| requestCoHost | Request co-host button. | `6` |
| cancelRequestCoHost | Cancel request co-host button. | `7` |
| endCoHost | End co-host button. | `8` |
| beauty | Beauty button. | `9` |
| soundEffect | Sound effect button. | `10` |
| screenSharing | Screen sharing button. | `11` |
| pk | PK button. | `12` |

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

## ZegoLiveStreamingPKBattleState

PK battle state.

- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| idle | No PK battle. | `0` |
| loading | PK battle is loading. | `1` |
| inPK | PK battle is in progress. | `2` |

---

## ZegoLiveStreamingPKBattleRejectCode

PK battle reject code.

- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| reject | The invited host rejects your PK request. | `0` |
| hostStateError | The invited host hasn't started their own live stream, is in a PK battle, or is being invited. | `1` |
| busy | The host is busy with another PK battle, invitation, or request. | `2` |

---

## ZegoLiveStreamingPKUser

PK user information.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| userInfo | User information. | `ZegoUIKitUser` | |
| liveID | Live ID of the user. | `String` | |

---

## ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent

Event received when an incoming PK battle request is received.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| requestID | The ID of the current PK session. | `String` | |
| fromHost | The host who sent the PK request. | `ZegoUIKitUser` | |
| fromLiveID | The live ID of the host who sent the request. | `String` | |
| isAutoAccept | Whether the PK request will be auto-accepted. | `bool` | |
| customData | Custom data attached to the request. | `String` | |
| startTimestampSecond | Timestamp (in seconds) when the PK starts. | `int` | |
| timeoutSecond | Timeout duration (in seconds) for this request. | `int` | |
| sessionHosts | The hosts already involved in the same PK session. | `List<ZegoLiveStreamingIncomingPKBattleRequestUser>` | `[]` |

---

## ZegoLiveStreamingIncomingPKBattleRequestUser

User information in an incoming PK battle request.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| id | User ID. | `String` | `''` |
| name | User name. | `String` | `''` |
| fromLiveID | The live ID the user is from. | `String` | `''` |
| state | Invitation user state. | `ZegoSignalingPluginInvitationUserState` | `ZegoSignalingPluginInvitationUserState.unknown` |
| customData | Custom data. | `String` | `''` |

---

## ZegoLiveStreamingIncomingPKBattleRequestTimeoutEvent

Event received when an incoming PK battle request times out.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| requestID | The ID of the current PK session. | `String` | |
| fromHost | The host who sent the PK request. | `ZegoUIKitUser` | |

---

## ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent

Event received when an incoming PK battle request is cancelled.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| requestID | The ID of the current PK session. | `String` | |
| fromHost | The host who sent the PK request. | `ZegoUIKitUser` | |
| customData | Custom data attached to the cancellation. | `String` | |

---

## ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent

Event received when an outgoing PK battle request is accepted.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| requestID | The ID of the current PK session. | `String` | |
| fromHost | The host who accepted the PK request. | `ZegoUIKitUser` | |
| fromLiveID | The live ID of the host who accepted the request. | `String` | |

---

## ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent

Event received when an outgoing PK battle request is rejected.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| requestID | The ID of the current PK session. | `String` | |
| fromHost | The host who rejected the PK request. | `ZegoUIKitUser` | |
| refuseCode | Reject reason code. | `int` | |

---

## ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent

Event received when an outgoing PK battle request times out.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| requestID | The ID of the current PK session. | `String` | |
| fromHost | The host who was invited. | `ZegoUIKitUser` | |

---

## ZegoLiveStreamingPKBattleEndedEvent

Event received when a PK battle ends.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| requestID | The ID of the current PK session. | `String` | |
| fromHost | The host involved in the PK. | `ZegoUIKitUser` | |
| time | End time. | `int` | |
| code | End reason code. | `int` | |
| isRequestFromLocal | Whether the request was from the local user. | `bool` | |

---

## ZegoLiveStreamingPKBattleUserOfflineEvent

Event received when a PK battle user goes offline.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| requestID | The ID of the current PK session. | `String` | |
| fromHost | The host who went offline. | `ZegoUIKitUser` | |

---

## ZegoLiveStreamingPKBattleUserQuitEvent

Event received when a PK battle user quits.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| requestID | The ID of the current PK session. | `String` | |
| fromHost | The host who quit. | `ZegoUIKitUser` | |

---

## ZegoLiveStreamingPKServiceSendRequestResult

Result of sending a PK request.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| requestID | The ID of the current PK session. | `String` | `''` |
| errorUserIDs | List of user IDs that had errors. | `List<String>` | `[]` |
| error | Platform exception if any. | `PlatformException?` | `null` |

---

## ZegoLiveStreamingPKServiceResult

Result of PK service operations.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| errorUserIDs | List of user IDs that had errors. | `List<String>` | `[]` |
| error | Platform exception if any. | `PlatformException?` | `null` |

---

## ZegoLiveStreamingPKMixinLayoutType

PK mix layout type.

- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| default | Default layout. | `0` |
| pkTopVsBottom | Top vs bottom layout. | `1` |

---

## ZegoLiveStreamingMiniOverlayPageState

Mini overlay page state.

- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| invisible | Not visible. | `0` |
| minimized | Minimized state. | `1` |
| showed | Showing state. | `2` |

---

## ZegoLiveStreamingHallListStyle

Hall list style.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| loadingBuilder | Custom loading widget builder. | `Widget? Function(BuildContext context)?` | `null` |
| item | Item style. | `ZegoLiveStreamingHallListItemStyle` | `const ZegoUIKitHallRoomListItemStyle()` |
| foreground | Foreground style. | `ZegoLiveStreamingHallListForegroundStyle` | `const ZegoLiveStreamingHallListForegroundStyle()` |

---

## ZegoLiveStreamingHallListForegroundStyle

Hall list foreground style.

- **Properties**

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| showUserInfo | Whether to show user info. | `bool` | `true` |
| showLivingFlag | Whether to show living flag. | `bool` | `true` |
| showCloseButton | Whether to show close button. | `bool` | `true` |

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
