// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';

/// Control the text on the UI.
/// Modify the values of the corresponding properties to modify the text on the UI.
/// You can also change it to other languages.
///
/// This class is used for the [ZegoUIKitPrebuiltLiveStreamingConfig.innerText] property.
///
/// **Note that the placeholder %0 in the text will be replaced with the corresponding username.**
class ZegoInnerText {
  /// %0: is a string placeholder, represents the first parameter of prompt
  /// @nodoc
  static String param_1 = '%0';

  /// The text of the button for the host to reject audience's co-host request on the member list.
  /// The **default value** is *"Disagree"*.
  String disagreeButton;

  /// The text of the button for the host to accept audience's co-host request on the member list.
  /// The **default value** is *"Agree"*.
  String agreeButton;

  /// The text of the start button on the host live preview page.
  /// The **default value** is *"Start"*.
  String startLiveStreamingButton;

  /// The text of button which co-host exit co-hosting.
  /// The **default value** is *"End"*.
  String endCoHostButton;

  /// The text of button which audience request to join co-hosting.
  /// The **default value** is *"Apply to co-host"*.
  String requestCoHostButton;

  /// The text of button which audience cancel request to join co-hosting.
  /// The **default value** is *"Cancel the application"*.
  String cancelRequestCoHostButton;

  /// The text of button which host remove co-host from the stage.
  /// The **default value** is *"Remove the co-host"*.
  String removeCoHostButton;

  /// The cancel button of the pop-up menu, clicking it will hide the menu.
  /// The **default value** is *"Cancel"*.
  String cancelMenuDialogButton;

  /// The text of button which host invite the audience to become a co-host.
  /// The **default value** is *"Invite %0 to co-host"*, where %0 will be replaced with the corresponding username.
  String inviteCoHostButton;

  /// The text of button which host kick out audience or co-host from the live stream.
  /// The **default value** is *"Remove %0 from the room"*, where %0 will be replaced with the corresponding username.
  String removeUserMenuDialogButton;

  /// Background prompt text when the host is not present.
  /// The **default value** is *"No host is online."*.
  String noHostOnline;

  /// The title of the member list, automatically adding (number of people in the live room).
  /// The **default value** is *"Audience."*.
  String memberListTitle;

  /// Identification of oneself on the member list.
  /// The **default value** is *"You"*.
  String memberListRoleYou;

  /// Identification of the host on the member list.
  /// The **default value** is *"Host"*.
  String memberListRoleHost;

  /// Identification of the co-host on the member list.
  /// The **default value** is *"Co-host"*.
  String memberListRoleCoHost;

  /// Notification after successful audience request to join co-hosting.
  /// If you don't want any notification to appear, leave it blank.
  /// The **default value** is *"You are applying to be a co-host, please wait for confirmation."*.
  String sendRequestCoHostToast;

  /// Notification for unsuccessful audience request to join co-hosting.
  /// If you don't want any notification to appear, leave it blank.
  /// The **default value** is *"Failed to apply for connection."*.
  String requestCoHostFailedToast;

  /// Notification received by the audience after their request to join co-hosting is declined by the host.
  /// If you don't want any notification to appear, leave it blank.
  /// The **default value** is *"Your request to co-host with the host has been refused."*.
  String hostRejectCoHostRequestToast;

  /// Notification for the failure of the host's invitation to the audience to join co-hosting.
  /// Leave it blank if you don't want any notification to appear.
  /// The **default value** is *"Failed to connect with the co-host, please try again."*.
  String inviteCoHostFailedToast;

  /// Notification for the audience's rejection of the host's co-hosting invitation.
  /// Leave it blank if you don't want any notification to appear.
  /// The **default value** is *"%0 refused to be a co-host."*, where %0 will be replaced with the corresponding username.
  String audienceRejectInvitationToast;

  /// Notification for the repeated co-hosting invitation.
  /// Leave it blank if you don't want any notification to appear.
  /// The **default value** is *"You've sent the invitation, please wait for confirmation."*.
  String repeatInviteCoHostFailedToast;

