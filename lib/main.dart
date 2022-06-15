import 'dart:io' as io;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

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
  //Rectangle position
  Map<String, double> _position = {
    'x': 0,
    'y': 0,
    'w': 0,
    'h': 0,
  };

  // Whether or not the rectangle is displayed
  bool _isRectangleVisible = false;

  late double ratio;
  late CameraController controller;
  late ObjectDetector objectDetector;
  late ObjectDetectorOptions options;
  late Future<String> modelPath;
  final path = 'assets/ml/object_labeler.tflite';
  String scannedText = "";
  bool _isAnalysisOn = false;

// Some logic to get the rectangle values
  void updateRectanglePosition(
      double left, double top, double right, double bottom) {
    setState(() {
      // assign new position
      _position = {
        'x': left / (controller.value.aspectRatio),
        'y': top / (controller.value.aspectRatio),
        'w': (right - left) / (controller.value.aspectRatio),
        'h': (bottom - top) / (controller.value.aspectRatio),
      };
      _isRectangleVisible = true;
    });
  }

  // Function to convert CameraImage to InputImage to get processed by ml kit
  Future<InputImage?> _convertCameraToInput(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final camera = _cameras[0];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation)!;
    if (imageRotation == null) {
      scannedText = "image rotation null";
      setState(() {
        scannedText = scannedText;
      });
      return null;
    }
    ;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) {
      scannedText = "image format null";
      setState(() {
        scannedText = scannedText;
      });
      return null;
    }
    ;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );
    InputImage inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    setState(() {
      scannedText = scannedText;
    });

    return inputImage;
  }

  // analyzing current frame
  void analyzeImage(CameraImage cameraImage) async {
    _isAnalysisOn = true;
    setState(() {
      _isAnalysisOn = true;
    });
    InputImage inputImage =
        await _convertCameraToInput(cameraImage) as InputImage;
    if (inputImage == null) {
      scannedText = "could not conver image";
    } else {}
    setState(() {
      scannedText = scannedText;
    });
    final List<DetectedObject> objects =
        await objectDetector.processImage(inputImage);
    final List<DetectedObject> _objects =
        await objectDetector.processImage(inputImage);

    for (DetectedObject detectedObject in _objects) {
      final rect = detectedObject.boundingBox;
      // final trackingId = detectedObject.trackingId;

      // scannedText += "Id: " + ('${trackingId}') + "\n";
      if (detectedObject.labels.length > 0) {
        for (Label label in detectedObject.labels) {
          // scannedText = ('${label.text} ${label.confidence}') + "\n";
          scannedText = ('${label.text}') + "\n";
        }
        updateRectanglePosition(rect.left, rect.top, rect.right, rect.bottom);
        // scannedText += "Rect: " + ('${rect.toString()}') + "\n";
      }
    }
    _isAnalysisOn = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getModel(path).then((modelPath) {
      options = LocalObjectDetectorOptions(
        mode: DetectionMode.stream,
        modelPath: modelPath,
        classifyObjects: true,
        multipleObjects: true,
      );
      objectDetector = ObjectDetector(options: options);
    });
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

  // loading local model
  Future<String> _getModel(String assetPath) async {
    if (io.Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    print("model downloaded: " + file.path.toString());
    return file.path;
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
        home: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Live Stream Detection"),
        backgroundColor: Colors.black87,
      ),
      body: Center(
          child: SingleChildScrollView(
              child: Stack(
        children: [
          // AspectRatio(
          //   aspectRatio: controller.value.aspectRatio,
          //   child: controller == null ? Container() : CameraPreview(controller),
          // ),
          controller == null ? Container() : CameraPreview(controller),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                    child: Text("Start Scanning"),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () async {
                      await controller
                          .startImageStream((CameraImage availableImage) {
                        if (!_isAnalysisOn) analyzeImage(availableImage);
                      });
                    }),
                MaterialButton(
                    child: Text("Stop Scanning"),
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: () async {
                      await controller.stopImageStream();
                      objectDetector.close();
                      // controller.dispose();
                    })
              ]),
          if (_isRectangleVisible)
            Positioned(
              left: _position['x'],
              top: _position['y'],
              child: InkWell(
                onTap: () {
                  // When the user taps on the rectangle, it will disappear
                  // setState(() {
                  //   _isRectangleVisible = false;
                  // });
                },
                child: Container(
                  width: _position['w'],
                  height: _position['h'],
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.blue,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      color: Colors.blue,
                      child: Text(
                        '${scannedText}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ))),
    ));
  }
}
