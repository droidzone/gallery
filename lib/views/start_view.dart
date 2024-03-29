// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/helpers/utils.dart';
import 'package:gallery/models/mainscreen_view_model.dart';
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
import 'package:path/path.dart' as Path;

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
  // late Store<AppState> store;
  bool copying = false;

  @override
  void initState() {
    super.initState();
    _log.info("Init state");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _draggableTop = (MediaQuery.of(context).size.height -
              _topInfoBarHeight -
              _draggableBarHeight) /
          2;
      setState(() {});
    });
    _listMediaDirectories();
    // store = StoreProvider.of<AppState>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, MainScreenViewModel>(
        converter: (store) => MainScreenViewModel.fromStore(store),
        distinct: true,
        onWillChange: (previousViewModel, newViewModel) {
          // if (previousViewModel!.files == newViewModel.files) {
          //   _log.info("Files not changed");
          //   return;
          // }
          _log.info("Will change");
          _log.info("firstBunch path: ${newViewModel.firstBunch!.path}");
        },
        builder: (context, viewModel) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: const Text(
                'Super Gallery',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              actions: _buildAppBarActions(viewModel),
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
                  Positioned(
                    top: _top,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.grey[400],
                      height: _topInfoBarHeight, // Standard AppBar height
                      child: viewModel.firstBunch != null
                          ? InfoBar(
                              windowIndex: 1,
                              scaffoldkey: _scaffoldKey,
                            )
                          : Container(),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: _top + _topInfoBarHeight,
                    height: viewModel.isSplit!
                        ? _draggableTop - 50
                        : totalHeight - _topInfoBarHeight,
                    child: FolderChildView(
                      windowIndex: 1,
                    ),
                  ),
                  viewModel.isSplit!
                      ? Positioned(
                          top: _draggableTop,
                          left: 0,
                          right: 0,
                          child: GestureDetector(
                            onVerticalDragUpdate: (DragUpdateDetails details) {
                              setState(() {
                                double delta = details.delta.dy;
                                _draggableTop += delta;
                                if (_draggableTop <
                                    (_top + _topInfoBarHeight)) {
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
                                  scaffoldkey: _scaffoldKey,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  viewModel.isSplit!
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
            endDrawer: Drawer(
              child: Container(
                color: Colors.purple[100],
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: DrawerHeader(
                        child: Text(
                          'Clipboard',
                          style: kDrawerHeaderStyle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ListView.builder(
                            itemCount: viewModel.combinedClipboard.length,
                            itemBuilder: (BuildContext context, int index) {
                              return imageAvatar(
                                  viewModel.combinedClipboard[index]);
                            },
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      clearClipBoard();
                                    },
                                    child: Text('Clear'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      showPasteDialog(context, viewModel);
                                    },
                                    child: Text('Paste'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _listMediaDirectories() async {
    _log.info("Listing media directories");
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
    var store = StoreProvider.of<AppState>(context, listen: false);
    // await store.dispatch(UpdateDirectoryBunchFirst(tmpFirst));
    await store.dispatch(ChangeDirectoryAction(tmpFirst.path, 1));
    // await store.dispatch(UpdateDirectoryBunchSecond(tmpFirst));

    setState(() {
      directories = tmpDirectoryList;
      directorybunchFirst = tmpFirst;
      // directorybunchSecond = directorybunchFirst;
      // TODO: Remove setting Secondbunch to firstbunch
    });
  }

  void _copyFilesToClipBoard() {
    _log.info("Copying files to clipboard");
    var store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(CopyFilesToClipBoardAction());
  }

  // bool areAnyFilesSelected() {
  //   if (store.state.activeChildWindow == 1) {
  //     return store.state.selectedFilesFirst!.isNotEmpty;
  //   } else {
  //     return store.state.selectedFilesSecond!.isNotEmpty;
  //   }
  // }

  // bool isClipBoardEmpty() {
  //   if (store.state.activeChildWindow == 1) {
  //     return store.state.clipboardFirst!.isEmpty;
  //   } else {
  //     return store.state.clipboardSecond!.isEmpty;
  //   }
  // }

  // bool isClipBoardNotEmpty() {
  //   return !isClipBoardEmpty();
  // }

  Future<void> _pasteFromClipBoard(MainScreenViewModel viewModel) async {
    _log.info("Pasting files from clipboard");
    var store = StoreProvider.of<AppState>(context, listen: false);
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

  Future<void> clearClipBoard() {
    _log.info("Clearing clipboard");
    var store = StoreProvider.of<AppState>(context, listen: false);
    return store.dispatch(ClearClipBoardAction());
  }

  void splitScreen() {
    _log.info("Splitting screen");
    var store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(UpdateScreenSplitAction(!store.state.isSplit!));
  }

  void _handleSorting(String result) {
    _log.info("Sorting by $result");
    var store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(SortFilesAction(result));
    // switch (result) {
    //   case 'Name Ascending':
    //     sortByName(true, store.state.filteredFiles);
    //     break;
    //   case 'Name Descending':
    //     sortByName(false, store.state.filteredFiles);
    //     break;
    //   case 'Creation Date Ascending':
    //     sortByCreationDate(true, store.state.filteredFiles);
    //     break;
    //   case 'Creation Date Descending':
    //     sortByCreationDate(false, store.state.filteredFiles);
    //     break;
    //   case 'Modification Date Ascending':
    //     sortByModificationDate(true, store.state.filteredFiles);
    //     break;
    //   case 'Modification Date Descending':
    //     sortByModificationDate(false, store.state.filteredFiles);
    //     break;
    // }
  }

  Future<void> deleteSelectedFilesHandler() async {
    _log.info("Deleting selected files..Voided!");
    // await store.dispatch(DeleteSelectedFilesAction());
    // Navigator.of(context).pop();
    // String targetPath;
    // if (store.state.activeChildWindow == 1) {
    //   targetPath = store.state.firstBunch!.path;
    // } else {
    //   targetPath = store.state.secondBunch!.path;
    // }
    // store.dispatch(LoadFilesAction(targetPath, store.state.activeChildWindow!));
  }

  PopupMenuButton<String> _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.sort,
        color: Theme.of(context).colorScheme.inversePrimary,
      ), // Use an icon button
      onSelected: _handleSorting,
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
    );
  }

  void _showDeleteDialog(BuildContext context, MainScreenViewModel viewModel) {
    var store = StoreProvider.of<AppState>(context, listen: false);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                const Text('Really Delete Files?', style: kDialogHeadingStyle),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Do you wish to delete these files permanenetly?',
                      style: kDialogTextStyle),
                  SizedBox(height: 10),
                  ...viewModel.selection
                      .map((e) => Text(e.path, style: kDialogTextStyle)),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Yes', style: kButtonOkStyle),
                onPressed: () async {
                  await deleteSelectedFilesHandler();
                },
              ),
              TextButton(
                child: const Text('Cancel', style: kButtonCancelStyle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  List<Widget> _buildAppBarActions(MainScreenViewModel viewModel) {
    return [
      viewModel.areFilesSelected
          ? IconButton(
              onPressed: () {
                _copyFilesToClipBoard();
              },
              icon: Icon(
                Icons.file_copy_sharp,
                color: Theme.of(context).colorScheme.inversePrimary,
              ))
          : Container(),
      viewModel.isClipBoardEmpty == false
          ? IconButton(
              onPressed: () {
                _log.info("Pressed paste");
                showPasteDialog(context, viewModel);
              },
              icon: Icon(
                Icons.content_paste_sharp,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            )
          : Container(),
      viewModel.areFilesSelected
          ? IconButton(
              onPressed: () {
                _log.info("Pressed delete");
                _showDeleteDialog(context, viewModel);
              },
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ))
          : Container(),
      IconButton(
        onPressed: () {
          _log.info("Pressed split screen");
          splitScreen();
        },
        icon: Icon(
          viewModel.isSplit != true
              ? Icons.splitscreen_outlined
              : Icons.splitscreen,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      _buildPopupMenu(),
    ];
  }

  Future<void> showPasteDialog(
      BuildContext context, MainScreenViewModel viewModel) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          // _log.info("state is ${store.state}");
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
                        (viewModel.activeChildWindow == 1
                            ? viewModel.firstBunch!.path
                            : viewModel.secondBunch!.path),
                    style: kDialogTextStyle,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Yes', style: kButtonOkStyle),
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
                                    style: kDialogTextStyle),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(viewModel.filesLeftToCopy.toString() +
                                    'left to copy'),
                              ],
                            ),
                          ),
                        );
                      });
                  await _pasteFromClipBoard(viewModel);
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
  }

  Widget imageAvatar(FileSystemEntity item) {
    String extension = Path.extension(item.path).toLowerCase();
    bool isImage = ['.jpg', '.jpeg', '.png', '.gif'].contains(extension);
    return ListTile(
      title: Text(item.path),
      leading: isImage
          ? Image.file(
              File(item.path),
            )
          : Container(),
    );
  }
}
