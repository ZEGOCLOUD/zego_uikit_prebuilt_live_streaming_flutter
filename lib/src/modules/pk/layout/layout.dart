// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'prefer_gird_layout.dart';

/// Width of the mixer canvas for PK battles.
const zegoLiveStreamingPKMixerCanvasWidth = 810.0;

/// Height of the mixer canvas for PK battles.
const zegoLiveStreamingPKMixerCanvasHeight = 720.0;

/// Abstract class for PK mixer layout.
///
/// Inheritance of the hybrid layout parent class allows you to return your
/// custom coordinates and modify the layout of the mixed stream.
///
/// You can refer to [ZegoLiveStreamingPKPreferGridMixerLayout] or [ZegoPKV2GridMixerLayout].
abstract class ZegoLiveStreamingPKMixerLayout {
  /// The size of the mixed stream canvas.
  ///
  /// Default is [zegoLiveStreamingPKMixerCanvasWidth] x [zegoLiveStreamingPKMixerCanvasHeight].
  Size getResolution() {
    return const Size(
      zegoLiveStreamingPKMixerCanvasWidth,
      zegoLiveStreamingPKMixerCanvasHeight,
    );
  }

  /// Get the coordinates of the user's video frame on the PK layout at position [hostCount].
  ///
  /// - [hostCount] is the number of hosts in the PK battle.
  /// - [scale] is the scale factor for the layout.
  ///
  /// Returns a list of [Rect] representing the coordinates for each host's video frame.
  List<Rect> getRectList(
    int hostCount, {
    double scale = 1.0,
  });
}

/// Default PK mixer layout.
///
/// This is a typedef for [ZegoLiveStreamingPKPreferGridMixerLayout].
typedef ZegoLiveStreamingPKMixerDefaultLayout
    = ZegoLiveStreamingPKPreferGridMixerLayout;
