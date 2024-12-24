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
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/overlay_machine.dart';

/// @nodoc
class ZegoLiveStreamingConnectManager {
  ZegoLiveStreamingConnectManager({
    required this.hostManager,
    required this.popUpManager,
    required this.liveStatusNotifier,
    required this.config,
    required this.events,
    required this.kickOutNotifier,
    this.contextQuery,
  }) {
    listenStream();
  }

  BuildContext Function()? contextQuery;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoUIKitPrebuiltLiveStreamingEvents events;

  final ZegoLiveStreamingHostManager hostManager;
  final ZegoLiveStreamingPopUpManager popUpManager;
  final ValueNotifier<LiveStatus> liveStatusNotifier;
  final ValueNotifier<bool> kickOutNotifier;

  bool _initialized = false;

  /// internal variables

  /// audience: current audience connection state, audience or co-host
  final audienceLocalConnectStateNotifier =
      ValueNotifier<ZegoLiveStreamingAudienceConnectState>(
          ZegoLiveStreamingAudienceConnectState.idle);

  /// for host: current requesting co-host's users
  final requestCoHostUsersNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);

  /// When the UI is minimized, and the audience receives a co-hosting invitation.
  final dataOfInvitedToJoinCoHostInMinimizingNotifier =
      ValueNotifier<ZegoLiveStreamingCoHostAudienceEventRequestReceivedData?>(
          null);

  ///
  bool isInvitedToJoinCoHostDlgVisible = false;
  bool isEndCoHostDialogVisible = false;

  /// co-host total count
  final coHostCount = ValueNotifier<int>(0);

  ZegoUIKitPrebuiltLiveStreamingInnerText get innerText => config.innerText;

  int get maxCoHostCount => config.coHost.maxCoHostCount;

  bool get isMaxCoHostReached =>
      coHostCount.value >= config.coHost.maxCoHostCount;

  List<String> audienceIDsOfInvitingConnect = [];
  List<StreamSubscription<dynamic>?> subscriptions = [];

  ZegoLiveStreamingRole get localRole {
    var role = ZegoLiveStreamingRole.audience;
    if (hostManager.isLocalHost) {
      role = ZegoLiveStreamingRole.host;
    } else if (isLocalAudience) {
      role = ZegoLiveStreamingRole.audience;
    }

    return role;
  }

  bool get isLocalAudience =>
      !hostManager.isLocalHost && !isCoHost(ZegoUIKit().getLocalUser());

  bool isCoHost(ZegoUIKitUser user) {
    if (hostManager.notifier.value?.id == user.id) {
      /// host also open camera/microphone
      return false;
    }

    /// if camera is in mute mode, same as open state
    final isCameraOpen = user.camera.value || user.cameraMuteMode.value;

    /// if microphone is in mute mode, same as open state
    final isMicrophoneOpen =
        user.microphone.value || user.microphoneMuteMode.value;

    return isCameraOpen || isMicrophoneOpen;
  }

  bool get isLocalConnected =>
      audienceLocalConnectStateNotifier.value ==
      ZegoLiveStreamingAudienceConnectState.connected;

  void init() {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live-streaming-coHost',
        subTag: 'seat manager',
      );

      return;
    }

    _initialized = true;

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live-streaming-coHost',
      subTag: 'connect manager',
    );

    if (ZegoLiveStreamingRole.host == config.role &&
        hostManager.notifier.value != null &&
        hostManager.notifier.value!.id != ZegoUIKit().getLocalUser().id) {
      ZegoLoggerService.logInfo(
        'switch local to be co-host',
        tag: 'live-streaming-coHost',
        subTag: 'connect manager',
      );

      updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);
    } else if (ZegoLiveStreamingRole.coHost == config.role) {
      ZegoLoggerService.logInfo(
        "config's role is co-host, connect state default to be connected",
        tag: 'live-streaming-coHost',
        subTag: 'connect manager',
      );

      final permissions = getCoHostPermissions();
      requestPermissions(
        context: contextQuery!(),
        isShowDialog: true,
        translationText: innerText,
        rootNavigator: config.rootNavigator,
        permissions: permissions,
        popUpManager: popUpManager,
        kickOutNotifier: kickOutNotifier,
      ).then((value) {
        ZegoUIKit().turnCameraOn(
          config.coHost.turnOnCameraWhenCohosted?.call() ?? true,
        );
        ZegoUIKit().turnMicrophoneOn(true);

        updateAudienceConnectState(
            ZegoLiveStreamingAudienceConnectState.connected);
      });
    }

    initCoHostMixin();
  }

  Future<bool> audienceCancelCoHostIfRequesting() async {
    if (audienceLocalConnectStateNotifier.value ==
        ZegoLiveStreamingAudienceConnectState.connecting) {
      ZegoLoggerService.logInfo(
        'local user is still in requesting connect, cancel the request internally',
        tag: 'live-streaming-coHost',
        subTag: 'connect manager',
      );

      return ZegoUIKitPrebuiltLiveStreamingController()
          .coHost
          .audienceCancelCoHostRequest();
    }

    return true;
  }

  void uninit() {
    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live-streaming-coHost',
        subTag: 'connect manager',
      );

      return;
    }

    _initialized = false;

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live-streaming-coHost',
      subTag: 'connect manager',
    );

    audienceLocalConnectStateNotifier.value =
        ZegoLiveStreamingAudienceConnectState.idle;

    requestCoHostUsersNotifier.value = [];
    dataOfInvitedToJoinCoHostInMinimizingNotifier.value = null;
    isInvitedToJoinCoHostDlgVisible = false;
    isEndCoHostDialogVisible = false;
    audienceIDsOfInvitingConnect.clear();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  void listenStream() {
    if (config.plugins.isNotEmpty) {
      subscriptions
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
      'kick-out co-host $coHost',
      tag: 'live-streaming-coHost',
      subTag: 'connect manager',
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
          ZegoLiveStreamingReporter.eventKeyRoomID: ZegoUIKit().getRoom().id,
          ZegoLiveStreamingReporter.eventKeyCoHostID: coHost.id,
        },
      );

      ZegoLoggerService.logInfo(
        'kick co-host ${coHost.id} ${coHost.name}, result:$result',
        tag: 'live-streaming-coHost',
        subTag: 'connect manager',
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
      'invite audience connect, ${invitee.id} ${invitee.name}',
      tag: 'live-streaming-coHost',
      subTag: 'connect manager',
    );

    if (audienceIDsOfInvitingConnect.contains(invitee.id)) {
      ZegoLoggerService.logInfo(
        'audience is int connect inviting',
        tag: 'live-streaming-coHost',
        subTag: 'connect manager',
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

        events.coHost.host.onInvitationSent
            ?.call(ZegoLiveStreamingCoHostHostEventInvitationSentData(
          audience: invitee,
        ));
      }

      return result.error != null;
    });
  }

  bool coHostEndConnect() {
    ZegoLoggerService.logInfo(
      'co-host end connect',
      tag: 'live-streaming-coHost',
      subTag: 'connect manager',
    );

    ZegoLiveStreamingReporter().report(
      event: ZegoLiveStreamingReporter.eventCoHostAudienceStop,
    );
    updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);

    return true;
  }

  void onInvitationReceived(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final int type = params['type']!; // call type
    final String customData = params['data']!; // extended field

    final invitationID = params['invitation_id'] as String? ?? '';
    final invitationType = ZegoInvitationTypeExtension.mapValue[type]!;

    ZegoLoggerService.logInfo(
      'inviter:$inviter, '
      'type:$type($invitationType) ,'
      'data:$customData, ',
      tag: 'live-streaming-coHost',
      subTag: 'connect, on invitation received',
    );

    if (hostManager.isLocalHost) {
      if (ZegoLiveStreamingInvitationType.requestCoHost == invitationType) {
        ZegoLiveStreamingReporter().report(
          event: ZegoLiveStreamingReporter.eventCoHostHostReceived,
          params: {
            ZegoLiveStreamingReporter.eventKeyCallID: invitationID,
            ZegoLiveStreamingReporter.eventKeyAudienceID: inviter.id,
            ZegoLiveStreamingReporter.eventKeyExtendedData: customData,
          },
        );

        events.coHost.host.onRequestReceived
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
    if (config.coHost.turnOnCameraWhenCohosted?.call() ?? true) {
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
        tag: 'live-streaming-coHost',
        subTag: 'connect, onAudienceReceivedCoHostInvitation',
      );
      return;
    }

    if (isMaxCoHostReached) {
      events.coHost.onMaxCountReached?.call(config.coHost.maxCoHostCount);

      ZegoLoggerService.logInfo(
        'co-host max count had reached, ignore current co-host invitation',
        tag: 'live-streaming-coHost',
        subTag: 'connect, onAudienceReceivedCoHostInvitation',
      );

      return;
    }

    events.coHost.audience.onInvitationReceived?.call(
      ZegoLiveStreamingCoHostAudienceEventRequestReceivedData(
        host: host,
        customData: customData,
      ),
    );

    dataOfInvitedToJoinCoHostInMinimizingNotifier.value = null;
    if (ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
      ZegoLoggerService.logInfo(
        'is minimizing now, cache the inviter:$host',
        tag: 'live-streaming-coHost',
        subTag: 'connect, onAudienceReceivedCoHostInvitation',
      );

      dataOfInvitedToJoinCoHostInMinimizingNotifier.value =
          ZegoLiveStreamingCoHostAudienceEventRequestReceivedData(
        host: host,
        customData: customData,
      );

      return;
    }

    if (config.coHost.disableCoHostInvitationReceivedDialog) {
      ZegoLoggerService.logInfo(
        'config set not show co-host invitation dialog',
        tag: 'live-streaming-coHost',
        subTag: 'connect, onAudienceReceivedCoHostInvitation',
      );
      return;
    }

    if (isInvitedToJoinCoHostDlgVisible) {
      ZegoLoggerService.logInfo(
        'invite to join co-host dialog is visible',
        tag: 'live-streaming-coHost',
        subTag: 'connect, onAudienceReceivedCoHostInvitation',
      );
      return;
    }

    final translation = innerText.receivedCoHostInvitationDialogInfo;
    isInvitedToJoinCoHostDlgVisible = true;

    final key = DateTime.now().millisecondsSinceEpoch;
    popUpManager.addAPopUpSheet(key);

    /// not in minimizing
    showLiveDialog(
      context: contextQuery!(),
      title: translation.title,
      content: translation.message,
      leftButtonText: translation.cancelButtonName,
      rootNavigator: config.rootNavigator,
      leftButtonCallback: () {
        isInvitedToJoinCoHostDlgVisible = false;

        if (LiveStatus.living == liveStatusNotifier.value) {
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

            events.coHost.audience.onActionRefuseInvitation?.call();

            ZegoLoggerService.logInfo(
              'refuse co-host invite, result:$result',
              tag: 'live-streaming-coHost',
              subTag: 'connect, onAudienceReceivedCoHostInvitation',
            );
          });
        } else {
          ZegoLoggerService.logInfo(
            'refuse co-host invite, not living now',
            tag: 'live-streaming-coHost',
            subTag: 'connect, onAudienceReceivedCoHostInvitation',
          );
        }

        Navigator.of(
          contextQuery!(),
          rootNavigator: config.rootNavigator,
        ).pop();
      },
      rightButtonText: translation.confirmButtonName,
      rightButtonCallback: () {
        isInvitedToJoinCoHostDlgVisible = false;

        do {
          if (isMaxCoHostReached) {
            events.coHost.onMaxCountReached?.call(config.coHost.maxCoHostCount);

            ZegoLoggerService.logInfo(
              'co-host max count had reached, ignore current accept co-host invite',
              tag: 'live-streaming-coHost',
              subTag: 'connect, onAudienceReceivedCoHostInvitation',
            );

            break;
          }

          ZegoLoggerService.logInfo(
            'accept co-host invite',
            tag: 'live-streaming-coHost',
            subTag: 'connect, onAudienceReceivedCoHostInvitation',
          );
          if (LiveStatus.living == liveStatusNotifier.value) {
            ZegoUIKit()
                .getSignalingPlugin()
                .acceptInvitation(inviterID: host.id, data: '')
                .then((result) {
              ZegoLoggerService.logInfo(
                'accept co-host invite, result:$result',
                tag: 'live-streaming-coHost',
                subTag: 'connect, onAudienceReceivedCoHostInvitation',
              );

              if (result.error != null) {
                showError('${result.error}');
                return;
              }

              ZegoLiveStreamingReporter().report(
                event: ZegoLiveStreamingReporter.eventCoHostAudienceRespond,
                params: {
                  ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
                  ZegoLiveStreamingReporter.eventKeyAction:
                      ZegoLiveStreamingReporter.eventKeyActionAccept,
                },
              );

              events.coHost.audience.onActionAcceptInvitation?.call();

              final permissions = getCoHostPermissions();
              requestPermissions(
                context: contextQuery!(),
                isShowDialog: true,
                translationText: innerText,
                rootNavigator: config.rootNavigator,
                permissions: permissions,
                popUpManager: popUpManager,
                kickOutNotifier: kickOutNotifier,
              ).then((_) {
                updateAudienceConnectState(
                  ZegoLiveStreamingAudienceConnectState.connected,
                );
              });
            });
          } else {
            ZegoLoggerService.logInfo(
              'accept co-host invite, not living now',
              tag: 'live-streaming-coHost',
              subTag: 'connect, onAudienceReceivedCoHostInvitation',
            );
          }
        } while (false);

        Navigator.of(
          contextQuery!(),
          rootNavigator: config.rootNavigator,
        ).pop();
      },
    ).whenComplete(() {
      popUpManager.removeAPopUpSheet(key);
    });
  }

  void onInvitationAccepted(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String customData = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'invitee:$invitee, '
      'customData:$customData, ',
      tag: 'live-streaming-coHost',
      subTag: 'connect, on invitation accepted',
    );

    if (hostManager.isLocalHost) {
      events.coHost.host.onInvitationAccepted?.call(
        ZegoLiveStreamingCoHostHostEventInvitationAcceptedData(
          audience: invitee,
          customData: customData,
        ),
      );

      audienceIDsOfInvitingConnect.remove(invitee.id);
    } else {
      events.coHost.audience.onRequestAccepted?.call(
        ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData(
          customData: customData,
        ),
      );

      final permissions = getCoHostPermissions();
      requestPermissions(
        context: contextQuery!(),
        isShowDialog: true,
        translationText: innerText,
        rootNavigator: config.rootNavigator,
        permissions: permissions,
        popUpManager: popUpManager,
        kickOutNotifier: kickOutNotifier,
      ).then((value) {
        ZegoUIKit().turnCameraOn(
          config.coHost.turnOnCameraWhenCohosted?.call() ?? true,
        );
        ZegoUIKit().turnMicrophoneOn(true);

        updateAudienceConnectState(
            ZegoLiveStreamingAudienceConnectState.connected);
      });
    }
  }

  void onInvitationCanceled(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String customData = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'inviter:$inviter, '
      'customData:$customData, ',
      tag: 'live-streaming-coHost',
      subTag: 'connect, on invitation canceled',
    );

    if (hostManager.isLocalHost) {
      events.coHost.host.onRequestCanceled?.call(
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
    final String customData = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'invitee:$invitee, '
      'customData: $customData, ',
      tag: 'live-streaming-coHost',
      subTag: 'connect, on invitation refused',
    );

    if (hostManager.isLocalHost) {
      events.coHost.host.onInvitationRefused?.call(
        ZegoLiveStreamingCoHostHostEventInvitationRefusedData(
          audience: invitee,
          customData: customData,
        ),
      );

      audienceIDsOfInvitingConnect.remove(invitee.id);

      showError(innerText.audienceRejectInvitationToast.replaceFirst(
        ZegoUIKitPrebuiltLiveStreamingInnerText.param_1,
        ZegoUIKit().getUser(invitee.id).name,
      ));
    } else {
      events.coHost.audience.onRequestRefused?.call(
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
    final String data = params['data']!; // extended field

    final invitationID = params['invitation_id'] as String? ?? '';
    final int type = params['type']!; // call type
    final invitationType = ZegoInvitationTypeExtension.mapValue[type]!;

    ZegoLoggerService.logInfo(
      'inviter:$inviter, data:$data',
      tag: 'live-streaming-coHost',
      subTag: 'connect, on invitation timeout',
    );

    if (hostManager.isLocalHost) {
      ZegoLiveStreamingReporter().report(
        event: ZegoLiveStreamingReporter.eventCoHostHostRespond,
        params: {
          ZegoLiveStreamingReporter.eventKeyCallID: invitationID,
          ZegoLiveStreamingReporter.eventKeyAction:
              ZegoLiveStreamingReporter.eventKeyActionTimeout,
        },
      );

      events.coHost.host.onRequestTimeout?.call(
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
            ZegoLiveStreamingReporter.eventKeyCallID: 'todo',
            ZegoLiveStreamingReporter.eventKeyAction:
                ZegoLiveStreamingReporter.eventKeyActionTimeout,
          },
        );

        events.coHost.audience.onInvitationTimeout?.call();
      }

      dataOfInvitedToJoinCoHostInMinimizingNotifier.value = null;

      /// hide invite join co-host dialog
      if (isInvitedToJoinCoHostDlgVisible) {
        isInvitedToJoinCoHostDlgVisible = false;
        Navigator.of(
          contextQuery!(),
          rootNavigator: config.rootNavigator,
        ).pop();
      }
    }
  }

  void onInvitationResponseTimeout(Map<String, dynamic> params) {
    final List<ZegoUIKitUser> invitees = params['invitees']!;
    final String data = params['data']!; // extended field
    final int type = params['type']!; // call type
    final invitationType = ZegoInvitationTypeExtension.mapValue[type]!;

    ZegoLoggerService.logInfo(
      'data: $data, '
      'invitees:${invitees.map((e) => e.toString())}',
      tag: 'live-streaming-coHost',
      subTag: 'connect, on invitation response timeout',
    );

    if (hostManager.isLocalHost) {
      for (final invitee in invitees) {
        audienceIDsOfInvitingConnect.remove(invitee.id);

        if (ZegoLiveStreamingInvitationType.inviteToJoinCoHost ==
            invitationType) {
          events.coHost.host.onInvitationTimeout?.call(
            ZegoLiveStreamingCoHostHostEventInvitationTimeoutData(
              audience: invitee,
            ),
          );
        }
      }
    } else {
      events.coHost.audience.onRequestTimeout?.call();

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
        tag: 'live-streaming-coHost',
        subTag: 'connect manager',
      );
      return false;
    }

    final key = DateTime.now().millisecondsSinceEpoch;
    popUpManager.addAPopUpSheet(key);

    isEndCoHostDialogVisible = true;
    return showLiveDialog(
      context: contextQuery!(),
      rootNavigator: config.rootNavigator,
      title: innerText.endConnectionDialogInfo.title,
      content: innerText.endConnectionDialogInfo.message,
      leftButtonText: innerText.endConnectionDialogInfo.cancelButtonName,
      leftButtonCallback: () {
        isEndCoHostDialogVisible = false;
        //  pop this dialog
        Navigator.of(
          contextQuery!(),
          rootNavigator: config.rootNavigator,
        ).pop(false);
      },
      rightButtonText: innerText.endConnectionDialogInfo.confirmButtonName,
      rightButtonCallback: () {
        isEndCoHostDialogVisible = false;
        Navigator.of(
          contextQuery!(),
          rootNavigator: config.rootNavigator,
        ).pop(true);

        coHostEndConnect();
      },
    ).whenComplete(() {
      popUpManager.removeAPopUpSheet(key);
    });
  }

  void updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState state) {
    if (state == audienceLocalConnectStateNotifier.value) {
      ZegoLoggerService.logInfo(
        'audience connect state is same: $state',
        tag: 'live-streaming-coHost',
        subTag: 'connect, updateAudienceConnectState',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'update audience connect state: $state',
      tag: 'live-streaming-coHost',
      subTag: 'connect, updateAudienceConnectState',
    );

    switch (state) {
      case ZegoLiveStreamingAudienceConnectState.idle:
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

        ZegoUIKit().turnCameraOn(false);
        ZegoUIKit().turnMicrophoneOn(false);

        /// hide invite join co-host dialog
        if (isInvitedToJoinCoHostDlgVisible) {
          isInvitedToJoinCoHostDlgVisible = false;
          Navigator.of(
            contextQuery!(),
            rootNavigator: config.rootNavigator,
          ).pop();
        }

        /// hide co-host end request dialog
        if (isEndCoHostDialogVisible) {
          isEndCoHostDialogVisible = false;
          Navigator.of(
            contextQuery!(),
            rootNavigator: config.rootNavigator,
          ).pop();
        }
        break;
      case ZegoLiveStreamingAudienceConnectState.connecting:
        break;
      case ZegoLiveStreamingAudienceConnectState.connected:
        ZegoUIKit().turnCameraOn(
          config.coHost.turnOnCameraWhenCohosted?.call() ?? true,
        );
        ZegoUIKit().turnMicrophoneOn(true);

        ZegoUIKit()
            .getLocalUser()
            .camera
            .addListener(onLocalCameraStateChanged);
        ZegoUIKit()
            .getLocalUser()
            .microphone
            .addListener(onLocalMicrophoneStateChanged);

        break;
    }

    events.coHost.coHost.onLocalConnectStateUpdated?.call(state);

    final localRequestConnected =
        ZegoLiveStreamingAudienceConnectState.connecting ==
                audienceLocalConnectStateNotifier.value &&
            ZegoLiveStreamingAudienceConnectState.connected == state;
    final hostInvitedConnected = ZegoLiveStreamingAudienceConnectState.idle ==
            audienceLocalConnectStateNotifier.value &&
        ZegoLiveStreamingAudienceConnectState.connected == state;
    if (localRequestConnected || hostInvitedConnected) {
      /// idle|connecting -> connected
      events.coHost.coHost.onLocalConnected?.call();
    } else if (ZegoLiveStreamingAudienceConnectState.connected ==
            audienceLocalConnectStateNotifier.value &&
        ZegoLiveStreamingAudienceConnectState.idle == state) {
      /// connected -> idle
      events.coHost.coHost.onLocalDisconnected?.call();
    }

    audienceLocalConnectStateNotifier.value = state;
  }

  void onLocalCameraStateChanged() {
    if (!ZegoUIKit().getLocalUser().camera.value &&
        (!ZegoUIKit().getLocalUser().microphone.value &&

            /// if mic is in mute mode, same as open state
            !ZegoUIKit().getLocalUser().microphoneMuteMode.value)) {
      ZegoLoggerService.logInfo(
        "co-host's camera and microphone are closed, update connect state to idle, "
        'local user:${ZegoUIKit().getLocalUser()} ',
        tag: 'live-streaming-coHost',
        subTag: 'connect, onLocalCameraStateChanged',
      );

      updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);
    }
  }

  void onLocalMicrophoneStateChanged() {
    if (!ZegoUIKit().getLocalUser().camera.value &&
        (!ZegoUIKit().getLocalUser().microphone.value &&

            /// if mic is in mute mode, same as open state
            !ZegoUIKit().getLocalUser().microphoneMuteMode.value)) {
      ZegoLoggerService.logInfo(
        "co-host's camera and microphone are closed, update connect state to idle, "
        'local user:${ZegoUIKit().getLocalUser()} ',
        tag: 'live-streaming-coHost',
        subTag: 'connect, onLocalMicrophoneStateChanged',
      );

      updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);
    }
  }
}

