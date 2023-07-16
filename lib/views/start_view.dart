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

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  List<FileSystemEntity> files = [];

  List<String> availableDirectories = [];
  List<DirectoryBunch> directories = [];
  final double _top = 0;
  final double _draggableBarHeight = 40;
  double _draggableTop = 0;
  final double _topInfoBarHeight = 40;
  late double topChildHeight;
  late double bottomChildHeight;
  DirectoryBunch? directorybunchFirst;
  DirectoryBunch? directorybunchSecond;
  late Store<AppState> store;

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
    _listMediaDirectories();
    store = StoreProvider.of<AppState>(context, listen: false);
  }

  void _listMediaDirectories() async {
    await getRequiredPermissions(widget.requiredPermissions);
    Directory? dir = await getExternalStorageDirectory();
    print("App Storage Directory: $dir");
    String path = "${dir!.path.split("Android")[0]}";
    print("Internal Storage Directory: $path");
    // List directories in path
    List<FileSystemEntity> files = await Directory(path).list().toList();
    print("No of directories found in $path: ${files.length}");
    List<DirectoryBunch> tmpDirectoryList = [];
    for (FileSystemEntity file in files) {
      if (file is Directory) {
        String name = file.path.split("/").last;
        print("Directory name: $name");
        // if (widget.mediaDirectories.contains(name)) {
        tmpDirectoryList.add(DirectoryBunch(
          path: file.path,
          name: name,
          imgPath: file.path,
        ));
        // }
      }
    }
    DirectoryBunch _tmpFirst = DirectoryBunch(
      path: path,
      name: "Internal Storage",
      imgPath: null,
    );
    print("Setting starting directory to ${_tmpFirst.name}");
    await store.dispatch(UpdateDirectoryBunchFirst(_tmpFirst!));
    await store.dispatch(UpdateDirectoryBunchSecond(_tmpFirst!));

    setState(() {
      directories = tmpDirectoryList;
      directorybunchFirst = _tmpFirst;
      directorybunchSecond = directorybunchFirst;
    });
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
                    child: store.state.firstBunch != null
                        ? InfoBar(
                            directorybunch: store.state.firstBunch,
                            windowIndex: 1,
                            changeDirCallBack: (DirectoryBunch directoryBunch) {
                              print(
                                  "Navigating first window to ${directoryBunch.path} from start_view...");
                              setState(() {
                                directorybunchFirst = directoryBunch;
                                store.dispatch(
                                    UpdateDirectoryBunchFirst(directoryBunch));
                              });
                            },
                          )
                        : Container(),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: _top + _topInfoBarHeight,
                  height: store.state.isSplit
                      ? _draggableTop
                      : totalHeight - _topInfoBarHeight,
                  child: store.state.firstBunch != null
                      ? FolderChildView(
                          // directoryBunch: store.state.firstBunch,
                          windowIndex: 1,
                          // onNavigate: (DirectoryBunch directoryBunch) {
                          //   setState(() {
                          //     print(
                          //         "Navigating first window to ${directoryBunch.name} from start_view...");
                          //     directorybunchFirst = directoryBunch;
                          //   });
                          // },
                        )
                      : Container(),
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
                              child: InfoBar(
                                directorybunch: store.state.secondBunch,
                                windowIndex: 2,
                                changeDirCallBack:
                                    (DirectoryBunch directoryBunch) {
                                  setState(() {
                                    print(
                                        "Navigating second window to ${directoryBunch.name} from start_view...");
                                    directorybunchSecond = directoryBunch;
                                  });
                                },
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
                        child:
                            //  directorybunchSecond == null
                            //     ? FolderList(
                            //         directories: directories,
                            //         onClick: (DirectoryBunch directorybunch) {
                            //           print("Clicked on ${directorybunch.name}");
                            //           setState(() {
                            //             directorybunchSecond = directorybunch;
                            //           });
                            //         })
                            //     :
                            FolderChildView(
                          // directoryBunch: store.state.secondBunch,
                          windowIndex: 2,
                          // onNavigate: (DirectoryBunch directoryBunch) {
                          //   setState(() {
                          //     directorybunchFirst = directoryBunch;
                          //   });
                          // },
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
