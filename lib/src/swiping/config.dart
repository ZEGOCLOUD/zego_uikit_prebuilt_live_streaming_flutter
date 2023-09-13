// Flutter imports:
import 'package:flutter/cupertino.dart';

/// Live Streaming swiping configuration.
class ZegoLiveStreamingSwipingConfig {
  final String Function() requirePreviousLiveID;
  final String Function() requireNextLiveID;

  /// Customize room loading effects
  Widget Function(String liveID)? loadingBuilder;

  ZegoLiveStreamingSwipingConfig({
    required this.requirePreviousLiveID,
    required this.requireNextLiveID,
    this.loadingBuilder,
  });
}
