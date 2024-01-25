// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/layout/prefer_gird_layout.dart';

/// width of mixer canvas
const zegoLiveStreamingPK2MixerCanvasWidth = 972.0;

/// height of mixer canvas
const zegoLiveStreamingPK2MixerCanvasHeight = 864.0;

/// Inheritance of the hybrid layout parent class allows you to return your
/// custom coordinates and modify the layout of the mixed stream.
/// You can refer to [ZegoLiveStreamingPKPreferGridMixerLayout] or [ZegoPKV2GridMixerLayout].
abstract class ZegoLiveStreamingPKMixerLayout {
  /// The size of the mixed stream canvas.
  /// default is zegoPK2MixerCanvasWidth x zegoPK2MixerCanvasHeight
  Size getResolution() {
    return const Size(
      zegoLiveStreamingPK2MixerCanvasWidth,
      zegoLiveStreamingPK2MixerCanvasHeight,
    );
  }

  /// Get the coordinates of the user's video frame on the PK layout at position [hostCount].
  List<Rect> getRectList(
    int hostCount, {
    double scale = 1.0,
  });
}

typedef ZegoLiveStreamingPKMixerDefaultLayout
    = ZegoLiveStreamingPKPreferGridMixerLayout;
