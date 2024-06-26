// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';

const deprecatedTipsV303 = ', '
    'deprecated since 3.0.3, '
    'will be removed after 3.10.0'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/topics/Migration_v3.x-topic.html#303';

extension ZegoLiveStreamingDurationEventsDeprecatedExtension
    on ZegoLiveStreamingDurationEvents {
  @Deprecated('Use onUpdated instead$deprecatedTipsV303')
  void Function(Duration)? get onUpdate => onUpdated;

  @Deprecated('Use onUpdated instead$deprecatedTipsV303')
  set onUpdate(void Function(Duration)? function) => onUpdated = function;
}
