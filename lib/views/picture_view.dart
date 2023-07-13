// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageView extends StatefulWidget {
  final String imagePath;

  FullScreenImageView({super.key, required this.imagePath});

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  Offset offset = Offset(100, 100);
  String overlayText = "";
  String? newText;
  GlobalKey stackKey = GlobalKey();
  ValueNotifier<bool> isDragging = ValueNotifier(false);

  Future<void> saveImage() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      RenderRepaintBoundary boundary =
          stackKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Create an image from the RenderRepaintBoundary
      var image = await boundary.toImage(pixelRatio: 2.0);

      // Convert the image to bytes
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save the image using ImageGallerySaver
      final result = await ImageGallerySaver.saveImage(pngBytes);
      print("File saved to gallery: $result");
      Fluttertoast.showToast(
          msg: "Image saved to gallery",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  // Future<void> saveImage() async {
  //   RenderRepaintBoundary boundary =
  //       stackKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

  //   // Create an image from the RenderRepaintBoundary
  //   var image = await boundary.toImage(pixelRatio: 2.0);

  //   // Convert the image to bytes
  //   ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
  //   Uint8List pngBytes = byteData!.buffer.asUint8List();

  //   // Save the image using ImageGallerySaver
  //   final result = await ImageGallerySaver.saveImage(pngBytes);
  //   print("File saved to gallery: $result");
  //   Fluttertoast.showToast(
  //       msg: "Image saved to gallery",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.grey,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }

  Future<void> _addText() async {
    newText = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: Text('Enter new text'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'New text',
            ),
            onChanged: (value) => newText = value,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, newText),
              child: const Text('OK'),
            ),
          ]),
    );
    if (newText != null) {
      setState(() {
        overlayText = newText!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        key: stackKey,
        child: Stack(
          children: [
            Stack(
              // key: stackKey,
              children: <Widget>[
                PhotoView(
                  imageProvider: FileImage(File(widget.imagePath)),
                ),
                Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: Draggable(
                    onDragStarted: () => isDragging.value = true,
                    onDragEnd: (details) {
                      setState(() {
                        var dx = details.offset.dx;
                        var dy = details.offset.dy;

                        if (dx < 0) dx = 0;
                        if (dy < 0) dy = 0;
                        if (dx > MediaQuery.of(context).size.width - 100) {
                          dx = MediaQuery.of(context).size.width - 100;
                        }
                        if (dy > MediaQuery.of(context).size.height - 50) {
                          dy = MediaQuery.of(context).size.height - 50;
                        }

                        offset = Offset(dx, dy);
                        isDragging.value = false;
                      });
                    },
                    feedback: ValueListenableBuilder<bool>(
                      valueListenable: isDragging,
                      builder: (context, isDragging, child) {
                        if (isDragging) {
                          return Material(
                            type: MaterialType.transparency,
                            child: Text(
                              overlayText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                backgroundColor: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        _addText();
                      },
                      child: Text(
                        overlayText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          backgroundColor: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 40.0, // Adjust as needed
              left: 0.0,
              right: 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                  ),
                  IconButton(
                      color: Colors.white,
                      onPressed: () async {
                        _addText();
                      },
                      icon: Icon(Icons.text_fields_rounded)),
                  IconButton(
                    color: Colors.white,
                    onPressed: () => saveImage(),
                    icon: Icon(Icons.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
