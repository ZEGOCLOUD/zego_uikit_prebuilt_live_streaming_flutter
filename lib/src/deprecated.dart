// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

const deprecatedTips = ', '
    'deprecated since 3.0.0, '
    'will be removed after 3.1.0,'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/topics/Migration:%20from%202.x%20to%203.0-topic.html';

@Deprecated(
    'use ZegoUIKitPrebuiltLiveStreamingController().minimize instead$deprecatedTips')
class ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine {
  @Deprecated(
      'use ZegoUIKitPrebuiltLiveStreamingController().minimize.state instead$deprecatedTips')
  PrebuiltLiveStreamingMiniOverlayPageState get state =>
      ZegoUIKitPrebuiltLiveStreamingController().minimize.state;

  @Deprecated(
      'use ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing instead$deprecatedTips')
  bool get isMinimizing =>
      ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing;

  @Deprecated(
      'use ZegoUIKitPrebuiltLiveStreamingController().minimize.restore instead$deprecatedTips')
  bool restoreFromMinimize(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  }) {
    return ZegoUIKitPrebuiltLiveStreamingController().minimize.restore(
          context,
          rootNavigator: rootNavigator,
          withSafeArea: withSafeArea,
        );
  }

  @Deprecated(
      'use ZegoUIKitPrebuiltLiveStreamingController().minimize.minimize instead$deprecatedTips')
  bool minimize(
    BuildContext context, {
    bool rootNavigator = true,
  }) {
    return ZegoUIKitPrebuiltLiveStreamingController().minimize.minimize(
          context,
          rootNavigator: rootNavigator,
        );
  }

  @Deprecated(
      'use ZegoUIKitPrebuiltLiveStreamingController().minimize.hide instead$deprecatedTips')
  void resetInLiving() {
    ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
  }
}

@Deprecated(
    'use ZegoLiveStreamingMiniOverlayPageState().minimize instead$deprecatedTips')
typedef PrebuiltLiveStreamingMiniOverlayPageState
    = ZegoLiveStreamingMiniOverlayPageState;
@Deprecated(
    'use ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage instead$deprecatedTips')
typedef ZegoMiniOverlayPage = ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage;

@Deprecated('Use ZegoInnerText instead$deprecatedTips')
typedef ZegoTranslationText = ZegoInnerText;

@Deprecated('Use ZegoLiveStreamingAudioVideoViewConfig instead$deprecatedTips')
typedef ZegoPrebuiltAudioVideoViewConfig
    = ZegoLiveStreamingAudioVideoViewConfig;

@Deprecated('Use ZegoLiveStreamingTopMenuBarConfig instead$deprecatedTips')
typedef ZegoTopMenuBarConfig = ZegoLiveStreamingTopMenuBarConfig;

@Deprecated('Use ZegoLiveStreamingBottomMenuBarConfig instead$deprecatedTips')
typedef ZegoBottomMenuBarConfig = ZegoLiveStreamingBottomMenuBarConfig;

@Deprecated('Use ZegoLiveStreamingMenuBarExtendButton instead$deprecatedTips')
typedef ZegoMenuBarExtendButton = ZegoLiveStreamingMenuBarExtendButton;

@Deprecated(
    'use ZegoLiveStreamingBottomMenuBarButtonStyle instead$deprecatedTips')
typedef ZegoBottomMenuBarButtonStyle
    = ZegoLiveStreamingBottomMenuBarButtonStyle;

@Deprecated('Use ZegoLiveStreamingMemberButtonConfig instead$deprecatedTips')
typedef ZegoMemberButtonConfig = ZegoLiveStreamingMemberButtonConfig;

@Deprecated('Use ZegoLiveStreamingMemberListConfig instead$deprecatedTips')
typedef ZegoMemberListConfig = ZegoLiveStreamingMemberListConfig;

