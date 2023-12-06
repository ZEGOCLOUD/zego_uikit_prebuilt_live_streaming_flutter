// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'layout.dart';

class ZegoPKV2GridMixerLayout extends ZegoPKV2MixerLayout {
  final widthFactor = 160.0;
  final heightFactor = 180.0;

  ZegoPKV2GridMixerLayoutResolutionLevel resolutionLevel =
      ZegoPKV2GridMixerLayoutResolutionLevel.standardDefinition;

  @override
  Size getResolution() => Size(
        widthFactor * resolutionLevel.ratio,
        heightFactor * resolutionLevel.ratio,
      );

  @override
  List<Rect> getRectList(
    int hostCount, {
    double scale = 1.0,
  }) {
    final resolution = getResolution();
    final rowCount = getRowCount(hostCount);
    final columnCount = getColumnCount(hostCount);
    final itemWidth = resolution.width / columnCount;
    final itemHeight = resolution.height / rowCount;

    List<Rect> rectList = [];
    var hostRowIndex = 0;
    var hostColumnIndex = 0;
    for (int hostIndex = 0; hostIndex < hostCount; ++hostIndex) {
      if (hostColumnIndex == columnCount) {
        hostColumnIndex = 0;
        hostRowIndex++;
      }

      rectList.add(
        Rect.fromLTWH(
          itemWidth * hostColumnIndex * scale,
          itemHeight * hostRowIndex * scale,
          itemWidth * scale,
          itemHeight * scale,
        ),
      );

      ++hostColumnIndex;
    }

    return rectList;
  }

  int getRowCount(int hostCount) {
    if (hostCount > 6) {
      return 3;
    }
    if (hostCount > 2) {
      return 2;
    }
    return 1;
  }

  int getColumnCount(int hostCount) {
    if (hostCount > 4) {
      return 3;
    }
    return 2;
  }
}

/// canvas w/h ratio is 16:18
enum ZegoPKV2GridMixerLayoutResolutionLevel {
  /// 320 * 360
  lowDefinition,

  /// 480 * 540
  basicDefinition,

  /// 640 * 720
  standardDefinition,

  /// 960 * 1080
  highDefinition,

  /// 1280 * 1440
  fullHighDefinition,
}

extension ZegoPKV2GridMixerLayoutResolutionLevelExtension
    on ZegoPKV2GridMixerLayoutResolutionLevel {
  double get ratio {
    switch (this) {
      case ZegoPKV2GridMixerLayoutResolutionLevel.lowDefinition:
        return 2.0;
      case ZegoPKV2GridMixerLayoutResolutionLevel.basicDefinition:
        return 3.0;
      case ZegoPKV2GridMixerLayoutResolutionLevel.standardDefinition:
        return 4.0;
      case ZegoPKV2GridMixerLayoutResolutionLevel.highDefinition:
        return 6.0;
      case ZegoPKV2GridMixerLayoutResolutionLevel.fullHighDefinition:
        return 8.0;
    }
  }
}
