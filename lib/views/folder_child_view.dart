// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/views/picture_view.dart';
import 'package:gallery/views/video_view.dart';

import 'package:intl/intl.dart';

import 'dart:io';

import 'package:gallery/structure/directory_bunch.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as p;
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';

class FolderChildView extends StatefulWidget {
  FolderChildView({
    Key? key,
    // required this.directoryBunch,
    required this.windowIndex,
    // required this.onNavigate,
    // required this.onPaste,
  }) : super(key: key);
  // Function onNavigate;
  // final DirectoryBunch directoryBunch;
  // final Function onPaste;
  int windowIndex;

  @override
  State<FolderChildView> createState() => _FolderChildViewState();
}

class _FolderChildViewState extends State<FolderChildView> {
  List<FileSystemEntity> _FilteredFiles = [];
  late Store<AppState> store;
  DirectoryBunch? directoryBunch;

  @override
  void initState() {
    super.initState();
    // directoryBunch = widget.directoryBunch;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    store = StoreProvider.of<AppState>(context, listen: false);
    _buildFileFilter();
  }

  Future requestPermission(Permission permission) async {
    print("Requesting permission: $permission");
    PermissionStatus status = await permission.status;
    print("Permission status: $status");

    if (status.isPermanentlyDenied) {
      print("Permission is permanently denied");
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    } else if (status.isDenied) {
      print("Permission is denied");
      // The user did not grant the permission.
      // You can display the permission dialog again and ask the user for
      // permission.
      status = await permission.request();
      print("Permission status on requesting again: $status");
    } else {
      print("Permission is not permanently denied");
      // You can request the permission again.
      status = await permission.request();
    }
  }

  void updateState(DirectoryBunch _newBunch) {
    if (widget.windowIndex == 1) {
      print("We are in the first window");
      store.dispatch(UpdateDirectoryBunchFirst(_newBunch));
    } else {
      print("We are in the second window");
      store.dispatch(UpdateDirectoryBunchSecond(_newBunch));
    }
  }