@Deprecated('Use ZegoLiveStreamingInRoomMessageConfig instead$deprecatedTips')
typedef ZegoInRoomMessageConfig = ZegoLiveStreamingInRoomMessageConfig;
@Deprecated('Use ZegoLiveStreamingInRoomMessageConfig instead$deprecatedTips')
typedef ZegoInRoomMessageViewConfig = ZegoLiveStreamingInRoomMessageConfig;

@Deprecated('Use ZegoLiveStreamingEffectConfig instead$deprecatedTips')
typedef ZegoEffectConfig = ZegoLiveStreamingEffectConfig;

@Deprecated('Use ZegoLiveStreamingPKBattleConfig instead$deprecatedTips')
typedef ZegoLiveStreamingPKBattleV2Config = ZegoLiveStreamingPKBattleConfig;

@Deprecated('Use ZegoLiveStreamingDurationConfig instead$deprecatedTips')
typedef ZegoLiveDurationConfig = ZegoLiveStreamingDurationConfig;

@Deprecated('Use ZegoLiveStreamingMediaPlayerConfig instead$deprecatedTips')
typedef ZegoMediaPlayerConfig = ZegoLiveStreamingMediaPlayerConfig;

@Deprecated('Use ZegoLiveStreamingCoHostHostEvents instead$deprecatedTips')
typedef ZegoUIKitPrebuiltLiveStreamingHostEvents
    = ZegoLiveStreamingCoHostHostEvents;

@Deprecated('Use ZegoLiveStreamingCoHostAudienceEvents instead$deprecatedTips')
typedef ZegoUIKitPrebuiltLiveStreamingAudienceEvents
    = ZegoLiveStreamingCoHostAudienceEvents;

@Deprecated('Use ZegoPKMixerLayout instead$deprecatedTips')
typedef ZegoPKV2MixerLayout = ZegoPKMixerLayout;

@Deprecated('Use ZegoLiveStreamingPKUser instead$deprecatedTips')
typedef ZegoUIKitPrebuiltLiveStreamingPKUser = ZegoLiveStreamingPKUser;

@Deprecated('Use ZegoLiveStreamingPKController instead$deprecatedTips')
typedef ZegoLiveStreamingPKControllerV2 = ZegoLiveStreamingPKController;

@Deprecated('Use ZegoLiveStreamingPKEvents instead$deprecatedTips')
typedef ZegoUIKitPrebuiltLiveStreamingPKV2Events = ZegoLiveStreamingPKEvents;

@Deprecated(
    'Use ZegoIncomingPKBattleRequestReceivedEvent instead$deprecatedTips')
typedef ZegoIncomingPKBattleRequestReceivedEventV2
    = ZegoIncomingPKBattleRequestReceivedEvent;

@Deprecated(
    'Use ZegoIncomingPKBattleRequestCancelledEvent instead$deprecatedTips')
typedef ZegoIncomingPKBattleRequestCancelledEventV2
    = ZegoIncomingPKBattleRequestCancelledEvent;

@Deprecated(
    'Use ZegoIncomingPKBattleRequestTimeoutEvent instead$deprecatedTips')
typedef ZegoIncomingPKBattleRequestTimeoutEventV2
    = ZegoIncomingPKBattleRequestTimeoutEvent;

@Deprecated(
    'Use ZegoOutgoingPKBattleRequestAcceptedEvent instead$deprecatedTips')
typedef ZegoOutgoingPKBattleRequestAcceptedEventV2
    = ZegoOutgoingPKBattleRequestAcceptedEvent;

@Deprecated(
    'Use ZegoOutgoingPKBattleRequestRejectedEvent instead$deprecatedTips')
typedef ZegoOutgoingPKBattleRequestRejectedEventV2
    = ZegoOutgoingPKBattleRequestRejectedEvent;

@Deprecated(
    'Use ZegoOutgoingPKBattleRequestTimeoutEvent instead$deprecatedTips')
typedef ZegoOutgoingPKBattleRequestTimeoutEventV2
    = ZegoOutgoingPKBattleRequestTimeoutEvent;

