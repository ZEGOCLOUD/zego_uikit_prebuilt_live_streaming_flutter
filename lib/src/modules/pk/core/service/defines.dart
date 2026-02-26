// Flutter imports:
import 'package:flutter/services.dart';

/// State of the PK battle service.
///
/// - [idle]: No active PK battle.
/// - [inPK]: Currently in a PK battle.
/// - [loading]: Loading state when setting up a PK battle.
enum ZegoLiveStreamingPKBattleState {
  idle,
  inPK,
  loading,
}

/// Reject code for PK battle requests.
///
/// These codes indicate why a PK battle request was rejected.
enum ZegoLiveStreamingPKBattleRejectCode {
  /// 0:
  /// The invited host rejects your PK request.
  reject,

  /// 1:
  /// The invited host hasn't started his own live stream yet,
  /// the host is in a PK battle with others,
  /// the host is being invited,
  /// or the host is sending a PK battle request to others.
  hostStateError,

  /// 2:
  /// The host is in a PK battle with others,
  /// the host is being invited,
  /// or the host is sending a PK battle request to others.
  busy,
}

/// Result of sending a PK battle request.
///
/// This class contains the result information when sending a PK battle request.
class ZegoLiveStreamingPKServiceSendRequestResult {
  /// Creates a PK service send request result.
  ///
  /// - [requestID] is the ID of the PK session request.
  /// - [errorUserIDs] is a list of user IDs that encountered errors.
  /// - [error] is the platform exception if an error occurred.
  const ZegoLiveStreamingPKServiceSendRequestResult({
    this.requestID = '',
    this.errorUserIDs = const [],
    this.error,
  });

  /// The ID of the current PK session.
  final String requestID;

  /// List of user IDs that encountered errors during the request.
  final List<String> errorUserIDs;

  /// Platform exception if an error occurred.
  final PlatformException? error;

  @override
  String toString() => '{'
      'requestID;$requestID, '
      'errorUserIDs:$errorUserIDs, '
      'error: $error, '
      '}';
}

/// Result of a PK battle request.
///
/// This class contains the result information for a PK battle request operation.
class ZegoLiveStreamingPKServiceResult {
  /// Creates a PK service result.
  ///
  /// - [errorUserIDs] is a list of user IDs that encountered errors.
  /// - [error] is the platform exception if an error occurred.
  const ZegoLiveStreamingPKServiceResult({
    this.errorUserIDs = const [],
    this.error,
  });

  /// List of user IDs that encountered errors during the request.
  final List<String> errorUserIDs;

  /// Platform exception if an error occurred.
  final PlatformException? error;

  @override
  String toString() => '{'
      'errorUserIDs:$errorUserIDs, '
      'error: $error, '
      '}';
}
