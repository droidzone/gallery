// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/helpers/utils.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/views/picture_view.dart';
import 'package:gallery/views/video_view.dart';
import 'package:gallery/widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as p;
import 'package:redux/redux.dart';

class FolderView extends StatefulWidget {
  const FolderView({Key? key, required this.directoryBunch}) : super(key: key);

  final DirectoryBunch directoryBunch;

  @override
  State<FolderView> createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  List<FileSystemEntity> _AllFiles = [];
  List<FileSystemEntity> _FilteredFiles = [];
  final List<File> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
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

  void _buildFileFilter() {
    print("Building file filter...");
    print("Directory: ${widget.directoryBunch.path}");
    List<FileSystemEntity> files = [];
    final Directory directory = Directory(widget.directoryBunch.path);
    List<FileSystemEntity> tmpFiles = directory.listSync();
    // _files = directory.listSync();
    print("Files: $tmpFiles");

    for (var file in tmpFiles) {
      if (file is File) {
        print("$file is a file");
      } else {
        print("$file is not a file");
      }
      files.add(file);
    }
    setState(() {
      _AllFiles = files;
      _FilteredFiles = files;
    });
  }

  bool _isMediaFile(String filePath) {
    final RegExp regExp =
        RegExp(r"\.(gif|jpe?g|tiff?|png|webp|bmp|mp4)$", caseSensitive: false);
    return regExp.hasMatch(filePath);
  }

  Future<void> loadFolder(BuildContext context, selectedFolder) async {
    print("Loading folder...");

    // This line brings prewiew image of the folder, but is performance heavy
    // List<FileSystemEntity> files =
    //     await Directory(selectedFolder.path).list().toList();
    // print("Files: $files No: ${files.length}");

    String dirName = basename(selectedFolder.path);

    // ignore: use_build_context_synchronously
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FolderView(
        directoryBunch: DirectoryBunch(
          path: selectedFolder.path,
          name: dirName,
          imgPath: null,
          // imgPath: files.isEmpty ? null : files[0].path,
        ),
      );
    }));
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

  String formatFileName(String fileName) {
    if (fileName.length > 20) {
      String first = fileName.substring(0, 15);
      String last = fileName.substring(fileName.length - 8);
      return '$first..$last';
    }
    return fileName;
  }

  void _longPressFile(index) {
    print("Long pressed file");
    setState(() {
      if (_selectedFiles.contains(_FilteredFiles[index])) {
        _selectedFiles.remove(_FilteredFiles[index] as File);
      } else {
        _selectedFiles.add(_FilteredFiles[index] as File);
      }
    });
  }

  String _formattedDate(index) {
    DateTime modificationDate = _FilteredFiles[index].statSync().modified;

    String formattedDate = DateFormat('dd-MM-yyyy').format(modificationDate);
    return formattedDate;
  }

  void _singleTapFile(context, index) {
    print("Tapped file");
    if (_selectedFiles.isNotEmpty) {
      setState(() {
        if (_selectedFiles.contains(_FilteredFiles[index])) {
          _selectedFiles.remove(_FilteredFiles[index] as File);
        } else {
          _selectedFiles.add(_FilteredFiles[index] as File);
        }
      });
    } else {
      String extension = p.extension(_FilteredFiles[index].path).toLowerCase();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        if (extension == '.mp4') {
          return FullScreenVideoView(
            videoPath: _FilteredFiles[index].path,
          );
        } else {
          return FullScreenImageView(
            imagePath: _FilteredFiles[index].path,
          );
        }
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store>(
      converter: (store) => store,
      builder: (context, store) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text('Gallery'),
                actions: <Widget>[
                  store.state.selectedFiles.length > 0
                      ? IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            print("Copy button pressed");
                          },
                        )
                      : Container(),
                  // Add a button for Sort
                  PopupMenuButton<String>(
                    icon: Icon(Icons.sort), // Use an icon button
                    onSelected: (String result) {
                      switch (result) {
                        case 'Name Ascending':
                          sortByName(true, store.state.filteredFiles);
                          break;
                        case 'Name Descending':
                          sortByName(false, store.state.filteredFiles);
                          break;
                        case 'Creation Date Ascending':
                          sortByCreationDate(true, store.state.filteredFiles);
                          break;
                        case 'Creation Date Descending':
                          sortByCreationDate(false, store.state.filteredFiles);
                          break;
                        case 'Modification Date Ascending':
                          sortByModificationDate(
                              true, store.state.filteredFiles);
                          break;
                        case 'Modification Date Descending':
                          sortByModificationDate(
                              false, store.state.filteredFiles);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Name Ascending',
                        child: Text('Name Ascending'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Name Descending',
                        child: Text('Name Descending'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Creation Date Ascending',
                        child: Text('Creation Date Ascending'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Creation Date Descending',
                        child: Text('Creation Date Descending'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Modification Date Ascending',
                        child: Text('Modification Date Ascending'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Modification Date Descending',
                        child: Text('Modification Date Descending'),
                      ),
                    ],
                  ),
                  // Add a normal action button for Copy
                ],
              ),
              body: _FilteredFiles.isEmpty
                  ? Container(
                      child: Center(
                        child: Text('No files found'),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: _FilteredFiles.length,
                      itemBuilder: (context, index) {
                        if (_isMediaFile(_FilteredFiles[index].path)) {
                          print("Media File found: ${_FilteredFiles[index]}");

                          String fileName =
                              basename(_FilteredFiles[index].path);
                          return InkWell(
                            onLongPress: () {
                              _longPressFile(index);
                            },
                            onTap: () {
                              _singleTapFile(context, index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                color: _selectedFiles
                                        .contains(_FilteredFiles[index])
                                    ? Colors.green.withOpacity(0.3)
                                    : null,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Wrap(
                                            children: [
                                              Text(formatFileName(fileName))
                                            ],
                                          )),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: FutureBuilder(
                                        future: _getThumbnail(
                                            _AllFiles[index].path),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<Uint8List> snapshot) {
                                          if (snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              snapshot.hasData) {
                                            return Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.contain,
                                            );
                                          } else {
                                            return Text('Loading...');
                                          }
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text(_formattedDate(index))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (_FilteredFiles[index] is Directory &&
                            store.state.mainviewCurrentTab == 'Folders') {
                          print("Directory found: ${_AllFiles[index]}");
                          print("currentview: ${store.state.currentView}");
                          //  &&
                          //   store.state.currentView == 'Folders'
                          String dirName = basename(_AllFiles[index].path);
                          return InkWell(
                            onTap: () async {
                              loadFolder(context, _AllFiles[index]);
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
                        } else {
                          print(
                              "Found non media file: ${_FilteredFiles[index]}, or view is set to Gallery and directories are being hidden. Not displaying");
                          return Container();
                        }
                      },
                    ),
              bottomNavigationBar: BottomNavigation(),
            ),
          ],
        );
      },
    );
  }
}
