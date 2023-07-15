// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/helpers/utils.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:gallery/views/folder_child_view.dart';
import 'package:gallery/views/folder_list_view.dart';
import 'package:gallery/widgets/bottom_nav_bar.dart';
import 'package:gallery/widgets/info_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

class StartView extends StatefulWidget {
  StartView({Key? key}) : super(key: key);
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
  late double _top = 0;
  double _draggableBarHeight = 20;
  double _draggableTop = 0;
  double _topInfoBarHeight = 20;
  late double topChildHeight;
  late double bottomChildHeight;
  double _draggableDelta = 0;
  DirectoryBunch? directorybunchFirst = null;
  DirectoryBunch? directorybunchSecond = null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _draggableTop = (MediaQuery.of(context).size.height -
              _topInfoBarHeight -
              _draggableBarHeight) /
          2;
      setState(() {});
    });
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
              topChildHeight =
                  (totalHeight - _topInfoBarHeight - _draggableBarHeight) / 2;
              bottomChildHeight = totalHeight - topChildHeight;
              return Stack(children: [
                // This is the first child
                Positioned(
                  top: _top,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.grey[400],
                    height: _topInfoBarHeight, // Standard AppBar height
                    child: InfoBar(),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: _top + _topInfoBarHeight,
                  height: store.state.isSplit
                      ? _draggableTop
                      : totalHeight - _topInfoBarHeight,
                  child: directorybunchFirst == null
                      ? FolderList(
                          directories: directories,
                          onClick: (DirectoryBunch directorybunch) {
                            print("Clicked on ${directorybunch.name}");
                            setState(() {
                              directorybunchFirst = directorybunch;
                            });
                          })
                      : FolderChildView(
                          directoryBunch: directorybunchFirst!,
                          windowIndex: 1,
                        ),
                ),
                // The following is the bar which can be used to partition the vertical space between the two children
                store.state.isSplit
                    ? Positioned(
                        top: _draggableTop,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onVerticalDragUpdate: (DragUpdateDetails details) {
                            setState(() {
                              double delta = details.delta.dy;
                              _draggableTop += delta;
                              print("\nDrag update details: Delta: ${delta}");
                              print(
                                  "_draggableTop: $_draggableTop firstchild height:${totalHeight - _topInfoBarHeight + _draggableTop}");
                              print(
                                  "Infobar bottom: ${_top + _topInfoBarHeight}");
                              if (_draggableTop < (_top + _topInfoBarHeight)) {
                                _draggableTop = _top + _topInfoBarHeight;
                              }
                            });
                          },
                          child: Container(
                            color: Colors.grey[400],
                            height:
                                _draggableBarHeight, // Standard AppBar height
                            child: Center(
                              child: Icon(
                                Icons.drag_handle,
                                color: Colors.white,
                                size: 8,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                store.state.isSplit
                    ? Positioned(
                        top: _draggableTop +
                            _draggableBarHeight, // Adding the height of the draggable bar
                        left: 0,
                        right: 0,
                        height: bottomChildHeight,
                        child: directorybunchSecond == null
                            ? FolderList(
                                directories: directories,
                                onClick: (DirectoryBunch directorybunch) {
                                  print("Clicked on ${directorybunch.name}");
                                  setState(() {
                                    directorybunchSecond = directorybunch;
                                  });
                                })
                            : FolderChildView(
                                directoryBunch: directorybunchSecond!,
                                windowIndex: 2,
                              ),
                      )
                    : Container(),
              ]);
            },
          ),
          bottomNavigationBar: const BottomNavigation(),
        );
      },
    );
  }
}