@Deprecated('Use ZegoPKBattleEndedEvent instead$deprecatedTips')
typedef ZegoPKBattleEndedEventV2 = ZegoPKBattleEndedEvent;

@Deprecated('Use ZegoPKBattleUserOfflineEvent instead$deprecatedTips')
typedef ZegoPKBattleUserOfflineEventV2 = ZegoPKBattleUserOfflineEvent;

@Deprecated('Use ZegoPKBattleUserQuitEvent instead$deprecatedTips')
typedef ZegoPKBattleUserQuitEventV2 = ZegoPKBattleUserQuitEvent;

@Deprecated('Use ZegoLiveStreamingPKBattleState instead$deprecatedTips')
typedef ZegoLiveStreamingPKBattleStateV2 = ZegoLiveStreamingPKBattleState;

extension ZegoLiveStreamingConfigDeprecated
    on ZegoUIKitPrebuiltLiveStreamingConfig {
  @Deprecated('Use mediaPlayer instead$deprecatedTips')
  ZegoMediaPlayerConfig get mediaPlayerConfig => mediaPlayer;

  @Deprecated('Use mediaPlayer instead$deprecatedTips')
  set mediaPlayerConfig(ZegoMediaPlayerConfig config) => mediaPlayer = config;

  @Deprecated('Use video instead$deprecatedTips')
  ZegoUIKitVideoConfig get videoConfig => video;

  @Deprecated('Use video instead$deprecatedTips')
  set videoConfig(ZegoUIKitVideoConfig config) => videoConfig = config;

  @Deprecated('Use audioVideoView instead$deprecatedTips')
  ZegoPrebuiltAudioVideoViewConfig get audioVideoViewConfig => audioVideoView;

  @Deprecated('Use audioVideoView instead$deprecatedTips')
  set audioVideoViewConfig(ZegoPrebuiltAudioVideoViewConfig config) =>
      audioVideoView = config;

  @Deprecated('Use topMenuBar instead$deprecatedTips')
  ZegoTopMenuBarConfig get topMenuBarConfig => topMenuBar;

  @Deprecated('Use topMenuBar instead$deprecatedTips')
  set topMenuBarConfig(ZegoTopMenuBarConfig config) => topMenuBar = config;

  @Deprecated('Use bottomMenuBar instead$deprecatedTips')
  ZegoBottomMenuBarConfig get bottomMenuBarConfig => bottomMenuBar;

  @Deprecated('Use bottomMenuBar instead$deprecatedTips')
  set bottomMenuBarConfig(ZegoBottomMenuBarConfig config) =>
      bottomMenuBar = config;

  @Deprecated('Use memberButton instead$deprecatedTips')
  ZegoMemberButtonConfig get memberButtonConfig => memberButton;

  @Deprecated('Use memberButton instead$deprecatedTips')
  set memberButtonConfig(ZegoMemberButtonConfig config) =>
      memberButton = config;

  @Deprecated('Use memberList instead$deprecatedTips')
  ZegoMemberListConfig get memberListConfig => memberList;

  @Deprecated('Use memberList instead$deprecatedTips')
  set memberListConfig(ZegoMemberListConfig config) => memberList = config;

  @Deprecated('Use inRoomMessage instead$deprecatedTips')
  ZegoInRoomMessageConfig get inRoomMessageConfig => inRoomMessage;

  @Deprecated('Use inRoomMessage instead$deprecatedTips')
  ZegoInRoomMessageViewConfig get inRoomMessageViewConfig => inRoomMessage;

  @Deprecated('Use inRoomMessage instead$deprecatedTips')
  set inRoomMessageConfig(ZegoInRoomMessageConfig config) =>
      inRoomMessage = config;

  @Deprecated('Use inRoomMessage instead$deprecatedTips')
  set inRoomMessageViewConfig(ZegoInRoomMessageViewConfig config) =>
      inRoomMessage = config;

  @Deprecated('Use effect instead$deprecatedTips')
  ZegoEffectConfig get effectConfig => effect;

  @Deprecated('Use effect instead$deprecatedTips')
  set effectConfig(ZegoEffectConfig config) => effect = config;

  @Deprecated('Use beauty instead$deprecatedTips')
  ZegoBeautyPluginConfig? get beautyConfig => beauty;

  @Deprecated('Use beauty instead$deprecatedTips')
  set beautyConfig(ZegoBeautyPluginConfig? config) => beauty = config;

  @Deprecated('Use preview instead$deprecatedTips')
  ZegoLiveStreamingPreviewConfig get previewConfig => preview;

  @Deprecated('Use preview instead$deprecatedTips')
  set previewConfig(ZegoLiveStreamingPreviewConfig config) => preview = config;

  @Deprecated('Use pkBattle instead$deprecatedTips')
  ZegoLiveStreamingPKBattleV2Config get pkBattleV2Config => pkBattle;

  @Deprecated('Use pkBattle instead$deprecatedTips')
  set pkBattleV2Config(ZegoLiveStreamingPKBattleV2Config config) =>
      pkBattle = config;

  @Deprecated('Use duration instead$deprecatedTips')
  ZegoLiveDurationConfig get durationConfig => duration;

  @Deprecated('Use duration instead$deprecatedTips')
  set durationConfig(ZegoLiveDurationConfig config) => duration = config;

  @Deprecated('Use preview.startLiveButtonBuilder instead$deprecatedTips')
  ZegoStartLiveButtonBuilder? get startLiveButtonBuilder =>
      preview.startLiveButtonBuilder;

  @Deprecated('Use preview.startLiveButtonBuilder instead$deprecatedTips')
  set startLiveButtonBuilder(ZegoStartLiveButtonBuilder? value) =>
      preview.startLiveButtonBuilder = value;

  @Deprecated('Use innerText instead$deprecatedTips')
  ZegoTranslationText get translationText => innerText;

  @Deprecated('Use innerText instead$deprecatedTips')
  set translationText(ZegoTranslationText text) => innerText = text;
}

