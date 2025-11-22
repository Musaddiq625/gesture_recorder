
# gesture_recorder

**gesture_recorder** enables you to "record" all the gesture event happening during recording.

The recorded data can be replayed, which means you can duplicate exactly the same behavior again and again.

## Features

- [x] record / replay
- [ ] persist recorded data
- [ ] customize / mimic gesture event

## Getting started

First, place `GestureRecorder` at the top of the entire widget tree.

```dart
GestureRecorder(
  child: MaterialApp(),
),
```

You can access the controller by calling static methods provided by `GestureRecorder` like below.

```dart
/// start recording
GestureRecorder.start(context);

/// stop recording and obtain recorded event data
final data = await GestureRecorder.stop(context);

/// replay recorded event data
await GestureDetector.replay(context, data);
```

Also, you can observe `RecordState` from `GestureRecorder`.

```dart
/// observe [RecordState]. Once the state changes, observing widget is rebuilt.
final recordState = GestureRecorder.stateOf(context);
```

# Contact

If you have anything you want to inform me ([@chooyan-eng](https://github.com/chooyan-eng)), such as suggestions to enhance this package or functionalities you want etc, feel free to make [issues on GitHub](https://github.com/chooyan-eng/gesture_recorder/issues) or send messages on X [@tsuyoshi_chujo](https://x.com/tsuyoshi_chujo) (Japanese [@chooyan_i18n](https://x.com/chooyan_i18n)).