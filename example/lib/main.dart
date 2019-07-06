import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lottie/flutter_lottie.dart';
import 'page_dragger.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LottieController controller;
  LottieController controller2;
  LottieController urlController;
  String url;

  StreamController<double> newProgressStream;

  @override
  void initState() {
    super.initState();
    newProgressStream = new StreamController<double>();

    controller = LottieController(onPlayFinished: () {
      print("Animation 1 finished playing");
    });
    controller.awaitInitialized().then((_) {
      controller.play();
    });
    controller2 = LottieController(onPlayFinished: () {
      print("Animation 2 finished playing");
    });
    newProgressStream.stream.listen((double progress) {
      controller2.setAnimationProgress(progress);
    });
    urlController = LottieController(onPlayFinished: () {
      print("Animation 3 finished playing");
    });
    final start = DateTime.now();
    urlController.awaitInitialized().then((_) {
      final loadTime = start.difference(DateTime.now());
      print("URL loaded in: $loadTime");
    });
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
                Text("Autoplay From URL"),
                Container(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: LottieView.fromURL(
                      "https://assets1.lottiefiles.com/packages/lf20_ld8FMO.json",
                      autoPlay: true,
                      loop: false,
                      reverse: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void dispose() {
    super.dispose();
    newProgressStream.close();
  }
}
