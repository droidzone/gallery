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

class FileWidget extends StatefulWidget {
  final FileSystemEntity file;
  final int windowIndex;

  const FileWidget({
    Key? key,
    required this.file,
    required this.windowIndex,
  }) : super(key: key);

  @override
  State<FileWidget> createState() => _FileWidgetState();
}

class _FileWidgetState extends State<FileWidget> {
  bool isSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // toggleFileSelectionAction(FileViewModel fileViewModel) {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FileViewModel>(
      // Convert the store into a bool by checking if this file is selected
      converter: (store) =>
          FileViewModel.fromStore(store, widget.file, widget.windowIndex),
      distinct: true, // Only call builder if this value changes+
      onWillChange: (oldViewModel, newViewModel) {
        // If the selection state of the file hasn't changed, return early and prevent a rebuild
        if (oldViewModel!.isSelected == newViewModel.isSelected) {
          return;
        }
      },
      builder: (context, viewModel) {
        String fileName = p.basename(viewModel.file.path);
        return Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? Colors.green.withOpacity(0.3) : null,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: FileThumbnail(
                  file: viewModel.file,
                  onTap: () {
                    _log.info("Tapped on file ${viewModel.file.path}");
                    Store store =
                        StoreProvider.of<AppState>(context, listen: false);
                    List<FileSystemEntity> selectedFiles =
                        store.state.selectedFiles;
                    _log.info("Selected files: $selectedFiles");

                    // Dispatch an action instead of mutating the state directly
                    // StoreProvider.of<AppState>(context).dispatch(
                    //     ToggleFileSelectionAction(
                    //         viewModel.file, widget.windowIndex));
                  },
                  onLongPress: () {
                    _log.info("Long pressed on file ${widget.file.path}");
                    setState(() {
                      isSelected = !isSelected;
                    });
                    // Dispatch an action instead of mutating the state directly
                    // StoreProvider.of<AppState>(context)
                    //     .dispatch(ToggleFileSelectionAction(viewModel.file));
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
