// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/permissions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimization/overlay_machine.dart';

/// @nodoc
class ZegoLiveStreamingConnectManager {
  ZegoLiveStreamingConnectManager({
    required this.liveID,
  });

  final String liveID;
  ZegoUIKitPrebuiltLiveStreamingConfig? config;
  ZegoUIKitPrebuiltLiveStreamingEvents? events;

  bool _initialized = false;

  /// internal variables

  /// audience: current audience connection state, audience or co-host
  final audienceLocalConnectStateNotifier =
      ValueNotifier<ZegoLiveStreamingAudienceConnectState>(
          ZegoLiveStreamingAudienceConnectState.idle);

  /// for host: current requesting co-host's users
  final requestCoHostUsersNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);

  /// When the UI is minimization, and the audience receives a co-hosting invitation.
  final dataOfInvitedToJoinCoHostInMinimizingNotifier =
      ValueNotifier<ZegoLiveStreamingCoHostAudienceEventRequestReceivedData?>(
          null);

  ///
  bool isInvitedToJoinCoHostDlgVisible = false;
  bool isEndCoHostDialogVisible = false;

  /// Completer used to serialize execution of updateAudienceConnectState
  /// When there are concurrent calls, subsequent calls will wait for the current call to complete
  Completer<void>? _currentUpdateStateCompleter;

  /// co-host total count
  final coHostCount = ValueNotifier<int>(0);

  ZegoUIKitPrebuiltLiveStreamingInnerText get innerText =>
      config?.innerText ?? ZegoUIKitPrebuiltLiveStreamingInnerText();

  int get maxCoHostCount => config?.coHost.maxCoHostCount ?? 12;

  bool get isMaxCoHostReached => coHostCount.value >= maxCoHostCount;

  bool get hostExist =>
      ZegoLiveStreamingPageLifeCycle()
          .manager(liveID)
          .hostManager
          .notifier
          .value
          ?.id
          .isNotEmpty ??
      false;

  bool get isLiving =>
      ZegoLiveStreamingPageLifeCycle()
          .manager(liveID)
          .liveStatusManager
          .notifier
          .value ==
      LiveStatus.living;

  List<String> audienceIDsOfInvitingConnect = [];
  List<StreamSubscription<dynamic>?> signalingSubscriptions = [];
  List<StreamSubscription<dynamic>?> rtcSubscriptions = [];

  ZegoLiveStreamingRole get localRole {
    var role = ZegoLiveStreamingRole.audience;
    if (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .hostManager
        .isLocalHost) {
      role = ZegoLiveStreamingRole.host;
    } else if (isLocalAudience) {
      role = ZegoLiveStreamingRole.audience;
    }

    return role;
  }

  bool get isLocalAudience =>
      !ZegoLiveStreamingPageLifeCycle()
          .manager(liveID)
          .hostManager
          .isLocalHost &&
      !isCoHost(ZegoUIKit().getLocalUser());

  bool isCoHost(ZegoUIKitUser user) {
    if (user.isEmpty()) {
      return false;
    }

    if (ZegoLiveStreamingPageLifeCycle()
            .manager(liveID)
            .hostManager
            .notifier
            .value
            ?.id ==
        user.id) {
      /// host also open camera/microphone
      return false;
    }

    /// if camera is in mute mode, same as open state
    final isCameraOpen = user.camera.value || user.cameraMuteMode.value;

    final useMuteMode =
        !(config?.coHost.stopCoHostingWhenMicCameraOff ?? false);
    final isMicrophoneOpen = useMuteMode
        ? (user.microphone.value ||

            /// if mic is in mute mode, same as open state
            user.microphoneMuteMode.value)
        : user.microphone.value;

    return isCameraOpen || isMicrophoneOpen;
  }

  bool get isLocalConnected =>
      audienceLocalConnectStateNotifier.value ==
      ZegoLiveStreamingAudienceConnectState.connected;

  void init({
    ZegoUIKitPrebuiltLiveStreamingConfig? config,
    ZegoUIKitPrebuiltLiveStreamingEvents? events,
  }) {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live.streaming.connect-mgr',
        subTag: 'init',
      );

      return;
    }

    _initialized = true;

    this.config = config;
    this.events = events;

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.connect-mgr',
      subTag: 'init',
    );

    listenSignalingEvents();

    registerRTCRoom(liveID);
  }

  void uninit() {
    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live.streaming.connect-mgr',
        subTag: 'uninit',
      );

      return;
    }

    _initialized = false;

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live.streaming.connect-mgr',
      subTag: 'uninit',
    );

    audienceLocalConnectStateNotifier.value =
        ZegoLiveStreamingAudienceConnectState.idle;

    requestCoHostUsersNotifier.value = [];
    dataOfInvitedToJoinCoHostInMinimizingNotifier.value = null;
    isInvitedToJoinCoHostDlgVisible = false;
    isEndCoHostDialogVisible = false;
    coHostCount.value = 0;

    audienceIDsOfInvitingConnect.clear();

    unregisterRTCRoom(liveID);

    for (final subscription in signalingSubscriptions) {
      subscription?.cancel();
    }

    // liveID = '';
  }

  void unregisterRTCRoom(String liveID) {
    removeRTCUsersDeviceListeners(
      ZegoUIKit().getRemoteUsers(targetRoomID: liveID),
    );

    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .removeListener(onRTCRoomStateUpdated);

    for (final subscription in rtcSubscriptions) {
      subscription?.cancel();
    }
  }

  void registerRTCRoom(String liveID) {
    listenRTCCoHostEvents();

    onUserListUpdated(ZegoUIKit().getAllUsers(targetRoomID: liveID));

    onRTCRoomStateUpdated();
    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .addListener(onRTCRoomStateUpdated);
  }

  void onRoomWillSwitch() {
    ZegoLoggerService.logInfo(
      'from $liveID to $liveID, ',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onRoomWillSwitch',
    );

    removeRTCUsersDeviceListeners(
      ZegoUIKit().getRemoteUsers(targetRoomID: liveID),
    );

    if (ZegoLiveStreamingAudienceConnectState.idle !=
        audienceLocalConnectStateNotifier.value) {
      events?.coHost.audience.onActionCancelRequest?.call();
      updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);
    }
  }

  void onRoomSwitched({
    ZegoUIKitPrebuiltLiveStreamingConfig? config,
    ZegoUIKitPrebuiltLiveStreamingEvents? events,
  }) {
    ZegoLoggerService.logInfo(
      'from $liveID to $liveID, ',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onRoomSwitched',
    );

    unregisterRTCRoom(liveID);

    audienceLocalConnectStateNotifier.value =
        ZegoLiveStreamingAudienceConnectState.idle;

    requestCoHostUsersNotifier.value = [];
    dataOfInvitedToJoinCoHostInMinimizingNotifier.value = null;
    isInvitedToJoinCoHostDlgVisible = false;
    isEndCoHostDialogVisible = false;
    coHostCount.value = 0;

    audienceIDsOfInvitingConnect.clear();

    this.config = config;
    this.events = events;

    registerRTCRoom(liveID);
  }

  void onRTCRoomStateUpdated() {
    if (ZegoLiveStreamingRole.host == config?.role &&
        ZegoLiveStreamingPageLifeCycle()
                .manager(liveID)
                .hostManager
                .notifier
                .value !=
            null &&
        ZegoLiveStreamingPageLifeCycle()
                .manager(liveID)
                .hostManager
                .notifier
                .value!
                .id !=
            ZegoUIKit().getLocalUser().id) {
      ZegoLoggerService.logInfo(
        'switch local to be co-host',
        tag: 'live.streaming.connect-mgr',
        subTag: 'onRoomStateUpdated',
      );

      updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);
    } else if (ZegoLiveStreamingRole.coHost == config?.role) {
      ZegoLoggerService.logInfo(
        "config's role is co-host, connect state default to be connected",
        tag: 'live.streaming.connect-mgr',
        subTag: 'onRoomStateUpdated',
      );

      final permissions = getCoHostPermissions();
      requestPermissions(
        context: ZegoLiveStreamingPageLifeCycle().contextQuery!(),
        isShowDialog: true,
        translationText: innerText,
        rootNavigator: config?.rootNavigator ?? false,
        permissions: permissions,
        popUpManager:
            ZegoLiveStreamingPageLifeCycle().contextData(liveID)?.popUpManager,
        kickOutNotifier:
            ZegoLiveStreamingPageLifeCycle().manager(liveID).kickOutNotifier,
      ).then((value) {
        ZegoUIKit().turnCameraOn(
          targetRoomID: liveID,
          config?.coHost.turnOnCameraWhenCohosted?.call() ?? true,
        );
        ZegoUIKit().turnMicrophoneOn(targetRoomID: liveID, true);

        updateAudienceConnectState(
          ZegoLiveStreamingAudienceConnectState.connected,
        );
      });
    }
  }

  Future<bool> audienceCancelCoHostIfRequesting() async {
    if (audienceLocalConnectStateNotifier.value ==
        ZegoLiveStreamingAudienceConnectState.connecting) {
      ZegoLoggerService.logInfo(
        'local user is still in requesting connect, cancel the request internally',
        tag: 'live.streaming.connect-mgr',
        subTag: 'audienceCancelCoHostIfRequesting',
      );

      return ZegoUIKitPrebuiltLiveStreamingController()
          .coHost
          .audienceCancelCoHostRequest();
    }

    return true;
  }

  void listenSignalingEvents() {
    if (config?.plugins.isNotEmpty ?? false) {
      signalingSubscriptions
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationReceivedStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationReceived))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationAcceptedStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationAccepted))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationCanceledStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationCanceled))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationRefusedStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationRefused))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationTimeoutStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationTimeout))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationResponseTimeoutStream()
            .where((param) => ZegoInvitationTypeExtension.isCoHostType(
                (param['type'] as int?) ?? -1))
            .listen(onInvitationResponseTimeout));
    }
  }

  Future<bool> kickCoHost(
    ZegoUIKitUser coHost, {
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'co-host: $coHost',
      tag: 'live.streaming.connect-mgr',
      subTag: 'kickCoHost',
    );

    return ZegoUIKit()
        .getSignalingPlugin()
        .sendInvitation(
          inviterID: ZegoUIKit().getLocalUser().id,
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: [coHost.id],
          timeout: 60,
          type: ZegoLiveStreamingInvitationType.removeFromCoHost.value,
          data: customData,
        )
        .then((result) {
      ZegoLiveStreamingReporter().report(
        event: ZegoLiveStreamingReporter.eventCoHostHostStop,
        params: {
          ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
          ZegoLiveStreamingReporter.eventKeyRoomID: liveID,
          ZegoLiveStreamingReporter.eventKeyCoHostID: coHost.id,
        },
      );

      ZegoLoggerService.logInfo(
        'result:$result',
        tag: 'live.streaming.connect-mgr',
        subTag: 'kickCoHost',
      );
      return result.error == null;
    });
  }

  Future<bool> inviteAudienceConnect(
    ZegoUIKitUser invitee, {
    int timeoutSecond = 60,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'inviter:${invitee.id} ${invitee.name}',
      tag: 'live.streaming.connect-mgr',
      subTag: 'inviteAudienceConnect',
    );

    if (audienceIDsOfInvitingConnect.contains(invitee.id)) {
      ZegoLoggerService.logInfo(
        'audience is int connect inviting',
        tag: 'live.streaming.connect-mgr',
        subTag: 'inviteAudienceConnect',
      );
      return true;
    }

    audienceIDsOfInvitingConnect.add(invitee.id);

    return ZegoUIKit()
        .getSignalingPlugin()
        .sendInvitation(
          inviterID: ZegoUIKit().getLocalUser().id,
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: [invitee.id],
          timeout: timeoutSecond,
          type: ZegoLiveStreamingInvitationType.inviteToJoinCoHost.value,
          data: customData,
        )
        .then((result) {
      if (result.error != null) {
        audienceIDsOfInvitingConnect.remove(invitee.id);

        showError(innerText.inviteCoHostFailedToast);
      } else {
        ZegoLiveStreamingReporter().report(
          event: ZegoLiveStreamingReporter.eventCoHostHostInvite,
          params: {
            ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
            ZegoLiveStreamingReporter.eventKeyAudienceID: invitee.id,
          },
        );

        events?.coHost.host.onInvitationSent
            ?.call(ZegoLiveStreamingCoHostHostEventInvitationSentData(
          audience: invitee,
        ));
      }

      return result.error != null;
    });
  }

  bool coHostEndConnect() {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.connect-mgr',
      subTag: 'coHostEndConnect',
    );

    ZegoLiveStreamingReporter().report(
      event: ZegoLiveStreamingReporter.eventCoHostAudienceStop,
    );
    updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);

    return true;
  }

  void onInvitationReceived(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final int type = params['type']!;

    /// call type
    final String customData = params['data']!;

    /// extended field

    final invitationID = params['invitation_id'] as String? ?? '';
    final invitationType = ZegoInvitationTypeExtension.mapValue[type]!;

    ZegoLoggerService.logInfo(
      'inviter:$inviter, '
      'type:$type($invitationType) ,'
      'data:$customData, ',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onInvitationReceived',
    );

    if (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .hostManager
        .isLocalHost) {
      if (ZegoLiveStreamingInvitationType.requestCoHost == invitationType) {
        ZegoLiveStreamingReporter().report(
          event: ZegoLiveStreamingReporter.eventCoHostHostReceived,
          params: {
            ZegoLiveStreamingReporter.eventKeyCallID: invitationID,
            ZegoLiveStreamingReporter.eventKeyAudienceID: inviter.id,
            ZegoLiveStreamingReporter.eventKeyExtendedData: customData,
          },
        );

        events?.coHost.host.onRequestReceived
            ?.call(ZegoLiveStreamingCoHostHostEventRequestReceivedData(
          audience: inviter,
          customData: customData,
        ));
        requestCoHostUsersNotifier.value =
            List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
              ..add(inviter);

        final translation = innerText.receivedCoHostRequestDialogInfo;
        showSuccess(
          translation.message.replaceFirst(
            ZegoUIKitPrebuiltLiveStreamingInnerText.param_1,
            inviter.name,
          ),
        );
      }
    } else {
      if (ZegoLiveStreamingInvitationType.inviteToJoinCoHost ==
          invitationType) {
        ZegoLiveStreamingReporter().report(
          event: ZegoLiveStreamingReporter.eventCoHostAudienceReceived,
          params: {
            ZegoLiveStreamingReporter.eventKeyCallID: invitationID,
            ZegoLiveStreamingReporter.eventKeyHostID: inviter.id,
            ZegoLiveStreamingReporter.eventKeyExtendedData: customData,
          },
        );

        onAudienceReceivedCoHostInvitation(inviter, customData);
      } else if (ZegoLiveStreamingInvitationType.removeFromCoHost ==
          invitationType) {
        ZegoLiveStreamingReporter().report(
          event: ZegoLiveStreamingReporter.eventCoHostCoHostReceived,
          params: {
            ZegoLiveStreamingReporter.eventKeyCallID: invitationID,
            ZegoLiveStreamingReporter.eventKeyHostID: inviter.id,
            ZegoLiveStreamingReporter.eventKeyExtendedData: customData,
          },
        );

        updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);
      }
    }
  }

  List<Permission> getCoHostPermissions() {
    final permissions = <Permission>[];
    if (config?.coHost.turnOnCameraWhenCohosted?.call() ?? true) {
      permissions.add(Permission.camera);
    }

    permissions.add(Permission.microphone);

    return permissions;
  }

  void onAudienceReceivedCoHostInvitation(
    ZegoUIKitUser host,
    String customData,
  ) {
    if (isCoHost(ZegoUIKit().getLocalUser())) {
      ZegoLoggerService.logInfo(
        'audience is co-host now',
        tag: 'live.streaming.connect-mgr',
        subTag: 'onAudienceReceivedCoHostInvitation',
      );
      return;
    }

    if (isMaxCoHostReached) {
      events?.coHost.onMaxCountReached?.call(maxCoHostCount);

      ZegoLoggerService.logInfo(
        'co-host max count had reached, ignore current co-host invitation',
        tag: 'live.streaming.connect-mgr',
        subTag: 'onAudienceReceivedCoHostInvitation',
      );

      return;
    }

    events?.coHost.audience.onInvitationReceived?.call(
      ZegoLiveStreamingCoHostAudienceEventRequestReceivedData(
        host: host,
        customData: customData,
      ),
    );

    dataOfInvitedToJoinCoHostInMinimizingNotifier.value = null;
    if (ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
      ZegoLoggerService.logInfo(
        'is minimizing now, cache the inviter:$host',
        tag: 'live.streaming.connect-mgr',
        subTag: 'onAudienceReceivedCoHostInvitation',
      );

      dataOfInvitedToJoinCoHostInMinimizingNotifier.value =
          ZegoLiveStreamingCoHostAudienceEventRequestReceivedData(
        host: host,
        customData: customData,
      );

      return;
    }

    if (config?.coHost.disableCoHostInvitationReceivedDialog ?? false) {
      ZegoLoggerService.logInfo(
        'config set not show co-host invitation dialog',
        tag: 'live.streaming.connect-mgr',
        subTag: 'onAudienceReceivedCoHostInvitation',
      );
      return;
    }

    if (isInvitedToJoinCoHostDlgVisible) {
      ZegoLoggerService.logInfo(
        'invite to join co-host dialog is visible',
        tag: 'live.streaming.connect-mgr',
        subTag: 'onAudienceReceivedCoHostInvitation',
      );
      return;
    }

    final translation = innerText.receivedCoHostInvitationDialogInfo;
    isInvitedToJoinCoHostDlgVisible = true;

    final key = DateTime.now().millisecondsSinceEpoch;
    ZegoLiveStreamingPageLifeCycle()
        .contextData(liveID)
        ?.popUpManager
        .addAPopUpSheet(key);

    /// not in minimizing
    showLiveDialog(
      context: ZegoLiveStreamingPageLifeCycle().contextQuery!(),
      title: translation.title,
      content: translation.message,
      leftButtonText: translation.cancelButtonName,
      rootNavigator: config?.rootNavigator ?? false,
      leftButtonCallback: () {
        hideInvitedJoinCoHostDialog();

        if (LiveStatus.living ==
            ZegoLiveStreamingPageLifeCycle()
                .manager(liveID)
                .liveStatusManager
                .notifier
                .value) {
          ZegoUIKit()
              .getSignalingPlugin()
              .refuseInvitation(inviterID: host.id, data: '')
              .then((result) {
            ZegoLiveStreamingReporter().report(
              event: ZegoLiveStreamingReporter.eventCoHostAudienceRespond,
              params: {
                ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
                ZegoLiveStreamingReporter.eventKeyAction:
                    ZegoLiveStreamingReporter.eventKeyActionRefuse,
              },
            );

            events?.coHost.audience.onActionRefuseInvitation?.call();

            ZegoLoggerService.logInfo(
              'refuse co-host invite, result:$result',
              tag: 'live.streaming.connect-mgr',
              subTag: 'onAudienceReceivedCoHostInvitation',
            );
          });
        } else {
          ZegoLoggerService.logInfo(
            'refuse co-host invite, not living now',
            tag: 'live.streaming.connect-mgr',
            subTag: 'onAudienceReceivedCoHostInvitation',
          );
        }
      },
      rightButtonText: translation.confirmButtonName,
      rightButtonCallback: () {
        hideInvitedJoinCoHostDialog();

        do {
          if (isMaxCoHostReached) {
            events?.coHost.onMaxCountReached?.call(maxCoHostCount);

            ZegoLoggerService.logInfo(
              'co-host max count had reached, ignore current accept co-host invite',
              tag: 'live.streaming.connect-mgr',
              subTag: 'onAudienceReceivedCoHostInvitation',
            );

            break;
          }

          ZegoLoggerService.logInfo(
            'accept co-host invite',
            tag: 'live.streaming.connect-mgr',
            subTag: 'onAudienceReceivedCoHostInvitation',
          );
          if (LiveStatus.living ==
              ZegoLiveStreamingPageLifeCycle()
                  .manager(liveID)
                  .liveStatusManager
                  .notifier
                  .value) {
            ZegoUIKit()
                .getSignalingPlugin()
                .acceptInvitation(inviterID: host.id, data: '')
                .then((result) {
              ZegoLoggerService.logInfo(
                'accept co-host invite, result:$result',
                tag: 'live.streaming.connect-mgr',
                subTag: 'onAudienceReceivedCoHostInvitation',
              );

              ZegoLiveStreamingReporter().report(
                event: ZegoLiveStreamingReporter.eventCoHostAudienceRespond,
                params: {
                  ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
                  ZegoLiveStreamingReporter.eventKeyAction:
                      ZegoLiveStreamingReporter.eventKeyActionAccept,
                },
              );

              if (result.error != null) {
                showError('${result.error}');
                return;
              }

              events?.coHost.audience.onActionAcceptInvitation?.call();

              final permissions = getCoHostPermissions();
              requestPermissions(
                context: ZegoLiveStreamingPageLifeCycle().contextQuery!(),
                isShowDialog: true,
                translationText: innerText,
                rootNavigator: config?.rootNavigator ?? false,
                permissions: permissions,
                popUpManager: ZegoLiveStreamingPageLifeCycle()
                    .contextData(liveID)
                    ?.popUpManager,
                kickOutNotifier: ZegoLiveStreamingPageLifeCycle()
                    .manager(liveID)
                    .kickOutNotifier,
              ).then((_) {
                updateAudienceConnectState(
                  ZegoLiveStreamingAudienceConnectState.connected,
                );
              });
            });
          } else {
            ZegoLoggerService.logInfo(
              'accept co-host invite, not living now',
              tag: 'live.streaming.connect-mgr',
              subTag: 'onAudienceReceivedCoHostInvitation',
            );
          }
        } while (false);
      },
    ).whenComplete(() {
      ZegoLiveStreamingPageLifeCycle()
          .contextData(liveID)
          ?.popUpManager
          .removeAPopUpSheet(key);
    });
  }

  void onInvitationAccepted(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String customData = params['data']!;

    /// extended field

    ZegoLoggerService.logInfo(
      'invitee:$invitee, '
      'customData:$customData, ',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onInvitationAccepted',
    );

    if (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .hostManager
        .isLocalHost) {
      events?.coHost.host.onInvitationAccepted?.call(
        ZegoLiveStreamingCoHostHostEventInvitationAcceptedData(
          audience: invitee,
          customData: customData,
        ),
      );

      audienceIDsOfInvitingConnect.remove(invitee.id);
    } else {
      events?.coHost.audience.onRequestAccepted?.call(
        ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData(
          customData: customData,
        ),
      );

      final permissions = getCoHostPermissions();
      requestPermissions(
        context: ZegoLiveStreamingPageLifeCycle().contextQuery!(),
        isShowDialog: true,
        translationText: innerText,
        rootNavigator: config?.rootNavigator ?? false,
        permissions: permissions,
        popUpManager:
            ZegoLiveStreamingPageLifeCycle().contextData(liveID)?.popUpManager,
        kickOutNotifier:
            ZegoLiveStreamingPageLifeCycle().manager(liveID).kickOutNotifier,
      ).then((value) {
        ZegoUIKit().turnCameraOn(
          targetRoomID: liveID,
          config?.coHost.turnOnCameraWhenCohosted?.call() ?? true,
        );
        ZegoUIKit().turnMicrophoneOn(targetRoomID: liveID, true);

        updateAudienceConnectState(
            ZegoLiveStreamingAudienceConnectState.connected);
      });
    }
  }

  void onInvitationCanceled(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String customData = params['data']!;

    /// extended field

    ZegoLoggerService.logInfo(
      'inviter:$inviter, '
      'customData:$customData, ',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onInvitationCanceled',
    );

    if (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .hostManager
        .isLocalHost) {
      events?.coHost.host.onRequestCanceled?.call(
        ZegoLiveStreamingCoHostHostEventRequestCanceledData(
          audience: inviter,
          customData: customData,
        ),
      );

      requestCoHostUsersNotifier.value =
          List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
            ..removeWhere((user) => user.id == inviter.id);
    }
  }

  void onInvitationRefused(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String customData = params['data']!;

    /// extended field

    ZegoLoggerService.logInfo(
      'invitee:$invitee, '
      'customData: $customData, ',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onInvitationRefused',
    );

    if (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .hostManager
        .isLocalHost) {
      events?.coHost.host.onInvitationRefused?.call(
        ZegoLiveStreamingCoHostHostEventInvitationRefusedData(
          audience: invitee,
          customData: customData,
        ),
      );

      audienceIDsOfInvitingConnect.remove(invitee.id);

      showError(innerText.audienceRejectInvitationToast.replaceFirst(
        ZegoUIKitPrebuiltLiveStreamingInnerText.param_1,
        ZegoUIKit().getUser(targetRoomID: liveID, invitee.id).name,
      ));
    } else {
      events?.coHost.audience.onRequestRefused?.call(
        ZegoLiveStreamingCoHostAudienceEventRequestRefusedData(
          customData: customData,
        ),
      );

      showError(innerText.hostRejectCoHostRequestToast);
      updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);
    }
  }

  void onInvitationTimeout(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!;

    /// extended field

    final invitationID = params['invitation_id'] as String? ?? '';
    final int type = params['type']!;

    /// call type
    final invitationType = ZegoInvitationTypeExtension.mapValue[type]!;

    ZegoLoggerService.logInfo(
      'inviter:$inviter, data:$data',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onInvitationTimeout',
    );

    if (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .hostManager
        .isLocalHost) {
      ZegoLiveStreamingReporter().report(
        event: ZegoLiveStreamingReporter.eventCoHostHostRespond,
        params: {
          ZegoLiveStreamingReporter.eventKeyCallID: invitationID,
          ZegoLiveStreamingReporter.eventKeyAction:
              ZegoLiveStreamingReporter.eventKeyActionTimeout,
        },
      );

      events?.coHost.host.onRequestTimeout?.call(
        ZegoLiveStreamingCoHostHostEventRequestTimeoutData(
          audience: inviter,
        ),
      );

      requestCoHostUsersNotifier.value =
          List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
            ..removeWhere((user) => user.id == inviter.id);
    } else {
      if (ZegoLiveStreamingInvitationType.inviteToJoinCoHost ==
          invitationType) {
        ZegoLiveStreamingReporter().report(
          event: ZegoLiveStreamingReporter.eventCoHostAudienceRespond,
          params: {
            ZegoLiveStreamingReporter.eventKeyCallID: invitationID,
            ZegoLiveStreamingReporter.eventKeyAction:
                ZegoLiveStreamingReporter.eventKeyActionTimeout,
          },
        );

        events?.coHost.audience.onInvitationTimeout?.call();
      }

      dataOfInvitedToJoinCoHostInMinimizingNotifier.value = null;

      hideInvitedJoinCoHostDialog();
    }
  }

  void onInvitationResponseTimeout(Map<String, dynamic> params) {
    final List<ZegoUIKitUser> invitees = params['invitees']!;
    final String data = params['data']!;

    /// extended field
    final int type = params['type']!;

    /// call type
    final invitationType = ZegoInvitationTypeExtension.mapValue[type]!;

    ZegoLoggerService.logInfo(
      'data: $data, '
      'invitees:${invitees.map((e) => e.toString())}',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onInvitationResponseTimeout',
    );

    if (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .hostManager
        .isLocalHost) {
      for (final invitee in invitees) {
        audienceIDsOfInvitingConnect.remove(invitee.id);

        if (ZegoLiveStreamingInvitationType.inviteToJoinCoHost ==
            invitationType) {
          events?.coHost.host.onInvitationTimeout?.call(
            ZegoLiveStreamingCoHostHostEventInvitationTimeoutData(
              audience: invitee,
            ),
          );
        }
      }
    } else {
      events?.coHost.audience.onRequestTimeout?.call();

      updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);
    }
  }

  void removeRequestCoHostUsers(ZegoUIKitUser targetUser) {
    requestCoHostUsersNotifier.value =
        List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
          ..removeWhere((user) => user.id == targetUser.id);
  }

  Future<bool> coHostRequestToEnd() async {
    if (isEndCoHostDialogVisible) {
      ZegoLoggerService.logInfo(
        'end host dialog is visible',
        tag: 'live.streaming.connect-mgr',
        subTag: 'coHostRequestToEnd',
      );
      return false;
    }

    final key = DateTime.now().millisecondsSinceEpoch;
    ZegoLiveStreamingPageLifeCycle()
        .contextData(liveID)
        ?.popUpManager
        .addAPopUpSheet(key);

    isEndCoHostDialogVisible = true;
    return showLiveDialog(
      context: ZegoLiveStreamingPageLifeCycle().contextQuery!(),
      rootNavigator: config?.rootNavigator ?? false,
      title: innerText.endConnectionDialogInfo.title,
      content: innerText.endConnectionDialogInfo.message,
      leftButtonText: innerText.endConnectionDialogInfo.cancelButtonName,
      leftButtonCallback: () {
        hideEndCoHostDialog();
      },
      rightButtonText: innerText.endConnectionDialogInfo.confirmButtonName,
      rightButtonCallback: () {
        hideEndCoHostDialog();

        coHostEndConnect();
      },
    ).whenComplete(() {
      ZegoLiveStreamingPageLifeCycle()
          .contextData(liveID)
          ?.popUpManager
          .removeAPopUpSheet(key);
    });
  }

  /// Update the audience connection state
  ///
  /// This function may be called asynchronously from multiple places.
  /// Uses a Completer queue mechanism to ensure serialized execution:
  /// - If there is a state update operation currently executing, new calls will wait for it to complete
  /// - This avoids race conditions and operation interleaving issues caused by concurrent calls
  Future<void> updateAudienceConnectState(
    ZegoLiveStreamingAudienceConnectState targetState,
  ) async {
    /// If there is a state update operation currently executing, wait for it to complete
    /// This ensures serialized execution of state updates and avoids concurrency issues
    if (_currentUpdateStateCompleter != null) {
      await _currentUpdateStateCompleter!.future;
    }

    /// Create a new Completer to mark that state update execution has started
    _currentUpdateStateCompleter = Completer<void>();

    try {
      /// After waiting, re-read the current state (may have been updated by a previous operation)
      final previousState = audienceLocalConnectStateNotifier.value;

      ZegoLoggerService.logInfo(
        'update audience connect state, '
        'previous:$previousState, '
        'target:$targetState, ',
        tag: 'live.streaming.connect-mgr',
        subTag: 'updateAudienceConnectState',
      );

      bool canChanged = true;
      switch (targetState) {
        case ZegoLiveStreamingAudienceConnectState.idle:
          hideInvitedJoinCoHostDialog();
          hideEndCoHostDialog();

          ZegoUIKit()
              .getLocalUser()
              .camera
              .removeListener(onLocalCameraStateChanged);
          ZegoUIKit()
              .getLocalUser()
              .microphone
              .removeListener(onLocalMicrophoneStateChanged);

          ZegoUIKit().resetSoundEffect();
          ZegoUIKit().resetBeautyEffect();

          ZegoUIKit().turnCameraOn(targetRoomID: liveID, false);
          ZegoUIKit().turnMicrophoneOn(targetRoomID: liveID, false);
          break;
        case ZegoLiveStreamingAudienceConnectState.connecting:
          break;
        case ZegoLiveStreamingAudienceConnectState.connected:
          if (hostExist && isLiving) {
            ZegoUIKit().turnCameraOn(
              targetRoomID: liveID,
              config?.coHost.turnOnCameraWhenCohosted?.call() ?? true,
            );
            ZegoUIKit().turnMicrophoneOn(targetRoomID: liveID, true);

            ZegoUIKit()
                .getLocalUser()
                .camera
                .addListener(onLocalCameraStateChanged);
            ZegoUIKit()
                .getLocalUser()
                .microphone
                .addListener(onLocalMicrophoneStateChanged);
          } else {
            canChanged = false;

            ZegoLoggerService.logInfo(
              'host no exist or is not living, '
              'hostExist:$hostExist, '
              'isLiving:$isLiving, ',
              tag: 'live.streaming.connect-mgr',
              subTag: 'updateAudienceConnectState',
            );
          }
          break;
      }

      if (canChanged) {
        if (previousState != targetState) {
          events?.coHost.coHost.onLocalConnectStateUpdated?.call(targetState);
        }

        final localRequestConnected =
            ZegoLiveStreamingAudienceConnectState.connecting == previousState &&
                ZegoLiveStreamingAudienceConnectState.connected == targetState;
        final hostInvitedConnected =
            ZegoLiveStreamingAudienceConnectState.idle == previousState &&
                ZegoLiveStreamingAudienceConnectState.connected == targetState;
        if (localRequestConnected || hostInvitedConnected) {
          /// idle|connecting -> connected
          events?.coHost.coHost.onLocalConnected?.call();
        } else if (ZegoLiveStreamingAudienceConnectState.connected ==
                previousState &&
            ZegoLiveStreamingAudienceConnectState.idle == targetState) {
          /// connected -> idle
          events?.coHost.coHost.onLocalDisconnected?.call();
        }

        audienceLocalConnectStateNotifier.value = targetState;
      } else {
        ZegoLoggerService.logInfo(
          'can not changed',
          tag: 'live.streaming.connect-mgr',
          subTag: 'updateAudienceConnectState',
        );
      }
    } finally {
      /// Complete the current Completer and clear the reference, regardless of success or failure
      /// This allows subsequent calls to proceed
      _currentUpdateStateCompleter?.complete();
      _currentUpdateStateCompleter = null;
    }
  }

  void onLocalCameraStateChanged() {
    final useMuteMode =
        !(config?.coHost.stopCoHostingWhenMicCameraOff ?? false);
    final isMicrophoneOpen = useMuteMode
        ? (ZegoUIKit().getLocalUser().microphone.value ||

            /// if mic is in mute mode, same as open state
            ZegoUIKit().getLocalUser().microphoneMuteMode.value)
        : ZegoUIKit().getLocalUser().microphone.value;

    if (!ZegoUIKit().getLocalUser().camera.value && !isMicrophoneOpen) {
      ZegoLoggerService.logInfo(
        "co-host's camera and microphone are closed, update connect state to idle, "
        'local user:${ZegoUIKit().getLocalUser()} ',
        tag: 'live.streaming.connect-mgr',
        subTag: 'onLocalCameraStateChanged',
      );

      updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);
    }
  }

  void onLocalMicrophoneStateChanged() {
    final useMuteMode =
        !(config?.coHost.stopCoHostingWhenMicCameraOff ?? false);
    final isMicrophoneOpen = useMuteMode
        ? (ZegoUIKit().getLocalUser().microphone.value ||

            /// if mic is in mute mode, same as open state
            ZegoUIKit().getLocalUser().microphoneMuteMode.value)
        : ZegoUIKit().getLocalUser().microphone.value;

    if (!ZegoUIKit().getLocalUser().camera.value && !isMicrophoneOpen) {
      ZegoLoggerService.logInfo(
        "co-host's camera and microphone are closed, update connect state to idle, "
        'local user:${ZegoUIKit().getLocalUser()} ',
        tag: 'live.streaming.connect-mgr',
        subTag: 'onLocalMicrophoneStateChanged',
      );

      updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);
    }
  }

  void removeRTCUsersDeviceListeners(List<ZegoUIKitUser> users) {
    for (final user in users) {
      user.camera.removeListener(onUserCameraStateChanged);
      user.microphone.removeListener(onUserMicrophoneStateChanged);
    }
  }
}

