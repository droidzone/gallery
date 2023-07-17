import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery/helpers/utils.dart';

class FileDateAvatarWidget extends StatelessWidget {
  FileDateAvatarWidget({
    super.key,
    required this.file,
  });
  FileSystemEntity file;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Text(
            formattedDD(file),
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
          Text(
            formattedMonth(file),
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
