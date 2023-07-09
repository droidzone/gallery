// ignore_for_file: prefer_const_constructors_in_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageView extends StatelessWidget {
  final String imagePath;

  FullScreenImageView({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: PhotoView(
          imageProvider: FileImage(File(imagePath)),
        ),
      ),
    );
  }
}
