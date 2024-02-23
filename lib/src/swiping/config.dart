// Flutter imports:
import 'package:flutter/cupertino.dart';

/// Live Streaming swiping configuration.
class ZegoLiveStreamingSwipingConfig {
  /// slide to the previous live streaming, you need to return the LIVE ID of
  /// the previous live streaming.
  final String Function() requirePreviousLiveID;

  /// slide to the next live streaming, you need to return the LIVE ID of
  /// the next live streaming.
  final String Function() requireNextLiveID;

  /// Customize room loading effects
  Widget Function(String liveID)? loadingBuilder;

  ZegoLiveStreamingSwipingConfig({
    required this.requirePreviousLiveID,
    required this.requireNextLiveID,
    this.loadingBuilder,
  });
}