extension ZegoLiveStreamingControllerDeprecated
    on ZegoUIKitPrebuiltLiveStreamingController {
  @Deprecated('Use coHost instead$deprecatedTips')
  ZegoLiveStreamingControllerCoHostImpl get connect => coHost;

  @Deprecated('Use coHost instead$deprecatedTips')
  ZegoLiveStreamingControllerCoHostImpl get connectInvite => coHost;

  @Deprecated('Use pk instead$deprecatedTips')
  ZegoLiveStreamingPKControllerV2 get pkV2 => pk;
}

extension ZegoLiveStreamingEventsDeprecated
    on ZegoUIKitPrebuiltLiveStreamingEvents {
  @Deprecated('Use coHost.onMaxCountReached instead$deprecatedTips')
  void Function(int count)? get onMaxCoHostReached => coHost.onMaxCountReached;

  @Deprecated('Use coHost.onMaxCountReached instead$deprecatedTips')
  set onMaxCoHostReached(void Function(int count)? value) =>
      coHost.onMaxCountReached = value;

  @Deprecated('Use coHost.onUpdated instead$deprecatedTips')
  Function(List<ZegoUIKitUser> coHosts)? get onCoHostsUpdated =>
      coHost.onUpdated;

  @Deprecated('Use coHost.onUpdated instead$deprecatedTips')
  set onCoHostsUpdated(Function(List<ZegoUIKitUser> coHosts)? value) =>
      coHost.onUpdated = value;

  @Deprecated('Use coHost.host instead$deprecatedTips')
  ZegoUIKitPrebuiltLiveStreamingHostEvents get hostEvents => coHost.host;

  @Deprecated('Use coHost.host instead$deprecatedTips')
  set hostEvents(ZegoUIKitPrebuiltLiveStreamingHostEvents value) =>
      coHost.host = value;

  @Deprecated('Use coHost.audience instead$deprecatedTips')
  ZegoUIKitPrebuiltLiveStreamingAudienceEvents get audienceEvents =>
      coHost.audience;

  @Deprecated('Use coHost.audience instead$deprecatedTips')
  set audienceEvents(ZegoUIKitPrebuiltLiveStreamingAudienceEvents value) =>
      coHost.audience = value;

  @Deprecated('Use pk instead$deprecatedTips')
  ZegoUIKitPrebuiltLiveStreamingPKV2Events get pkV2Events => pk;

  @Deprecated('Use pk instead$deprecatedTips')
  set pkV2Events(ZegoUIKitPrebuiltLiveStreamingPKV2Events value) => pk = value;
}

