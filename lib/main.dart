// import 'dart:io' as io;
//
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:flutter_vlc_player/vlc_player.dart';
// import 'package:flutter_vlc_player/vlc_player_controller.dart';
// //////
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
// import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';
//
// //////////////////////////////////////////////////////
//
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   bool textScanning = false;
//
//   XFile? imageFile;
//
//   String scannedText = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("Text Recognition example"),
//       ),
//       body: Center(
//           child: SingleChildScrollView(
//             child: Container(
//                 margin: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     if (textScanning) const CircularProgressIndicator(),
//                     if (!textScanning && imageFile == null)
//                       Container(
//                         width: 300,
//                         height: 300,
//                         color: Colors.grey[300]!,
//                       ),
//                     if (imageFile != null) Image.file(io.File(imageFile!.path)),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 5),
//                             padding: const EdgeInsets.only(top: 10),
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 primary: Colors.white,
//                                 onPrimary: Colors.grey,
//                                 shadowColor: Colors.grey[400],
//                                 elevation: 10,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8.0)),
//                               ),
//                               onPressed: () {
//                                 getImage(ImageSource.gallery);
//                               },
//                               child: Container(
//                                 margin: const EdgeInsets.symmetric(
//                                     vertical: 5, horizontal: 5),
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.image,
//                                       size: 30,
//                                     ),
//                                     Text(
//                                       "Gallery",
//                                       style: TextStyle(
//                                           fontSize: 13, color: Colors.grey[600]),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )),
//                         Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 5),
//                             padding: const EdgeInsets.only(top: 10),
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 primary: Colors.white,
//                                 onPrimary: Colors.grey,
//                                 shadowColor: Colors.grey[400],
//                                 elevation: 10,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8.0)),
//                               ),
//                               onPressed: () {
//                                 getImage(ImageSource.camera);
//                               },
//                               child: Container(
//                                 margin: const EdgeInsets.symmetric(
//                                     vertical: 5, horizontal: 5),
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.camera_alt,
//                                       size: 30,
//                                     ),
//                                     Text(
//                                       "Camera",
//                                       style: TextStyle(
//                                           fontSize: 13, color: Colors.grey[600]),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             )),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     Container(
//                       child: Text(
//                         scannedText,
//                         style: TextStyle(fontSize: 20),
//                       ),
//                     )
//                   ],
//                 )),
//           )),
//     );
//   }
//
//
//
//   void getImage(ImageSource source) async {
//     try {
//       final pickedImage = await ImagePicker().pickImage(source: source);
//       if (pickedImage != null) {
//         textScanning = true;
//         imageFile = pickedImage;
//         setState(() {});
//         getRecognisedText(pickedImage);
//       }
//     } catch (e) {
//       textScanning = false;
//       imageFile = null;
//       scannedText = "Error occured while scanning";
//       setState(() {});
//     }
//   }
//
//   void getRecognisedText(XFile image) async {
//
//     //Loading the model
//     final path = 'assets/ml/object_labeler.tflite';
//     final modelPath = await _getModel(path);
//     print("model path");
//     print(modelPath);
//
//     final options = LocalObjectDetectorOptions(
//         mode: DetectionMode.singleImage,
//         modelPath: modelPath,
//         classifyObjects: true,
//         multipleObjects: true,
//     );
//
//     final inputImage = InputImage.fromFilePath(image.path);
//
//     // text recognition code
//
//     // final TextRecognizer textRecognizer = TextRecognizer();
//     // final recognisedText = await textRecognizer.processImage(inputImage);
//     // await textRecognizer.close();
//     // scannedText = "";
//     // for (TextBlock block in recognisedText.blocks) {
//     //   for (TextLine line in block.lines) {
//     //     scannedText = scannedText + line.text + "\n";
//     //   }
//     // }
//
//     //image labeling code
//
//     // final ImageLabeler imgLbl = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
//     // final List<ImageLabel> labels = await imgLbl.processImage(inputImage);
//     // await imgLbl.close();
//     //
//     // if(labels == null){
//     //   print("No labels detected");
//     //   scannedText = "no labels detected \n";
//     // }
//     // for(ImageLabel label in labels){
//     //   var confidence = double.parse((label.confidence * 100).toStringAsFixed(1));
//     //   scannedText = scannedText + '[$confidence%] = ${label.label} \n';
//     // }
//
//
//     // object detection code
//
//     // final ObjectDetectorOptions options2 = ObjectDetectorOptions(mode: DetectionMode.singleImage, classifyObjects: true, multipleObjects: true);
//     final ObjectDetector objectDetector = ObjectDetector(options: options);
//     scannedText += "Object detector created with options \n";
//     final List<DetectedObject> objects = await objectDetector.processImage(inputImage);
//     scannedText += "Objects found : [" + objects.length.toString() + "]\n";
//
//
//     final List<DetectedObject> _objects = await objectDetector.processImage(inputImage);
//
//     for(DetectedObject detectedObject in _objects){
//       final rect = detectedObject.boundingBox;
//       final trackingId = detectedObject.trackingId;
//
//
//       // scannedText += "Id: " + ('${trackingId}') + "\n";
//       if(detectedObject.labels.length > 0){
//         for(Label label in detectedObject.labels){
//           scannedText = scannedText + ('${label.text} ${label.confidence}') + "\n";
//         }
//         scannedText += "Rect: " + ('${rect.toString()}') + "\n";
//       }
//
//     }
//
//     objectDetector.close();
//
//
//     textScanning = false;
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   Future<String> _getModel(String assetPath) async {
//     if (io.Platform.isAndroid) {
//       return 'flutter_assets/$assetPath';
//
//     }
//     final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
//     await io.Directory(dirname(path)).create(recursive: true);
//     final file = io.File(path);
//     if (!await file.exists()) {
//       final byteData = await rootBundle.load(assetPath);
//       await file.writeAsBytes(byteData.buffer
//           .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
//     }
//     print("model downloaded: " + file.path.toString());
//     return file.path;
//   }
// }

//-----------------------------------------------------------------------------------------------------------//

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  // bool _isScanBusy = false;
  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
        home:Scaffold(
          appBar: AppBar(
            title: Text("Container App"),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CameraPreview(controller), Text("This is a sample description")
                ],
              )
            )
          ),
        )
    );

    // return MaterialApp(
    //   home: CameraPreview(controller),
    // );
    // return Container(
    //   child: AspectRatio(
    //     aspectRatio: controller.value.aspectRatio,
    //     child: CameraPreview(controller),
    //   )
    // );
    // return AspectRatio(
    //   aspectRatio: controller.value.aspectRatio,
    //   child: CameraPreview(controller),
    // );
  }

  // @override
  // Widget build(BuildContext context) {
  //   if (!controller.value.isInitialized) {
  //     return Container();
  //   }
  //   return Column(
  //       children: [
  //         Expanded(
  //             child: _cameraPreviewWidget()
  //         ),
  //         Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               MaterialButton(
  //                   child: Text("Start Scanning"),
  //                   textColor: Colors.white,
  //                   color: Colors.blue,
  //                   onPressed: () async {
  //                     await controller.startImageStream((CameraImage availableImage) {
  //                       //controller.stopImageStream();
  //
  //                       // if (!_isScanBusy)
  //                       //   _scanText(availableImage);
  //                     });
  //                   }
  //               ),
  //               MaterialButton(
  //                   child: Text("Stop Scanning"),
  //                   textColor: Colors.white,
  //                   color: Colors.red,
  //                   onPressed: () async => await controller.stopImageStream()
  //               )
  //             ]
  //         )
  //       ]
  //   );
  //
  // }

  // Widget _cameraPreviewWidget() {
  //   if (controller == null || !controller.value.isInitialized) {
  //     return const Text(
  //       'Tap a camera',
  //       style: TextStyle(
  //         color: Colors.white,
  //         fontSize: 24.0,
  //         fontWeight: FontWeight.w900,
  //       ),
  //     );
  //   } else {
  //     return AspectRatio(
  //       aspectRatio: controller.value.aspectRatio,
  //       child: CameraPreview(controller),
  //     );
  //   }
  // }
}