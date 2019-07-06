import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lotvalues/lot_value.dart';

class LottieController {
  int id;
  MethodChannel _channel;
  EventChannel _playFinished;
  EventChannel _initialized;
  final Completer _initializedCompleter = Completer();
  final VoidCallback onPlayFinished;

  LottieController({this.onPlayFinished});

  Future<LottieController> awaitInitialized() async {
    await _initializedCompleter.future;
    return this;
  }

  initialize(int id) {
    if (this.id != null) {
      throw Exception("Attempting to initialize a lottie controller twice");
    }
    this.id = id;
    print('Creating Method Channel ${lottiePluginPath}_$id');
    this._channel = MethodChannel('${lottiePluginPath}_$id');
    this._playFinished = EventChannel('${lottiePluginPath}_stream_playfinish_$id');
    this._initialized = EventChannel('${lottiePluginPath}_stream_initialized_$id');
    if (onPlayFinished != null) {
      _playFinished
          .receiveBroadcastStream()
          .where((finished) => finished == true)
          .listen((finished) => onPlayFinished());
    }

    _initialized.receiveBroadcastStream().listen((_) {
      if (!_initializedCompleter.isCompleted) {
        _initializedCompleter.complete();
      }
    });
  }

  Future<void> setLoopAnimation(bool loop) async {
    assert(loop != null);
    return _channel?.invokeMethod('setLoopAnimation', {"loop": loop});
  }

  Future<void> setAutoReverseAnimation(bool reverse) async {
    assert(reverse != null);
    return _channel?.invokeMethod('setAutoReverseAnimation', {"reverse": reverse});
  }

  Future<void> play() async {
    return _channel?.invokeMethod('play');
  }

  Future<void> playWithProgress({double fromProgress, double toProgress}) async {
    assert(toProgress != null);
    return _channel?.invokeMethod('playWithProgress', {"fromProgress": fromProgress, "toProgress": toProgress});
  }

  Future<void> playWithFrames({int fromFrame, int toFrame}) async {
    assert(toFrame != null);
    return _channel?.invokeMethod('playWithFrames', {"fromFrame": fromFrame, "toFrame": toFrame});
  }

  Future<void> stop() async {
    return _channel?.invokeMethod('stop');
  }

  Future<void> pause() async {
    return _channel?.invokeMethod('pause');
  }

  Future<void> resume() async {
    return _channel?.invokeMethod('resume');
  }

  Future<void> setAnimationSpeed(double speed) async {
    return _channel?.invokeMethod('setAnimationSpeed', {"speed": speed.clamp(0, 1)});
  }

  Future<void> setAnimationProgress(double progress) async {
    return _channel?.invokeMethod('setAnimationProgress', {"progress": progress.clamp(0, 1)});
  }

  Future<void> setProgressWithFrame(int frame) async {
    return _channel?.invokeMethod('setProgressWithFrame', {"frame": frame});
  }

  Future<double> getAnimationDuration() async {
    return _channel?.invokeMethod('getAnimationDuration');
  }

  Future<double> getAnimationProgress() async {
    return _channel?.invokeMethod('getAnimationProgress');
  }

  Future<double> getAnimationSpeed() async {
    return _channel?.invokeMethod('getAnimationSpeed');
  }

  Future<bool> isAnimationPlaying() async {
    return _channel?.invokeMethod('isAnimationPlaying');
  }

  Future<bool> getLoopAnimation() async {
    return _channel?.invokeMethod('getLoopAnimation');
  }

  Future<bool> getAutoReverseAnimation() async {
    return _channel?.invokeMethod('getAutoReverseAnimation');
  }

  Future<void> setValue({LOTValue value, @required String keyPath}) async {
    assert(value != null);
    assert(keyPath != null);
    return _channel?.invokeMethod('setValue', {
      "value": value.value,
      "type": valueType(value.type),
      "keyPath": keyPath,
    });
  }
}

String valueType(LOTValueType type) {
  switch (type) {
    case LOTValueType.Color:
      return "ColorValue";
    case LOTValueType.Opacity:
      return "OpacityValue";
    default:
      return null;
  }
}

const lottiePluginPath = "sunnyapp/flutter_lottie";