@Deprecated(
    'Use ZegoUIKitPrebuiltLiveStreamingHostEvents instead$deprecatedTips')
extension ZegoLiveStreamingHostEventsExtension
    on ZegoUIKitPrebuiltLiveStreamingHostEvents {
  @Deprecated('Use onRequestReceived instead$deprecatedTips')
  Function(ZegoUIKitUser audience)? get onCoHostRequestReceived =>
      onRequestReceived;

  @Deprecated('Use onRequestReceived instead$deprecatedTips')
  set onCoHostRequestReceived(Function(ZegoUIKitUser audience)? value) =>
      onRequestReceived = value;

  @Deprecated('Use onRequestCanceled instead$deprecatedTips')
  Function(ZegoUIKitUser audience)? get onCoHostRequestCanceled =>
      onRequestCanceled;

  @Deprecated('Use onRequestCanceled instead$deprecatedTips')
  set onCoHostRequestCanceled(Function(ZegoUIKitUser audience)? value) =>
      onRequestCanceled = value;

  @Deprecated('Use onRequestTimeout instead$deprecatedTips')
  Function(ZegoUIKitUser audience)? get onCoHostRequestTimeout =>
      onRequestTimeout;

  @Deprecated('Use onRequestTimeout instead$deprecatedTips')
  set onCoHostRequestTimeout(Function(ZegoUIKitUser audience)? value) =>
      onRequestTimeout = value;

  @Deprecated('Use onActionAcceptRequest instead$deprecatedTips')
  Function()? get onActionAcceptCoHostRequest => onActionAcceptRequest;

  @Deprecated('Use onActionAcceptRequest instead$deprecatedTips')
  set onActionAcceptCoHostRequest(Function()? value) =>
      onActionAcceptRequest = value;

  @Deprecated('Use onActionRefuseRequest instead$deprecatedTips')
  Function()? get onActionRefuseCoHostRequest => onActionRefuseRequest;

  @Deprecated('Use onActionRefuseRequest instead$deprecatedTips')
  set onActionRefuseCoHostRequest(Function()? value) =>
      onActionRefuseRequest = value;

  @Deprecated('Use onInvitationSent instead$deprecatedTips')
  Function(ZegoUIKitUser audience)? get onCoHostInvitationSent =>
      onInvitationSent;

  @Deprecated('Use onInvitationSent instead$deprecatedTips')
  set onCoHostInvitationSent(Function(ZegoUIKitUser audience)? value) =>
      onInvitationSent = value;

  @Deprecated('Use onInvitationTimeout instead$deprecatedTips')
  Function(ZegoUIKitUser audience)? get onCoHostInvitationTimeout =>
      onInvitationTimeout;

  @Deprecated('Use onInvitationTimeout instead$deprecatedTips')
  set onCoHostInvitationTimeout(Function(ZegoUIKitUser audience)? value) =>
      onInvitationTimeout = value;

  @Deprecated('Use onInvitationAccepted instead$deprecatedTips')
  Function(ZegoUIKitUser audience)? get onCoHostInvitationAccepted =>
      onInvitationAccepted;

  @Deprecated('Use onInvitationAccepted instead$deprecatedTips')
  set onCoHostInvitationAccepted(Function(ZegoUIKitUser audience)? value) =>
      onInvitationAccepted = value;

  @Deprecated('Use onInvitationRefused instead$deprecatedTips')
  Function(ZegoUIKitUser audience)? get onCoHostInvitationRefused =>
      onInvitationRefused;

  @Deprecated('Use onInvitationRefused instead$deprecatedTips')
  set onCoHostInvitationRefused(Function(ZegoUIKitUser audience)? value) =>
      onInvitationRefused = value;
}

