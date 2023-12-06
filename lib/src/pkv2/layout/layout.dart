// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/layout/prefer_gird_layout.dart';

/// width of mixer canvas
const zegoPK2MixerCanvasWidth = 864.0;

/// height of mixer canvas
const zegoPK2MixerCanvasHeight = 972.0;

/// Inheritance of the hybrid layout parent class allows you to return your
/// custom coordinates and modify the layout of the mixed stream.
/// You can refer to [ZegoPKV2PreferGridMixerLayout] or [ZegoPKV2GridMixerLayout].
abstract class ZegoPKV2MixerLayout {
  /// The size of the mixed stream canvas.
  /// default is zegoPK2MixerCanvasWidth x zegoPK2MixerCanvasHeight
  Size getResolution() {
    return const Size(
      zegoPK2MixerCanvasWidth,
      zegoPK2MixerCanvasHeight,
    );
  }

  /// Get the coordinates of the user's video frame on the PK layout at position [hostCount].
  List<Rect> getRectList(
    int hostCount, {
    double scale = 1.0,
  });
}

typedef ZegoPKV2MixerDefaultLayout = ZegoPKV2PreferGridMixerLayout;
