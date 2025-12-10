// Project imports:
import 'defines.dart';
import 'inner_text.dart';

/// ZegoUIKitPrebuiltLiveStreaming हिंदी टेक्स्ट कॉन्फ़िगरेशन
///
/// उपयोग:
/// ```dart
/// ZegoUIKitPrebuiltLiveStreamingConfig(
///   innerText: ZegoUIKitPrebuiltLiveStreamingInnerTextHi(),
/// )
/// ```
class ZegoUIKitPrebuiltLiveStreamingInnerTextHi
    extends ZegoUIKitPrebuiltLiveStreamingInnerText {
  ZegoUIKitPrebuiltLiveStreamingInnerTextHi()
      : super(
          /// बटन टेक्स्ट
          disagreeButton: 'असहमत',
          agreeButton: 'सहमत',
          startLiveStreamingButton: 'शुरू करें',
          endCoHostButton: 'समाप्त करें',
          requestCoHostButton: 'सह-होस्टिंग के लिए आवेदन करें',
          cancelRequestCoHostButton: 'आवेदन रद्द करें',
          removeCoHostButton: 'सह-होस्ट हटाएं',
          cancelMenuDialogButton: 'रद्द करें',
          inviteCoHostButton:
              '${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} को सह-होस्टिंग के लिए आमंत्रित करें',
          removeUserMenuDialogButton:
              '${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} को कमरे से हटाएं',

          /// संकेत टेक्स्ट
          noHostOnline: 'कोई होस्ट ऑनलाइन नहीं है',
          memberListTitle: 'दर्शक',
          memberListRoleYou: 'आप',
          memberListRoleHost: 'होस्ट',
          memberListRoleCoHost: 'सह-होस्ट',

          /// Toast संकेत
          sendRequestCoHostToast:
              'आप सह-होस्टिंग के लिए आवेदन कर रहे हैं, कृपया पुष्टि की प्रतीक्षा करें',
          hostRejectCoHostRequestToast:
              'आपका सह-होस्टिंग आवेदन अस्वीकार कर दिया गया है',
          inviteCoHostFailedToast:
              'सह-होस्ट से कनेक्ट करने में विफल, कृपया पुनः प्रयास करें',
          repeatInviteCoHostFailedToast:
              'आपने आमंत्रण भेज दिया है, कृपया पुष्टि की प्रतीक्षा करें',
          messageEmptyToast: 'कुछ कहें...',
          userEnter: 'प्रवेश किया',
          userLeave: 'बाहर गए',
          audienceRejectInvitationToast:
              '${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} ने सह-होस्टिंग आमंत्रण अस्वीकार कर दिया',
          requestCoHostFailedToast: 'सह-होस्टिंग के लिए आवेदन विफल',

          /// अनुमति डायलॉग
          cameraPermissionSettingDialogInfo: ZegoLiveStreamingDialogInfo(
            title: 'कैमरा का उपयोग नहीं कर सकते!',
            message: 'कृपया सिस्टम सेटिंग्स में कैमरा अनुमति सक्षम करें!',
            cancelButtonName: 'रद्द करें',
            confirmButtonName: 'सेटिंग्स',
          ),
          microphonePermissionSettingDialogInfo: ZegoLiveStreamingDialogInfo(
            title: 'माइक्रोफोन का उपयोग नहीं कर सकते!',
            message: 'कृपया सिस्टम सेटिंग्स में माइक्रोफोन अनुमति सक्षम करें!',
            cancelButtonName: 'रद्द करें',
            confirmButtonName: 'सेटिंग्स',
          ),

          /// सह-होस्टिंग संबंधी डायलॉग
          receivedCoHostRequestDialogInfo: ZegoLiveStreamingDialogInfo(
            title: 'सह-होस्टिंग अनुरोध',
            message:
                '${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} आपके साथ सह-होस्टिंग करना चाहता/चाहती है',
            cancelButtonName: 'असहमत',
            confirmButtonName: 'सहमत',
          ),
          receivedCoHostInvitationDialogInfo: ZegoLiveStreamingDialogInfo(
            title: 'आमंत्रण',
            message: 'होस्ट आपको सह-होस्टिंग के लिए आमंत्रित कर रहा है',
            cancelButtonName: 'असहमत',
            confirmButtonName: 'सहमत',
          ),
          endConnectionDialogInfo: ZegoLiveStreamingDialogInfo(
            title: 'कनेक्शन समाप्त करें',
            message: 'क्या आप सह-होस्टिंग समाप्त करना चाहते हैं?',
            cancelButtonName: 'रद्द करें',
            confirmButtonName: 'ठीक है',
          ),

          /// ऑडियो इफेक्ट संबंधी
          audioEffectTitle: 'ऑडियो इफेक्ट',
          audioEffectReverbTitle: 'रिवर्ब',
          audioEffectVoiceChangingTitle: 'वॉइस चेंजर',
          beautyEffectTitle: 'ब्यूटी इफेक्ट',

          /// वॉइस चेंजर इफेक्ट
          voiceChangerNoneTitle: 'कोई नहीं',
          voiceChangerLittleBoyTitle: 'छोटा लड़का',
          voiceChangerLittleGirlTitle: 'छोटी लड़की',
          voiceChangerDeepTitle: 'गहरा',
          voiceChangerCrystalClearTitle: 'स्पष्ट',
          voiceChangerRobotTitle: 'रोबोट',
          voiceChangerEtherealTitle: 'अलौकिक',
          voiceChangerFemaleTitle: 'महिला',
          voiceChangerMaleTitle: 'पुरुष',
          voiceChangerOptimusPrimeTitle: 'ऑप्टिमस प्राइम',
          voiceChangerCMajorTitle: 'C मेजर',
          voiceChangerAMajorTitle: 'A मेजर',
          voiceChangerHarmonicMinorTitle: 'हार्मोनिक माइनर',

          /// रिवर्ब इफेक्ट
          reverbTypeNoneTitle: 'कोई नहीं',
          reverbTypeKTVTitle: 'KTV',
          reverbTypeHallTitle: 'हॉल',
          reverbTypeConcertTitle: 'कॉन्सर्ट',
          reverbTypeRockTitle: 'रॉक',
          reverbTypeSmallRoomTitle: 'छोटा कमरा',
          reverbTypeLargeRoomTitle: 'बड़ा कमरा',
          reverbTypeValleyTitle: 'घाटी',
          reverbTypeRecordingStudioTitle: 'रिकॉर्डिंग स्टूडियो',
          reverbTypeBasementTitle: 'तहखाना',
          reverbTypePopularTitle: 'पॉप',
          reverbTypeGramophoneTitle: 'ग्रामोफोन',

          /// ब्यूटी इफेक्ट
          beautyEffectTypeWhitenTitle: 'गोरा करना',
          beautyEffectTypeRosyTitle: 'गुलाबी',
          beautyEffectTypeSmoothTitle: 'चिकना',
          beautyEffectTypeSharpenTitle: 'तेज़ करना',
          beautyEffectTypeNoneTitle: 'कोई नहीं',

          /// PK संबंधी डायलॉग
          incomingPKBattleRequestReceived: ZegoLiveStreamingDialogInfo(
            title: 'PK बैटल अनुरोध',
            message:
                '${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} ने आपको PK बैटल अनुरोध भेजा है',
            cancelButtonName: 'अस्वीकार करें',
            confirmButtonName: 'स्वीकार करें',
          ),
          coHostEndCauseByHostStartPK: ZegoLiveStreamingDialogInfo(
            title: 'होस्ट ने PK बैटल शुरू की',
            message: 'आपकी सह-होस्टिंग समाप्त हो गई है',
            cancelButtonName: '',
            confirmButtonName: 'ठीक है',
          ),
          pkBattleEndedCauseByAnotherHost: ZegoLiveStreamingDialogInfo(
            title: 'PK बैटल समाप्त',
            message:
                '${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} ने PK बैटल समाप्त कर दी',
            cancelButtonName: '',
            confirmButtonName: 'ठीक है',
          ),
          outgoingPKBattleRequestRejectedCauseByError:
              ZegoLiveStreamingDialogInfo(
            title: 'PK बैटल शुरू करने में विफल',
            message:
                'त्रुटि कोड: ${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1}',
            cancelButtonName: '',
            confirmButtonName: 'ठीक है',
          ),
          outgoingPKBattleRequestRejectedCauseByBusy:
              ZegoLiveStreamingDialogInfo(
            title: 'PK बैटल शुरू करने में विफल',
            message:
                'होस्ट ${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} व्यस्त है',
            cancelButtonName: '',
            confirmButtonName: 'ठीक है',
          ),
          outgoingPKBattleRequestRejectedCauseByLocalHostStateError:
              ZegoLiveStreamingDialogInfo(
            title: 'PK बैटल शुरू करने में विफल',
            message:
                'आप केवल तभी PK बैटल शुरू कर सकते हैं जब होस्ट ने लाइव स्ट्रीम शुरू की हो',
            cancelButtonName: '',
            confirmButtonName: 'ठीक है',
          ),
          outgoingPKBattleRequestRejectedCauseByReject:
              ZegoLiveStreamingDialogInfo(
            title: 'PK बैटल अस्वीकार',
            message:
                'होस्ट ${ZegoUIKitPrebuiltLiveStreamingInnerText.param_1} ने आपके अनुरोध को अस्वीकार कर दिया',
            cancelButtonName: '',
            confirmButtonName: 'ठीक है',
          ),
          hostResumePKConfirmDialogInfo: ZegoLiveStreamingDialogInfo(
            title: 'लाइव स्ट्रीमिंग अप्रत्याशित रूप से बाधित हो गई',
            message: 'लाइव स्ट्रीमिंग अप्रत्याशित रूप से बाधित हो गई',
            cancelButtonName: 'रद्द करें',
            confirmButtonName: 'लाइव स्ट्रीमिंग फिर से शुरू करें',
          ),

          /// स्क्रीन शेयरिंग
          screenSharingTipText: 'आप स्क्रीन साझा कर रहे हैं',
          stopScreenSharingButtonText: 'साझा करना बंद करें',

          /// हॉल संबंधी
          livingFlagText: 'लाइव',
          enterLiveButtonText: 'लाइव रूम में प्रवेश करें',
        );
}
