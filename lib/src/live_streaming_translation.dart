// Project imports:
import 'live_streaming_defines.dart';

/// %0: is a string placeholder, represents the first parameter of prompt
class ZegoTranslationText {
  final String param_1 = "%0";

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

  ZegoDialogInfo cameraPermissionSettingDialogInfo;
  ZegoDialogInfo microphonePermissionSettingDialogInfo;
  ZegoDialogInfo receivedCoHostRequestDialogInfo;
  ZegoDialogInfo receivedCoHostInvitationDialogInfo;
  ZegoDialogInfo endConnectionDialogInfo;

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
    ZegoDialogInfo? cameraPermissionSettingDialogInfo,
    ZegoDialogInfo? microphonePermissionSettingDialogInfo,
    ZegoDialogInfo? receivedCoHostRequestDialogInfo,
    ZegoDialogInfo? receivedCoHostInvitationDialogInfo,
    ZegoDialogInfo? endConnectionDialogInfo,
  })  : disagreeButton = disagreeButton ?? "Disagree",
        agreeButton = agreeButton ?? "Agree",
        startLiveStreamingButton = startLiveStreamingButton ?? "Start",
        endCoHostButton = endCoHostButton ?? "End",
        requestCoHostButton = requestCoHostButton ?? "Apply to co-host",
        cancelRequestCoHostButton =
            cancelRequestCoHostButton ?? "Cancel the application",
        removeCoHostButton = removeCoHostButton ?? "Remove the co-host",
        inviteCoHostButton = inviteCoHostButton ?? "Invite %0 to co-host",
        removeUserMenuDialogButton =
            removeUserMenuDialogButton ?? "remove %0 from the room",
        cancelMenuDialogButton = cancelMenuDialogButton ?? "Cancel",
        noHostOnline = noHostOnline ?? "No host is online.",
        memberListTitle = memberListTitle ?? "Attendance",
        sendRequestCoHostToast = sendRequestCoHostToast ??
            "You are applying to be a co-host, please wait for confirmation.",
        hostRejectCoHostRequestToast = hostRejectCoHostRequestToast ??
            "Your request to co-host with the host has been refused.",
        inviteCoHostFailedToast = inviteCoHostFailedToast ??
            "Failed to connect with the co-host, please try again.",
        repeatInviteCoHostFailedToast = repeatInviteCoHostFailedToast ??
            "You've sent the invitation, please wait for confirmation.",
        audienceRejectInvitationToast =
            audienceRejectInvitationToast ?? "%0 refused to be a co-host.",
        requestCoHostFailedToast =
            requestCoHostFailedToast ?? "Failed to apply for connection.",
        cameraPermissionSettingDialogInfo = cameraPermissionSettingDialogInfo ??
            ZegoDialogInfo(
              title: "Can not use Camera!",
              message: "Please enable camera access in the system settings!",
              cancelButtonName: "Cancel",
              confirmButtonName: "Settings",
            ),
        microphonePermissionSettingDialogInfo =
            microphonePermissionSettingDialogInfo ??
                ZegoDialogInfo(
                  title: "Can not use Microphone!",
                  message:
                      "Please enable microphone access in the system settings!",
                  cancelButtonName: "Cancel",
                  confirmButtonName: "Settings",
                ),
        receivedCoHostRequestDialogInfo = receivedCoHostRequestDialogInfo ??
            ZegoDialogInfo(
              title: "Co-host request",
              message: "%0 wants to co-host with you.",
              cancelButtonName: "Disagree",
              confirmButtonName: "Agree",
            ),
        receivedCoHostInvitationDialogInfo =
            receivedCoHostInvitationDialogInfo ??
                ZegoDialogInfo(
                  title: "Invitation",
                  message: "The host is inviting you to co-host.",
                  cancelButtonName: "Disagree",
                  confirmButtonName: "Agree",
                ),
        endConnectionDialogInfo = endConnectionDialogInfo ??
            ZegoDialogInfo(
              title: "End the connection",
              message: "Do you want to end the cohosting?",
            );
}
