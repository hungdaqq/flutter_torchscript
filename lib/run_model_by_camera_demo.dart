import 'package:flutter/material.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

import 'ui/camera_view.dart';

class RunModelByCameraDemo extends StatefulWidget {
  const RunModelByCameraDemo({Key? key}) : super(key: key);

  @override
  _RunModelByCameraDemoState createState() => _RunModelByCameraDemoState();
}

class _RunModelByCameraDemoState extends State<RunModelByCameraDemo> {

  String? classification;
  Duration? classificationInferenceTime;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          // Camera View
          CameraView(resultsCallbackClassification),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                if (classification != null)
                  StatsRow('Classification:', '$classification'),
                if (classificationInferenceTime != null)
                  StatsRow('Classification Inference time:',
                      '${classificationInferenceTime?.inMilliseconds} ms'),
              ],
            ),
          )
        ],
      ),
    );
  }

  void resultsCallbackClassification(
      String classification, Duration inferenceTime) {
    if (!mounted) {
      return;
    }
    setState(() {
      this.classification = classification;
      classificationInferenceTime = inferenceTime;
    });
  }
}

/// Row for one Stats field
class StatsRow extends StatelessWidget {
  final String title;
  final String value;

  const StatsRow(this.title, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.green),
          ),
          Text(value)
        ],
      ),
    );
  }
}
