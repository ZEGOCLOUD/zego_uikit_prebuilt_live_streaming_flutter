part of 'services.dart';

extension PKServiceCompleter on ZegoUIKitPrebuiltLiveStreamingPKServices {
  Future<void> waitCompleter(String apiName) async {
    if (_completer != null) {
      ZegoLoggerService.logInfo(
        '$apiName, start',
        tag: 'live.streaming.pk.services',
        subTag: 'waitCompleter',
      );
      await _completer!.future;
      ZegoLoggerService.logInfo(
        '$apiName, done',
        tag: 'live.streaming.pk.services',
        subTag: 'waitCompleter',
      );
    }
    _completer = Completer();
  }

  void completeCompleter(String apiName) {
    ZegoLoggerService.logInfo(
      'apiName:$apiName',
      tag: 'live.streaming.pk.services',
      subTag: 'completeCompleter',
    );
    _completer?.complete();
    _completer = null;
  }
}