extension ZegoLiveConnectManagerCoHostCount on ZegoLiveStreamingConnectManager {
  void initCoHostMixin() {
    subscriptions
      ..add(ZegoUIKit().getUserListStream().listen(onUserListUpdated))
      ..add(ZegoUIKit().getUserJoinStream().listen(onUserJoinUpdated))
      ..add(ZegoUIKit().getUserLeaveStream().listen(onUserLeaveUpdated))
      ..add(ZegoUIKit()
          .getAudioVideoListStream()
          .listen(onAudioVideoListUpdated));
  }

  void onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    final coHosts = users.where((user) => isCoHost(user)).toList();
    coHostCount.value = coHosts.length;

    events.coHost.onUpdated?.call(coHosts);

    ZegoLoggerService.logInfo(
      'audio video list changed, co-host count changed to ${coHostCount.value}',
      tag: 'live-streaming-coHost',
      subTag: 'connect, onAudioVideoListUpdated',
    );

    if (isMaxCoHostReached && hostManager.isLocalHost) {
      final coHosts = List<ZegoUIKitUser>.from(users)
        ..removeWhere((user) => hostManager.notifier.value?.id == user.id)
        ..sort((left, right) {
          return left.streamTimestamp.compareTo(right.streamTimestamp);
        });

      final kickCount = coHosts.length - config.coHost.maxCoHostCount;
      final kickUsers = coHosts.sublist(0, kickCount);
      ZegoLoggerService.logInfo(
        'audio video list changed, max co-host count reach, '
        'will kick $kickCount user in ${coHosts.length} by sort:$kickUsers',
        tag: 'live-streaming-coHost',
        subTag: 'connect, onAudioVideoListUpdated',
      );

      kickUsers.forEach(kickCoHost);
    }
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    coHostCount.value = users.where((user) => isCoHost(user)).length;

