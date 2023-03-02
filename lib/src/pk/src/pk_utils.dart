part of 'pk_impl.dart';

extension ZegoLiveStreamingPKBattleUtils on ZegoLiveStreamingPKBattleManager {
  Future<void> _waitCompleter(String apiName) async {
    if (stateTrancformCompleter != null) {
      ZegoLoggerService.logInfo(
        '$apiName, waitCompleter start',
        tag: 'ZegoLiveStreamingPKBattleService',
        subTag: 'api',
      );
      await stateTrancformCompleter!.future;
      ZegoLoggerService.logInfo(
        '$apiName, waitCompleter done',
        tag: 'ZegoLiveStreamingPKBattleService',
        subTag: 'api',
      );
    }
    stateTrancformCompleter = Completer();
  }

  void _completeCompleter(String apiName) {
    ZegoLoggerService.logInfo(
      '$apiName, _completeCompleter',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    stateTrancformCompleter?.complete();
    stateTrancformCompleter = null;
  }
}
