# Minimization

- [ZegoLiveStreamingMiniOverlayPageState](#zegolivstreamingminioverlaypagestate)
- [ZegoLiveStreamingControllerMinimizing](#zegolivstreamingcontrollerminimizing)

---

## ZegoLiveStreamingMiniOverlayPageState

Mini overlay page state.

- **Description**
  - Represents the mini (minimized) state of the live streaming overlay.
  - This enum defines the possible states for the minimized live streaming view.
- **Enum Values**

| Name | Description | Value |
| :--- | :--- | :--- |
| invisible | Not visible. | `0` |
| minimized | Minimized state. | `1` |
| showed | Showing state. | `2` |

- **Note**
  - The values in the documentation may differ from the actual enum values. Please refer to the source code for the exact values.

---

## ZegoLiveStreamingControllerMinimizing

### state
  - **Description**
    - Get current minimization state.
  - **Prototype**
    ```dart
    ZegoLiveStreamingMiniOverlayPageState get state
    ```
  - **Example**
    ```dart
    var state = ZegoUIKitPrebuiltLiveStreamingController().minimize.state;
    ```

### isMinimizing
  - **Description**
    - Is it currently in the minimization state or not.
  - **Prototype**
    ```dart
    bool get isMinimizing
    ```

### isMinimizingNotifier
  - **Description**
    - Minimization state notifier.
  - **Prototype**
    ```dart
    ValueNotifier<bool> get isMinimizingNotifier
    ```

### restore
  - **Description**
    - Restore the minimized window.
  - **Prototype**
    ```dart
    bool restore(BuildContext context, {bool rootNavigator = true, bool withSafeArea = false})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().minimize.restore(context);
    ```

### minimize
  - **Description**
    - Minimize the window.
  - **Prototype**
    ```dart
    bool minimize(BuildContext context, {bool rootNavigator = true})
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().minimize.minimize(context);
    ```

### hide
  - **Description**
    - Hide the minimized window.
  - **Prototype**
    ```dart
    void hide()
    ```
  - **Example**
    ```dart
    ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
    ```
