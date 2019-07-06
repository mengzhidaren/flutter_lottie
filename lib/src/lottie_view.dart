import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lottie_controller.dart';

class LottieView extends StatefulWidget {
  LottieView.fromURL(
    this.url, {
    Key key,
    this.loop = false,
    this.controller,
    this.autoPlay,
    this.reverse,
  })  : filePath = null,
        super(key: key);

  LottieView.fromFile(
    this.filePath, {
    Key key,
    this.controller,
    this.loop = false,
    this.autoPlay,
    this.reverse,
  })  : url = null,
        super(key: key);

  final bool loop;
  final bool autoPlay;
  final bool reverse;
  final String url;
  final String filePath;
  final LottieController controller;

  @override
  _LottieViewState createState() => _LottieViewState();
}

class _LottieViewState extends State<LottieView> {
  LottieController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? LottieController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'sunnyapp/flutter_lottie',
        creationParams: <String, dynamic>{
          "url": widget.url,
          "filePath": widget.filePath,
          "loop": widget.loop,
          "reverse": widget.reverse,
          "autoPlay": widget.autoPlay,
        },
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: _controller.initialize,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'sunnyapp/flutter_lottie',
        creationParams: <String, dynamic>{
          "url": widget.url,
          "filePath": widget.filePath,
          "loop": widget.loop,
          "reverse": widget.reverse,
          "autoPlay": widget.autoPlay,
        },
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: _controller.initialize,
      );
    }

    return new Text('$defaultTargetPlatform is not yet supported by this plugin');
  }
}
