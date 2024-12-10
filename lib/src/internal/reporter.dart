import 'package:zego_uikit/zego_uikit.dart';

class ZegoLiveStreamingReporter {
  static String eventInit = "livestreaming/init";
  static String eventUninit = "livestreaming/unInit";

  /// Version number of each kit, usually in three segments
  static String eventKeyKitVersion = "livestreaming_version";

  Future<void> report({
    required String event,
    Map<String, Object> params = const {},
  }) async {
    ZegoUIKit().reporter().report(event: event, params: params);
  }

  factory ZegoLiveStreamingReporter() {
    return instance;
  }

  ZegoLiveStreamingReporter._internal();

  static final ZegoLiveStreamingReporter instance =
      ZegoLiveStreamingReporter._internal();
}
