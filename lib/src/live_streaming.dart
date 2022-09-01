// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'components/components.dart';
import 'internal/internal.dart';
import 'live_streaming_config.dart';

class ZegoUIKitPrebuiltLiveStreaming extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreaming({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveName,
    required this.config,
    this.tokenServerUrl = '',
  }) : super(key: key);

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appID you obtained from console.zegocloud.com
  final String appSign;

  /// tokenServerUrl is only for web.
  /// If you have to support Web and Android, iOS, then you can use it like this
  /// ```
  ///   ZegoUIKitPrebuiltLiveConfig(
  ///     appID: appID,
  ///     userID: userID,
  ///     userName: userName,
  ///     appSign: kIsWeb ? '' : appSign,
  ///     tokenServerUrl: kIsWeb ? tokenServerUrl：'',
  ///   );
  /// ```
  final String tokenServerUrl;

  /// local user info
  final String userID;
  final String userName;

  /// You can customize the liveName arbitrarily,
  /// just need to know: users who use the same liveName can talk with each other.
  final String liveName;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  @override
  State<ZegoUIKitPrebuiltLiveStreaming> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingState();
}

class _ZegoUIKitPrebuiltLiveStreamingState
    extends State<ZegoUIKitPrebuiltLiveStreaming>
    with SingleTickerProviderStateMixin {
  // var layoutModeNotifier =ValueNotifier<ZegoLayoutMode>(ZegoLayoutMode.pictureInPicture);

  StreamSubscription<dynamic>? roomEndStreamSubscription;

  @override
  void initState() {
    super.initState();

    correctConfigValue();

    ZegoUIKit().getZegoUIKitVersion().then((version) {
      log("ZegoUIKit version: $version");
    });

    initUIKIt();

    roomEndStreamSubscription =
        ZegoUIKit().getLeaveRoomRequiredStream().listen(onLeaveRoomRequired);
  }

  @override
  void dispose() async {
    super.dispose();

    roomEndStreamSubscription?.cancel();

    await ZegoUIKit().leaveRoom();
    // await ZegoUIKit().stopEffectsEnv();
    // await ZegoUIKit().uninit();
  }

  @override
  Widget build(BuildContext context) {
    widget.config.onEndOrLiveStreamingConfirming ??=
        onEndOrLiveStreamingConfirming;
    return ScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          body: WillPopScope(
            onWillPop: () async {
              return await widget
                  .config.onEndOrLiveStreamingConfirming!(context);
            },
            child: clickListener(
              child: Stack(
                children: [
                  audioVideoContainer(),
                  topBar(),
                  bottomBar(),
                  messageList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void initUIKIt() {
    ZegoUIKitPrebuiltLiveStreamingConfig config = widget.config;
    if (!kIsWeb) {
      assert(widget.appSign.isNotEmpty);
      ZegoUIKit().login(widget.userID, widget.userName).then((value) {
        ZegoUIKit()
            .init(appID: widget.appID, appSign: widget.appSign)
            .then((value) async {
          // await ZegoUIKit().startEffectsEnv();

          ZegoUIKit()
            ..updateVideoViewMode(config.useVideoViewAspectFill)
            ..turnCameraOn(config.turnOnCameraWhenJoining)
            ..turnMicrophoneOn(config.turnOnMicrophoneWhenJoining)
            // ..enableBeauty(true)
            ..joinRoom(widget.liveName);
        });
      });
    } else {
      assert(widget.tokenServerUrl.isNotEmpty);
      ZegoUIKit().login(widget.userID, widget.userName).then((value) {
        ZegoUIKit()
            .init(appID: widget.appID, tokenServerUrl: widget.tokenServerUrl)
            .then((value) async {
          // await ZegoUIKit().startEffectsEnv();

          ZegoUIKit()
            ..updateVideoViewMode(config.useVideoViewAspectFill)
            // ..enableBeauty(true)
            ..turnCameraOn(config.turnOnCameraWhenJoining)
            ..turnMicrophoneOn(config.turnOnMicrophoneWhenJoining)
            ..setAudioOutputToSpeaker(config.useSpeakerWhenJoining);

          getToken(widget.userID).then((token) {
            assert(token.isNotEmpty);
            ZegoUIKit().joinRoom(widget.liveName, token: token);
          });
        });
      });
    }
  }

  void correctConfigValue() {
    if (widget.config.menuBarButtonsMaxCount > 5) {
      widget.config.menuBarButtonsMaxCount = 5;
      debugPrint('menu bar buttons limited count\'s value  is exceeding the '
          'maximum limit');
    }
  }

  Widget clickListener({required Widget child}) {
    return GestureDetector(
      onTap: () {
        /// listen only click event in empty space
      },
      child: Listener(
        ///  listen for all click events in current view, include the click
        ///  receivers(such as button...), but only listen
        onPointerDown: (e) {},
        child: AbsorbPointer(
          absorbing: false,
          child: child,
        ),
      ),
    );
  }

  Widget audioVideoContainer() {
    return StreamBuilder<List<ZegoUIKitUser>>(
      stream: ZegoUIKit().getAudioVideoListStream(),
      builder: (context, snapshot) {
        List<ZegoUIKitUser> userList = snapshot.data ?? [];

        return ZegoAudioVideoView(
          user: userList.isEmpty ? ZegoUIKitUser.empty() : userList.first,
          backgroundBuilder: audioVideoViewBackground,
          foregroundBuilder: audioVideoViewForeground,
        );
      },
    );

    // return ValueListenableBuilder<ZegoLayoutMode>(
    //     valueListenable: layoutModeNotifier,
    //     builder: (context, zegoLayoutMode, _) {
    //       var layout = ZegoLayout.pictureInPicture(
    //         isSmallViewDraggable: false,
    //         showSelfViewWithVideoOnly: true,
    //         smallViewPosition: ZegoViewPosition.bottomRight,
    //         showSelfInLargeView: widget.config.turnOnCameraWhenJoining ||
    //             widget.config.turnOnMicrophoneWhenJoining, // host?
    //       );
    //
    //       return ZegoAudioVideoContainer(
    //         layout: layout,
    //         backgroundBuilder: audioVideoViewBackground,
    //         foregroundBuilder: audioVideoViewForeground,
    //       );
    //     });
  }

  /// Get your token from tokenServer
  Future<String> getToken(String userID) async {
    final response = await http
        .get(Uri.parse('${widget.tokenServerUrl}/access_token?uid=$userID'));
    if (response.statusCode == 200) {
      final jsonObj = json.decode(response.body);
      return jsonObj['token'];
    } else {
      return "";
    }
  }

  Future<bool> onEndOrLiveStreamingConfirming(BuildContext context) async {
    if (widget.config.confirmDialogInfo == null) {
      return true;
    }

    return await showAlertDialog(
      context,
      widget.config.confirmDialogInfo!.title,
      widget.config.confirmDialogInfo!.message,
      [
        ElevatedButton(
          child: Text(
            widget.config.confirmDialogInfo!.cancelButtonName,
            style: TextStyle(fontSize: 26.r, color: const Color(0xff0055FF)),
          ),
          onPressed: () {
            //  pop this dialog
            Navigator.of(context).pop(false);
          },
          // style: ElevatedButton.styleFrom(primary: Colors.white),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ),
        ElevatedButton(
          child: Text(
            widget.config.confirmDialogInfo!.confirmButtonName,
            style: TextStyle(fontSize: 26.r, color: Colors.white),
          ),
          onPressed: () {
            //  pop this dialog
            Navigator.of(context).pop(true);
          },
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(const Color(0xff0055FF)),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceEvenly,
    );
  }

  Widget audioVideoViewForeground(
      BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
    return Stack(
      children: [
        widget.config.foregroundBuilder?.call(context, size, user, extraInfo) ??
            Container(color: Colors.transparent),
      ],
    );
  }

  Widget audioVideoViewBackground(
      BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
    var screenSize = MediaQuery.of(context).size;
    var isSmallView = (screenSize.width - size.width).abs() > 1;
    return Stack(
      children: [
        Container(
            color: isSmallView
                ? const Color(0xff333437)
                : const Color(0xff4A4B4D)),
        widget.config.backgroundBuilder?.call(context, size, user, extraInfo) ??
            Container(color: Colors.transparent),
        ZegoAvatar(
          avatarSize: isSmallView ? Size(110.r, 110.r) : Size(258.r, 258.r),
          user: user,
          showAvatar: widget.config.showAvatarInAudioMode,
          showSoundLevel: widget.config.showSoundWavesInAudioMode,
          avatarBuilder: widget.config.avatarBuilder,
          soundLevelSize: size,
        ),
      ],
    );
  }

  Widget topBar() {
    return Positioned(
      left: 0,
      right: 0,
      top: 64.r,
      child: ZegoTopBar(config: widget.config),
    );
  }

  Widget bottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 32.r,
      child: ZegoBottomBar(
        buttonSize: zegoLiveButtonSize,
        config: widget.config,
      ),
    );
  }

  Widget messageList() {
    return Positioned(
      left: 32.r,
      bottom: 124.r,
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size(540.r, 400.r)),
        child: const ZegoInRoomMessageView(),
      ),
    );
  }

  void onLeaveRoomRequired(ZegoUIKitUser fromUser) {
    if (null != widget.config.onLiveStreamingBeEnd) {
      widget.config.onLiveStreamingBeEnd!.call();
    } else {
      showAlertDialog(
              context,
              "Attention",
              "The Live is over",
              [
                ElevatedButton(
                  child: Text(
                    "Close",
                    style: TextStyle(
                        fontSize: 26.r, color: const Color(0xff0055FF)),
                  ),
                  onPressed: () {
                    //  pop this dialog
                    Navigator.of(context).pop();
                  },
                  // style: ElevatedButton.styleFrom(primary: Colors.white),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ],
              actionsAlignment: MainAxisAlignment.spaceEvenly)
          .then((value) {
        //  to previous page
        Navigator.of(context).pop();
      });
    }
  }
}
