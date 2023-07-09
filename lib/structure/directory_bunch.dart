// create a class DirectoryBunch with  properties: a String path, and String name, and an Image? thumbnail.
// create a constructor for DirectoryBunch that takes a String ,String name, and String path as parameters.

// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';

class DirectoryBunch {
  String path;
  String name;
  String imgPath;

  DirectoryBunch(
      {required this.path, required this.name, required this.imgPath});

  Widget getThumbnail() {
    var file = File(imgPath);
    try {
      var fileType = FileSystemEntity.typeSync(file.path);
      if (fileType == FileSystemEntityType.file) {
        return Image.file(
          File(imgPath),
          height: 100,
          width: 100,
        );
      }
    } catch (e) {}
    return Icon(
      Icons.folder,
      size: 100,
      color: Colors.blue,
    );
  }
}
