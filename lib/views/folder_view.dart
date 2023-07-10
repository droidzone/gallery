// ignore_for_file: prefer_const_constructors
import 'package:flutter/foundation.dart';
import 'package:gallery/views/picture_view.dart';
import 'package:gallery/views/video_view.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery/structure/directory_bunch.dart';
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

  @override
  void initState() {
    super.initState();
    _buildFileFilter();
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

  // Future<void> _listFiles() async {
  //   final Directory directory = Directory(widget.directoryBunch.path);
  //   setState(() {
  //     _AllFiles = directory.listSync();
  //     print("Files: $_AllFiles");
  //   });
  // }

  bool _isMediaFile(String filePath) {
    final RegExp regExp =
        RegExp(r"\.(gif|jpe?g|tiff?|png|webp|bmp|mp4)$", caseSensitive: false);
    return regExp.hasMatch(filePath);
  }

  Future<void> loadFolder(BuildContext context, selectedFolder) async {
    // context, path, name, imgpath)

    List<FileSystemEntity> files =
        await Directory(selectedFolder.path).list().toList();
    String dirName = basename(selectedFolder.path);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FolderView(
        directoryBunch: DirectoryBunch(
          path: selectedFolder.path,
          name: dirName,
          imgPath: files[0].path,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: GridView.builder(
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
              onTap: () {
                print('Tapped on media file $fileName');
                String extension =
                    p.extension(_FilteredFiles[index].path).toLowerCase();
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
              },
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Align(
                        alignment: Alignment.center, child: Text(fileName)),
                  ),
                  Expanded(
                    flex: 2,
                    child: FutureBuilder(
                      future: _getThumbnail(_AllFiles[index].path),
                      builder: (BuildContext context,
                          AsyncSnapshot<Uint8List> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ),

                  // Expanded(
                  //   flex: 2,
                  //   child: Container(
                  //     child: Image.file(
                  //       File(_AllFiles[index].path),
                  //       fit: BoxFit.contain,
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('${formattedDate.toString()}')),
                  ),
                ],
              ),
            );
          } else if (_AllFiles[index] is Directory) {
            print("Directory found: ${_AllFiles[index]}");
            String dirName = basename(_AllFiles[index].path);
            return InkWell(
              onTap: () async {
                print('Tapped on folder $dirName');

                // print("Files: $files");
                print("Loading new folder view");
                loadFolder(context, _AllFiles[index]);
                // loadFolder(
                //     context, _AllFiles[index].path, dirName, files[0].path);
                // print('Files in $directory: $files');
                // tmpFolderList.add(directory);
              },
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Icon(
                      Icons.folder,
                      size: 100,
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.center, child: Text(dirName)),
                  ),
                ],
              ),
            );
          } else {
            print("Found non media file: ${_AllFiles[index]}. Not displaying");
            return Container();
          }
        },
      ),
    );
  }
}
