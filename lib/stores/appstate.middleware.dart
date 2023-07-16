import 'dart:io';

import 'package:gallery/helpers/utils.dart';
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
  } else if (action is PasteFilesFromClipBoardAction) {
    _log.info("Pasting files from clipboard");
    _log.info("state.activeChildWindow: ${store.state.activeChildWindow}");
    _log.info("state.clipboardFirst: ${store.state.clipboardFirst}");
    _log.info("state.clipboardSecond: ${store.state.clipboardSecond}");

    String targetPath = "";
    if (store.state.activeChildWindow == 1) {
      targetPath = store.state.firstBunch!.path;
    } else {
      targetPath = store.state.secondBunch!.path;
    }
    _log.info("targetPath: $targetPath");
    if (store.state.clipboardFirst!.isNotEmpty) {
      _log.info("Pasting files from clipboardFirst");
      int totalFiles = store.state.clipboardFirst!.length;
      store.dispatch(UpdateFilesLeftToCopyAction(totalFiles));

      for (FileSystemEntity file in store.state.clipboardFirst!) {
        _log.info("file: $file");
        String fileName = p.basename(file.path);
        _log.info("fileName: $fileName");
        String newPath = p.join(targetPath, fileName);
        _log.info("newPath: $newPath");
        await copyFile(file.path, newPath);
        _log.info("Copied file");
        store.dispatch(RemoveFileFromClipBoardAction(file, 1));
        store.dispatch(
            UpdateFilesLeftToCopyAction(store.state.clipboardFirst!.length));
      }
    } else if (store.state.clipboardSecond!.isNotEmpty) {
      _log.info("Pasting files from clipboardSecond");
      // int totalFiles = store.state.clipboardSecond!.length;
      for (FileSystemEntity file in store.state.clipboardSecond!) {
        _log.info("file: $file");
        String fileName = p.basename(file.path);
        _log.info("fileName: $fileName");
        String newPath = p.join(targetPath, fileName);
        _log.info("newPath: $newPath");
        await copyFile(file.path, newPath);
        _log.info("Copied file");
        store.dispatch(RemoveFileFromClipBoardAction(file, 2));
        store.dispatch(
            UpdateFilesLeftToCopyAction(store.state.clipboardSecond!.length));
      }
    }
    _log.info("state: ${store.state}");
  } else if (action is DeleteSelectedFilesAction) {
    _log.info("DeleteSelectedFiles reducer");
    int index = store.state.activeChildWindow!;
    _log.info("index: ${index}");
    List<FileSystemEntity> files = (index == 1)
        ? List.from(store.state.clipboardFirst!)
        : List.from(store.state.clipboardSecond!);
    _log.info("files: $files");
    files.forEach((element) {
      element.deleteSync(recursive: true);
      _log.info("Deleting file: $element");
      if (index == 1) {
        store.state.selectedFilesFirst!.remove(element);
      } else if (index == 2) {
        store.state.selectedFilesSecond!.remove(element);
      }
    });
  }
  next(action);
}
