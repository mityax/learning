import 'package:flutter/material.dart';
import 'package:learning_image_labeling/learning_image_labeling.dart';
import 'package:learning_input_image/learning_input_image.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
      ),
      home: ChangeNotifierProvider(
        create: (_) => ImageLabelingData(),
        child: ImageLabelingPage(),
      ),
    );
  }
}

class ImageLabelingPage extends StatefulWidget {
  @override
  _ImageLabelingPageState createState() => _ImageLabelingPageState();
}

class _ImageLabelingPageState extends State<ImageLabelingPage> {
  ImageLabelingData get data =>
      Provider.of<ImageLabelingData>(context, listen: false);

  ImageLabeling _imageLabeling = ImageLabeling();

  @override
  void dispose() {
    _imageLabeling.dispose();
    super.dispose();
  }

  Future<void> _processLabeling(InputImage image) async {
    if (data.isNotProcessing) {
      data.startProcessing();
      data.image = image;
      data.labels = await _imageLabeling.process(image);
      data.stopProcessing();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputCameraView(
      mode: InputCameraMode.gallery,
      cameraDefault: InputCameraType.rear,
      title: 'Image Labeling',
      onImage: _processLabeling,
      overlay: Consumer<ImageLabelingData>(
        builder: (_, data, __) {
          if (data.isEmpty) {
            return Container();
          }

          if (data.isProcessing && data.notFromLive) {
            return Center(
              child: Container(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(data.toString(),
                  style: TextStyle(fontWeight: FontWeight.w500)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageLabelingData extends ChangeNotifier {
  InputImage? _image;
  List _labels = [];
  bool _isProcessing = false;

  InputImage? get image => _image;
  List get labels => _labels;
  String get label => _labels.isNotEmpty ? _labels.first['label'] : '';

  String? get type => _image?.type;
  InputImageRotation? get rotation => _image?.metadata?.rotation;
  Size? get size => _image?.metadata?.size;

  bool get isProcessing => _isProcessing;
  bool get isNotProcessing => !_isProcessing;
  bool get isEmpty => _labels.isEmpty;
  bool get notFromLive => type != 'bytes';

  void startProcessing() {
    _isProcessing = true;
    notifyListeners();
  }

  void stopProcessing() {
    _isProcessing = false;
    notifyListeners();
  }

  set isProcessing(bool isProcessing) {
    _isProcessing = isProcessing;
    notifyListeners();
  }

  set image(InputImage? image) {
    _image = image;
    notifyListeners();
  }

  set labels(List labels) {
    _labels = labels;
    notifyListeners();
  }

  @override
  String toString() {
    List<String> result = [];
    for (Map label in labels) {
      result.add(label['label']);
    }
    return result.join(', ');
  }
}
