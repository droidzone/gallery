// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/helpers/utils.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:gallery/views/folder_child_view.dart';
import 'package:gallery/widgets/bottom_nav_bar.dart';
import 'package:gallery/widgets/info_bar.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

import '../resources/constants.dart';

final Logger _log = Logger('StartView');

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
  bool copying = false;

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
    _log.info("App Storage Directory: $dir");
    String path = dir!.path.split("Android")[0];
    _log.info("Internal Storage Directory: $path");
    // List directories in path
    List<FileSystemEntity> files = await Directory(path).list().toList();
    _log.info("No of directories found in $path: ${files.length}");
    List<DirectoryBunch> tmpDirectoryList = [];
    for (FileSystemEntity file in files) {
      if (file is Directory) {
        String name = file.path.split("/").last;
        _log.info("Directory name: $name");
        tmpDirectoryList.add(DirectoryBunch(
          path: file.path,
          name: name,
          imgPath: file.path,
        ));
        // }
      }
    }
    DirectoryBunch tmpFirst = DirectoryBunch(
      path: path,
      name: "Internal Storage",
      imgPath: null,
    );
    _log.info("Setting starting directory to ${tmpFirst.name}");
    await store.dispatch(UpdateDirectoryBunchFirst(tmpFirst));
    await store.dispatch(UpdateDirectoryBunchSecond(tmpFirst));

    setState(() {
      directories = tmpDirectoryList;
      directorybunchFirst = tmpFirst;
      directorybunchSecond = directorybunchFirst;
    });
  }

  void _copyFilesToClipBoard() {
    _log.info("Copying files to clipboard");
    store.dispatch(CopyFilesToClipBoardAction());
  }

  bool areAnyFilesSelected() {
    if (store.state.activeChildWindow == 1) {
      return store.state.selectedFilesFirst!.isNotEmpty;
    } else {
      return store.state.selectedFilesSecond!.isNotEmpty;
    }
  }

  bool isClipBoardEmpty() {
    if (store.state.activeChildWindow == 1) {
      return store.state.clipboardFirst!.isEmpty;
    } else {
      return store.state.clipboardSecond!.isEmpty;
    }
  }

  bool isClipBoardNotEmpty() {
    return !isClipBoardEmpty();
  }

  Future<void> _pasteFromClipBoard() async {
    _log.info("Pasting files from clipboard");
    setState(() {
      copying = true;
    });
    await store.dispatch(PasteFilesFromClipBoardAction());
    String targetPath;
    if (store.state.activeChildWindow == 1) {
      targetPath = store.state.firstBunch!.path;
    } else {
      targetPath = store.state.secondBunch!.path;
    }
    store.dispatch(LoadFilesAction(targetPath, store.state.activeChildWindow!));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store>(
      converter: (store) => store,
      builder: (context, store) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text(
              'Super Gallery',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              areAnyFilesSelected()
                  ? IconButton(
                      onPressed: () {
                        _copyFilesToClipBoard();
                      },
                      icon: Icon(
                        Icons.file_copy_sharp,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ))
                  : Container(),
              isClipBoardNotEmpty()
                  ? IconButton(
                      onPressed: () {
                        _log.info("Pressed paste");
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              _log.info("state is ${store.state}");
                              return AlertDialog(
                                title: const Text(
                                  'Start Copying Files?',
                                  style: kDialogHeadingStyle,
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                          'Do you wish to copy files from clipboard to this directory?',
                                          style: kDialogTextStyle),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Files will be copied to ' +
                                            (store.state.activeChildWindow == 1
                                                ? store.state.firstBunch!.path
                                                : store
                                                    .state.secondBunch!.path),
                                        style: kDialogTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Yes',
                                        style: kButtonOkStyle),
                                    onPressed: () async {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Start Copying Files?',
                                                style: kDialogHeadingStyle,
                                              ),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text('Copying files..',
                                                        style:
                                                            kDialogTextStyle),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(store.state
                                                            .filesLeftToCopy
                                                            .toString() +
                                                        'left to copy'),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                      await _pasteFromClipBoard();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Cancel',
                                      style: kButtonCancelStyle,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      icon: Icon(
                        Icons.content_paste_sharp,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    )
                  : Container(),
              areAnyFilesSelected()
                  ? IconButton(
                      onPressed: () {
                        _log.info("Pressed delete");
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              _log.info("state is ${store.state}");
                              List<FileSystemEntity> filesToDelete = [];
                              filesToDelete = store.state.activeChildWindow == 1
                                  ? store.state.selectedFilesFirst!
                                  : store.state.selectedFilesSecond!;
                              _log.info("files to delete are $filesToDelete");
                              return AlertDialog(
                                title: const Text(
                                  'Really Delete Files?',
                                  style: kDialogHeadingStyle,
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                          'Do you wish to delete these files permanenetly?',
                                          style: kDialogTextStyle),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ...filesToDelete.map(
                                        (e) => Text(
                                          e.path,
                                          style: kDialogTextStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Yes',
                                        style: kButtonOkStyle),
                                    onPressed: () async {
                                      await store.dispatch(
                                          DeleteSelectedFilesAction());
                                      Navigator.of(context).pop();
                                      String targetPath;
                                      if (store.state.activeChildWindow == 1) {
                                        targetPath =
                                            store.state.firstBunch!.path;
                                      } else {
                                        targetPath =
                                            store.state.secondBunch!.path;
                                      }
                                      store.dispatch(LoadFilesAction(targetPath,
                                          store.state.activeChildWindow!));
                                    },
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Cancel',
                                      style: kButtonCancelStyle,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ))
                  : Container(),
              IconButton(
                onPressed: () {
                  _log.info("Pressed split screen");
                  store.dispatch(UpdateScreenSplitAction(!store.state.isSplit));
                },
                icon: Icon(
                  store.state.isSplit != true
                      ? Icons.splitscreen_outlined
                      : Icons.splitscreen,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final totalHeight = constraints.maxHeight;
              topChildHeight =
                  (totalHeight - _topInfoBarHeight - _draggableBarHeight) / 2;
              bottomChildHeight = totalHeight -
                  _draggableTop -
                  50; //Final subtraction is for the bottom nav
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
                            windowIndex: 1,
                          )
                        : Container(),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: _top + _topInfoBarHeight,
                  height: store.state.isSplit
                      ? _draggableTop - 50
                      : totalHeight - _topInfoBarHeight,
                  child: store.state.firstBunch != null
                      ? FolderChildView(
                          windowIndex: 1,
                        )
                      : Container(),
                ),
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
                                windowIndex: 2,
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
                        child: FolderChildView(
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