@Deprecated(
    'Use ZegoUIKitPrebuiltLiveStreamingAudienceEvents instead$deprecatedTips')
extension ZegoLiveStreamingAudienceEventsExtension
    on ZegoUIKitPrebuiltLiveStreamingAudienceEvents {
  @Deprecated('Use onRequestSent instead$deprecatedTips')
  Function()? get onCoHostRequestSent => onRequestSent;

  @Deprecated('Use onRequestSent instead$deprecatedTips')
  set onCoHostRequestSent(Function()? value) => onRequestSent = value;

  @Deprecated('Use onActionCancelRequest instead$deprecatedTips')
  Function()? get onActionCancelCoHostRequest => onActionCancelRequest;

  @Deprecated('Use onActionCancelRequest instead$deprecatedTips')
  set onActionCancelCoHostRequest(Function()? value) =>
      onActionCancelRequest = value;

  @Deprecated('Use onRequestTimeout instead$deprecatedTips')
  Function()? get onCoHostRequestTimeout => onRequestTimeout;

  @Deprecated('Use onRequestTimeout instead$deprecatedTips')
  set onCoHostRequestTimeout(Function()? value) => onRequestTimeout = value;

  @Deprecated('Use onRequestAccepted instead$deprecatedTips')
  Function()? get onCoHostRequestAccepted => onRequestAccepted;

  @Deprecated('Use onRequestAccepted instead$deprecatedTips')
  set onCoHostRequestAccepted(Function()? value) => onRequestAccepted = value;

  @Deprecated('Use onRequestRefused instead$deprecatedTips')
  Function()? get onCoHostRequestRefused => onRequestRefused;

  @Deprecated('Use onRequestRefused instead$deprecatedTips')
  set onCoHostRequestRefused(Function()? value) => onRequestRefused = value;

  @Deprecated('Use onInvitationReceived instead$deprecatedTips')
  Function(ZegoUIKitUser host)? get onCoHostInvitationReceived =>
      onInvitationReceived;

  @Deprecated('Use onInvitationReceived instead$deprecatedTips')
  set onCoHostInvitationReceived(void Function(ZegoUIKitUser host)? value) =>
      onInvitationReceived = value;

  @Deprecated('Use onInvitationTimeout instead$deprecatedTips')
  Function()? get onCoHostInvitationTimeout => onInvitationTimeout;

  @Deprecated('Use onInvitationTimeout instead$deprecatedTips')
  set onCoHostInvitationTimeout(Function()? value) =>
      onInvitationTimeout = value;

  @Deprecated('Use onActionAcceptInvitation instead$deprecatedTips')
  Function()? get onActionAcceptCoHostInvitation => onActionAcceptInvitation;

  @Deprecated('Use onActionAcceptInvitation instead$deprecatedTips')
  set onActionAcceptCoHostInvitation(Function()? value) =>
      onActionAcceptInvitation = value;

  @Deprecated('Use onActionRefuseInvitation instead$deprecatedTips')
  Function()? get onActionRefuseCoHostInvitation => onActionRefuseInvitation;

  @Deprecated('Use onActionRefuseInvitation instead$deprecatedTips')
  set onActionRefuseCoHostInvitation(Function()? value) =>
      onActionRefuseInvitation = value;
}

