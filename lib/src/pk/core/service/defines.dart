// Flutter imports:
import 'package:flutter/services.dart';

/// state in pk service
enum ZegoLiveStreamingPKBattleState {
  idle,
  inPK,
  loading,
}

/// reject code in pk service
enum ZegoLiveStreamingPKBattleRejectCode {
  /// 0:
  /// the invited host rejects your PK request.
  reject,

  /// 1:
  /// the invited host hasn't started his own live stream yet,
  /// the host is in a PK battle with others,
  /// the host is being invited,
  /// or the host is sending a PK battle request to others.
  hostStateError,

  /// 2:
  /// the host is in a PK battle with others,
  /// the host is being invited,
  /// or the host is sending a PK battle request to others.
  busy,
}

/// result of send request in pk service
class ZegoLiveStreamingPKServiceSendRequestResult {
  const ZegoLiveStreamingPKServiceSendRequestResult({
    this.requestID = '',
    this.errorUserIDs = const [],
    this.error,
  });

  /// The ID of the current PK session
  final String requestID;

  final List<String> errorUserIDs;
  final PlatformException? error;

  @override
  String toString() => '{requestID;$requestID, '
      'errorUserIDs:$errorUserIDs, '
      'error: $error}';
}

/// result of request in pk service
class ZegoLiveStreamingPKServiceResult {
  const ZegoLiveStreamingPKServiceResult({
    this.errorUserIDs = const [],
    this.error,
  });

  final List<String> errorUserIDs;
  final PlatformException? error;

  @override
  String toString() => '{errorUserIDs:$errorUserIDs, error: $error}';
}
