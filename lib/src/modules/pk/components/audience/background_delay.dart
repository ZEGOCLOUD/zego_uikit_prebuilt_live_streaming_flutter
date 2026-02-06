// Dart imports:
import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that delays the display of the background when the camera is off.
/// This prevents the background from flashing briefly before the video stream is ready
/// when the initial camera state might be false but quickly becomes true.
class ZegoPKBackgroundDelayedShow extends StatefulWidget {
  const ZegoPKBackgroundDelayedShow({
    super.key,
    required this.isCameraOn,
    required this.childBuilder,
    this.delay = const Duration(milliseconds: 500),
  });

  final bool isCameraOn;
  final Widget Function() childBuilder;
  final Duration delay;

  @override
  State<ZegoPKBackgroundDelayedShow> createState() =>
      _ZegoPKBackgroundDelayedShowState();
}

class _ZegoPKBackgroundDelayedShowState
    extends State<ZegoPKBackgroundDelayedShow> {
  Timer? _timer;
  bool _showBackground = false;

  @override
  void initState() {
    super.initState();
    _updateState();
  }

  @override
  void didUpdateWidget(ZegoPKBackgroundDelayedShow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCameraOn != widget.isCameraOn) {
      _updateState();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateState() {
    _timer?.cancel();

    if (widget.isCameraOn) {
      // Camera is ON, hide background immediately
      _showBackground = false;
    } else {
      // Camera is OFF, delay showing background
      if (!_showBackground) {
        _timer = Timer(widget.delay, () {
          if (mounted) {
            setState(() {
              _showBackground = true;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCameraOn) {
      return Container(color: Colors.transparent);
    }

    if (_showBackground) {
      return widget.childBuilder();
    }

    return Container(color: Colors.transparent);
  }
}
