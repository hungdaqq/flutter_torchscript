import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:path/path.dart' as path;

class RunModelByImageDemo extends StatefulWidget {
  const RunModelByImageDemo({Key? key}) : super(key: key);

  @override
  _RunModelByImageDemoState createState() => _RunModelByImageDemoState();
}

class _RunModelByImageDemoState extends State<RunModelByImageDemo> {
  late List<ClassificationModel> _imageModels;
  String? inferenceTime;
  File? _media;
  String? label;
  String? _fileName;
  String? probability;
  final ImagePicker _picker = ImagePicker();
  bool objectDetection = false;

  @override
  void initState() {
    super.initState();
    _imageModels = [];
    loadModels();
  }

  Future<void> loadModels() async {
    List<String> modelPaths = [
      "assets/models/mobilevit_xxs_torchscript.pt",
      "assets/models/mobilevit_xxs_torchscript.pt",
      "assets/models/mobilevit_xxs_torchscript.pt",
    ];
    for (String modelPath in modelPaths) {
      ClassificationModel? model = await loadModel(modelPath);
      if (model != null) {
        _imageModels.add(model);
      }
    }
  }

  Future<ClassificationModel?> loadModel(String path) async {
    try {
      return await PytorchLite.loadClassificationModel(
        path,
        224,
        224,
        16,
        labelPath: "assets/labels/labels.txt",
      );
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
      return null;
    }
  }

  String inferenceTimeAsString(Stopwatch stopwatch) =>
      "${stopwatch.elapsed.inMilliseconds} ms";