    ZegoLoggerService.logInfo(
      'user list changed, co-host count changed to ${coHostCount.value}',
      tag: 'live-streaming-coHost',
      subTag: 'connect, onUserListUpdated',
    );
  }

  void onUserJoinUpdated(List<ZegoUIKitUser> users) {
    for (final user in users) {
      user.camera.addListener(onUserCameraStateChanged);
      user.microphone.addListener(onUserMicrophoneStateChanged);
    }
  }

  void onUserLeaveUpdated(List<ZegoUIKitUser> users) {
    for (final user in users) {
      user.camera.removeListener(onUserCameraStateChanged);
      user.microphone.removeListener(onUserMicrophoneStateChanged);
    }

    for (var requestCoHostUser in requestCoHostUsersNotifier.value) {
      events.coHost.host.onRequestCanceled?.call(
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
    coHostCount.value =
        ZegoUIKit().getAllUsers().where((user) => isCoHost(user)).length;

    ZegoLoggerService.logInfo(
      'user camera state changed, co-host count changed to ${coHostCount.value}',
      tag: 'live-streaming-coHost',
      subTag: 'connect, onUserCameraStateChanged',
    );
  }

  void onUserMicrophoneStateChanged() {
    coHostCount.value =
        ZegoUIKit().getAllUsers().where((user) => isCoHost(user)).length;

    ZegoLoggerService.logInfo(
      'user microphone state changed, co-host count changed to ${coHostCount.value}',
      tag: 'live-streaming-coHost',
      subTag: 'connect, onUserMicrophoneStateChanged',
    );
  }
}
