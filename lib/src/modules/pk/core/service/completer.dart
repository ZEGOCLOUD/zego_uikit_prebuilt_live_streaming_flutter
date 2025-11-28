part of 'services.dart';

extension PKServiceCompleter on ZegoUIKitPrebuiltLiveStreamingPKServices {
  Future<void> waitCompleter(String apiName) async {
    if (_completer != null) {
      ZegoLoggerService.logInfo(
        '$apiName, waitCompleter start',
        tag: 'live.streaming.pk.services',
        subTag: 'service',
      );
      await _completer!.future;
      ZegoLoggerService.logInfo(
        '$apiName, waitCompleter done',
        tag: 'live.streaming.pk.services',
        subTag: 'service',
      );
    }
    _completer = Completer();
  }

  void completeCompleter(String apiName) {
    ZegoLoggerService.logInfo(
      '$apiName, _completeCompleter',
      tag: 'live.streaming.pk.services',
      subTag: 'service',
    );
    _completer?.complete();
    _completer = null;
  }
}
