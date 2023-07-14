// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/helpers/utils.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:gallery/views/folder_list_view.dart';
import 'package:gallery/widgets/bottom_nav_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

class StartView extends StatefulWidget {
  StartView({super.key});
  final List<Permission> requiredPermissions = [
    Permission.photos,
    Permission.videos,
    Permission.storage,
  ];
  final List<String> mediaDirectories = [
    'DCIM',
    'Pictures',
    'Movies',
    'Music',
    'Download'
  ];

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  List<FileSystemEntity> files = [];

  List<String> availableDirectories = [];
  List<DirectoryBunch> directories = [];

  @override
  void initState() {
    super.initState();
    listMediaDirectories();
  }

  void listMediaDirectories() async {
    Directory? dir = await getExternalStorageDirectory();
    List<DirectoryBunch> tmpDirectoryList = [];
    await getRequiredPermissions(widget.requiredPermissions);

    if (dir != null) {
      for (String directory in widget.mediaDirectories) {
        String path = "${dir.path.split("Android")[0]}$directory";
        try {
          List<FileSystemEntity> files = await Directory(path).list().toList();
          print('Files in $directory: $files');
          // tmpFolderList.add(directory);
          tmpDirectoryList.add(DirectoryBunch(
            path: path,
            name: directory,
            imgPath: files[0].path,
          ));
        } catch (e) {
          print('An error occurred while getting files from $directory: $e');
        }
      }
      setState(() {
        directories = tmpDirectoryList;
      });
    } else {
      print('Directory is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store>(
      converter: (store) => store,
      builder: (context, store) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Super Gallery'),
            actions: [
              IconButton(
                onPressed: () {
                  print("Pressed split screen");
                  store.dispatch(UpdateScreenSplitAction(!store.state.isSplit));
                },
                icon: Icon(
                  store.state.isSplit != true
                      ? Icons.splitscreen_outlined
                      : Icons.splitscreen,
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final totalHeight = constraints.maxHeight;
              final double _draggableBarHeight = 20;
              final double _topInfoBarHeight = 0;

              final topChildHeight =
                  (totalHeight - _draggableBarHeight - _topInfoBarHeight) / 2;
              final bottomChildHeight = totalHeight -
                  topChildHeight; // Subtracting the height of the draggable bar
              double _draggableTop = topChildHeight;
              return Stack(children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: topChildHeight,
                  child: FolderList(directories: directories),
                ),
                Positioned(
                  top: _draggableTop,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onVerticalDragUpdate: (DragUpdateDetails details) {
                      print("Drag update details: ${details.delta.dy}");
                      setState(() {
                        _draggableTop += details.delta.dy;
                      });
                    },
                    child: Container(
                      color: Colors.grey[400],
                      height: _draggableBarHeight, // Standard AppBar height
                      child: Center(
                        child: Icon(
                          Icons.drag_handle,
                          color: Colors.white,
                          size: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: topChildHeight + _draggableBarHeight,
                  left: 0,
                  right: 0,
                  height: bottomChildHeight,
                  child: FolderList(directories: directories),
                ),
                // store.state.isSplit
                //     ? FolderList(directories: directories)
                //     : Container(),
              ]);
            },
          ),
          bottomNavigationBar: const BottomNavigation(),
        );
      },
    );
  }
}
