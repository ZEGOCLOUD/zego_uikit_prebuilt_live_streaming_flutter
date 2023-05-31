part of 'pk_impl.dart';

/// @nodoc
extension ZegoLiveStreamingPKBattleUtils on ZegoLiveStreamingPKBattleManager {
  Future<void> _waitCompleter(String apiName) async {
    if (stateTransformCompleter != null) {
      ZegoLoggerService.logInfo(
        '$apiName, waitCompleter start',
        tag: 'ZegoLiveStreamingPKBattleService',
        subTag: 'api',
      );
      await stateTransformCompleter!.future;
      ZegoLoggerService.logInfo(
        '$apiName, waitCompleter done',
        tag: 'ZegoLiveStreamingPKBattleService',
        subTag: 'api',
      );
    }
    stateTransformCompleter = Completer();
  }

  void _completeCompleter(String apiName) {
    ZegoLoggerService.logInfo(
      '$apiName, _completeCompleter',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    stateTransformCompleter?.complete();
    stateTransformCompleter = null;
  }
}
