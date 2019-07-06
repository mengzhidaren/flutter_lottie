import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lottie/flutter_lottie.dart';
import 'page_dragger.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

Map<int, String> _animations = [
  "https://assets1.lottiefiles.com/packages/lf20_ld8FMO.json",
  "https://assets6.lottiefiles.com/datafiles/T11VsOdRDtsaJlw/data.json",
  "https://assets9.lottiefiles.com/datafiles/s2s8nJzgDOVLOcz/data.json",
  "https://assets10.lottiefiles.com/temp/lf20_7rPCHc.json",
  "https://assets2.lottiefiles.com/datafiles/jEgAWaDrrm6qdJx/data.json"
].asMap();

class _MyAppState extends State<MyApp> {
  LottieController controller;
  LottieController controller2;
  Widget switcher;
  LottieController switcherController;
  String url;

  StreamController<double> newProgressStream;

  @override
  void initState() {
    super.initState();
    newProgressStream = new StreamController<double>();

    controller = LottieController(
      onPlayFinished: () => print("Animation 1 finished playing"),
      onInitialized: (controller) => controller.play(),
    );
    controller2 = LottieController(onPlayFinished: () {
      print("Animation 2 finished playing");
    });
    newProgressStream.stream.listen((double progress) {
      controller2.setAnimationProgress(progress);
    });
    _index = 0;
    _createAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageDragger(
        stream: this.newProgressStream,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Lottie'),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 150,
                  height: 150,
                  child: LottieView.fromURL(
                    "https://assets9.lottiefiles.com/datafiles/s2s8nJzgDOVLOcz/data.json",
                    autoPlay: false, // Starts via controller
                    loop: false,
                    reverse: false,
                    controller: controller,
                  ),
                ),
                Wrap(
                  children: [
                    FlatButton(
                      child: Text("Play"),
                      onPressed: () {
                        controller.play();
                      },
                    ),
                    FlatButton(
                      child: Text("Stop"),
                      onPressed: () {
                        controller.stop();
                      },
                    ),
                    FlatButton(
                      child: Text("Pause"),
                      onPressed: () {
                        controller.pause();
                      },
                    ),
                    FlatButton(
                      child: Text("Resume"),
                      onPressed: () {
                        controller.resume();
                      },
                    ),
                  ],
                ),
                Text("From File"),
                Container(
                  color: Colors.blue,
                  height: 150,
                  width: 150,
                  child: switcher,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      child: Text("Previous"),
                      onPressed: _previous,
                    ),
                    MaterialButton(
                      child: Text("Next"),
                      onPressed: _advance,
                    )
                  ],
                ),
                Container(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: LottieView.fromFile(
                      "animations/newAnimation.json",
                      autoPlay: true,
                      loop: false,
                      reverse: false,
                      controller: controller2,
                    ),
                  ),
                ),
                FlatButton(
                  child: Text("Change Color"),
                  onPressed: () {
                    // Set Color of KeyPath
                    this.controller2.setValue(
                        value: LOTColorValue.fromColor(Color.fromRGBO(0, 0, 255, 1)),
                        keyPath: "body Konturen.Gruppe 1.Fläche 1");
                    // Set Opacity of KeyPath
                    this.controller2.setValue(value: LOTOpacityValue(0.5), keyPath: "body Konturen.Gruppe 1.Fläche 1");
                  },
                ),
                Text("Drag anywhere to change animation progress"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _index = 0;
  String name;

  _advance() {
    setState(() {
      if (_animations.containsKey(_index + 1)) {
        _index++;
      }
      _createAnimation();
    });
  }

  _previous() {
    if (_index < 1) return;
    setState(() {
      _index--;
      _createAnimation();
    });
  }

  _createAnimation() {
    String anim = _animations[_index];
    final _i = _index;
    print("Initializing animation: $anim");
    switcherController?.dispose();
    switcherController = LottieController(onPlayFinished: () async {
      await Future.delayed(Duration(seconds: 1));
      print("Completed playing $anim at index $_index");
      if (_i == _index) {
        _advance();
      }
    }, onInitialized: (controller) {
      print("Initialized at index $_index");
      return controller.play();
    });
    switcher = LottieView.fromURL(
      anim,
      key: Key(anim),
      controller: switcherController,
      autoPlay: false,
      reverse: false,
      loop: false,
    );
  }

  void dispose() {
    super.dispose();
    newProgressStream.close();
    switcherController?.dispose();
    controller?.dispose();
    controller2?.dispose();
  }
}
