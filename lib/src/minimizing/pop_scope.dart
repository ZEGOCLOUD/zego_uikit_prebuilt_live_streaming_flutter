// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// When minimizing, it is not allowed to directly return to the previous page, otherwise the page will be destroyed
class ZegoUIKitPrebuiltLiveStreamingMiniPopScope extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreamingMiniPopScope({
    Key? key,
    required this.child,
    this.canPop = false,
    this.onPopInvoked,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// When in the minimizing state, is it allowed back to the desktop or not.
  /// If true, it will back to the desktop; if false, nothing will happen.
  final bool canPop;

  /// If you don't want to back to the desktop directly, you can customize the pop logic
  final void Function(bool isMinimizing)? onPopInvoked;

  @override
  ZegoUIKitPrebuiltLiveStreamingMiniPopScopeState createState() =>
      ZegoUIKitPrebuiltLiveStreamingMiniPopScopeState();
}

/// @nodoc
class ZegoUIKitPrebuiltLiveStreamingMiniPopScopeState
    extends State<ZegoUIKitPrebuiltLiveStreamingMiniPopScope> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKitPrebuiltLiveStreamingController()
          .minimize
          .isMinimizingNotifier,
      builder: (context, isMinimizing, _) {
        return PopScope(
          /// Don't pop current widget directly when in minimizing
          canPop: false,
          onPopInvokedWithResult: (didPop, Object? result) async {
            if (didPop) {
              return;
            }

            if (isMinimizing) {
              if (widget.canPop) {
                onPopInvoked(isMinimizing);
              }

              // Prevent the default pop-up behavior in the minimized state
              // Prevent popping by not calling Navigator.pop()
            } else {
              onPopInvoked(isMinimizing);
              // Allows pop-up when not in minimized state
            }
          },
          child: widget.child,
        );
      },
    );
  }

  void onPopInvoked(bool isMinimizing) {
    if (null == widget.onPopInvoked) {
      ZegoUIKit().backToDesktop();
    } else {
      widget.onPopInvoked?.call(isMinimizing);
    }
  }
}
