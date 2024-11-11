// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/deprecated/deprecated_352.dart';

const deprecatedTipsV350 = ', '
    'deprecated since 3.5.0, '
    'will be removed after 3.10.0'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/topics/Migration_v3.x-topic.html#350';

extension ZegoLiveStreamingControllerRoomImplDeprecated
    on ZegoLiveStreamingControllerRoomImpl {
  @Deprecated(
      'Use \'ZegoUIKitPrebuiltLiveStreamingController().user.addFake\' instead$deprecatedTipsV350')
  void addFakeUser(ZegoUIKitUser user) {
    ZegoUIKitPrebuiltLiveStreamingController().user.addFake(user);
  }

  @Deprecated(
      'Use \'ZegoUIKitPrebuiltLiveStreamingController().user.removeFake\' instead$deprecatedTipsV350')
  void removeFakeUser(ZegoUIKitUser user) {
    ZegoUIKitPrebuiltLiveStreamingController().user.removeFake(user);
  }
}
