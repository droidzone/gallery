// ignore_for_file: prefer_const_constructors
import 'package:gallery/views/picture_view.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery/structure/directory_bunch.dart';

class FolderView extends StatefulWidget {
  const FolderView({Key? key, required this.directoryBunch}) : super(key: key);

  final DirectoryBunch directoryBunch;

  @override
  State<FolderView> createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _listFiles();
  }

  Future<void> _listFiles() async {
    final Directory directory = Directory(widget.directoryBunch.path);
    setState(() {
      _files = directory.listSync();
      print("Files: $_files");
    });
  }

  bool _isMediaFile(String filePath) {
    final RegExp regExp =
        RegExp(r"\.(gif|jpe?g|tiff?|png|webp|bmp|mp4)$", caseSensitive: false);
    return regExp.hasMatch(filePath);
  }

  Future<void> loadFolder(context, path, name, imgpath) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FolderView(
        directoryBunch: DirectoryBunch(
          path: path,
          name: name,
          imgPath: imgpath,
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: _files.length,
        itemBuilder: (context, index) {
          if (_isMediaFile(_files[index].path)) {
            DateTime modificationDate = _files[index].statSync().modified;
            String formattedDate =
                DateFormat('dd-MM-yyyy').format(modificationDate);

            String fileName = basename(_files[index].path);
            return InkWell(
              onTap: () {
                print('Tapped on $fileName');
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FullScreenImageView(
                    imagePath: _files[index].path,
                  );
                }));
                // FullScreenImageView
              },
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Align(
                        alignment: Alignment.center, child: Text(fileName)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Image.file(
                        File(_files[index].path),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('${formattedDate.toString()}')),
                  ),
                ],
              ),
            );
          } else if (_files[index] is Directory) {
            String dirName = basename(_files[index].path);
            return InkWell(
              onTap: () async {
                print('Tapped on $dirName');
                List<FileSystemEntity> files =
                    await Directory(_files[index].path).list().toList();
                print("Files: $files");
                print("Loading new folder view");
                loadFolder(context, _files[index].path, dirName, files[0].path);
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
            return Container();
          }
        },
      ),
    );
  }
}
