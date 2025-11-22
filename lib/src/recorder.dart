import 'dart:ui';

import 'package:flutter/material.dart';

typedef CapturedPointerData = ({PointerDataPacket packet, DateTime timestamp});

enum RecordState { none, recording, playing }

class GestureRecorder extends StatefulWidget {
  const GestureRecorder({super.key, required this.child});

  final Widget child;

  static RecordState stateOf(BuildContext context) {
    final state = context
        .dependOnInheritedWidgetOfExactType<_GestureRecorderScope>();
    assert(
      state != null,
      'GestureRecorder must be used within a GestureRecorder',
    );
    return state!.state;
  }

  static _GestureRecorderState _of(BuildContext context) {
    final state = context.findAncestorStateOfType<_GestureRecorderState>();
    assert(
      state != null,
      'GestureRecorder must be used within a GestureRecorder',
    );
    return state!;
  }

  static void start(BuildContext context) async {
    _of(context)._start();
  }

  static Future<List<CapturedPointerData>> stop(BuildContext context) async {
    return _of(context)._stop();
  }

  static Future<void> replay(
    BuildContext context,
    List<CapturedPointerData> pointerHistory,
  ) async {
    return _of(context)._replay(pointerHistory);
  }

  @override
  State<GestureRecorder> createState() => _GestureRecorderState();
}

class _GestureRecorderState extends State<GestureRecorder> {
  final List<CapturedPointerData> _pointerData = [];
  void Function()? _restoreFunc;
  RecordState _state = RecordState.none;

  void _start() {
    final dispatcher = PlatformDispatcher.instance.onPointerDataPacket;
    if (dispatcher != null) {
      setState(() {
        _state = RecordState.recording;
      });

      void wrappedFunc(PointerDataPacket packet) {
        _pointerData.add((packet: packet, timestamp: DateTime.now()));
        dispatcher(packet);
      }

      PlatformDispatcher.instance.onPointerDataPacket = wrappedFunc;
      _restoreFunc = () =>
          PlatformDispatcher.instance.onPointerDataPacket = dispatcher;
    }
  }

  List<CapturedPointerData> _stop() {
    setState(() {
      _state = RecordState.none;
    });

    if (_restoreFunc != null) {
      _restoreFunc!();
      _restoreFunc = null;
    }
    final copied = [..._pointerData];
    _pointerData.clear();
    return copied;
  }

  Future<void> _replay(List<CapturedPointerData> pointerHistory) async {
    final dispatcher = PlatformDispatcher.instance.onPointerDataPacket;
    if (dispatcher == null) {
      return;
    }

    setState(() {
      _state = RecordState.playing;
    });

    DateTime? previousTime;
    for (final historyItem in pointerHistory) {
      if (previousTime != null) {
        final delay = historyItem.timestamp.difference(previousTime);
        if (delay.inMicroseconds > 0) {
          await Future.delayed(delay);
        }
      }
      dispatcher(historyItem.packet);
      previousTime = historyItem.timestamp;
    }

    setState(() {
      _state = RecordState.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _GestureRecorderScope(state: _state, child: widget.child);
  }
}

class _GestureRecorderScope extends InheritedWidget {
  const _GestureRecorderScope({required super.child, required this.state});

  final RecordState state;

  @override
  bool updateShouldNotify(_GestureRecorderScope oldWidget) {
    return state != oldWidget.state;
  }
}
