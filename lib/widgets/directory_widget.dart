// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:redux/redux.dart';

class DirectoryWidget extends StatelessWidget {
  DirectoryWidget(
      {super.key, required this.directory, required this.windowIndex});

  FileSystemEntity directory;
  final Logger _log = Logger('FolderChildView');
  int windowIndex;

  void _changeDirectory(BuildContext context, directory) {
    _log.info("Changing directory");
    Store<AppState> store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(ChangeDirectoryAction(directory.path, windowIndex));
    // Also remove files selected, but not from clipboard
    store.dispatch(DeSelectAllFilesForWindowAction(windowIndex));
  }

  @override
  Widget build(BuildContext context) {
    String dirName = p.basename(directory.path);

    return InkWell(
      onTap: () async {
        _changeDirectory(context, directory);
      },
      child: Column(
        children: <Widget>[
          Icon(
            Icons.folder,
            size: 70,
            color: Colors.blue,
          ),
          Expanded(
            child: Text(dirName),
          ),
        ],
      ),
    );
  }
}