@Deprecated('Use ZegoLiveStreamingPKEvents instead$deprecatedTips')
extension ZegoLiveStreamingPKEventsExtension on ZegoLiveStreamingPKEvents {
  @Deprecated('Use onIncomingRequestReceived instead')
  void Function(
    ZegoIncomingPKBattleRequestReceivedEvent event,
    VoidCallback defaultAction,
  )? get onIncomingPKBattleRequestReceived => onIncomingRequestReceived;

  @Deprecated('Use onIncomingRequestReceived instead')
  set onIncomingPKBattleRequestReceived(
          void Function(
            ZegoIncomingPKBattleRequestReceivedEvent event,
            VoidCallback defaultAction,
          )? value) =>
      onIncomingRequestReceived = value;

  @Deprecated('Use onIncomingRequestCancelled instead$deprecatedTips')
  Function(
    ZegoIncomingPKBattleRequestCancelledEventV2 event,
    VoidCallback defaultAction,
  )? get onIncomingPKBattleRequestCancelled => onIncomingRequestCancelled;

  @Deprecated('Use onIncomingRequestCancelled instead$deprecatedTips')
  set onIncomingPKBattleRequestCancelled(
          Function(
            ZegoIncomingPKBattleRequestCancelledEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onIncomingRequestCancelled = value;

  @Deprecated('Use onIncomingRequestTimeout instead$deprecatedTips')
  void Function(
    ZegoIncomingPKBattleRequestTimeoutEventV2 event,
    VoidCallback defaultAction,
  )? get onIncomingPKBattleRequestTimeout => onIncomingRequestTimeout;

  @Deprecated('Use onIncomingRequestTimeout instead$deprecatedTips')
  set onIncomingPKBattleRequestTimeout(
          void Function(
            ZegoIncomingPKBattleRequestTimeoutEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onIncomingRequestTimeout = value;

  @Deprecated('Use onOutgoingRequestAccepted instead$deprecatedTips')
  void Function(
    ZegoOutgoingPKBattleRequestAcceptedEventV2 event,
    VoidCallback defaultAction,
  )? get onOutgoingPKBattleRequestAccepted => onOutgoingRequestAccepted;

  @Deprecated('Use onOutgoingRequestAccepted instead$deprecatedTips')
  set onOutgoingPKBattleRequestAccepted(
          void Function(
            ZegoOutgoingPKBattleRequestAcceptedEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onOutgoingRequestAccepted = value;

  @Deprecated('Use onOutgoingRequestRejected instead$deprecatedTips')
  void Function(
    ZegoOutgoingPKBattleRequestRejectedEventV2 event,
    VoidCallback defaultAction,
  )? get onOutgoingPKBattleRequestRejected => onOutgoingRequestRejected;

  @Deprecated('Use onOutgoingRequestRejected instead$deprecatedTips')
  set onOutgoingPKBattleRequestRejected(
          void Function(
            ZegoOutgoingPKBattleRequestRejectedEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onOutgoingRequestRejected = value;

  @Deprecated('Use onOutgoingRequestTimeout instead$deprecatedTips')
  void Function(
    ZegoOutgoingPKBattleRequestTimeoutEventV2 event,
    VoidCallback defaultAction,
  )? get onOutgoingPKBattleRequestTimeout => onOutgoingRequestTimeout;

  @Deprecated('Use onOutgoingRequestTimeout instead$deprecatedTips')
  set onOutgoingPKBattleRequestTimeout(
          void Function(
            ZegoOutgoingPKBattleRequestTimeoutEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onOutgoingRequestTimeout = value;

  @Deprecated('Use onEnded instead$deprecatedTips')
  void Function(
    ZegoPKBattleEndedEventV2 event,
    VoidCallback defaultAction,
  )? get onPKBattleEnded => onEnded;

  @Deprecated('Use onEnded instead$deprecatedTips')
  set onPKBattleEnded(
          void Function(
            ZegoPKBattleEndedEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onEnded = value;
}
