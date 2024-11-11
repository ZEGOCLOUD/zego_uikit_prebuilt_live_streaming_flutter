// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';

const deprecatedTipsV340 = ', '
    'deprecated since 3.4.0, '
    'will be removed after 3.10.0'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/topics/Migration_v3.x-topic.html#340';

extension ZegoUIKitPrebuiltLiveStreamingConfigDeprecatedExtensionV340
    on ZegoUIKitPrebuiltLiveStreamingConfig {
  @Deprecated('Use coHost.maxCoHostCount instead$deprecatedTipsV340')
  int get maxCoHostCount => coHost.maxCoHostCount;

  @Deprecated('Use coHost.maxCoHostCount instead$deprecatedTipsV340')
  set maxCoHostCount(int value) => coHost.maxCoHostCount = value;

  @Deprecated('Use coHost.turnOnCameraWhenCohosted instead$deprecatedTipsV340')
  bool get stopCoHostingWhenMicCameraOff =>
      coHost.stopCoHostingWhenMicCameraOff;

  @Deprecated(
      'Use coHost.stopCoHostingWhenMicCameraOff instead$deprecatedTipsV340')
  set stopCoHostingWhenMicCameraOff(bool value) =>
      coHost.stopCoHostingWhenMicCameraOff = value;

  @Deprecated(
      'Use coHost.disableCoHostInvitationReceivedDialog instead$deprecatedTipsV340')
  bool get disableCoHostInvitationReceivedDialog =>
      coHost.disableCoHostInvitationReceivedDialog;

  @Deprecated(
      'Use coHost.disableCoHostInvitationReceivedDialog instead$deprecatedTipsV340')
  set disableCoHostInvitationReceivedDialog(bool value) =>
      coHost.disableCoHostInvitationReceivedDialog = value;

  bool Function()? get turnOnCameraWhenCohosted =>
      coHost.turnOnCameraWhenCohosted;

  @Deprecated('Use coHost.turnOnCameraWhenCohosted instead$deprecatedTipsV340')
  set turnOnCameraWhenCohosted(bool Function()? value) =>
      coHost.turnOnCameraWhenCohosted = value;
}
