// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'layout.dart';

class ZegoPKV2PreferGridMixerLayout extends ZegoPKV2MixerLayout {
  @override
  Size getResolution() {
    return const Size(
      zegoPK2MixerCanvasWidth,
      zegoPK2MixerCanvasHeight,
    );
  }

  @override
  List<Rect> getRectList(
    int hostCount, {
    double scale = 1.0,
  }) {
    if (3 == hostCount) {
      return getRectListFor3Hosts(scale: scale);
    } else if (5 == hostCount) {
      return getRectListFor5Hosts(scale: scale);
    } else {
      return getNormalRectList(hostCount, scale: scale);
    }
  }

  List<Rect> getRectListFor3Hosts({
    double scale = 1.0,
  }) {
    final resolution = getResolution();
    return <Rect>[
      Rect.fromLTWH(
        0,
        0,
        resolution.width / 2.0 * scale,
        resolution.height * scale,
      ),
      Rect.fromLTWH(
        resolution.width / 2.0 * scale,
        0,
        resolution.width / 2.0 * scale,
        resolution.height / 2.0 * scale,
      ),
      Rect.fromLTWH(
        resolution.width / 2.0 * scale,
        resolution.height / 2.0 * scale,
        resolution.width / 2.0 * scale,
        resolution.height / 2.0 * scale,
      ),
    ];
  }

  List<Rect> getRectListFor5Hosts({
    double scale = 1.0,
  }) {
    final resolution = getResolution();
    return <Rect>[
      Rect.fromLTWH(
        0,
        0,
        resolution.width / 2.0 * scale,
        resolution.height / 2.0 * scale,
      ),
      Rect.fromLTWH(
        resolution.width / 2.0 * scale,
        0,
        resolution.width / 2.0 * scale,
        resolution.height / 2.0 * scale,
      ),
      Rect.fromLTWH(
        0,
        resolution.height / 2.0 * scale,
        resolution.width / 3.0 * scale,
        resolution.height / 2.0 * scale,
      ),
      Rect.fromLTWH(
        resolution.width / 3.0 * scale,
        resolution.height / 2.0 * scale,
        resolution.width / 3.0 * scale,
        resolution.height / 2.0 * scale,
      ),
      Rect.fromLTWH(
        resolution.width / 3.0 * 2.0 * scale,
        resolution.height / 2.0 * scale,
        resolution.width / 3.0 * scale,
        resolution.height / 2.0 * scale,
      ),
    ];
  }

  /// only for 2/4/6/7~9
  List<Rect> getNormalRectList(
    int hostCount, {
    double scale = 1.0,
  }) {
    final resolution = getResolution();
    final rowCount = getNormalRowCount(hostCount);
    final columnCount = getNormalColumnCount(hostCount);
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

  int getNormalRowCount(int hostCount) {
    if (hostCount > 6) {
      return 3;
    }
    if (hostCount > 2) {
      return 2;
    }
    return 1;
  }

  int getNormalColumnCount(int hostCount) {
    if (hostCount > 4) {
      return 3;
    }
    return 2;
  }
}
