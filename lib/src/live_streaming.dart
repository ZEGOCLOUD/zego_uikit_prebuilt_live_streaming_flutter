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
import 'internal/icon_defines.dart';
import 'live_streaming_config.dart';

class ZegoUIKitPrebuiltLiveStreaming extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreaming({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
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
  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  @override
  State<ZegoUIKitPrebuiltLiveStreaming> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingState();
}

class _ZegoUIKitPrebuiltLiveStreamingState
    extends State<ZegoUIKitPrebuiltLiveStreaming>
    with SingleTickerProviderStateMixin {
  StreamSubscription<dynamic>? userListSubscription;
  var hostNotifier = ValueNotifier<ZegoUIKitUser?>(null);

  @override
  void initState() {
    super.initState();

    correctConfigValue();

    ZegoUIKit().getZegoUIKitVersion().then((version) {
      log("ZegoUIKit version: $version");
    });

    userListSubscription =
        ZegoUIKit().getUserListStream().listen(onUserListUpdated);

    initUIKIt();
  }

  @override
  void dispose() async {
    super.dispose();

    userListSubscription?.cancel();

    await ZegoUIKit().leaveRoom();
    // await ZegoUIKit().stopEffectsEnv();
    // await ZegoUIKit().uninit();
  }

  @override
  Widget build(BuildContext context) {
    widget.config.onLeaveLiveStreamingConfirmation ??=
        onEndOrLiveStreamingConfirming;

    return ScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        var page = clickListener(
          child: Stack(
            children: [
              background(),
              backgroundTips(),
              audioVideoContainer(),
              topBar(),
              bottomBar(),
              messageList(),
            ],
          ),
        );
        return Scaffold(
          body: WillPopScope(
            onWillPop: () async {
              return await widget
                  .config.onLeaveLiveStreamingConfirmation!(context);
            },
            child: page,
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
            ..updateVideoViewMode(
                config.audioVideoViewConfig.useVideoViewAspectFill)
            ..turnCameraOn(config.turnOnCameraWhenJoining)
            ..turnMicrophoneOn(config.turnOnMicrophoneWhenJoining)
            // ..enableBeauty(true)
            ..joinRoom(widget.liveID);
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
            ..updateVideoViewMode(
                config.audioVideoViewConfig.useVideoViewAspectFill)
            // ..enableBeauty(true)
            ..turnCameraOn(config.turnOnCameraWhenJoining)
            ..turnMicrophoneOn(config.turnOnMicrophoneWhenJoining)
            ..setAudioOutputToSpeaker(config.useSpeakerWhenJoining);

          getToken(widget.userID).then((token) {
            assert(token.isNotEmpty);
            ZegoUIKit().joinRoom(widget.liveID, token: token);
          });
        });
      });
    }
  }

  void correctConfigValue() {
    if (widget.config.bottomMenuBarConfig.maxCount > 5) {
      widget.config.bottomMenuBarConfig.maxCount = 5;
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

  Widget backgroundTips() {
    return Center(
      child: Text(
        "No host is currently online",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32.r,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget background() {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        width: 750.w,
        height: 1334.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: PrebuiltLiveStreamingImage.assetImage(
                PrebuiltLiveStreamingIconUrls.background),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget audioVideoContainer() {
    return Positioned(
      top: 0,
      left: 0,
      child: SizedBox(
        width: 750.w,
        height: 1334.h,
        child: StreamBuilder<List<ZegoUIKitUser>>(
          stream: ZegoUIKit().getAudioVideoListStream(),
          builder: (context, snapshot) {
            List<ZegoUIKitUser> userList = snapshot.data ?? [];
            if (userList.isNotEmpty) {
              hostNotifier.value = userList.first;
            }

            return ValueListenableBuilder<ZegoUIKitUser?>(
                valueListenable: hostNotifier,
                builder: (context, host, _) {
                  if (host == null) {
                    return Container();
                  }

                  return ZegoAudioVideoView(
                    user: host,
                    backgroundBuilder: audioVideoViewBackground,
                    foregroundBuilder: audioVideoViewForeground,
                  );
                });
          },
        ),
      ),
    );
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
        widget.config.audioVideoViewConfig.foregroundBuilder
                ?.call(context, size, user, extraInfo) ??
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
        widget.config.audioVideoViewConfig.backgroundBuilder
                ?.call(context, size, user, extraInfo) ??
            Container(color: Colors.transparent),
        ZegoAvatar(
          avatarSize: isSmallView ? Size(110.r, 110.r) : Size(258.r, 258.r),
          user: user,
          showAvatar: widget.config.audioVideoViewConfig.showAvatarInAudioMode,
          showSoundLevel:
              widget.config.audioVideoViewConfig.showSoundWavesInAudioMode,
          avatarBuilder: widget.config.audioVideoViewConfig.avatarBuilder,
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
    return Align(
      alignment: Alignment.bottomCenter,
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

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    if (hostNotifier.value == null) {
      return;
    }

    if (users
        .where((user) => user.id == hostNotifier.value!.id)
        .toList()
        .isEmpty) {
      hostNotifier.value = null;
    }
  }
}
