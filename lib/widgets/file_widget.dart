import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/helpers/utils.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/widgets/file_thumbnail_widget.dart';
import 'package:redux/redux.dart';
import 'package:path/path.dart' as p;

class FileWidget extends StatefulWidget {
  FileWidget({
    super.key,
    required this.file,
    required this.windowIndex,
    required this.onTap,
    required this.onLongPress,
    // required this.isSelected,
  });
  FileSystemEntity file;
  int windowIndex;
  Function onTap;
  Function onLongPress;
  // bool isSelected;

  @override
  State<FileWidget> createState() => _FileWidgetState();
}

class _FileWidgetState extends State<FileWidget> {
  bool isFileSelected(BuildContext context) {
    Store<AppState> store = StoreProvider.of<AppState>(context, listen: false);

    if (widget.windowIndex == 1) {
      return store.state.selectedFilesFirst!.contains(widget.file);
    } else {
      return store.state.selectedFilesSecond!.contains(widget.file);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("For file ${widget.file.path}, isSelected is ${widget.isSelected}");
    String fileName = p.basename(widget.file.path);
    return Container(
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isFileSelected(context) ? Colors.green.withOpacity(0.3) : null,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: FileThumbnail(
              file: widget.file,
              onTap: () => widget.onTap(context, widget.file),
              onLongPress: () => widget.onLongPress(widget.file),
            ),
          ),
          Expanded(
            child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  children: [Text(formatFileName(fileName))],
                )),
          ),
        ],
      ),
    );
  }
}