  Future<void> runClassification(int modelIndex) async {
    final XFile? media = await _picker.pickImage(source: ImageSource.gallery);
    if (media == null) return;

    Stopwatch stopwatch = Stopwatch()..start();
    ClassificationModel model = _imageModels[modelIndex];
    Map<String, dynamic> result =
        await model.getImagePredictionAndProbabilities(
      await File(media.path).readAsBytes(),
    );
    inferenceTime = inferenceTimeAsString(stopwatch);
    label = result['label'];
    probability = result['probability'];

    setState(() {
      _media = File(media.path);
      _fileName = path.basename(media.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(5),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _media == null
                ? const Text('Chưa chọn ảnh nào!')
                : Image.file(_media!),
          ),
          Positioned(
            bottom: 120,
            left: 450,
            child: Container(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: _fileName != null,
                    child: Text(_fileName ?? ''),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: label != null,
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          const TextSpan(
                            text: 'Nhãn phân loại: ',
                          ),
                          TextSpan(
                            text: '$label',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: probability != null,
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          const TextSpan(
                            text: 'Xác suất phân loại: ',
                          ),
                          TextSpan(
                            text: "$probability%",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: inferenceTime != null,
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          const TextSpan(
                            text: 'Thời gian xử lý: ',
                          ),
                          TextSpan(
                            text: '$inferenceTime',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 10,
            child: DropdownButton<int>(
              value: 0, // Change this to selected model index
              onChanged: (int? newIndex) {
                if (newIndex != null) {
                  runClassification(newIndex);
                }
              },
              items: List.generate(
                _imageModels.length,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text('Model ${['XXS', 'XS', 'S'][index]}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pytorch_lite/pytorch_lite.dart';
// import 'package:path/path.dart' as path;
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
// import 'package:path_provider/path_provider.dart';

// class RunModelByImageDemo extends StatefulWidget {
//   const RunModelByImageDemo({Key? key}) : super(key: key);

//   @override
//   _RunModelByImageDemoState createState() => _RunModelByImageDemoState();
// }

// class _RunModelByImageDemoState extends State<RunModelByImageDemo> {
//   late List<ClassificationModel> _imageModels;
//   String? inferenceTime;
//   File? _media;
//   String? label;
//   String? _fileName;
//   String? probability;
//   final ImagePicker _picker = ImagePicker();
//   bool objectDetection = false;
//   final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

//   @override
//   void initState() {
//     super.initState();
//     _imageModels = [];
//     loadModels();
//   }

//   Future<void> loadModels() async {
//     List<String> modelPaths = [
//       "assets/models/mobilevit_xxs_torchscript.pt",
//       "assets/models/mobilevit_xxs_torchscript.pt",
//       "assets/models/mobilevit_xxs_torchscript.pt",
//     ];
//     for (String modelPath in modelPaths) {
//       ClassificationModel? model = await loadModel(modelPath);
//       if (model != null) {
//         _imageModels.add(model);
//       }
//     }
//   }

//   Future<ClassificationModel?> loadModel(String path) async {
//     try {
//       return await PytorchLite.loadClassificationModel(
//         path,
//         224,
//         224,
//         16,
//         labelPath: "assets/labels/labels.txt",
//       );
//     } catch (e) {
//       if (e is PlatformException) {
//         print("only supported for android, Error is $e");
//       } else {
//         print("Error is $e");
//       }
//       return null;
//     }
//   }

//   String inferenceTimeAsString(Stopwatch stopwatch) =>
//       "${stopwatch.elapsed.inMilliseconds} ms";

//   Future<void> runClassification(int modelIndex, File imageFile) async {
//     Stopwatch stopwatch = Stopwatch()..start();
//     ClassificationModel model = _imageModels[modelIndex];
//     Map<String, dynamic> result =
//         await model.getImagePredictionAndProbabilities(
//       await imageFile.readAsBytes(),
//     );
//     inferenceTime = inferenceTimeAsString(stopwatch);
//     label = result['label'];
//     probability = result['probability'];

//     setState(() {
//       _media = imageFile;
//       _fileName = path.basename(imageFile.path);
//     });
//   }

//   Future<void> extractFramesAndRunClassification(
//       int model, String videoPath) async {
//     final Directory extDir = await getApplicationDocumentsDirectory();
//     final String dirPath = '${extDir.path}/frames/';
//     await Directory(dirPath).create(recursive: true);
//     final String outputPath = '$dirPath/image_%04d.jpg';

//     await _flutterFFmpeg.execute(
//         '-i $videoPath -vf fps=1 $outputPath'); // Extract frames from video

//     // Get list of extracted frame files
//     List<FileSystemEntity> files =
//         Directory(dirPath).listSync(); // List of files without sorting

//     // Sort the list of files
//     files.sort((a, b) => a.path.compareTo(b.path));

//     for (var file in files) {
//       if (file is File) {
//         await runClassification(
//             model, file); // Run classification on each frame
//         await Future.delayed(Duration(
//             milliseconds: 750)); // Optional delay between classifications
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             alignment: Alignment.topLeft,
//             padding: const EdgeInsets.all(5),
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             child: _media == null
//                 ? const Text('Chưa chọn ảnh nào!')
//                 : Image.file(_media!),
//           ),
//           Positioned(
//             bottom: 130,
//             left: 450,
//             child: Container(
//               width: 500,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Visibility(
//                   //   visible: _fileName != null,
//                   //   child: Text(_fileName ?? ''),
//                   // ),
//                   const SizedBox(height: 10),
//                   Visibility(
//                     visible: label != null,
//                     child: RichText(
//                       text: TextSpan(
//                         style: DefaultTextStyle.of(context).style,
//                         children: [
//                           const TextSpan(
//                             text: 'Nhãn phân loại: ',
//                           ),
//                           TextSpan(
//                             text: '$label',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Visibility(
//                     visible: probability != null,
//                     child: RichText(
//                       text: TextSpan(
//                         style: DefaultTextStyle.of(context).style,
//                         children: [
//                           const TextSpan(
//                             text: 'Xác suất phân loại: ',
//                           ),
//                           TextSpan(
//                             text: "$probability%",
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Visibility(
//                     visible: inferenceTime != null,
//                     child: RichText(
//                       text: TextSpan(
//                         style: DefaultTextStyle.of(context).style,
//                         children: [
//                           const TextSpan(
//                             text: 'Thời gian xử lý: ',
//                           ),
//                           TextSpan(
//                             text: '$inferenceTime',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Positioned(
//           //   bottom: 5,
//           //   right: 10,
//           //   child: ElevatedButton(
//           //     onPressed: () async {
//           //       final XFile? video =
//           //           await _picker.pickVideo(source: ImageSource.gallery);
//           //       if (video == null) return;

//           //       await extractFramesAndRunClassification(video.path);
//           //     },
//           //     child: Text('Chọn video'),
//           //   ),
//           // ),
//           Positioned(
//             bottom: 5,
//             right: 10,
//             child: DropdownButton<int>(
//               value: 0, // Change this to selected model index
//               onChanged: (int? newIndex) async {
//                 final XFile? video =
//                     await _picker.pickVideo(source: ImageSource.gallery);
//                 if (video == null) return;
//                 if (newIndex != null) {
//                   await extractFramesAndRunClassification(newIndex, video.path);
//                 }
//               },
//               items: List.generate(
//                 _imageModels.length,
//                 (index) => DropdownMenuItem<int>(
//                   value: index,
//                   child: Text('Proposed ${['XXS', 'XS', 'S'][index]}'),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
