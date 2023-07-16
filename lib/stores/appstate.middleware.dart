import 'dart:io';

import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:redux/redux.dart';
import 'package:path/path.dart' as p;

void loadFilesMiddleware(
  Store<AppState> store,
  action,
  NextDispatcher next,
) async {
  if (action is LoadFilesAction) {
    print("Loading files");
    print("action.path: ${action.path}");
    print("action.windowIndex: ${action.windowIndex}");
    final Directory directory = Directory(action.path);

    try {
      List<FileSystemEntity> _tmpFiles = directory.listSync();
      store.dispatch(UpdateFilesAction(_tmpFiles, action.windowIndex));
    } on Exception catch (e) {
      print('An error occurred while accessing the directory: $e');
    }
  } else if (action is ChangeDirectoryAction) {
    print("Changing directory");
    print("action.path: ${action.path}");
    print("action.windowIndex: ${action.windowIndex}");
    final Directory directory = Directory(action.path);

    try {
      List<FileSystemEntity> _tmpFiles = directory.listSync();
      print("Files in directory, ${action.path} include: $_tmpFiles");
      String dirName = p.basename(action.path);
      store.dispatch(
        UpdateDirectoryBunch(
            DirectoryBunch(
              name: dirName,
              path: action.path,
            ),
            action.windowIndex),
      );
      print("After dispatching UpdateDirectoryBunch, state is ${store.state}");
      store.dispatch(UpdateFilesAction(_tmpFiles, action.windowIndex));
    } on Exception catch (e) {
      print('An error occurred while accessing the directory: $e');
    }
  }
  next(action);
}
