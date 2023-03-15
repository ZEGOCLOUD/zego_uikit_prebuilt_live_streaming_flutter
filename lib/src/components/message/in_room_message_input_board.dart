// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

// Package imports:

class ZegoInRoomMessageInputBoard extends ModalRoute<String> {
  ZegoInRoomMessageInputBoard({
    required this.translationText,
    required this.rootNavigator,
  }) : super();

  final ZegoTranslationText translationText;
  final bool rootNavigator;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => ZegoUIKitDefaultTheme.viewBarrierColor;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(
                context,
                rootNavigator: rootNavigator,
              ).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          ZegoInRoomMessageInput(
            placeHolder: translationText.messageEmptyToast,
            onSubmit: () {
              Navigator.of(
                context,
                rootNavigator: rootNavigator,
              ).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}