  /// message's place holder
  String messageEmptyToast;

  /// user enter tips in message
  String userEnter;

  /// user leave tips in message
  String userLeave;

  /// Info for camera permission request dialog.
  /// The **default values** are:
  /// - Title: "Can not use Camera!"
  /// - Message: "Please enable camera access in the system settings!"
  /// - Cancel button name: "Cancel"
  /// - Confirm button name: "Settings"
  ZegoDialogInfo cameraPermissionSettingDialogInfo;

  /// Info for microphone permission request dialog.
  /// The **default values** are:
  /// - Title: ""
  /// - Message: ""
  /// - Cancel button name: ""
  /// - Confirm button name: ""
  ZegoDialogInfo microphonePermissionSettingDialogInfo;

  /// The dialog info for the host when receiving a request from an audience to join co-hosting.
  /// The **default values** are:
  /// - Title: "Can not use Microphone!"
  /// - Message: "Please enable microphone access in the system settings!"
  /// - Cancel button name: "Cancel"
  /// - Confirm button name: "Settings"
  ZegoDialogInfo receivedCoHostRequestDialogInfo;

  /// The dialog info for the audience when receiving an invitation from the host to join co-hosting.
  /// The **default values** are:
  /// - Title: "Invitation"
  /// - Message: "The host is inviting you to co-host."
  /// - Cancel button name: "Disagree"
  /// - Confirm button name: "Agree"
  ZegoDialogInfo receivedCoHostInvitationDialogInfo;

  /// The dialog info for the co-host when ending the co-hosting session.
  /// The **default values** are:
  /// - Title: "End the connection"
  /// - Message: "Do you want to end the cohosting?"
  /// - Cancel button name: "Cancel"
  /// - Confirm button name: "OK"
  ZegoDialogInfo endConnectionDialogInfo;

  /// The title of the voice changing category.
  /// The **default value** is *"Audio effect"*.
  String audioEffectTitle;

  /// The title of the voice changing category.
  /// The **default value** is *"Reverb"*.
  String audioEffectReverbTitle;

  /// The title of the voice changing category.
  /// The **default value** is *"Voice changing"*.
  String audioEffectVoiceChangingTitle;

  /// The title of the voice changing category.
  /// The **default value** is *"Face beautification"*.
  String beautyEffectTitle;

  /// Voice changing effect: None
  String voiceChangerNoneTitle;

  /// Voice changing effect: Little Boy
  String voiceChangerLittleBoyTitle;

  /// Voice changing effect: Little Girl
  String voiceChangerLittleGirlTitle;

  /// Voice changing effect: Deep
  String voiceChangerDeepTitle;

  /// Voice changing effect: Crystal-clear
  String voiceChangerCrystalClearTitle;

  /// Voice changing effect: Robot
  String voiceChangerRobotTitle;

  /// Voice changing effect: Ethereal
  String voiceChangerEtherealTitle;

  /// Voice changing effect：Female
  String voiceChangerFemaleTitle;

  /// Voice changing effect：Male
  String voiceChangerMaleTitle;

  /// Voice changing effect：Optimus Prime
  String voiceChangerOptimusPrimeTitle;

  /// Voice changing effect：C Major
  String voiceChangerCMajorTitle;

  /// Voice changing effect：A Major
  String voiceChangerAMajorTitle;

  /// Voice changing effect：Harmonic minor
  String voiceChangerHarmonicMinorTitle;

  /// Reverb effect：None
  String reverbTypeNoneTitle;

  /// Reverb effect: Karaoke
  String reverbTypeKTVTitle;

  /// Reverb effect：Hall
  String reverbTypeHallTitle;

  /// Reverb effect：Concert
  String reverbTypeConcertTitle;

  /// Reverb effect：Rock
  String reverbTypeRockTitle;

  /// Reverb effect：Small room
  String reverbTypeSmallRoomTitle;

  /// Reverb effect：Large room
  String reverbTypeLargeRoomTitle;

  /// Reverb effect：Valley
  String reverbTypeValleyTitle;

