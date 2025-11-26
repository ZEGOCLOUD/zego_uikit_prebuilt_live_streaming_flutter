// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming.dart';
import 'controller.dart';
import 'defines.dart';
import 'foreground/foreground.dart';

/// live hall
class ZegoUIKitLiveStreamingHallList extends StatefulWidget {
  const ZegoUIKitLiveStreamingHallList({
    super.key,
    required this.appID,
    required this.userID,
    required this.userName,
    required this.configsQuery,
    this.appSign = '',
    this.token = '',
    this.eventsQuery,
    this.hallController,
    this.hallModel,
    this.hallModelDelegate,
    ZegoLiveStreamingHallListStyle? hallStyle,
    ZegoLiveStreamingHallListConfig? hallConfig,
  })  : hallStyle = hallStyle ?? const ZegoLiveStreamingHallListStyle(),
        hallConfig = hallConfig ?? const ZegoLiveStreamingHallListConfig();

  /// You can create a project and obtain an appID from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final int appID;

  /// log in by using [appID] + [appSign].
  ///
  /// You can create a project and obtain an appSign from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  ///
  /// Of course, you can also log in by using [appID] + [token]. For details, see [token].
  final String appSign;

  /// log in by using [appID] + [token].
  ///
  /// The token issued by the developer's business server is used to ensure security.
  /// Please note that if you want to use [appID] + [token] login, do not assign a value to [appSign]
  ///
  /// For the generation rules, please refer to [Using Token Authentication] (https://doc-zh.zego.im/article/10360), the default is an empty string, that is, no authentication.
  ///
  /// if appSign is not passed in or if appSign is empty, this parameter must be set for authentication when logging in to a room.
  final String token;

  /// The ID of the currently logged-in user.
  /// It can be any valid string.
  /// Typically, you would use the ID from your own user system, such as Firebase.
  final String userID;

  /// The name of the currently logged-in user.
  /// It can be any valid string.
  /// Typically, you would use the name from your own user system, such as Firebase.
  final String userName;

  /// Initialize the configuration for the live-streaming.
  final ZegoUIKitPrebuiltLiveStreamingConfig Function(String liveID)
      configsQuery;

  /// You can listen to events that you are interested in here.
  final ZegoUIKitPrebuiltLiveStreamingEvents? Function(String liveID)?
      eventsQuery;

  ///  hallStyle
  final ZegoLiveStreamingHallListStyle hallStyle;

  /// hallConfig
  final ZegoLiveStreamingHallListConfig hallConfig;

  /// hall Controller
  final ZegoLiveStreamingHallListController? hallController;

  /// hallModel
  /// list of [host id && live id]
  /// When swiping up or down, the corresponding LIVE information will be returned via this [hallModel]
  final ZegoLiveStreamingHallListModel? hallModel;

  /// If you want to manage data yourself, please refer to [ZegoUIKitHallRoomListModel],
  /// then cancel the setting of [hallModel], and then set [hallModelDelegate]
  final ZegoLiveStreamingHallListModelDelegate? hallModelDelegate;

  @override
  State<ZegoUIKitLiveStreamingHallList> createState() =>
      _ZegoUIKitLiveStreamingHallListState();
}

