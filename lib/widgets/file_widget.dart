import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/helpers/utils.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/widgets/file_thumbnail_widget.dart';
import 'package:logging/logging.dart';
import 'package:redux/redux.dart';
import 'package:path/path.dart' as p;

final Logger _log = Logger('FileWidget');

class FileViewModel {
  final FileSystemEntity file;
  bool isSelected;

  FileViewModel({
    required this.file,
    required this.isSelected,
  });

  static FileViewModel fromStore(
      Store<AppState> store, FileSystemEntity file, int windowIndex) {
    bool isSelected = windowIndex == 1
        ? store.state.selectedFilesFirst!.contains(file)
        : store.state.selectedFilesSecond!.contains(file);

    return FileViewModel(
      file: file,
      isSelected: isSelected,
    );
  }
}

class FileWidget extends StatelessWidget {
  final FileSystemEntity file;
  final int windowIndex;

  FileWidget({
    Key? key,
    required this.file,
    required this.windowIndex,
  }) : super(key: key);

  // toggleFileSelectionAction(FileViewModel fileViewModel) {
  //   fileViewModel.isSelected = !fileViewModel.isSelected;
  //   _log.info(
  //       "Toggled file ${fileViewModel.file.path} selection. Currently it is ${fileViewModel.isSelected}");
  // }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      // Convert the store into a bool by checking if this file is selected
      converter: (store) => store.state.selectedFilesFirst!.contains(file),
      distinct: true, // Only call builder if this value changes
      builder: (context, isSelected) {
        String fileName = p.basename(file.path);
        return Container(
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? Colors.green.withOpacity(0.3) : null,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: FileThumbnail(
                  file: file,
                  onTap: () {
                    _log.info("Tapped on file ${file.path}");

                    // Dispatch an action instead of mutating the state directly
                    StoreProvider.of<AppState>(context)
                        .dispatch(ToggleFileSelectionAction(file, windowIndex));
                  },
                  onLongPress: () {
                    _log.info("Long pressed on file ${file.path}");
                    // Dispatch an action instead of mutating the state directly
                    StoreProvider.of<AppState>(context)
                        .dispatch(ToggleFileSelectionAction(file, windowIndex));
                  },
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    children: [Text(formatFileName(fileName))],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