  /// Reverb effect：Recording studio
  String reverbTypeRecordingStudioTitle;

  /// Reverb effect：Basement
  String reverbTypeBasementTitle;

  /// Reverb effect：Pop
  String reverbTypePopularTitle;

  /// Reverb effect：Gramophone
  String reverbTypeGramophoneTitle;

  /// Beauty effect：Whiten
  String beautyEffectTypeWhitenTitle;

  /// Beauty effect：Rosy
  String beautyEffectTypeRosyTitle;

  /// Beauty effect：Smooth
  String beautyEffectTypeSmoothTitle;

  /// Beauty effect：Sharpen
  String beautyEffectTypeSharpenTitle;

  /// Beauty effect：None
  String beautyEffectTypeNoneTitle;

  /// The dialog info for the local host receives a PK invitation
  /// The **default values** are:
  /// - Title: "PK Battle Request"
  /// - Message: "%0 sends a PK battle request to you.", where %0 will be replaced with the corresponding username.
  /// - Cancel button name: "Reject"
  /// - Confirm button name: "Accept"
  ZegoDialogInfo incomingPKBattleRequestReceived;

  /// The dialog info for the co-host is terminated cause by host start PK
  /// The **default values** are:
  /// - Title: "Host Start PK Battle"
  /// - Message: "Your co-hosting ended."
  /// - Cancel button name: ""
  /// - Confirm button name: "OK"
  ZegoDialogInfo coHostEndCauseByHostStartPK;

  /// The dialog info for the remote host end the PK
  /// The **default values** are:
  /// - Title: "PK Battle Ended"
  /// - Message: "%0 ended the PK Battle.", where %0 will be replaced with the corresponding username.
  /// - Cancel button name: ""
  /// - Confirm button name: "OK"
  ZegoDialogInfo pkBattleEndedCauseByAnotherHost;

  /// The dialog info for the pk invitation failed cause by other error happen
  /// The **default values** are:
  /// - Title: "PK Battle Initiate Failed"
  /// - Message: "code: %0.", where %0 will be replaced with the corresponding error code.
  /// - Cancel button name: ""
  /// - Confirm button name: "OK"
  ZegoDialogInfo outgoingPKBattleRequestRejectedCauseByError;

  /// The dialog info for the pk invitation failed cause by the remote host was busy
  /// The **default values** are:
  /// - Title: "PK Battle Initiate Failed"
  /// - Message: "The host is busy."
  /// - Cancel button name: ""
  /// - Confirm button name: "OK"
  ZegoDialogInfo outgoingPKBattleRequestRejectedCauseByBusy;

  /// The dialog info for the pk invitation failed cause by the status of the local host was wrong
  /// The **default values** are:
  /// - Title: "PK Battle Initiate Failed"
  /// - Message: "You can only initiate the PK battle when the host has started a livestream."
  /// - Cancel button name: ""
  /// - Confirm button name: "OK"
  ZegoDialogInfo outgoingPKBattleRequestRejectedCauseByLocalHostStateError;

  /// The dialog info for the pk invitation failed cause by the remote host refused
  /// The **default values** are:
  /// - Title: "PK Battle Initiate Failed"
  /// - Message: "The host rejected your request."
  /// - Cancel button name: ""
  /// - Confirm button name: "OK"
  ZegoDialogInfo outgoingPKBattleRequestRejectedCauseByReject;

