import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f_logs/f_logs.dart';
import 'package:nutrivision/Pages/analysis_page/analysis.dart';
import 'package:nutrivision/Models/meal_analysis_model.dart';
import 'package:nutrivision/Provider/diseases_provider.dart';
import 'package:nutrivision/global.dart';

class BoundingBox {
  double top;
  double left;
  double width;
  double height;

  BoundingBox(
      {required this.top,
      required this.left,
      required this.width,
      required this.height});
}

class ImagePreviewScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const ImagePreviewScreen({super.key, required this.imagePath});

  @override
  ImagePreviewScreenState createState() => ImagePreviewScreenState();
}

class ImagePreviewScreenState extends ConsumerState<ImagePreviewScreen> {
  final GlobalKey _imageKey = GlobalKey();

  bool _isLoading = false;
  bool _useBoundingBox = false; // Track whether the bounding box should be used
  double _imageWidth = 0;
  double _imageHeight = 0;
  double _rawImageWidth = 0;
  double _rawImageHeight = 0;
  List<BoundingBox> _boundingBoxList = []; // List to store bounding boxes

  // Variables for the bounding box’s position and size

  Future<void> analyzeImage() async {
    setState(() {
      _isLoading = true;
    });
    Uri uri;
    // Log bounding box coordinates for debugging
    if (_useBoundingBox) {
      uri = Uri.parse('http://$ipaddress:8000/analyze_meal_image_bounding/');
    } else {
      uri = Uri.parse('http://$ipaddress:8000/analyze_meal_image/');
    }

    final request = http.MultipartRequest('POST', uri);

    final imageFile = File(widget.imagePath);

    // Attach the image file to the request
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));
    _calculateDisplayedImageSize();

    late List<Map<String, int>> boundingBox; // Correct type
    boundingBox = _useBoundingBox
        ? _boundingBoxList
            .map((box) => _scaleBoundingBoxToRawDimensions(box))
            .toList()
        : [];
    List<String> selectedDisease = ref.read(selectedDiseasesProvider);

    FLog.info(text: "Bounding Boxes $boundingBox");
    final inputData = {
      "diseases": selectedDisease,
      'bounding_box': boundingBox
    };

    request.fields['input_data'] = jsonEncode(inputData);

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);

        if (data.containsKey('message')) {
        // Show snackbar with the message from the server
        _showSnackbar(data['message']);
        return;
      }


        if (mounted) {
          // Assuming MealAnalysis is a model class
          final analysis = MealAnalysis.fromJson(data['mealAnalysis']);
          Map<String, int> foodCount = {};

          data['foodCount'].forEach((key, value) {
            foodCount[key] =
                value is int ? value : int.tryParse(value.toString()) ?? 0;
          });
          Map<String, double> servingSize = {};
          data['servingSize'].forEach((key, value) {
            if (value is num) {
              // Check if value is a number
              servingSize[key] = value.toDouble();
            } else {
              // Handle or log the error for invalid (non-numeric) data
              print('Invalid data for $key: $value');
            }
          });
          servingSize.forEach(
            (key, value) => FLog.info(text: "$key $value"),
          );

          foodCount.forEach((itemName, count) {
            FLog.info(text: "$itemName $count");
          });
          FLog.info(text: "");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisPage(
                analysis: analysis,
                foodCount: foodCount,
                sirvingSize: servingSize,
              ),
            ),
          );
        }
      } else {
        _showSnackbar('Failed to analyze the image.');
      }
    } catch (e) {
      FLog.error(text: "Error uploading image: $e");
      _showSnackbar('Error uploading image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _calculateDisplayedImageSize() {
    // Ensure the widget tree is fully built before calculating sizes

    final renderBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      FLog.error(text: "RenderBox is null; cannot calculate displayed size.");
      return;
    }

    final containerWidth = renderBox.size.width;
    final containerHeight = renderBox.size.height;

    // Log container size
    FLog.info(
        text:
            "Container dimensions - width: $containerWidth, height: $containerHeight");

    if (containerWidth == 0 || containerHeight == 0) {
      FLog.warning(
          text: "Container size is zero; skipping image size calculation.");
      return;
    }

    // Resolve the image dimensions
    final decodedImage = Image.file(File(widget.imagePath));
    decodedImage.image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (info, _) {
              final rawImageWidth = info.image.width.toDouble();
              final rawImageHeight = info.image.height.toDouble();

              // Log raw image size
              FLog.info(
                  text:
                      "Raw image dimensions - width: $rawImageWidth, height: $rawImageHeight");

              if (rawImageWidth == 0 || rawImageHeight == 0) {
                FLog.warning(
                    text: "Image dimensions are zero; skipping calculations.");
                return;
              }

              // Calculate scaling
              final widthScale = containerWidth / rawImageWidth;
              final heightScale = containerHeight / rawImageHeight;
              final scale = widthScale < heightScale ? widthScale : heightScale;

              // Update state
              setState(() {
                _imageWidth = rawImageWidth * scale;
                _imageHeight = rawImageHeight * scale;
                _rawImageHeight = rawImageHeight;
                _rawImageWidth = rawImageWidth;

                // Log calculated displayed size
                FLog.info(
                    text:
                        "Displayed image size - width: $_imageWidth, height: $_imageHeight");
              });
            },
            onError: (exception, stackTrace) {
              FLog.error(text: "Error loading image: $exception");
            },
          ),
        );
  }

  void _addBoundingBox() {
    setState(() {
      _boundingBoxList
          .add(BoundingBox(height: 100, width: 100, top: 0, left: 0));
    });
  }

  void _removeBoundingBox(int i) {
    setState(() {
      _boundingBoxList.removeAt(i);
    });
  }

  Map<String, int> _scaleBoundingBoxToRawDimensions(BoundingBox box) {
    FLog.info(
      text:
          '_scaleBoundingBoxToRawDimensions $_imageWidth $_imageHeight $_rawImageWidth $_rawImageHeight',
    );
    return {
      'x1': ((box.left / _imageWidth) * _rawImageWidth).toInt(),
      'y1': ((box.top / _imageHeight) * _rawImageHeight).toInt(),
      'x2': (((box.left + box.width) / _imageWidth) * _rawImageWidth).toInt(),
      'y2': (((box.top + box.height) / _imageHeight) * _rawImageHeight).toInt(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: _addBoundingBox, // Add a new bounding box
            // onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.maxFinite,
            height: 600,
            child: Stack(
              children: [
                SizedBox(
                  child: Image.file(
                    File(widget.imagePath),
                    key: _imageKey,
                    fit: BoxFit.contain,
                  ),
                ),
                if (_useBoundingBox)
                  for (int i = 0; i < _boundingBoxList.length; i++)
                    CreateBoundingBox(
                        box: _boundingBoxList[i],
                        onDelete: () => _removeBoundingBox(i),
                        onUpdate: (updatedBox) {
                          setState(() {
                            _boundingBoxList[i] = updatedBox;
                            FLog.info(
                                text:
                                    "${_boundingBoxList[i]}"); // Update the specific box in the list
                          });
                        }),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Use Bounding Box"),
              Switch(
                value: _useBoundingBox,
                onChanged: (value) {
                  setState(() {
                    _useBoundingBox = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                ),
                ElevatedButton.icon(
                  onPressed: analyzeImage,
                  icon: const Icon(Icons.save),
                  label: const Text('Analyze'),
                ),
              ],
            ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

class CreateBoundingBox extends StatefulWidget {
  final VoidCallback onDelete;
  final BoundingBox box;
  final Function(BoundingBox) onUpdate;

  const CreateBoundingBox(
      {super.key,
      required this.box,
      required this.onUpdate,
      required this.onDelete});

  @override
  State<CreateBoundingBox> createState() => _CreateBoundingBoxState();
}

class _CreateBoundingBoxState extends State<CreateBoundingBox> {
  late double _top;
  late double _left;
  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
    _top = widget.box.top;
    _left = widget.box.left;
    _width = widget.box.width;
    _height = widget.box.height;
  }

  void _updateBox() {
    widget.onUpdate(
        BoundingBox(top: _top, left: _left, width: _width, height: _height));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _top,
      left: _left,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _left += details.delta.dx;
            _top += details.delta.dy;
            _updateBox();
          });
        },
        child: Container(
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
            color: Colors.red.withOpacity(0.2),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _width = (_width + details.delta.dx)
                          .clamp(20.0, double.infinity);
                      _height = (_height + details.delta.dy)
                          .clamp(20.0, double.infinity);
                      _updateBox();
                    });
                  },
                  child: const Icon(Icons.crop_square, color: Colors.red),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: const Icon(Icons.close, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
