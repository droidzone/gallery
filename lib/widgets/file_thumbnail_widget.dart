import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery/helpers/utils.dart';
import 'package:gallery/widgets/file_date_avatar_widget.dart';

class FileThumbnail extends StatelessWidget {
  FileThumbnail({
    super.key,
    required this.file,
    required this.onLongPress,
    required this.onTap,
  });
  FileSystemEntity file;
  Function onLongPress;
  Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Draw a border around each file
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onLongPress: () {
          onLongPress();
        },
        onTap: () {
          onTap();
        },
        child: Stack(
          children: [
            FutureBuilder(
              future: getThumbnail(file.path),
              builder:
                  (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain,
                    height: 100,
                  );
                } else {
                  return const Text('Loading...');
                }
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: FileDateAvatarWidget(
                file: file,
              ),
            )
          ],
        ),
      ),
    );
  }
}
