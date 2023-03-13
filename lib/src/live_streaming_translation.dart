// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';

/// %0: is a string placeholder, represents the first parameter of prompt
class ZegoTranslationText {
  final String param_1 = '%0';

  String disagreeButton;
  String agreeButton;
  String startLiveStreamingButton;
  String endCoHostButton;
  String requestCoHostButton;
  String cancelRequestCoHostButton;
  String removeCoHostButton;
  String cancelMenuDialogButton;
  String inviteCoHostButton;
  String removeUserMenuDialogButton;

  String noHostOnline;
  String memberListTitle;
  String sendRequestCoHostToast;
  String hostRejectCoHostRequestToast;
  String inviteCoHostFailedToast;
  String audienceRejectInvitationToast;
  String requestCoHostFailedToast;
  String repeatInviteCoHostFailedToast;

  String messageEmptyToast;

  ZegoDialogInfo cameraPermissionSettingDialogInfo;
  ZegoDialogInfo microphonePermissionSettingDialogInfo;
  ZegoDialogInfo receivedCoHostRequestDialogInfo;
  ZegoDialogInfo receivedCoHostInvitationDialogInfo;
  ZegoDialogInfo endConnectionDialogInfo;

  /// effect
  String audioEffectTitle;
  String audioEffectReverbTitle;
  String audioEffectVoiceChangingTitle;

  /// voice effect
  String voiceChangerNoneTitle;
  String voiceChangerLittleBoyTitle;
  String voiceChangerLittleGirlTitle;
  String voiceChangerDeepTitle;
  String voiceChangerCrystalClearTitle;
  String voiceChangerRobotTitle;
  String voiceChangerEtherealTitle;
  String voiceChangerFemaleTitle;
  String voiceChangerMaleTitle;
  String voiceChangerOptimusPrimeTitle;
  String voiceChangerCMajorTitle;
  String voiceChangerAMajorTitle;
  String voiceChangerHarmonicMinorTitle;

  /// revert effect
  String reverbTypeNoneTitle;
  String reverbTypeKTVTitle;
  String reverbTypeHallTitle;
  String reverbTypeConcertTitle;
  String reverbTypeRockTitle;
  String reverbTypeSmallRoomTitle;
  String reverbTypeLargeRoomTitle;
  String reverbTypeValleyTitle;
  String reverbTypeRecordingStudioTitle;
  String reverbTypeBasementTitle;
  String reverbTypePopularTitle;
  String reverbTypeGramophoneTitle;

  /// beauty effect
  String beautyEffectTypeWhitenTitle;
  String beautyEffectTypeRosyTitle;
  String beautyEffectTypeSmoothTitle;
  String beautyEffectTypeSharpenTitle;
  String beautyEffectTypeNoneTitle;

  ZegoTranslationText({
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
    String? sendRequestCoHostToast,
    String? hostRejectCoHostRequestToast,
    String? inviteCoHostFailedToast,
    String? audienceRejectInvitationToast,
    String? requestCoHostFailedToast,
    String? repeatInviteCoHostFailedToast,
    String? messageEmptyToast,
    ZegoDialogInfo? cameraPermissionSettingDialogInfo,
    ZegoDialogInfo? microphonePermissionSettingDialogInfo,
    ZegoDialogInfo? receivedCoHostRequestDialogInfo,
    ZegoDialogInfo? receivedCoHostInvitationDialogInfo,
    ZegoDialogInfo? endConnectionDialogInfo,
    String? audioEffectTitle,
    String? audioEffectReverbTitle,
    String? audioEffectVoiceChangingTitle,
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
  })  : disagreeButton = disagreeButton ?? 'Disagree',
        agreeButton = agreeButton ?? 'Agree',
        startLiveStreamingButton = startLiveStreamingButton ?? 'Start',
        endCoHostButton = endCoHostButton ?? 'End',
        requestCoHostButton = requestCoHostButton ?? 'Apply to co-host',
        cancelRequestCoHostButton =
            cancelRequestCoHostButton ?? 'Cancel the application',
        removeCoHostButton = removeCoHostButton ?? 'Remove the co-host',
        inviteCoHostButton = inviteCoHostButton ?? 'Invite %0 to co-host',
        removeUserMenuDialogButton =
            removeUserMenuDialogButton ?? 'remove %0 from the room',
        cancelMenuDialogButton = cancelMenuDialogButton ?? 'Cancel',
        noHostOnline = noHostOnline ?? 'No host is online.',
        memberListTitle = memberListTitle ?? 'Audience',
        sendRequestCoHostToast = sendRequestCoHostToast ??
            'You are applying to be a co-host, please wait for confirmation.',
        hostRejectCoHostRequestToast = hostRejectCoHostRequestToast ??
            'Your request to co-host with the host has been refused.',
        inviteCoHostFailedToast = inviteCoHostFailedToast ??
            'Failed to connect with the co-host, please try again.',
        repeatInviteCoHostFailedToast = repeatInviteCoHostFailedToast ??
            "You've sent the invitation, please wait for confirmation.",
        messageEmptyToast = messageEmptyToast ?? 'Say something...',
        audienceRejectInvitationToast =
            audienceRejectInvitationToast ?? '%0 refused to be a co-host.',
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
              message: '%0 wants to co-host with you.',
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
        beautyEffectTypeNoneTitle = beautyEffectTypeNoneTitle ?? 'None';
}
