/// Represents the mini (minimized) state of the live streaming overlay.
///
/// This enum defines the possible states for the minimized live streaming view:
/// - [idle]: The live streaming is not in a minimized state.
/// - [living]: The live streaming is currently active in a minimized state.
/// - [minimizing]: The live streaming is in the process of being minimized.
enum ZegoLiveStreamingMiniOverlayPageState {
  /// Live streaming is not minimized (normal state).
  idle,

  /// Live streaming is active and minimized.
  living,

  /// Live streaming is being minimized.
  minimizing,
}
