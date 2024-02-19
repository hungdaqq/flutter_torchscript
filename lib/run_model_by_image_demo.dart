import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class RunModelByImageDemo extends StatefulWidget {
  const RunModelByImageDemo({Key? key}) : super(key: key);

  @override
  _RunModelByImageDemoState createState() => _RunModelByImageDemoState();
}

class _RunModelByImageDemoState extends State<RunModelByImageDemo> {
  ClassificationModel? _imageModel;
  //CustomModel? _customModel;
  // late ModelObjectDetection _objectModel;

  String? textToShow;
  List? _prediction;
  File? _media;
  // bool _isPlaying = false;
  final ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  //load your model
  Future loadModel() async {
    String pathImageModel = "assets/models/efficientnet_scripted.pt";
    //String pathCustomModel = "assets/models/custom_model.ptl";
    try {
      _imageModel = await PytorchLite.loadClassificationModel(
          pathImageModel, 224, 224, 1000,
          labelPath: "assets/labels/label_classification_imageNet.txt");
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  String inferenceTimeAsString(Stopwatch stopwatch) =>
      "Inference time: ${stopwatch.elapsed.inMilliseconds} ms";

  Future runClassification() async {
    //pick a random image
    // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    final XFile? media = await _picker.pickImage(source: ImageSource.gallery);
    print(media!.path);

    Stopwatch stopwatch = Stopwatch()..start();
    textToShow = await _imageModel!.getImagePredictionAndProbabilities(
        await File(media.path).readAsBytes());
    textToShow = "$textToShow\n${inferenceTimeAsString(stopwatch)}";

    setState(() {
      _media = File(media.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                width: MediaQuery.of(context).size.width,
                child: _media == null
                    ? const Text('Chưa chọn ảnh nào.')
                    : Image.file(_media!),
              ),
              SizedBox(
                child: Visibility(
                  visible: textToShow != null,
                  child: Text(
                    "$textToShow",
                    maxLines: 3,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
                onPressed: runClassification,
                icon: const Icon(Icons.add_a_photo)),
          ),
        ],
      ),
    );
  }
}
