// ignore_for_file: prefer_const_constructors


import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/helpers/utils.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:gallery/views/folder_child_view.dart';
import 'package:gallery/widgets/bottom_nav_bar.dart';
import 'package:redux/redux.dart';

class SuperFolderView extends StatefulWidget {
  const SuperFolderView({Key? key, required this.directoryBunch})
      : super(key: key);

  final DirectoryBunch directoryBunch;

  @override
  State<SuperFolderView> createState() => _SuperFolderViewState();
}

class _SuperFolderViewState extends State<SuperFolderView> {
  late double _top = 0.0;
  final double _draggableBarHeight = 20;
  final double _topInfoBarHeight = 20;
  late Store<AppState> store;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _top = MediaQuery.of(context).size.height / 2;
      // setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    store = StoreProvider.of<AppState>(context, listen: false);
  }

  void pasteFiles() {
    print("Paste files");
    // print("Received files from child: $_selected");
    // print("Files in memory include: ${store.state.selectedFiles}");
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store>(
        converter: (store) => store,
        builder: (context, store) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Gallery'),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    // store.state.isSplit = !store.state.isSplit;
                    store.dispatch(
                        UpdateScreenSplitAction(!store.state.isSplit));
                    print("Split button pressed. store is ${store.state}");
                  },
                  icon: Icon(
                    store.state.isSplit != true
                        ? Icons.splitscreen_outlined
                        : Icons.splitscreen,
                  ),
                  color:
                      store.state.isSplit == true ? Colors.blue : Colors.black,
                ),
                store.state.selectedFiles.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          print("Copy button pressed");
                        },
                      )
                    : Container(),
                store.state.selectedFiles.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.paste,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          print("Paste button pressed");
                          // pasteFiles();
                        },
                      )
                    : Container(),
                // Add a button for Sort
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.sort,
                    color: Colors.blue,
                  ), // Use an icon button
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
                        sortByModificationDate(true, store.state.filteredFiles);
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
            body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // _top = MediaQuery.of(context).size.height / 2;
                final totalHeight = constraints.maxHeight;
                final topChildHeight =
                    (totalHeight - _draggableBarHeight - _topInfoBarHeight) / 2;
                final bottomChildHeight = totalHeight -
                    topChildHeight; // Subtracting the height of the draggable bar

                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.grey[400],
                        height: _topInfoBarHeight, // Standard AppBar height
                        child: Center(
                          child: Icon(
                            Icons.drag_handle,
                            color: Colors.white,
                            size: 8,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: _topInfoBarHeight,
                      left: 0,
                      right: 0,
                      height:
                          store.state.isSplit ? topChildHeight : totalHeight,
                      child: FolderChildView(
                        windowIndex: 0,
                        // directoryBunch: widget.directoryBunch,
                        // onNavigate: () {},
                      ),
                    ),
                    store.state.isSplit
                        ? Positioned(
                            top: _top +
                                _draggableBarHeight, // Adding the height of the draggable bar
                            left: 0,
                            right: 0,
                            height: bottomChildHeight,
                            child: FolderChildView(
                              windowIndex: 1,
                              // directoryBunch: widget.directoryBunch,
                              // onNavigate: () {},
                            ),
                          )
                        : Container(),
                    store.state.isSplit
                        ? Positioned(
                            top: _top,
                            left: 0,
                            right: 0,
                            child: GestureDetector(
                              onVerticalDragUpdate:
                                  (DragUpdateDetails details) {
                                print(
                                    "Drag update details: ${details.delta.dy}");
                                setState(() {
                                  _top += details.delta.dy;
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
                  ],
                );
              },
            ),
            bottomNavigationBar: BottomNavigation(),
          );
        });
  }
}
