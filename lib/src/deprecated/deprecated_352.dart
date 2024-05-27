// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

const deprecatedTipsV352 = ', '
    'deprecated since 3.5.2, '
    'will be removed after 3.10.0'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/topics/Migration_v3.x-topic.html#352';

extension ZegoLiveStreamingControllerUserImplDeprecated
    on ZegoLiveStreamingControllerUserImpl {
  @Deprecated(
      'Use \'ZegoUIKitPrebuiltLiveStreamingController().user.addFakeUser\' instead$deprecatedTipsV352')
  void addFake(ZegoUIKitUser user) {
    ZegoUIKitPrebuiltLiveStreamingController().user.addFakeUser(user);
  }

  @Deprecated(
      'Use \'ZegoUIKitPrebuiltLiveStreamingController().user.removeFakeUser\' instead$deprecatedTipsV352')
  void removeFake(ZegoUIKitUser user) {
    ZegoUIKitPrebuiltLiveStreamingController().user.removeFakeUser(user);
  }

  @Deprecated(
      'Use \'ZegoUIKitPrebuiltLiveStreamingController().user.stream\' instead$deprecatedTipsV352')
  Stream<List<ZegoUIKitUser>> get listStream =>
      ZegoUIKitPrebuiltLiveStreamingController().user.stream(
            includeFakeUser: false,
          );
}
