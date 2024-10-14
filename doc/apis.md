
- [ZegoUIKitPrebuiltLiveStreaming](#zegouikitprebuiltlivestreaming)
- [ZegoUIKitPrebuiltLiveStreamingController](#zegouikitprebuiltlivestreamingcontroller)
  - [leave](#leave)
  - [pk](#pk)
    - [stateNotifier](#statenotifier)
    - [isInPK](#isinpk)
    - [mutedUsersNotifier](#mutedusersnotifier)
    - [getHosts](#gethosts)
    - [sendRequest](#sendrequest)
    - [cancelRequest](#cancelrequest)
    - [acceptRequest](#acceptrequest)
    - [rejectRequest](#rejectrequest)
    - [quit](#quit)
    - [stop](#stop)
    - [muteAudios](#muteaudios)
  - [swiping](#swiping)
    - [previous](#previous)
    - [next](#next)
    - [jumpTo](#jumpto)
  - [coHost](#cohost)
    - [audienceLocalConnectStateNotifier](#audiencelocalconnectstatenotifier)
    - [requestCoHostUsersNotifier](#requestcohostusersnotifier)
    - [hostNotifier](#hostnotifier)
    - [audienceSendCoHostRequest](#audiencesendcohostrequest)
    - [audienceCancelCoHostRequest](#audiencecancelcohostrequest)
    - [startCoHost](#startcohost)
    - [stopCoHost](#stopcohost)
    - [hostAgreeCoHostRequest](#hostagreecohostrequest)
    - [hostRejectCoHostRequest](#hostrejectcohostrequest)
    - [removeCoHost](#removecohost)
    - [hostSendCoHostInvitationToAudience](#hostsendcohostinvitationtoaudience)
    - [audienceAgreeCoHostInvitation](#audienceagreecohostinvitation)
    - [audienceRejectCoHostInvitation](#audiencerejectcohostinvitation)
  - [message](#message)
    - [send](#send)
    - [list](#list)
    - [stream](#stream)
    - [sendFakeMessage](#sendfakemessage)
  - [minimize](#minimize)
    - [state](#state)
    - [isMinimizingNotifier(ValueNotifier)](#isminimizingnotifiervaluenotifier)
    - [isMinimizing](#isminimizing)
    - [restore](#restore)
    - [minimize](#minimize-1)
    - [hide](#hide)
  - [pip](#pip)
    - [enable](#enable)
    - [enableWhenBackground](#enablewhenbackground)
    - [cancelBackground](#cancelbackground)
  - [screenSharing](#screensharing)
    - [viewController](#viewcontroller)
    - [showViewInFullscreenMode](#showviewinfullscreenmode)
  - [audioVideo](#audiovideo)
    - [microphone](#microphone)
      - [localState](#localstate)
      - [localStateNotifier](#localstatenotifier)
      - [state](#state-1)
      - [stateNotifier](#statenotifier-1)
      - [turnOn](#turnon)
      - [switchState](#switchstate)
    - [camera](#camera)
      - [localState](#localstate-1)
      - [localStateNotifier](#localstatenotifier-1)
      - [state](#state-2)
      - [stateNotifier](#statenotifier-2)
      - [turnOn](#turnon-1)
      - [switchState](#switchstate-1)
  - [room](#room)
    - [property](#property)
      - [updateProperty/updateProperties](#updatepropertyupdateproperties)
      - [deleteProperties](#deleteproperties)
      - [queryProperties](#queryproperties)
      - [propertiesStream](#propertiesstream)
    - [command](#command)
      - [sendCommand](#sendcommand)
      - [commandReceivedStream](#commandreceivedstream)
    - [user](#user)
      - [countNotifier](#countnotifier)
      - [stream](#stream-1)
      - [remove](#remove)
      - [addFakeUser](#addfakeuser)
      - [removeFakeUser](#removefakeuser)

---
# ZegoUIKitPrebuiltLiveStreaming

>
> Live Streaming Widget.
>
> You can embed this widget into any page of your project to integrate the functionality of a live streaming.
>
> - function prototype:
>
>```dart
>class ZegoUIKitPrebuiltLiveStreaming extends StatefulWidget {
>  const ZegoUIKitPrebuiltLiveStreaming({
>    Key? key,
>    required this.appID,
>    required this.appSign,
>    required this.userID,
>    required this.userName,
>    required this.liveID,
>    required this.config,
>    this.events,
>  }) : super(key: key);
>
>  /// You can create a project and obtain an appID from the [ZEGOCLOUD Admin >Console](https://console.zegocloud.com).
>  final int appID;
>
>  /// You can create a project and obtain an appSign from the [ZEGOCLOUD >Admin Console](https://console.zegocloud.com).
>  final String appSign;
>
>  /// The ID of the currently logged-in user.
>  /// It can be any valid string.
>  /// Typically, you would use the ID from your own user system, such as >Firebase.
>  final String userID;
>
>  /// The name of the currently logged-in user.
>  /// It can be any valid string.
>  /// Typically, you would use the name from your own user system, such as >Firebase.
>  final String userName;
>
>  /// You can customize the live ID arbitrarily,
>  /// just need to know: users who use the same live ID can talk with each >other.
>  final String liveID;
>
>  /// Initialize the configuration for the live-streaming.
>  final ZegoUIKitPrebuiltLiveStreamingConfig config;
>
>  /// You can listen to events that you are interested in here.
>  final ZegoUIKitPrebuiltLiveStreamingEvents? events;
>}
>```

# ZegoUIKitPrebuiltLiveStreamingController

>
> These APIs are categorized as pk, swiping, connect, connect invite, message, minimize, and screen sharing.
>
> To make a function call, use like > `ZegoUIKitPrebuiltLiveStreamingController().${category_name}. ${specific_function_name}`, just like:
> ```dart
> ZegoUIKitPrebuiltLiveStreamingController().message.send(...);
> ```

## leave

>
> This function is used to end the Live Streaming.
>
> You can pass the `context` for any necessary pop-ups or page transitions.
> By using the `showConfirmation` parameter, you can control whether to display a confirmation dialog to confirm ending the Live Streaming.
>
> This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the `ZegoUIKitPrebuiltLiveStreamingEvents.onLeaveConfirmation`, `ZegoUIKitPrebuiltLiveStreamingEvents.onLiveStreamingEnded` settings in the config.
>
> - function prototype:
>
> ```dart
> Future<bool> leave(
>   BuildContext context, {
>   bool showConfirmation = false,
> }) async
> ```

## pk

>
> - ZegoLiveStreamingPKServiceResult:
>
> ```dart
> /// result of request in pk service
> class ZegoLiveStreamingPKServiceResult {
>   final List<String> errorUserIDs;
>   final PlatformException? error;
> }
> ```

### stateNotifier

>
> pk state notifier
>
> - function prototype:
>
> ```dart
> ValueNotifier<ZegoLiveStreamingPKBattleState> get stateNotifier
> ```

### isInPK

>
> is in pk or not
>
> - function prototype:
>
> ```dart
> bool get isInPK
> ```

### mutedUsersNotifier

>
> mute users notifier
>
> - function prototype:
>
> ```dart
> ValueNotifier<List<String>> get mutedUsersNotifier
> ```

### getHosts

>
> the host list in invitation or PK.
>
> - function prototype:
>
> ```dart
> List<AdvanceInvitationUser> getHosts(String requestID)
> ```
>
> - AdvanceInvitationUser:
> ```dart
> /// invitation user info in advance mode
> class AdvanceInvitationUser {
>   String userID;
>   AdvanceInvitationState state;
>   String extendedData;
> }
> ```
>
> - AdvanceInvitationState:
> ```dart
> /// invitation state in advance mode
> enum AdvanceInvitationState {
>   idle,
>   error,
>   waiting,
>   accepted,
>   rejected,
>   cancelled,
> }
> ```

### sendRequest

>
> Inviting hosts for a PK.
>
> You will need to specify the `targetHostIDs` you want to connect with.
>
> Remember the hosts you invite must has started a live stream, otherwise, an error will return via the method you called.
>
> You can used `timeout` to set the timeout duration of the PK battle request you sent.
>After it timed out, the host who sent the request will receive a callback notification via the `ZegoUIKitPrebuiltLiveStreamingPKEvents.onOutgoingPKBattleRequestTimeout`.
>
> If you want to customize the info that you want the host you invited to receive, you can set `customData`, and the invited host will receive via `ZegoUIKitPrebuiltLiveStreamingPKEvents
.onIncomingPKBattleRequestReceived`.
>
> If you want the remote host to directly accept without a confirmation dialog before entering the PK, you can set `isAutoAccept` to true.
>
> Please note that within the same PK session, this value ONLY takes effect the FIRST time it is set (after the first acceptance of the invitation), subsequent invitations will use the value set during the
> first acceptance.
>
> - function prototype:
>
> ```dart
> Future<ZegoLiveStreamingPKServiceSendRequestResult> sendRequest({
>   required List<String> targetHostIDs,
>   int timeout = 60,
>   String customData = '',
>   bool isAutoAccept = false,
> }) async
> ```
>
> - ZegoLiveStreamingPKServiceSendRequestResult:
>
> ```dart
> /// result of send request in pk service
> class ZegoLiveStreamingPKServiceSendRequestResult {
>   /// The ID of the current PK session
>   final String requestID;
> 
>   final List<String> errorUserIDs;
>   final PlatformException? error;
> }
> ```

### cancelRequest

>
> Cancel the PK invitation to `targetHostIDs`.
>
> You can provide your reason by attaching `customData`.
>
> Please note that, if the PK has already started (and any invited host has accepted), the PK invitation cannot be cancelled.
>
> - function prototype:
>
> ```dart
>   Future<ZegoLiveStreamingPKServiceResult> cancelRequest({
>   required List<String> targetHostIDs,
>   String customData = '',
> })
> ```

### acceptRequest

>
> Accept the PK invitation from the `targetHost`, which invitation ID is `requestID`.
>
> If exceeds `timeout` seconds, the accept will be considered timed out.
> You can provide your reason by attaching `customData`.
>
> - function prototype:
>
> ```dart
> Future<ZegoLiveStreamingPKServiceResult> acceptRequest({
>   required String requestID,
>   required ZegoUIKitPrebuiltLiveStreamingPKUser targetHost,
>   int timeout = 60,
>   String customData = '',
> }) async
> ```

### rejectRequest

>
> Rejects the PK invitation from the `targetHost`, which invitation ID is `requestID`.
>
> If the rejection exceeds `timeout` seconds, the rejection will be considered timed out.
> You can provide your reason by attaching `customData`.
>
> - function prototype:
>
> ```dart
> Future<ZegoLiveStreamingPKServiceResult> rejectRequest({
>   required String requestID,
>   required String targetHostID,
>   int timeout = 60,
>   String customData = '',
> }) async
> ```

### quit

>
> Quit PK on your own.
>
> only pop the PK View on your own end, other PK participants decide on their own.
>
> - function prototype:
>
> ```dart
> Future<ZegoLiveStreamingPKServiceResult> quit()
> ```

### stop

>
> Stop PK to all pk-hosts, only the PK Initiator can stop it.
>
> The PK is over and all participants will exit the PK View.
>
> - function prototype:
>
> ```dart
> Future<ZegoLiveStreamingPKServiceResult> stop()
> ```

### muteAudios

>
> Silence the `targetHostIDs` in PK, local host and audience in the live streaming won't hear the muted host's voice.
>
> If you want to cancel mute, set `isMute` to false.
>
> - function prototype:
>
> ```dart
>   Future<bool> muteAudios({
>   required List<String> targetHostIDs,
>   required bool isMute,
> }) async
> ```

## swiping

### previous

>
> swiping to previous live streaming which query from `ZegoLiveStreamingSwipingConfig.requirePreviousLiveID`
>
> - function prototype:
>
> ```dart
> bool previous()
> ```

### next

>
> swiping to next live streaming which query from `ZegoLiveStreamingSwipingConfig.requireNextLiveID`
>
> - function prototype:
>
> ```dart
> bool next()
> ```

### jumpTo

>
> swiping to live streaming of `targetLiveID`
>
> - function prototype:
>
> ```dart
> bool jumpTo(String targetLiveID)
> ```

## coHost

### audienceLocalConnectStateNotifier

>
> for audience: current audience connection state, audience or co-host(connected)
>
> - function prototype:
>
> ```dart
> ValueNotifier<ZegoLiveStreamingAudienceConnectState> get audienceLocalConnectStateNotifier
> ```
>
> - ZegoLiveStreamingAudienceConnectState:
>
> ```dart
> /// only for audience or co-host, connection state
> enum ZegoLiveStreamingAudienceConnectState {
>   ///
>   idle,
> 
>   /// requesting to be a co-host, wait response from host
>   connecting,
> 
>   /// be a co-host now, host agree the co-host request
>   connected,
> }
> ```

### requestCoHostUsersNotifier

>
> for host: current requesting co-host's audiences
>
> - function prototype:
>
> ```dart
> ValueNotifier<List<ZegoUIKitUser>> get requestCoHostUsersNotifier
> ```

### hostNotifier

>
> host changed notifier
>
> - function prototype:
>
> ```dart
> ValueNotifier<ZegoUIKitUser?> get hostNotifier
> ```

### audienceSendCoHostRequest

>
> audience requests to become a co-host by sending a request to the host.
>
> if you want audience be co-host without request to the host, use `startCoHost`
>
> If `withToast` is set to true, a toast message will be displayed after the request succeeds or fails.
>
> return a `Future` that representing whether the request was successful.
>
> - function prototype:
>
> ```dart
> Future<bool> audienceSendCoHostRequest({
>   bool withToast = false,
>   String customData = '',
> }) async
> ```

### audienceCancelCoHostRequest

>
> audience cancels the co-host request to the host.
>
> return A `Future` that representing whether the request was successful.
>
> - function prototype:
>
> ```dart
> Future<bool> audienceCancelCoHostRequest({
>   String customData = '',
> }) async
> ```

### startCoHost

>
> audience switch to be an co-host directly, without request to host
>
> if you want audience be co-host with request to the host, use `audienceSendCoHostRequest`
>
> return A `Future` that representing whether the request was successful.
>
> - function prototype:
>
> ```dart
> Future<bool> startCoHost() async
> ```

### stopCoHost

>
> co-host ends the connection and switches to the audience role voluntarily.
>
> If `showRequestDialog` is true, a confirmation dialog will be displayed to prevent accidental clicks.
> return A `Future` that representing whether the request was successful.
>
> - function prototype:
>
> ```dart
> Future<bool> stopCoHost({
>   bool showRequestDialog = true,
> })
> ```

### hostAgreeCoHostRequest

>
> host approve the co-host request made by `audience`.
>
> return A `Future` that representing whether the request was successful.
>
> - function prototype:
>
> ```dart
> Future<bool> hostAgreeCoHostRequest(
>  ZegoUIKitUser audience, {
>  String customData = '',
> }) async
> ```

### hostRejectCoHostRequest

>
> host reject the co-host request made by `audience`.
>
> return A `Future` that representing whether the request was successful.
>
> - function prototype:
>
> ```dart
> Future<bool> hostRejectCoHostRequest(
>  ZegoUIKitUser audience, {
>  String customData = '',
> }) async
> ```

### removeCoHost

>
> host remove the co-host, make `coHost` to be a audience
>
> return A `Future` that representing whether the request was successful.
>
> - function prototype:
>
> ```dart
> Future<bool> removeCoHost(
>  ZegoUIKitUser coHost, {
>  String customData = '',
> }) async
> ```

### hostSendCoHostInvitationToAudience

>
> host invite `audience` to be a co-host
>
> If `withToast` is set to true, a toast message will be displayed after the request succeeds or fails.
>
> return A `Future` that representing whether the request was successful.
>
> - function prototype:
>
> ```dart
> Future<bool> hostSendCoHostInvitationToAudience(
>   ZegoUIKitUser audience, {
>   bool withToast = false,
>   int timeoutSecond = 60,
>   String customData = '',
> }) async
> ```

### audienceAgreeCoHostInvitation

>
> audidenct agree co-host invitation from host
>
> - function prototype:
>
> ```dart
> Future<bool> audienceAgreeCoHostInvitation({
>   bool withToast = false,
    String customData = '',
> }) async
> ```

### audienceRejectCoHostInvitation

>
> audidenct reject co-host invitation from host
>
> - function prototype:
>
> ```dart
> Future<bool> audienceRejectCoHostInvitation({
>    String customData = '',
> }) async
> ```

## message

### send

>
> sends the chat message, return a `Future` that representing whether the  request was successful.
>
> - function prototype:
>
> ```dart
> Future<bool> send(String message) async
> ```

### list

>
> Retrieves a list of chat messages that already exist in the room.
>
> return a `List` of `ZegoInRoomMessage` objects representing the chat messages that already exist in the room.
>
> - function prototype:
>
> ```dart
> List<ZegoInRoomMessage> list()
> ```
>
> - ZegoInRoomMessage:
> ```dart
> /// in-room message
> class ZegoInRoomMessage {
>   /// If the local message sending fails, then the message ID at this time is unreliable, and is a negative sequential value.
>   int messageID;
> 
>   /// message sender.
>   ZegoUIKitUser user;
> 
>   /// message content.
>   String message;
> 
>   /// message attributes
>   Map<String, String> attributes;
> 
>   /// The timestamp at which the message was sent.
>   /// You can format the timestamp, which is in milliseconds since epoch, using DateTime.fromMillisecondsSinceEpoch(timestamp).
>   int timestamp;
> 
>   var state = ValueNotifier<ZegoInRoomMessageState>(ZegoInRoomMessageState.success);
> }
> ```

### stream

>
> Retrieves a list stream of chat messages that already exist in the room.
> the stream will dynamically update when new chat messages are received,
> and you can use a `StreamBuilder` to listen to it and update the UI in
real time.
>
> @return a `List` of `ZegoInRoomMessage` objects representing the chat
messages that already exist in the room.
>
> - function prototype:
>
> ```dart
> Stream<List<ZegoInRoomMessage>> stream({bool includeFakeMessage = true,})
> ```
>
> - Example
>
> ```dart
> ..foreground = Positioned(
>     left: 10,
>     bottom: 50,
>     child: StreamBuilder<List<ZegoInRoomMessage>>(
>       stream: ZegoUIKitPrebuiltLiveStreamingController().message.stream(),
>       builder: (context, snapshot) {
>         final messages = snapshot.data ?? <ZegoInRoomMessage>[];
>
>         return Container(
>           width: 200,
>           height: 200,
>           decoration: BoxDecoration(
>             color: Colors.white.withOpacity(0.2),
>           ),
>           child: ListView.builder(
>             itemCount: messages.length,
>             itemBuilder: (context, index) {
>               final message = messages[index];
>               return Text('${message.user.name}: ${message.message}');
>             },
>           ),
>         );
>       },
>     ),
>   )
> ```

### sendFakeMessage

>
> send fake message in message list.
> please make sure [message].timestamp has valid value.
>
> - function prototype:
>
> ```dart
> void sendFakeMessage({
>     required ZegoUIKitUser sender,
>     required String message,
>     Map<String, String>? attributes,
> })
> ```

## minimize

### state

>
> minimize state
>
> - function prototype:
>
> ```dart
> PrebuiltLiveStreamingMiniOverlayPageState get state
> ```
>
> - PrebuiltLiveStreamingMiniOverlayPageState:
>
> ```dart
> enum PrebuiltLiveStreamingMiniOverlayPageState {
>   idle,
>   living,
>   minimizing,
> }
> ```

### isMinimizingNotifier(ValueNotifier<bool>)

> is it currently in the minimized state or not
>
> - example:
>
> ```dart
> ValueListenableBuilder<bool>(
>   valueListenable:
>   ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizingNotifier,
>   builder: (context, isMinimized, _) {
>     ...
>   },
> )
> ```

### isMinimizing

>
> Is it currently in the minimized state or not
>
> - function prototype:
>
> ```dart
> bool get isMinimizing
> ```

### restore

>
> restore the ZegoUIKitPrebuiltLiveStreaming from minimize
>
> - function prototype:
>
> ```dart
> bool restore(
>   BuildContext context, {
>   bool rootNavigator = true,
>   bool withSafeArea = false,
> })
> ```

### minimize

>
> To minimize the ZegoUIKitPrebuiltLiveStreaming
>
> - function prototype:
>
> ```dart
> bool minimize(
>   BuildContext context, {
>   bool rootNavigator = true,
> })
> ```

### hide

>
> if live streaming ended in minimizing state, not need to navigate, just hide the minimize widget.
>
>
> ```dart
> void hide()
> ```

## pip

### enable

>
> - function prototype:
>
> ```dart
> Future<PiPStatus> enable({
>   int aspectWidth = 9,
>   int aspectHeight = 16,
> }) async
> ```

### enableWhenBackground

>
> - function prototype:
>
> ```dart
> Future<PiPStatus> enableWhenBackground({
>   int aspectWidth = 9,
>   int aspectHeight = 16,
> }) async
> ```

### cancelBackground

>
> - function prototype:
>
> ```dart
> Future<PiPStatus> cancelBackground() async
> ```

## screenSharing

### viewController

### showViewInFullscreenMode

>
> This function is used to specify whether a certain user enters or exits full-screen mode during screen sharing.
>
> You need to provide the user's ID `userID` to determine which user to perform the operation on.
>
> By using a boolean value `isFullscreen`, you can specify whether the user enters or exits full-screen mode.
>
> - function prototype:
>
> ```dart
> void showViewInFullscreenMode(String userID, bool isFullscreen)
> ```

## audioVideo

> APIs related to audio video

### microphone

> microphone series APIs

#### localState

>
> microphone state of local user
>
> - function prototype:
>
> ```dart
> bool get localState
> ```

#### localStateNotifier

>
> microphone state notifier of local user
>
> - function prototype:
>
> ```dart
> ValueNotifier<bool> get localStateNotifier
> ```

#### state

>
> microphone state of `userID`
>
> - function prototype:
>
> ```dart
> bool state(String userID)
> ```

#### stateNotifier

>
> microphone state notifier of `userID`
>
> - function prototype:
>
> ```dart
> ValueNotifier<bool> stateNotifier(String userID)
> ```

#### turnOn

>
> turn on/off `userID` microphone, if `userID` is empty, then it refers to local user
>
> - function prototype:
>
> ```dart
> void turnOn(bool isOn, {String? userID})
> ```

#### switchState

>
> switch `userID` microphone state, if `userID` is empty, then it refers to local user
>
> - function prototype:
>
> ```dart
> void switchState({String? userID})
> ```

### camera

> camera series APIs

#### localState

>
> camera state of local user
>
> - function prototype:
>
> ```dart
> bool get localState
> ```

#### localStateNotifier

>
> camera state notifier of local user
>
> - function prototype:
>
> ```dart
> ValueNotifier<bool> get localStateNotifier
> ```

#### state

>
> camera state of `userID`
>
> - function prototype:
>
> ```dart
> bool state(String userID)
> ```

#### stateNotifier

>
> camera state notifier of `userID`
>
> - function prototype:
>
> ```dart
> ValueNotifier<bool> stateNotifier(String userID)
> ```

#### turnOn

>
> turn on/off `userID` camera, if `userID` is empty, then it refers to local user
>
> - function prototype:
>
> ```dart
> void turnOn(bool isOn, {String? userID})
> ```

#### switchState

>
> void switchState({String? userID})
>
> - function prototype:
>
> ```dart
> switch `userID` camera state, if `userID` is empty, then it refers to local user
> ```


## room

### property

#### updateProperty/updateProperties

>
> add/update room properties
>
> - function prototype:
>
> ```dart
> Future<bool> updateProperty({
>   required String roomID,
>   required String key,
>   required String value,
>   bool isForce = false,
>   bool isDeleteAfterOwnerLeft = false,
>   bool isUpdateOwner = false,
> }) async
>
> Future<bool> updateProperties({
>  required String roomID,
>  required Map<String, String> roomProperties,
>  bool isForce = false,
>  bool isDeleteAfterOwnerLeft = false,
>  bool isUpdateOwner = false,
>}) async
> ```

#### deleteProperties

>
> delete room properties
>
> - function prototype:
>
> ```dart
> Future<bool> deleteProperties({
>   required String roomID,
>   required List<String> keys,
>   bool isForce = false,
> }) async
> ```

#### queryProperties

>
> query room properties
>
> - function prototype:
>
> ```dart
> Future<Map<String, String>> queryProperties({
>   required String roomID,
> }) async
> ```

#### propertiesStream

>
> room properties stream notify
>
> - function prototype:
>
> ```dart
> Stream<ZegoSignalingPluginRoomPropertiesUpdatedEvent> propertiesStream()
> 
> class ZegoSignalingPluginRoomPropertiesUpdatedEvent {
>   final String roomID;
>   final Map<String, String> setProperties;
>   final Map<String, String> deleteProperties;
> }
> ```

### command

#### sendCommand

>
> send room command

>
>
>
> - function prototype:
>
> ```dart
>  Future<bool> sendCommand({
>    required String roomID,
>    required Uint8List command,
>  }) async
> ```

#### commandReceivedStream

>
> room command stream notify
>
> - function prototype:
>
> ```dart
> Stream<ZegoSignalingPluginInRoomCommandMessageReceivedEvent> commandReceivedStream()
>
>
> class ZegoSignalingPluginInRoomCommandMessageReceivedEvent {
>   final List<ZegoSignalingPluginInRoomCommandMessage> messages;
>   final String roomID;
> }
> 
> class ZegoSignalingPluginInRoomCommandMessage {
>   /// If you have a string encoded in UTF-8 and want to convert a Uint8List
>   /// to that string, you can use the following method:
>   ///
>   /// import 'dart:convert';
>   /// import 'dart:typed_data';
>   ///
>   /// String result = utf8.decode(commandMessage.message); // Convert the Uint8List to a string
>   ///
>   final Uint8List message;
> 
>   final String senderUserID;
>   final int timestamp;
>   final int orderKey;
> }
> ```

### user

#### countNotifier

>
> user list count notifier
>
> - function prototype:
>
> ```dart
> ValueNotifier<int> get countNotifier
> ```

#### stream

>
> user list stream
>
> - function prototype:
>
> ```dart
>   Stream<List<ZegoUIKitUser>> stream({bool includeFakeUser = true,})
> ```

#### remove

>
> remove user from live, kick out
>
> - function prototype:
>
> ```dart
> Future<bool> remove(List<String> userIDs)
> ```

#### addFakeUser

>
> add fake user
>
> - function prototype:
>
> ```dart
> void addFakeUser(ZegoUIKitUser user)
> ```


#### removeFakeUser

>
> remove fake user
>
> - function prototype:
>
> ```dart
> void removeFakeUser(ZegoUIKitUser user)
> ```