  Future<bool> _buildFileFilter() async {
    print("Building file filter...");
    // print("Directory: ${directoryBunch!.path}");
    print("store is $store");
    final Directory directory = Directory(store.state.firstBunch!.path);

    try {
      List<FileSystemEntity> tmpFiles = directory
          .listSync(); //At this point, we might get a Unhandled Exception: PathAccessException: Directory listing failed, path = '/storage/emulated/0/Android/data/' (OS Error: Permission denied, errno = 13) We need to handle it with try catch. If there is an error, display a toast message to the user that the app needs permission to access the files.

      print("Files: $tmpFiles");
      store.dispatch(UpdateFilesAction(tmpFiles, widget.windowIndex));
      return true;
    } on Exception catch (e) {
      print('An error occurred while accessing the directory: $e');
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

  bool _isMediaFileOld(String filePath) {
    final RegExp regExp =
        RegExp(r"\.(gif|jpe?g|tiff?|png|webp|bmp|mp4)$", caseSensitive: false);
    return regExp.hasMatch(filePath);
  }

  bool isMediaFile(FileSystemEntity _file) {
    if (_file is Directory) {
      return false;
    } else {
      final RegExp regExp = RegExp(r"\.(gif|jpe?g|tiff?|png|webp|bmp|mp4)$",
          caseSensitive: false);
      return regExp.hasMatch(_file.path);
    }
  }

  Future<void> loadFolder(BuildContext context, selectedFolder) async {
    print("In FolderChildView: Loading folder: $selectedFolder");

    // This line brings prewiew image of the folder, but is performance heavy
    // List<FileSystemEntity> files =
    //     await Directory(selectedFolder.path).list().toList();
    // print("Files: $files No: ${files.length}");

    String dirName = p.basename(selectedFolder.path);

    // if is split, refresh the dir location without navigating to it
    // if (store.state.isSplit!) {
    // print("We are in a split view");
    DirectoryBunch _newBunch = DirectoryBunch(
      path: selectedFolder.path,
      name: dirName,
      imgPath: null,
      // imgPath: files.isEmpty ? null : files[0].path,
    );

    setState(() {
      directoryBunch = _newBunch;
    });
    // widget.onNavigate(directoryBunch);
    bool successfulChangeDirectory = await _buildFileFilter();
    if (successfulChangeDirectory) {
      updateState(_newBunch);
    }
  }

  Future<Uint8List> _getThumbnail(String path) async {
    String extension = p.extension(path).toLowerCase();
    if (extension == '.mp4') {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth:
            128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 25,
      );
      return uint8list!;
    } else {
      final file = File(path);
      return file.readAsBytesSync();
    }
  }

  void _sortByName(bool ascending) {
    _FilteredFiles.sort((a, b) {
      return ascending
          ? p.basename(a.path).compareTo(p.basename(b.path))
          : p.basename(b.path).compareTo(p.basename(a.path));
    });
    setState(() {});
  }

  void _sortByCreationDate(bool ascending) {
    _FilteredFiles.sort((a, b) {
      return ascending
          ? a.statSync().changed.compareTo(b.statSync().changed)
          : b.statSync().changed.compareTo(a.statSync().changed);
    });
    setState(() {});
  }

  void _sortByModificationDate(bool ascending) {
    _FilteredFiles.sort((a, b) {
      return ascending
          ? a.statSync().modified.compareTo(b.statSync().modified)
          : b.statSync().modified.compareTo(a.statSync().modified);
    });
    setState(() {});
  }

  String formatFileName(String fileName) {
    if (fileName.length > 15) {
      String first = fileName.substring(0, 7);
      String last = fileName.substring(fileName.length - 8);
      return '$first..$last';
    }
    return fileName;
  }

  void _longPressFile(_file) {
    setState(() {
      if (store.state.selectedFiles!.contains(_file)) {
        store.state.selectedFiles!.remove(_file as File);
      } else {
        store.state.selectedFiles!.add(_file as File);
      }
    });
  }

  String _formattedDate(_file) {
    DateTime modificationDate = _file.statSync().modified;

    String formattedDate = DateFormat('dd-MM-yyyy').format(modificationDate);
    return formattedDate;
  }

  String _formattedDD(_file) {
    DateTime modificationDate = _file.statSync().modified;

    String formattedDate = DateFormat('dd').format(modificationDate);
    return formattedDate;
  }

  String _formattedMonth(_file) {
    DateTime modificationDate = _file.statSync().modified;

    String formattedDate = DateFormat('MMM').format(modificationDate);
    return formattedDate;
  }

  void _singleTapFile(context, _file) {
    print("Tapped file");
    if (store.state.selectedFiles!.isNotEmpty) {
      setState(() {
        if (store.state.selectedFiles!.contains(_file)) {
          store.state.selectedFiles!.remove(_file as File);
        } else {
          store.state.selectedFiles!.add(_file as File);
        }
      });
    } else {
      String extension = p.extension(_file.path).toLowerCase();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        if (extension == '.mp4') {
          return FullScreenVideoView(
            videoPath: _file.path,
          );
        } else {
          return FullScreenImageView(
            imagePath: _file.path,
          );
        }
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //     "In FolderChildView build method, directoryBunch is ${directoryBunch!.path}");
    // print("store is $store");
    return StoreConnector<AppState, Store>(
      converter: (store) => store,
      builder: (context, store) {
        // print(
        //     "In FolderChildView build method, store is $store. It is rebuilding...");
        List<FileSystemEntity> files = [];
        List<FileSystemEntity> allfiles = widget.windowIndex == 1
            ? store.state.firstFiles
            : store.state.secondFiles;
        List<FileSystemEntity> mediaFiles =
            allfiles.where((file) => isMediaFile(file)).toList();
        if (store.state.mainviewCurrentTab == "Media") {
          files = mediaFiles;
        } else {
          files = allfiles;
        }
        return Stack(
          children: [
            Scaffold(
              body: files.isEmpty
                  ? Center(
                      child: Text('No files found'),
                    )
                  : InkWell(
                      onTap: () {
                        store.dispatch(
                            UpdateActiveChildWindow(widget.windowIndex));
                      },
                      child: Container(
                        color: store.state.isSplit &&
                                widget.windowIndex ==
                                    store.state.activeChildWindow
                            ? Colors.blue[50]
                            : Colors.white,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            if (isMediaFile(files[index])) {
                              // print("Media File found");

                              String fileName = p.basename(files[index].path);
                              return Container(
                                margin: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: store.state.selectedFiles!
                                          .contains(files[index])
                                      ? Colors.green.withOpacity(0.3)
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          // Draw a border around each file
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: InkWell(
                                          onLongPress: () {
                                            _longPressFile(files[index]);
                                          },
                                          onTap: () {
                                            _singleTapFile(
                                                context, files[index]);
                                          },
                                          child: Stack(
                                            children: [
                                              FutureBuilder(
                                                future: _getThumbnail(
                                                    files[index].path),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<Uint8List>
                                                        snapshot) {
                                                  if (snapshot.connectionState ==
                                                          ConnectionState
                                                              .done &&
                                                      snapshot.hasData) {
                                                    return Image.memory(
                                                      snapshot.data!,
                                                      fit: BoxFit.contain,
                                                      height: 100,
                                                    );
                                                  } else {
                                                    return Text('Loading...');
                                                  }
                                                },
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        _formattedDD(
                                                            files[index]),
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        _formattedMonth(
                                                            files[index]),
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Wrap(
                                            children: [
                                              Text(formatFileName(fileName))
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // print("Directory found: ${_files[index]}");
                              // print("currentview: ${store.state.currentView}");
                              //  &&
                              //   store.state.currentView == 'Folders'
                              String dirName = p.basename(files[index].path);
                              return InkWell(
                                onTap: () async {
                                  // loadFolder(context, _AllFiles[index]);
                                  store.dispatch(ChangeDirectoryAction(
                                      files[index].path, widget.windowIndex));
                                },
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Icon(
                                        Icons.folder,
                                        size: 160,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text(dirName)),
                                    ),
                                  ],
                                ),
                              );
                            }
                            // else {
                            //   print(
                            //       "Found non media file: ${_files[index]}, or view is set to Gallery and directories are being hidden. Not displaying");
                            //   return Container();
                            // }
                          },
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
