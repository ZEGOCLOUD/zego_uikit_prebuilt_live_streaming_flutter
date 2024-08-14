// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_list/defines.dart';

class ZegoLiveStreamingOutsideLiveListController {
  ZegoOutsideRoomAudioVideoViewListController private;

  ZegoLiveStreamingOutsideLiveListController({
    List<ZegoLiveStreamingOutsideLiveListHost> hosts = const [],
  }) : private = ZegoOutsideRoomAudioVideoViewListController(streams: hosts);

  /// start play all hosts stream
  Future<bool> startPlayAll() async {
    return private.startPlayAll();
  }

  /// stop play all hosts stream
  Future<bool> stopPlayAll() async {
    return private.stopPlayAll();
  }

  /// start play target host
  Future<bool> startPlayOne(
    ZegoLiveStreamingOutsideLiveListHost host,
  ) async {
    return private.startPlayOne(ZegoOutsideRoomAudioVideoViewStreamUser(
      user: host.user,
      roomID: host.roomID,
    ));
  }

  /// stop play target host
  Future<bool> stopPlayOne(
    ZegoLiveStreamingOutsideLiveListHost host,
  ) async {
    return private.stopPlayOne(ZegoOutsideRoomAudioVideoViewStreamUser(
      user: host.user,
      roomID: host.roomID,
    ));
  }

  /// replay hosts to play
  void updateHosts(
    List<ZegoLiveStreamingOutsideLiveListHost> hosts, {
    bool startPlay = true,
  }) {
    private.updateStreams(hosts, startPlay: startPlay);
  }

  void addHost(
    ZegoLiveStreamingOutsideLiveListHost host, {
    bool startPlay = true,
  }) {
    private.addStream(host, startPlay: startPlay);
  }

  void removeHost(ZegoLiveStreamingOutsideLiveListHost host) {
    private.removeStream(host);
  }
}
