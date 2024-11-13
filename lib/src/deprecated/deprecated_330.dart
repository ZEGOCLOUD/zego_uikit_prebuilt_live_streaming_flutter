// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';

const deprecatedTipsV330 = ', '
    'deprecated since 3.3.0, '
    'will be removed after 3.10.0'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/topics/Migration_v3.x-topic.html#330';

extension ZegoLiveStreamingPKBattleConfigDeprecatedExtension
    on ZegoLiveStreamingPKBattleConfig {
  @Deprecated('Use topPadding instead$deprecatedTipsV330')
  double? get pKBattleViewTopPadding => topPadding;

  @Deprecated('Use topPadding instead$deprecatedTipsV330')
  set pKBattleViewTopPadding(double? value) => topPadding = value;

  @Deprecated('Use topBuilder instead$deprecatedTipsV330')
  set pkBattleViewTopBuilder(ZegoLiveStreamingPKBattleViewBuilder? value) =>
      topBuilder = value;

  @Deprecated('Use topBuilder instead$deprecatedTipsV330')
  ZegoLiveStreamingPKBattleViewBuilder? get pkBattleViewTopBuilder =>
      topBuilder;

  @Deprecated('Use bottomBuilder instead$deprecatedTipsV330')
  set pkBattleViewBottomBuilder(ZegoLiveStreamingPKBattleViewBuilder? value) =>
      bottomBuilder = value;

  @Deprecated('Use bottomBuilder instead$deprecatedTipsV330')
  ZegoLiveStreamingPKBattleViewBuilder? get pkBattleViewBottomBuilder =>
      bottomBuilder;

  @Deprecated('Use foregroundBuilder instead$deprecatedTipsV330')
  set pkBattleViewForegroundBuilder(
    ZegoLiveStreamingPKBattleViewBuilder? value,
  ) =>
      foregroundBuilder = value;

  @Deprecated('Use foregroundBuilder instead$deprecatedTipsV330')
  ZegoLiveStreamingPKBattleViewBuilder? get pkBattleViewForegroundBuilder =>
      foregroundBuilder;
}
