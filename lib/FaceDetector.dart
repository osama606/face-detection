import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'FacePeinter.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetector extends StatefulWidget {
  @override
  _FaceDetectorState createState() => _FaceDetectorState();
}

class _FaceDetectorState extends State<FaceDetector> {
  File _imageFile;
  List<Face> _face;
  bool isLoading = false;
  ui.Image _image;

  Future getImage(bool camera) async {
    File image;
    final _picker = ImagePicker();
    var prckedFile;
    if (camera) {
      prckedFile = await _picker.getImage(source: ImageSource.camera);
      image = File(prckedFile.path);
    } else {
      prckedFile = await _picker.getImage(source: ImageSource.gallery);
      image = File(prckedFile.path);
    }
    setState(() {
      _imageFile = image;
      isLoading = true;
    });
    detectFaces(_imageFile);
  }

  detectFaces(File imageFile) async {
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> face = await faceDetector.processImage(image);
    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _face = face;
        _LoadImage(_imageFile);
      });
    }
  }

  _LoadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
          _image = value;
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("face detection"),
      ),
      body: isLoading
          ? Center(
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width / 1.1,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          : (_imageFile == null)
              ? Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(" No Image Selected"),
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: FittedBox(
                      child: SizedBox(
                        width: _image.width.toDouble(),
                        height: _image.height.toDouble(),
                        child: CustomPaint(
                          painter: FacePainter(_image, _face),
                        ),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _imageFile = null;
                });
              },
              child: Icon(Icons.refresh),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: FloatingActionButton(
              onPressed: () {
                getImage(true);
              },
              child: Icon(Icons.camera),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: FloatingActionButton(
              onPressed: () {
                getImage(false);
              },
              child: Icon(Icons.image),
            ),
          ),
        ],
      ),
    );
  }
}