extension ZegoLiveConnectManagerCoHostCount on ZegoLiveStreamingConnectManager {
  void listenRTCCoHostEvents() {
    rtcSubscriptions
      ..add(ZegoUIKit()
          .getUserListStream(targetRoomID: liveID)
          .listen(onUserListUpdated))
      ..add(ZegoUIKit()
          .getUserJoinStream(targetRoomID: liveID)
          .listen(onUserJoinUpdated))
      ..add(ZegoUIKit()
          .getUserLeaveStream(targetRoomID: liveID)
          .listen(onUserLeaveUpdated))
      ..add(ZegoUIKit()
          .getAudioVideoListStream(targetRoomID: liveID)
          .listen(onAudioVideoListUpdated));
  }

  void onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    final coHosts = users.where((user) => isCoHost(user)).toList();
    coHostCount.value = coHosts.length;

    events?.coHost.onUpdated?.call(coHosts);

    ZegoLoggerService.logInfo(
      'audio video list changed, co-host count changed to ${coHostCount.value}',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onAudioVideoListUpdated',
    );

    if (isMaxCoHostReached &&
        ZegoLiveStreamingPageLifeCycle()
            .manager(liveID)
            .hostManager
            .isLocalHost) {
      final coHosts = List<ZegoUIKitUser>.from(users)
        ..removeWhere((user) =>
            ZegoLiveStreamingPageLifeCycle()
                .manager(liveID)
                .hostManager
                .notifier
                .value
                ?.id ==
            user.id)
        ..sort((left, right) {
          return left.streamTimestamp.compareTo(right.streamTimestamp);
        });

      final kickCount = coHosts.length - maxCoHostCount;
      final kickUsers = coHosts.sublist(0, kickCount);
      ZegoLoggerService.logInfo(
        'audio video list changed, max co-host count reach, '
        'will kick $kickCount user in ${coHosts.length} by sort:$kickUsers',
        tag: 'live.streaming.connect-mgr',
        subTag: 'onAudioVideoListUpdated',
      );

      kickUsers.forEach(kickCoHost);
    }
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    syncCoHostCount(users);