class _ZegoUIKitLiveStreamingHallListState
    extends State<ZegoUIKitLiveStreamingHallList> {
  final roomLogoutNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();

    ZegoUIKitPrebuiltLiveStreamingController()
        .hall
        .private
        .initByPrebuilt(hallController: widget.hallController);

    if (null != widget.hallConfig.audioVideoResourceMode) {
      ZegoUIKit().setPlayerResourceMode(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController()
            .hall
            .private
            .controller
            .roomID,
        widget.hallConfig.audioVideoResourceMode!,
      );
    }

    roomLogoutNotifier.value = ZegoUIKitRoomStateChangedReason.Logout ==
        ZegoUIKit()
            .getRoomStateStream(
                targetRoomID: ZegoUIKitPrebuiltLiveStreamingController()
                    .hall
                    .private
                    .controller
                    .roomID)
            .value
            .reason;
    if (!roomLogoutNotifier.value) {
      ZegoUIKit()
          .getRoomStateStream(
              targetRoomID: ZegoUIKitPrebuiltLiveStreamingController()
                  .hall
                  .private
                  .controller
                  .roomID)
          .addListener(onRoomStateUpdated);
    }
  }

  @override
  dispose() {
    super.dispose();

    ZegoUIKitPrebuiltLiveStreamingController().hall.private.uninitByPrebuilt();

    ZegoUIKit()
        .getRoomStateStream(
            targetRoomID: ZegoUIKitPrebuiltLiveStreamingController()
                .hall
                .private
                .controller
                .roomID)
        .removeListener(onRoomStateUpdated);

    if (null != widget.hallConfig.audioVideoResourceMode) {
      ZegoUIKit().setPlayerResourceMode(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController()
            .hall
            .private
            .controller
            .roomID,
        ZegoUIKitStreamResourceMode.Default,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: roomLogoutNotifier,
      builder: (context, isRoomLogout, _) {
        if (!isRoomLogout) {
          /// wait previous room logout
          return widget.hallStyle.loadingBuilder?.call(context) ??
              const CircularProgressIndicator();
        }

        return ZegoUIKitHallRoomList(
          appID: widget.appID,
          controller: ZegoUIKitPrebuiltLiveStreamingController()
              .hall
              .private
              .controller
              .private,
          appSign: widget.appSign,
          token: widget.token,
          scenario: ZegoUIKitScenario.Broadcast,
          style: ZegoLiveStreamingHallListStyle(
            loadingBuilder: widget.hallStyle.loadingBuilder,
            item: ZegoLiveStreamingHallListItemStyle(
              backgroundBuilder: widget.hallStyle.item.backgroundBuilder,
              foregroundBuilder: widget.hallStyle.item.foregroundBuilder ??
                  defaultItemForeground,
              loadingBuilder:
                  widget.hallStyle.item.loadingBuilder ?? defaultLoadingBuilder,
              avatar: widget.hallStyle.item.avatar,
            ),
          ),
          config: widget.hallConfig,
          model: widget.hallModel,
          modelDelegate: widget.hallModelDelegate,
        );
      },
    );
  }

  Widget defaultLoadingBuilder(
    BuildContext context,
    ZegoUIKitUser? user,
    String roomID,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getCameraStateNotifier(
        targetRoomID: roomID,
        user?.id ?? '',
      ),
      builder: (context, isCameraOpen, _) {
        return isCameraOpen
            ? Container()
            : Stack(
                children: [
                  CircleAvatar(
                    child: ZegoAvatar(
                      roomID: roomID,
                      avatarSize: Size(30.zR, 30.zR),
                    ),
                  ),
                  const CircularProgressIndicator()
                ],
              );
      },
    );
  }

  Widget defaultItemForeground(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    String roomID,
  ) {
    final roomConfigs = widget.configsQuery.call(roomID);
    return ZegoLiveStreamingHallForeground(
      user: user,
      liveID: roomID,
      innerText: roomConfigs.innerText,
      onEnterLivePressed: (String liveID) {
        final configs = widget.configsQuery.call(liveID);
        configs.hall = ZegoLiveStreamingHallConfig(
          fromHall: true,
        );

        /// swiping config
        configs.swiping = ZegoLiveStreamingSwipingConfig(
          model: widget.hallModel,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SafeArea(
              child: ZegoUIKitPrebuiltLiveStreaming(
                appID: widget.appID,
                appSign: widget.appSign,
                userID: widget.userID,
                userName: widget.userName,
                liveID: liveID,
                config: configs,
                events: widget.eventsQuery?.call(liveID),
              ),
            ),
          ),
        );
      },
    );
  }

  void onRoomStateUpdated() {
    final roomState = ZegoUIKit()
        .getRoomStateStream(
            targetRoomID: ZegoUIKitPrebuiltLiveStreamingController()
                .hall
                .private
                .controller
                .roomID)
        .value;
    roomLogoutNotifier.value =
        ZegoUIKitRoomStateChangedReason.Logout == roomState.reason;

    if (roomLogoutNotifier.value) {
      ZegoUIKit()
          .getRoomStateStream(
              targetRoomID: ZegoUIKitPrebuiltLiveStreamingController()
                  .hall
                  .private
                  .controller
                  .roomID)
          .removeListener(onRoomStateUpdated);
    }
  }
}
