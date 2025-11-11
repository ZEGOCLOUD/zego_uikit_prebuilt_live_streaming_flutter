// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'enter_wave_painter.dart';

/// Wave line animation component
class ZegoLiveStreamingLiveHallEnterWaveAnimation extends StatefulWidget {
  const ZegoLiveStreamingLiveHallEnterWaveAnimation({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  State<ZegoLiveStreamingLiveHallEnterWaveAnimation> createState() =>
      _ZegoLiveStreamingLiveHallEnterWaveAnimationState();
}

class _ZegoLiveStreamingLiveHallEnterWaveAnimationState
    extends State<ZegoLiveStreamingLiveHallEnterWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ZegoLiveStreamingLiveHallEnterWavePainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}