    ZegoLoggerService.logInfo(
      'user list changed, co-host count changed to ${coHostCount.value}',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onUserListUpdated',
    );
  }

  void onUserJoinUpdated(List<ZegoUIKitUser> users) {
    removeRTCUsersDeviceListeners(users);

    for (final user in users) {
      user.camera.addListener(onUserCameraStateChanged);
      user.microphone.addListener(onUserMicrophoneStateChanged);
    }
  }

  void onUserLeaveUpdated(List<ZegoUIKitUser> users) {
    removeRTCUsersDeviceListeners(users);

    for (var requestCoHostUser in requestCoHostUsersNotifier.value) {
      events?.coHost.host.onRequestCanceled?.call(
        ZegoLiveStreamingCoHostHostEventRequestCanceledData(
          audience: requestCoHostUser,
          customData: '', //todo what data?
        ),
      );
    }

    final userIDs = users.map((e) => e.id).toList();
    requestCoHostUsersNotifier.value =
        List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
          ..removeWhere(
            (user) => userIDs.contains(user.id),
          );
  }

  void onUserCameraStateChanged() {
    if (!_initialized) {
      return;
    }

    syncCoHostCount(ZegoUIKit().getAllUsers(targetRoomID: liveID));

    ZegoLoggerService.logInfo(
      'user camera state changed, co-host count changed to ${coHostCount.value}',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onUserCameraStateChanged',
    );
  }

  void onUserMicrophoneStateChanged() {
    if (!_initialized) {
      return;
    }

    syncCoHostCount(ZegoUIKit().getAllUsers(targetRoomID: liveID));

    ZegoLoggerService.logInfo(
      'user microphone state changed, co-host count changed to ${coHostCount.value}',
      tag: 'live.streaming.connect-mgr',
      subTag: 'onUserMicrophoneStateChanged',
    );
  }

  void hideInvitedJoinCoHostDialog() {
    /// hide invite join co-host dialog
    if (isInvitedToJoinCoHostDlgVisible) {
      isInvitedToJoinCoHostDlgVisible = false;
      Navigator.of(
        ZegoLiveStreamingPageLifeCycle().contextQuery!(),
        rootNavigator: config?.rootNavigator ?? false,
      ).pop();
    }
  }

  void hideEndCoHostDialog() {
    /// hide co-host end request dialog
    if (isEndCoHostDialogVisible) {
      isEndCoHostDialogVisible = false;
      Navigator.of(
        ZegoLiveStreamingPageLifeCycle().contextQuery!(),
        rootNavigator: config?.rootNavigator ?? false,
      ).pop();
    }
  }

  void syncCoHostCount(List<ZegoUIKitUser> users) {
    coHostCount.value = users.where((user) => isCoHost(user)).length;

    ZegoLoggerService.logInfo(
      'co-host count changed to ${coHostCount.value}',
      tag: 'live.streaming.connect-mgr',
      subTag: 'syncCoHostCount',
    );
  }
}
