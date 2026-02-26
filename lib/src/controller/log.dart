part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// Mixin that provides log control functionality for the live streaming controller.
///
/// Access via [ZegoUIKitPrebuiltLiveStreamingController.log].
mixin ZegoLiveStreamingControllerLog {
  final _logImpl = ZegoLiveStreamingControllerLogImpl();

  /// Returns the log implementation instance.
  ZegoLiveStreamingControllerLogImpl get log => _logImpl;
}

/// Here are the APIs related to user
class ZegoLiveStreamingControllerLogImpl {
  /// export logs
  ///
  /// [title] export title, defaults to current timestamp
  /// [content] export content description
  /// [fileName] Zip file name (without extension), defaults to current timestamp
  /// [fileTypes] List of file types to collect, defaults to `ZegoLogExporterFileType.txt, ZegoLogExporterFileType.log, ZegoLogExporterFileType.zip`
  /// [directories] List of directory types to collect, defaults to 5 log directories
  /// [onProgress] Optional progress callback, returns progress percentage (0.0 to 1.0)
  Future<bool> exportLogs({
    String? title,
    String? content,
    String? fileName,
    List<ZegoLogExporterFileType> fileTypes = const [
      ZegoLogExporterFileType.txt,
      ZegoLogExporterFileType.log,
      ZegoLogExporterFileType.zip
    ],
    List<ZegoLogExporterDirectoryType> directories = const [
      ZegoLogExporterDirectoryType.zegoUIKits,
      ZegoLogExporterDirectoryType.zimAudioLog,
      ZegoLogExporterDirectoryType.zimLogs,
      ZegoLogExporterDirectoryType.zefLogs,
      ZegoLogExporterDirectoryType.zegoLogs,
    ],
    void Function(double progress)? onProgress,
  }) async {
    return ZegoUIKit().exportLogs(
      title: title,
      content: content,
      fileName: fileName,
      fileTypes: fileTypes,
      directories: directories,
      onProgress: onProgress,
    );
  }
}
