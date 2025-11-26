// Project imports:
import 'defines.dart';
import 'inner_text.dart';

/// ZegoUIKitPrebuiltLiveStreaming 简体中文文本配置
///
/// 使用方式：
/// ```dart
/// ZegoUIKitPrebuiltLiveStreamingConfig(
///   innerText: ZegoUIKitPrebuiltLiveStreamingInnerTextZhCN(),
/// )
/// ```
class ZegoUIKitPrebuiltLiveStreamingInnerTextZhCN
    extends ZegoUIKitPrebuiltLiveStreamingInnerText {
  ZegoUIKitPrebuiltLiveStreamingInnerTextZhCN()
      : super(
          /// 按钮文本
          disagreeButton: '不同意',
          agreeButton: '同意',
          startLiveStreamingButton: '开始',
          endCoHostButton: '结束',
          requestCoHostButton: '申请连麦',
          cancelRequestCoHostButton: '取消申请',
          removeCoHostButton: '移除连麦',
          cancelMenuDialogButton: '取消',
          inviteCoHostButton:
              '邀请 ${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} 连麦',
          removeUserMenuDialogButton:
              '将 ${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} 移出房间',

          /// 提示文本
          noHostOnline: '暂无主播在线',
          memberListTitle: '观众',
          memberListRoleYou: '你',
          memberListRoleHost: '主播',
          memberListRoleCoHost: '连麦',

          /// Toast 提示
          sendRequestCoHostToast: '你正在申请连麦，请等待确认',
          hostRejectCoHostRequestToast: '你的连麦申请已被拒绝',
          inviteCoHostFailedToast: '连麦连接失败，请重试',
          repeatInviteCoHostFailedToast: '你已发送邀请，请等待确认',
          messageEmptyToast: '说点什么...',
          userEnter: '进入',
          userLeave: '离开',
          audienceRejectInvitationToast:
              '${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} 拒绝了连麦邀请',
          requestCoHostFailedToast: '申请连麦失败',

          /// 权限对话框
          cameraPermissionSettingDialogInfo: ZegoLiveStreamingDialogInfo(
            title: '无法使用摄像头！',
            message: '请在系统设置中启用摄像头权限！',
            cancelButtonName: '取消',
            confirmButtonName: '设置',
          ),
          microphonePermissionSettingDialogInfo: ZegoLiveStreamingDialogInfo(
            title: '无法使用麦克风！',
            message: '请在系统设置中启用麦克风权限！',
            cancelButtonName: '取消',
            confirmButtonName: '设置',
          ),

          /// 连麦相关对话框
          receivedCoHostRequestDialogInfo: ZegoLiveStreamingDialogInfo(
            title: '连麦申请',
            message:
                '${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} 想要与你连麦',
            cancelButtonName: '不同意',
            confirmButtonName: '同意',
          ),
          receivedCoHostInvitationDialogInfo: ZegoLiveStreamingDialogInfo(
            title: '邀请',
            message: '主播邀请你连麦',
            cancelButtonName: '不同意',
            confirmButtonName: '同意',
          ),
          endConnectionDialogInfo: ZegoLiveStreamingDialogInfo(
            title: '结束连麦',
            message: '确定要结束连麦吗？',
            cancelButtonName: '取消',
            confirmButtonName: '确定',
          ),

          /// 音效相关
          audioEffectTitle: '音效',
          audioEffectReverbTitle: '混响',
          audioEffectVoiceChangingTitle: '变声',
          beautyEffectTitle: '美颜',

          /// 变声效果
          voiceChangerNoneTitle: '无',
          voiceChangerLittleBoyTitle: '小男孩',
          voiceChangerLittleGirlTitle: '小女孩',
          voiceChangerDeepTitle: '低沉',
          voiceChangerCrystalClearTitle: '清澈',
          voiceChangerRobotTitle: '机器人',
          voiceChangerEtherealTitle: '空灵',
          voiceChangerFemaleTitle: '女声',
          voiceChangerMaleTitle: '男声',
          voiceChangerOptimusPrimeTitle: '擎天柱',
          voiceChangerCMajorTitle: 'C大调',
          voiceChangerAMajorTitle: 'A大调',
          voiceChangerHarmonicMinorTitle: '和声小调',

          /// 混响效果
          reverbTypeNoneTitle: '无',
          reverbTypeKTVTitle: 'KTV',
          reverbTypeHallTitle: '大厅',
          reverbTypeConcertTitle: '演唱会',
          reverbTypeRockTitle: '摇滚',
          reverbTypeSmallRoomTitle: '小房间',
          reverbTypeLargeRoomTitle: '大房间',
          reverbTypeValleyTitle: '山谷',
          reverbTypeRecordingStudioTitle: '录音棚',
          reverbTypeBasementTitle: '地下室',
          reverbTypePopularTitle: '流行',
          reverbTypeGramophoneTitle: '留声机',

          /// 美颜效果
          beautyEffectTypeWhitenTitle: '美白',
          beautyEffectTypeRosyTitle: '红润',
          beautyEffectTypeSmoothTitle: '磨皮',
          beautyEffectTypeSharpenTitle: '锐化',
          beautyEffectTypeNoneTitle: '无',

          /// PK 相关对话框
          incomingPKBattleRequestReceived: ZegoLiveStreamingDialogInfo(
            title: 'PK 请求',
            message:
                '${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} 向你发送了 PK 请求',
            cancelButtonName: '拒绝',
            confirmButtonName: '接受',
          ),
          coHostEndCauseByHostStartPK: ZegoLiveStreamingDialogInfo(
            title: '主播开始 PK',
            message: '你的连麦已结束',
            cancelButtonName: '',
            confirmButtonName: '确定',
          ),
          pkBattleEndedCauseByAnotherHost: ZegoLiveStreamingDialogInfo(
            title: 'PK 已结束',
            message:
                '${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} 结束了 PK',
            cancelButtonName: '',
            confirmButtonName: '确定',
          ),
          outgoingPKBattleRequestRejectedCauseByError:
              ZegoLiveStreamingDialogInfo(
            title: 'PK 发起失败',
            message: '错误码: ${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1}',
            cancelButtonName: '',
            confirmButtonName: '确定',
          ),
          outgoingPKBattleRequestRejectedCauseByBusy:
              ZegoLiveStreamingDialogInfo(
            title: 'PK 发起失败',
            message: '主播 ${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} 正忙',
            cancelButtonName: '',
            confirmButtonName: '确定',
          ),
          outgoingPKBattleRequestRejectedCauseByLocalHostStateError:
              ZegoLiveStreamingDialogInfo(
            title: 'PK 发起失败',
            message: '只有在主播已开始直播时才能发起 PK',
            cancelButtonName: '',
            confirmButtonName: '确定',
          ),
          outgoingPKBattleRequestRejectedCauseByReject:
              ZegoLiveStreamingDialogInfo(
            title: 'PK 被拒绝',
            message:
                '主播 ${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} 拒绝了你的请求',
            cancelButtonName: '',
            confirmButtonName: '确定',
          ),

          /// 屏幕共享
          screenSharingTipText: '你正在共享屏幕',
          stopScreenSharingButtonText: '停止共享',

          /// 大厅相关
          livingFlagText: '直播中',
          enterLiveButtonText: '进入直播间',
        );
}