  ZegoInnerText({
    String? disagreeButton,
    String? agreeButton,
    String? startLiveStreamingButton,
    String? endCoHostButton,
    String? requestCoHostButton,
    String? cancelRequestCoHostButton,
    String? removeCoHostButton,
    String? cancelMenuDialogButton,
    String? inviteCoHostButton,
    String? removeUserMenuDialogButton,
    String? noHostOnline,
    String? memberListTitle,
    String? memberListRoleYou,
    String? memberListRoleHost,
    String? memberListRoleCoHost,
    String? sendRequestCoHostToast,
    String? hostRejectCoHostRequestToast,
    String? inviteCoHostFailedToast,
    String? audienceRejectInvitationToast,
    String? requestCoHostFailedToast,
    String? repeatInviteCoHostFailedToast,
    String? messageEmptyToast,
    String? userEnter,
    String? userLeave,
    ZegoDialogInfo? cameraPermissionSettingDialogInfo,
    ZegoDialogInfo? microphonePermissionSettingDialogInfo,
    ZegoDialogInfo? receivedCoHostRequestDialogInfo,
    ZegoDialogInfo? receivedCoHostInvitationDialogInfo,
    ZegoDialogInfo? endConnectionDialogInfo,
    String? audioEffectTitle,
    String? audioEffectReverbTitle,
    String? audioEffectVoiceChangingTitle,
    String? beautyEffectTitle,
    String? voiceChangerNoneTitle,
    String? voiceChangerLittleBoyTitle,
    String? voiceChangerLittleGirlTitle,
    String? voiceChangerDeepTitle,
    String? voiceChangerCrystalClearTitle,
    String? voiceChangerRobotTitle,
    String? voiceChangerEtherealTitle,
    String? voiceChangerFemaleTitle,
    String? voiceChangerMaleTitle,
    String? voiceChangerOptimusPrimeTitle,
    String? voiceChangerCMajorTitle,
    String? voiceChangerAMajorTitle,
    String? voiceChangerHarmonicMinorTitle,
    String? reverbTypeNoneTitle,
    String? reverbTypeKTVTitle,
    String? reverbTypeHallTitle,
    String? reverbTypeConcertTitle,
    String? reverbTypeRockTitle,
    String? reverbTypeSmallRoomTitle,
    String? reverbTypeLargeRoomTitle,
    String? reverbTypeValleyTitle,
    String? reverbTypeRecordingStudioTitle,
    String? reverbTypeBasementTitle,
    String? reverbTypePopularTitle,
    String? reverbTypeGramophoneTitle,
    String? beautyEffectTypeWhitenTitle,
    String? beautyEffectTypeRosyTitle,
    String? beautyEffectTypeSmoothTitle,
    String? beautyEffectTypeSharpenTitle,
    String? beautyEffectTypeNoneTitle,
    ZegoDialogInfo? incomingPKBattleRequestReceived,
    ZegoDialogInfo? coHostEndCauseByHostStartPK,
    ZegoDialogInfo? pkBattleEndedCauseByAnotherHost,
    ZegoDialogInfo? outgoingPKBattleRequestRejectedCauseByError,
    ZegoDialogInfo? outgoingPKBattleRequestRejectedCauseByBusy,
    ZegoDialogInfo? outgoingPKBattleRequestRejectedCauseByLocalHostStateError,
    ZegoDialogInfo? outgoingPKBattleRequestRejectedCauseByReject,
  })  : disagreeButton = disagreeButton ?? 'Disagree',
        agreeButton = agreeButton ?? 'Agree',
        startLiveStreamingButton = startLiveStreamingButton ?? 'Start',
        endCoHostButton = endCoHostButton ?? 'End',
        requestCoHostButton = requestCoHostButton ?? 'Apply to co-host',
        cancelRequestCoHostButton =
            cancelRequestCoHostButton ?? 'Cancel the application',
        removeCoHostButton = removeCoHostButton ?? 'Remove the co-host',
        inviteCoHostButton = inviteCoHostButton ?? 'Invite $param_1 to co-host',
        removeUserMenuDialogButton =
            removeUserMenuDialogButton ?? 'Remove $param_1 from the room',
        cancelMenuDialogButton = cancelMenuDialogButton ?? 'Cancel',
        noHostOnline = noHostOnline ?? 'No host is online.',
        memberListTitle = memberListTitle ?? 'Audience',
        memberListRoleYou = memberListRoleYou ?? 'You',
        memberListRoleHost = memberListRoleHost ?? 'Host',
        memberListRoleCoHost = memberListRoleCoHost ?? 'Co-host',
        sendRequestCoHostToast = sendRequestCoHostToast ??
            'You are applying to be a co-host, please wait for confirmation.',
        hostRejectCoHostRequestToast = hostRejectCoHostRequestToast ??
            'Your request to co-host with the host has been refused.',
        inviteCoHostFailedToast = inviteCoHostFailedToast ??
            'Failed to connect with the co-host, please try again.',
        repeatInviteCoHostFailedToast = repeatInviteCoHostFailedToast ??
            "You've sent the invitation, please wait for confirmation.",
        messageEmptyToast = messageEmptyToast ?? 'Say something...',
        userEnter = userEnter ?? 'entered',
        userLeave = userLeave ?? 'left',
        audienceRejectInvitationToast = audienceRejectInvitationToast ??
            '$param_1 refused to be a co-host.',
        requestCoHostFailedToast =
            requestCoHostFailedToast ?? 'Failed to apply for connection.',
        cameraPermissionSettingDialogInfo = cameraPermissionSettingDialogInfo ??
            ZegoDialogInfo(
              title: 'Can not use Camera!',
              message: 'Please enable camera access in the system settings!',
              cancelButtonName: 'Cancel',
              confirmButtonName: 'Settings',
            ),
        microphonePermissionSettingDialogInfo =
            microphonePermissionSettingDialogInfo ??
                ZegoDialogInfo(
                  title: 'Can not use Microphone!',
                  message:
                      'Please enable microphone access in the system settings!',
                  cancelButtonName: 'Cancel',
                  confirmButtonName: 'Settings',
                ),
        receivedCoHostRequestDialogInfo = receivedCoHostRequestDialogInfo ??
            ZegoDialogInfo(
              title: 'Co-host request',
              message: '$param_1 wants to co-host with you.',
              cancelButtonName: 'Disagree',
              confirmButtonName: 'Agree',
            ),
        receivedCoHostInvitationDialogInfo =
            receivedCoHostInvitationDialogInfo ??
                ZegoDialogInfo(
                  title: 'Invitation',
                  message: 'The host is inviting you to co-host.',
                  cancelButtonName: 'Disagree',
                  confirmButtonName: 'Agree',
                ),
        endConnectionDialogInfo = endConnectionDialogInfo ??
            ZegoDialogInfo(
              title: 'End the connection',
              message: 'Do you want to end the cohosting?',
            ),
        audioEffectTitle = audioEffectTitle ?? 'Audio effect',
        audioEffectReverbTitle = audioEffectReverbTitle ?? 'Reverb',
        audioEffectVoiceChangingTitle =
            audioEffectVoiceChangingTitle ?? 'Voice changing',
        beautyEffectTitle = beautyEffectTitle ?? 'Face beautification',
        voiceChangerNoneTitle = voiceChangerNoneTitle ?? 'None',
        voiceChangerLittleBoyTitle = voiceChangerLittleBoyTitle ?? 'Little boy',
        voiceChangerLittleGirlTitle =
            voiceChangerLittleGirlTitle ?? 'Little girl',
        voiceChangerDeepTitle = voiceChangerDeepTitle ?? 'Deep',
        voiceChangerCrystalClearTitle =
            voiceChangerCrystalClearTitle ?? 'Crystal-clear',
        voiceChangerRobotTitle = voiceChangerRobotTitle ?? 'Robot',
        voiceChangerEtherealTitle = voiceChangerEtherealTitle ?? 'Ethereal',
        voiceChangerFemaleTitle = voiceChangerFemaleTitle ?? 'Female',
        voiceChangerMaleTitle = voiceChangerMaleTitle ?? 'Male',
        voiceChangerOptimusPrimeTitle =
            voiceChangerOptimusPrimeTitle ?? 'Optimus Prime',
        voiceChangerCMajorTitle = voiceChangerCMajorTitle ?? 'C major',
        voiceChangerAMajorTitle = voiceChangerAMajorTitle ?? 'A major',
        voiceChangerHarmonicMinorTitle =
            voiceChangerHarmonicMinorTitle ?? 'Harmonic minor',
        reverbTypeNoneTitle = reverbTypeNoneTitle ?? 'None',
        reverbTypeKTVTitle = reverbTypeKTVTitle ?? 'Karaoke',
        reverbTypeHallTitle = reverbTypeHallTitle ?? 'Hall',
        reverbTypeConcertTitle = reverbTypeConcertTitle ?? 'Concert',
        reverbTypeRockTitle = reverbTypeRockTitle ?? 'Rock',
        reverbTypeSmallRoomTitle = reverbTypeSmallRoomTitle ?? 'Small room',
        reverbTypeLargeRoomTitle = reverbTypeLargeRoomTitle ?? 'Large room',
        reverbTypeValleyTitle = reverbTypeValleyTitle ?? 'Valley',
        reverbTypeRecordingStudioTitle =
            reverbTypeRecordingStudioTitle ?? 'Recording studio',
        reverbTypeBasementTitle = reverbTypeBasementTitle ?? 'Basement',
        reverbTypePopularTitle = reverbTypePopularTitle ?? 'Pop',
        reverbTypeGramophoneTitle = reverbTypeGramophoneTitle ?? 'Gramophone',
        beautyEffectTypeWhitenTitle =
            beautyEffectTypeWhitenTitle ?? 'Skin Tone',
        beautyEffectTypeRosyTitle = beautyEffectTypeRosyTitle ?? 'Blusher',
        beautyEffectTypeSmoothTitle =
            beautyEffectTypeSmoothTitle ?? 'Smoothing',
        beautyEffectTypeSharpenTitle =
            beautyEffectTypeSharpenTitle ?? 'Sharpening',
        beautyEffectTypeNoneTitle = beautyEffectTypeNoneTitle ?? 'None',
        incomingPKBattleRequestReceived = incomingPKBattleRequestReceived ??
            ZegoDialogInfo(
              title: 'PK Battle Request',
              message: '$param_1 sends a PK battle request to you.',
              cancelButtonName: 'Reject',
              confirmButtonName: 'Accept',
            ),
        coHostEndCauseByHostStartPK = coHostEndCauseByHostStartPK ??
            ZegoDialogInfo(
              title: 'Host Start PK Battle',
              message: 'Your co-hosting ended.',
              cancelButtonName: '',
              confirmButtonName: 'OK',
            ),
        pkBattleEndedCauseByAnotherHost = pkBattleEndedCauseByAnotherHost ??
            ZegoDialogInfo(
              title: 'PK Battle Ended',
              message: '$param_1 ended the PK Battle.',
              cancelButtonName: '',
              confirmButtonName: 'OK',
            ),
        outgoingPKBattleRequestRejectedCauseByError =
            outgoingPKBattleRequestRejectedCauseByError ??
                ZegoDialogInfo(
                  title: 'PK Battle Initiate Failed',
                  message: 'code: $param_1.',
                  cancelButtonName: '',
                  confirmButtonName: 'OK',
                ),
        outgoingPKBattleRequestRejectedCauseByBusy =
            outgoingPKBattleRequestRejectedCauseByBusy ??
                ZegoDialogInfo(
                  title: 'PK Battle Initiate Failed',
                  message: 'The host $param_1 is busy.',
                  cancelButtonName: '',
                  confirmButtonName: 'OK',
                ),
        outgoingPKBattleRequestRejectedCauseByLocalHostStateError =
            outgoingPKBattleRequestRejectedCauseByLocalHostStateError ??
                ZegoDialogInfo(
                  title: 'PK Battle Initiate Failed',
                  message:
                      'You can only initiate the PK battle when the host has started a livestream.',
                  cancelButtonName: '',
                  confirmButtonName: 'OK',
                ),
        outgoingPKBattleRequestRejectedCauseByReject =
            outgoingPKBattleRequestRejectedCauseByReject ??
                ZegoDialogInfo(
                  title: 'PK Battle Rejected',
                  message: 'The host $param_1 rejected your request.',
                  cancelButtonName: '',
                  confirmButtonName: 'OK',
                );
}

/// @nodoc
@Deprecated('Since 2.5.8, please use ZegoInnerText instead')
typedef ZegoTranslationText = ZegoInnerText;
