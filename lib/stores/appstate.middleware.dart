import 'dart:io';

import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:logging/logging.dart';
import 'package:redux/redux.dart';
import 'package:path/path.dart' as p;

final Logger _log = Logger('MiddleWare');

void loadFilesMiddleware(
  Store<AppState> store,
  action,
  NextDispatcher next,
) async {
  if (action is LoadFilesAction) {
    _log.info("Loading files");
    _log.info("action.path: ${action.path}");
    _log.info("action.windowIndex: ${action.windowIndex}");
    final Directory directory = Directory(action.path);

    try {
      List<FileSystemEntity> _tmpFiles = directory.listSync();
      store.dispatch(UpdateFilesAction(_tmpFiles, action.windowIndex));
    } on Exception catch (e) {
      _log.info('An error occurred while accessing the directory: $e');
    }
  } else if (action is ChangeDirectoryAction) {
    _log.info("Changing directory");
    _log.info("action.path: ${action.path}");
    _log.info("action.windowIndex: ${action.windowIndex}");
    final Directory directory = Directory(action.path);

    try {
      List<FileSystemEntity> _tmpFiles = directory.listSync();
      _log.info("Files in directory, ${action.path} include: $_tmpFiles");
      String dirName = p.basename(action.path);
      store.dispatch(
        UpdateDirectoryBunch(
            DirectoryBunch(
              name: dirName,
              path: action.path,
            ),
            action.windowIndex),
      );
      _log.info(
          "After dispatching UpdateDirectoryBunch, state is ${store.state}");
      store.dispatch(UpdateFilesAction(_tmpFiles, action.windowIndex));
      return Future.value('Success');
    } on Exception catch (e) {
      _log.info('An error occurred while accessing the directory: $e');
      return Future.error("Failed to change directory");
    }
  } else if (action is UpdateScreenSplitAction) {
    _log.info("Updating screen split");
    _log.info("action.split: ${action.isSplit}");
    if (action.isSplit) {
      // If we are splitting for the first time, we need to update secondBunch to be the same as firstBunch
      store.dispatch(UpdateDirectoryBunchSecond(store.state.firstBunch!));
    }
    // store.dispatch(UpdateScreenSplitAction(action.isSplit));
  }
  next(action);
}
