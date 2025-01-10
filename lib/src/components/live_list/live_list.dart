// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_list/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_list/defines.dart';

/// live list widget, you can preview the host live list outside of [ZegoUIKitPrebuiltLiveStreaming]
///
/// Notice:
/// you need assign the controller of [ZegoLiveStreamingOutsideLiveList] to
/// controller of [ZegoLiveStreamingOutsideLiveConfig], which is
/// [config.outsideLive.controller] in [ZegoUIKitPrebuiltLiveStreaming]
///
/// Example:
/// ```dart
/// class HomePage extends StatefulWidget {
///   const HomePage({
///     Key? key,
///   }) : super(key: key);
///
///   @override
///   State<HomePage> createState() => _HomePageState();
/// }
///
/// class _HomePageState extends State<HomePage> {
///   ///   1/3 steps
///   final outsideLiveListController = ZegoLiveStreamingOutsideLiveListController();
///
///   @override
///   void initState() {
///     super.initState();
///
///     outsideLiveListController.updateHosts([
///       ZegoLiveStreamingOutsideLiveListHost(
///         roomID: live_id,
///         user: ZegoUIKitUser(id: user_id, name: user_name),
///       ),
///     ]);
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: [
///         Align(
///           alignment: Alignment.bottomCenter,
///           child: ElevatedButton(
///             child: const Text('Start a live'),
///             onPressed: () {
///               Navigator.push(
///                 context,
///                 MaterialPageRoute(
///                   builder: (context) => ZegoUIKitPrebuiltLiveStreaming(
///                     appID: /*input your AppID*/,
///                     appSign: /*input your AppSign*/,
///                     userID: 'userID',
///                     userName: 'userName',
///                     liveID: 'liveID',
///                     config: ZegoUIKitPrebuiltLiveStreamingConfig(
///                       ///   2/3 steps
///                       /// Notice this !!
///                       outsideLive: ZegoLiveStreamingOutsideLiveConfig(
///                         controller: outsideLiveListController,
///                       ),
///                     ),
///                   ),
///                 ),
///               );
///             },
///           ),
///         ),
///         Positioned(
///           top: 100,
///           left: 10,
///           right: 10,
///           child: SizedBox(
///             /// you need set a height to parent widget
///             height: 200,
///             ///   3/3 steps
///             child: ZegoLiveStreamingOutsideLiveList(
///               appID: /*input your AppID*/,
///               appSign: /*input your AppSign*/,
///               controller: outsideLiveListController,
///             ),
///           ),
///         ),
///       ],
///     );
///   }
/// }
/// ```
///
class ZegoLiveStreamingOutsideLiveList extends StatefulWidget {
  const ZegoLiveStreamingOutsideLiveList({
    Key? key,
    required this.appID,
    required this.controller,
    this.appSign = '',
    this.token = '',
    ZegoLiveStreamingOutsideLiveListStyle? style,
    ZegoLiveStreamingOutsideLiveListConfig? config,
  })  : style = style ?? const ZegoLiveStreamingOutsideLiveListStyle(),
        config = config ?? const ZegoLiveStreamingOutsideLiveListConfig(),
        super(key: key);

  /// same as [ZegoUIKitPrebuiltLiveStreaming.appID]
  final int appID;

  /// same as [ZegoUIKitPrebuiltLiveStreaming.appSign]
  final String appSign;

  /// same as [ZegoUIKitPrebuiltLiveStreaming.token]
  final String token;

  ///  style
  final ZegoLiveStreamingOutsideLiveListStyle style;

  /// config
  final ZegoLiveStreamingOutsideLiveListConfig config;

  /// controller
  final ZegoLiveStreamingOutsideLiveListController controller;

  @override
  State<ZegoLiveStreamingOutsideLiveList> createState() =>
      _ZegoLiveStreamingOutsideLiveListState();
}

class _ZegoLiveStreamingOutsideLiveListState
    extends State<ZegoLiveStreamingOutsideLiveList> {
  final roomLogoutNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();

    if (null != widget.config.audioVideoResourceMode) {
      ZegoUIKit().setAudioVideoResourceMode(
        widget.config.audioVideoResourceMode!,
      );
    }

    roomLogoutNotifier.value = ZegoRoomStateChangedReason.Logout ==
        ZegoUIKit().getRoomStateStream().value.reason;
    if (!roomLogoutNotifier.value) {
      ZegoUIKit().getRoomStateStream().addListener(onRoomStateUpdated);
    }
  }

  @override
  dispose() {
    super.dispose();

    ZegoUIKit().getRoomStateStream().removeListener(onRoomStateUpdated);

    if (null != widget.config.audioVideoResourceMode) {
      ZegoUIKit().setAudioVideoResourceMode(
        ZegoAudioVideoResourceMode.defaultMode,
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
          return widget.style.loadingBuilder?.call(context) ??
              const CircularProgressIndicator();
        }

        return ZegoOutsideRoomAudioVideoViewList(
          appID: widget.appID,
          controller: widget.controller.private,
          appSign: widget.appSign,
          token: widget.token,
          scenario: ZegoScenario.Broadcast,
          style: widget.style,
          config: widget.config,
        );
      },
    );
  }

  void onRoomStateUpdated() {
    final roomState = ZegoUIKit().getRoomStateStream().value;
    roomLogoutNotifier.value =
        ZegoRoomStateChangedReason.Logout == roomState.reason;

    if (roomLogoutNotifier.value) {
      ZegoUIKit().getRoomStateStream().removeListener(onRoomStateUpdated);
    }
  }
}
