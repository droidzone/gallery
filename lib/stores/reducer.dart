import 'dart:io';

import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:logging/logging.dart';

final Logger _log = Logger('Redux Reducer');

AppState updateReducer(AppState state, action) {
  switch (action.runtimeType) {
    case UpdateCurrentViewAction:
      return state.copyWith(view: action.view);
    case UpdateMainViewCurrentTabAction:
      _log.info("UpdateMainViewCurrentTabAction reducer");
      _log.info("action.tab: ${action.tab}");
      _log.info("store.state.firstFiles: ${state.firstFiles}");
      _log.info("store.state.secondFiles: ${state.secondFiles}");
      _log.info("state is $state");
      return state.copyWith(tab: action.tab);
    case UpdateScreenSplitAction:
      return state.copyWith(split: action.isSplit);
    case UpdateActiveChildWindow:
      return state.copyWith(childWindowSelected: action.childWindowSelected);
    case UpdateDirectoryFirst:
      return state.copyWith(currentDirFirst: action.currentDirFirst);
    case UpdateDirectorySecond:
      return state.copyWith(currentDirSecond: action.currentDirSecond);
    case UpdateDirectoryBunchFirst:
      _log.info("UpdateDirectoryBunchFirst reducer");
      _log.info("action.bunchFirst: ${action.bunchFirst.path}");
      return state.copyWith(bunchFirst: action.bunchFirst);
    case UpdateDirectoryBunchSecond:
      _log.info("UpdateDirectoryBunchSecond reducer");
      _log.info("action.bunchSecond: ${action.bunchSecond.path}");
      return state.copyWith(bunchSecond: action.bunchSecond);
    case UpdateDirectoryBunch:
      _log.info("UpdateDirectoryBunch reducer");
      _log.info("action.bunch: ${action.bunch.path}");
      _log.info("action.windowIndex: ${action.windowIndex}");

      if (action.windowIndex == 1) {
        return state.copyWith(bunchFirst: action.bunch);
      } else if (action.windowIndex == 2) {
        return state.copyWith(bunchSecond: action.bunch);
      }
    case UpdateFilesAction:
      _log.info("UpdateFilesAction reducer");
      _log.info("action.files: ${action.files}");
      _log.info("action.windowIndex: ${action.windowIndex}");
      if (action.windowIndex == 1) {
        return state.copyWith(filesFirst: action.files);
      } else if (action.windowIndex == 2) {
        return state.copyWith(filesSecond: action.files);
      }
    case CopyFilesToClipBoardyAction:
      _log.info("CopyFilesToClipBoardyAction reducer");
      _log.info("action.files: ${action.files}");
      _log.info("action.windowIndex: ${action.windowIndex}");
      if (action.windowIndex == 1) {
        List<FileSystemEntity> combinedList =
            state.clipboardFirst! + action.files;
        _log.info("Clipboard 1, combinedList: $combinedList");
        return state.copyWith(filesCopiedForFirst: combinedList);
      } else if (action.windowIndex == 2) {
        List<FileSystemEntity> combinedList =
            state.clipboardSecond! + action.files;
        _log.info("Clipboard 2, combinedList: $combinedList");
        return state.copyWith(filesCopiedForSecond: combinedList);
      }
    case SelectFileAction:
      _log.info("SelectFileAction reducer");
      _log.info("action.file: ${action.file}");
      _log.info("action.windowIndex: ${action.windowIndex}");

      List<FileSystemEntity> updateSelectedFiles(
          List<FileSystemEntity> selectedFiles) {
        List<FileSystemEntity> combinedList = selectedFiles;
        if (selectedFiles.contains(action.file)) {
          combinedList.remove(action.file);
        } else {
          combinedList.add(action.file);
        }
        _log.info("SelectFileAction, combinedList: $combinedList");
        return combinedList;
      }
      if (action.windowIndex == 1) {
        return state.copyWith(
            selectedFirst: updateSelectedFiles(state.selectedFilesFirst!));
      } else if (action.windowIndex == 2) {
        return state.copyWith(
            selectedSecond: updateSelectedFiles(state.selectedFilesSecond!));
      }
    case CopyFilesToClipBoardAction:
      _log.info("CopyFilesToClipBoardAction reducer");
      // We need to copy selectedFilesFirst to clipboardFirst if each of them dont exist in clipboardFirst, and similiarly, copy selectedFilesSecond to clipboardSecond if each of them dont exist in clipboardSecond
      List<FileSystemEntity> updateClipboard(
          List<FileSystemEntity> selectedFiles,
          List<FileSystemEntity> clipboard) {
        List<FileSystemEntity> combinedList = clipboard;
        selectedFiles.forEach((element) {
          if (!clipboard.contains(element)) {
            combinedList.add(element);
          }
        });

        _log.info("CopyFilesToClipBoardAction, combinedList: $combinedList");
        return combinedList;
      }
      _log.info("Updating first clipboard");
      updateClipboard(state.selectedFilesFirst!, state.clipboardFirst!);
      _log.info("Updating second clipboard");
      updateClipboard(state.selectedFilesSecond!, state.clipboardSecond!);
      _log.info("state is $state");
  }
  return state;
}


    // case SelectFileAction:
    //   _log.info("SelectFileAction reducer");
    //   _log.info("action.file: ${action.file}");
    //   _log.info("action.windowIndex: ${action.windowIndex}");
    //   if (action.windowIndex == 1) {
    //     List<FileSystemEntity> combinedList = state.selectedFilesFirst!;
    //     if (state.selectedFilesFirst!.contains(action.file)) {
    //       combinedList.remove(action.file);
    //     } else {
    //       combinedList.add(action.file);
    //     }
    //     _log.info("SelectFileAction, combinedList: $combinedList");
    //     return state.copyWith(selectedFirst: combinedList);
    //   } else if (action.windowIndex == 2) {
    //     List<FileSystemEntity> combinedList = state.selectedFilesSecond!;
    //     if (state.selectedFilesSecond!.contains(action.file)) {
    //       combinedList.remove(action.file);
    //     } else {
    //       combinedList.add(action.file);
    //     }
    //     _log.info("SelectFileAction, combinedList: $combinedList");
    //     return state.copyWith(selectedSecond: combinedList);
    //   }