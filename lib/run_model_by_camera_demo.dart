import 'package:flutter/material.dart';

import 'ui/camera_view.dart';

class RunModelByCameraDemo extends StatefulWidget {
  const RunModelByCameraDemo({Key? key}) : super(key: key);

  @override
  _RunModelByCameraDemoState createState() => _RunModelByCameraDemoState();
}

class _RunModelByCameraDemoState extends State<RunModelByCameraDemo> {
  String? classification;
  String? probability;

  Duration? classificationInferenceTime;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(5),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CameraView(resultsCallbackClassification),
          ), // Camera View
          Positioned(
            bottom: 0,
            right: 0,
            child: Column(
              children: [
                if (classification != null) Text('$classification'),
                if (probability != null) Text('$probability'),
                if (classificationInferenceTime != null)
                  Text(
                      'Thời gian xử lý: ${classificationInferenceTime?.inMilliseconds} ms')
              ],
            ),
          )
        ],
      ),
    );
  }

  void resultsCallbackClassification(
      String classification, String probability, Duration inferenceTime) {
    if (!mounted) {
      return;
    }
    setState(() {
      this.classification = classification;
      this.probability = probability;
      classificationInferenceTime = inferenceTime;
    });
  }
}
