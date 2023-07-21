// ignore_for_file: prefer_const_constructors

import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery/models/files_view_model.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/views/picture_view.dart';
import 'package:gallery/views/video_view.dart';

import 'dart:io';

import 'package:gallery/structure/directory_bunch.dart';
import 'package:gallery/widgets/directory_widget.dart';
import 'package:gallery/widgets/file_widget.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:gallery/helpers/utils.dart';

final Logger _log = Logger('FolderChildView');

class FolderChildView extends StatefulWidget {
  const FolderChildView({
    Key? key,
    required this.windowIndex,
  }) : super(key: key);
  final int windowIndex;

  @override
  State<FolderChildView> createState() => _FolderChildViewState();
}

class _FolderChildViewState extends State<FolderChildView> {
  final List<FileSystemEntity> _FilteredFiles = [];
  late Store<AppState> store;
  DirectoryBunch? directoryBunch;
  final Logger _log = Logger('FolderChildView');
  List<FileSystemEntity> selectedFiles = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    store = StoreProvider.of<AppState>(context, listen: false);
    _buildFileFilter();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FilesViewModel>(
      converter: (store) => FilesViewModel.fromStore(store, widget.windowIndex),
      distinct: true,
      onWillChange: (previousViewModel, newViewModel) {
        if (previousViewModel!.files == newViewModel.files) {
          _log.info("Files not changed");
          return;
        }
        _log.info("Files changed");
      },

      //  shouldUpdate: (previousViewModel, newViewModel) =>
      //     previousViewModel.files != newViewModel.files,
      builder: (context, viewModel) {
        return Stack(
          children: [
            Scaffold(
              body: viewModel.files.isEmpty
                  ? Center(
                      child: Text('No files found'),
                    )
                  : InkWell(
                      onTap: () {
                        StoreProvider.of<AppState>(context).dispatch(
                            UpdateActiveChildWindow(widget.windowIndex));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: viewModel.isSplit &&
                                  widget.windowIndex ==
                                      viewModel.activeChildWindow
                              ? Colors.lime[50]
                              : Colors.white,
                          child: GridView.builder(
                            padding: EdgeInsets.only(bottom: 50, top: 20),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 50,
                                    mainAxisSpacing: 20),
                            itemCount: viewModel.files.length,
                            itemBuilder: (context, index) {
                              if (isMediaFile(viewModel.files[index])) {
                                return FileWidget(
                                  file: viewModel.files[index],
                                  windowIndex: widget.windowIndex,
                                );
                              } else {
                                return DirectoryWidget(
                                  directory: viewModel.files[index],
                                  windowIndex: widget.windowIndex,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void updateState(DirectoryBunch newBunch) {
    if (widget.windowIndex == 1) {
      _log.info("We are in the first window");
      store.dispatch(UpdateDirectoryBunchFirst(newBunch));
    } else {
      _log.info("We are in the second window");
      store.dispatch(UpdateDirectoryBunchSecond(newBunch));
    }
  }

  Future<bool> _buildFileFilter() async {
    _log.info("Building file filter...");
    _log.info("store is $store");
    final Directory directory = Directory(store.state.firstBunch!.path);

    try {
      List<FileSystemEntity> tmpFiles = directory
          .listSync(); //At this point, we might get a Unhandled Exception: PathAccessException: Directory listing failed, path = '/storage/emulated/0/Android/data/' (OS Error: Permission denied, errno = 13) We need to handle it with try catch. If there is an error, display a toast message to the user that the app needs permission to access the files.

      _log.info("Files: $tmpFiles");
      store.dispatch(UpdateFilesAction(tmpFiles, widget.windowIndex));
      return true;
    } on Exception catch (e) {
      _log.info('An error occurred while accessing the directory: $e');
      Fluttertoast.showToast(
          msg: "No permission to access this directory!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
  }

  String formatFileName(String fileName) {
    if (fileName.length > 15) {
      String first = fileName.substring(0, 7);
      String last = fileName.substring(fileName.length - 8);
      return '$first..$last';
    }
    return fileName;
  }

  _handleFileSelection(file) {
    _log.info("Handling file selection for file $file");
    setState(() {
      if (selectedFiles.isNotEmpty) {
        _log.info("Selected files is not empty");
        if (selectedFiles.contains(file)) {
          _log.info("Selected files contains file. Removing from selection");
          selectedFiles.remove(file);
          return;
        } else {
          _log.info(
              "Selected files does not contain file. Adding to selection");
          selectedFiles.add(file);
        }
      } else {
        _log.info("Selected files is empty. Adding file to selection");
        selectedFiles.add(file);
      }
    });
  }

  _longPressFile(file) {
    _log.info("Handling long press for file $file");
    store.dispatch(SelectFileAction(file, widget.windowIndex));
    return;
  }

  _singleTapFile(context, file) {
    _log.info("Tapped file");
    if (widget.windowIndex == 1) {
      _log.info("We are in the first window");
      if (store.state.selectedFilesFirst!.isNotEmpty) {
        store.dispatch(SelectFileAction(file, widget.windowIndex));
        return;
      }
    } else {
      _log.info("We are in the second window");
      if (store.state.selectedFilesSecond!.isNotEmpty) {
        store.dispatch(SelectFileAction(file, widget.windowIndex));
        return;
      }
    }
    String extension = p.extension(file.path).toLowerCase();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      if (extension == '.mp4') {
        return FullScreenVideoView(
          videoPath: file.path,
        );
      } else {
        return FullScreenImageView(
          imagePath: file.path,
        );
      }
    }));
  }

  bool isFileSelected(FileSystemEntity file) {
    if (selectedFiles.contains(file)) {
      return true;
    }
    return false;
  }
}
