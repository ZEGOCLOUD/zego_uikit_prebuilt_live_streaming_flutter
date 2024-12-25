// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoLiveStreamingReporter {
  static String eventInit = "livestreaming/init";
  static String eventUninit = "livestreaming/unInit";

  static String eventCoHostHostInvite = "livestreaming/cohost/host/invite";
  static String eventCoHostHostReceived = "livestreaming/cohost/host/received";
  static String eventCoHostHostRespond = "livestreaming/cohost/host/respond";
  static String eventCoHostHostStop = "livestreaming/cohost/host/stop";
  static String eventCoHostAudienceInvite =
      "livestreaming/cohost/audience/invite";
  static String eventCoHostAudienceReceived =
      "livestreaming/cohost/audience/received";
  static String eventCoHostAudienceRespond =
      "livestreaming/cohost/audience/respond";
  static String eventCoHostAudienceStart =
      "livestreaming/cohost/audience/start";
  static String eventCoHostAudienceStop = "livestreaming/cohost/audience/stop";
  static String eventCoHostCoHostReceived =
      "livestreaming/cohost/cohost/received";

  static String eventPKInvite = "livestreaming/pk/invite";
  static String eventPKAdd = "livestreaming/pk/add";
  static String eventPKEnd = "livestreaming/pk/end";
  static String eventPKQuit = "livestreaming/pk/quit";
  static String eventPKReceived = "livestreaming/pk/received";
  static String eventPKRespond = "livestreaming/pk/respond";
  static String eventPKStartPlay = "livestreaming/pk/stream/startplay";
  static String eventPKStartPlayFinished =
      "livestreaming/pk/stream/startplay_finished";

  static String eventKeyAudienceID = "audience_id";
  static String eventKeyCoHostID = "cohost_id";
  static String eventKeyHostID = "host_id";
  static String eventKeyCallID = "call_id";
  static String eventKeyRoomID = "roomID";
  static String eventKeyExtendedData = "extended_data";
  static String eventKeyStreamID = "stream_id";
  static String eventKeyError = "error";

  static String eventKeyAction = "action";
  static String eventKeyActionAccept = "accept";
  static String eventKeyActionRefuse = "refuse";
  static String eventKeyActionCancel = "cancel";
  static String eventKeyActionTimeout = "timeout";

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
