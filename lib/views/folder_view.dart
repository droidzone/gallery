// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:gallery/views/picture_view.dart';
import 'package:gallery/views/video_view.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as p;

class FolderView extends StatefulWidget {
  const FolderView({Key? key, required this.directoryBunch}) : super(key: key);

  final DirectoryBunch directoryBunch;

  @override
  State<FolderView> createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  List<FileSystemEntity> _AllFiles = [];
  List<FileSystemEntity> _FilteredFiles = [];
  List<File> _selectedFiles = [];

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
    List<FileSystemEntity> _tmpFiles = directory.listSync();
    // _files = directory.listSync();
    print("Files: $_tmpFiles");

    for (var file in _tmpFiles) {
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

    List<FileSystemEntity> files =
        await Directory(selectedFolder.path).list().toList();
    print("Files: $files No: ${files.length}");

    String dirName = basename(selectedFolder.path);

    // ignore: use_build_context_synchronously
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FolderView(
        directoryBunch: DirectoryBunch(
          path: selectedFolder.path,
          name: dirName,
          imgPath: files.isEmpty ? null : files[0].path,
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

  void _sortByName(bool ascending) {
    _FilteredFiles.sort((a, b) {
      return ascending
          ? basename(a.path).compareTo(basename(b.path))
          : basename(b.path).compareTo(basename(a.path));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: <Widget>[
          _selectedFiles.length > 0
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
                  _sortByName(true);
                  break;
                case 'Name Descending':
                  _sortByName(false);
                  break;
                case 'Creation Date Ascending':
                  _sortByCreationDate(true);
                  break;
                case 'Creation Date Descending':
                  _sortByCreationDate(false);
                  break;
                case 'Modification Date Ascending':
                  _sortByModificationDate(true);
                  break;
                case 'Modification Date Descending':
                  _sortByModificationDate(false);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
      body: _FilteredFiles.length == 0
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
                  DateTime modificationDate =
                      _FilteredFiles[index].statSync().modified;
                  String formattedDate =
                      DateFormat('dd-MM-yyyy').format(modificationDate);

                  String fileName = basename(_FilteredFiles[index].path);
                  return InkWell(
                    onLongPress: () {
                      setState(() {
                        if (_selectedFiles.contains(_FilteredFiles[index])) {
                          _selectedFiles.remove(_FilteredFiles[index] as File);
                        } else {
                          _selectedFiles.add(_FilteredFiles[index] as File);
                        }
                      });
                    },
                    onTap: () {
                      if (_selectedFiles.isNotEmpty) {
                        setState(() {
                          if (_selectedFiles.contains(_FilteredFiles[index])) {
                            _selectedFiles
                                .remove(_FilteredFiles[index] as File);
                          } else {
                            _selectedFiles.add(_FilteredFiles[index] as File);
                          }
                        });
                      } else {
                        print('Tapped on media file $fileName');
                        String extension = p
                            .extension(_FilteredFiles[index].path)
                            .toLowerCase();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
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
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        color: _selectedFiles.contains(_FilteredFiles[index])
                            ? Colors.green.withOpacity(0.3)
                            : null,
                        // decoration: BoxDecoration(
                        //   border: Border.all(
                        //     color: _selectedFiles.contains(_FilteredFiles[index])
                        //         ? Colors.blue
                        //         : Colors.transparent,
                        //     width: 3.0,
                        //   ),
                        // ),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Wrap(
                                    children: [Text(fileName)],
                                  )),
                            ),
                            Expanded(
                              flex: 5,
                              child: FutureBuilder(
                                future: _getThumbnail(_AllFiles[index].path),
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
                                  child: Text('${formattedDate.toString()}')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (_AllFiles[index] is Directory) {
                  print("Directory found: ${_AllFiles[index]}");
                  String dirName = basename(_AllFiles[index].path);
                  return InkWell(
                    onTap: () async {
                      print('Tapped on folder $dirName');
                      print("Loading new folder view");
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
                      "Found non media file: ${_AllFiles[index]}. Not displaying");
                  return Container();
                }
              },
            ),
    );
  }
}
