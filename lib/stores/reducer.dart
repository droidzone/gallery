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
      return _handleCopyFilesToClipboard(state, action);
    case SelectFileAction:
      return _handleSelectFileAction(state, action);
    case CopyFilesToClipBoardAction:
      return _handleCopyFilesToClipboardAction(state, action);
    case RemoveFileFromClipBoardAction:
      return _handleRemoveFileFromClipboardAction(state, action);
    case DeSelectAllFilesForWindowAction:
      return _handleDeSelectAllFilesForWindowAction(state, action);
    case ClearClipBoardAction:
      return _handleClearClipBoardAction(state, action);
    case SelectDeselectFileAction:
      return _handleSelectDeselctFileAction(state, action);
    case ToggleFileSelectionAction:
      return _toggleFileSelection(state, action);
  }
  return state;
}

AppState _toggleFileSelection(
    AppState state, ToggleFileSelectionAction action) {
  _log.info("_toggleFileSelection reducer");
  _log.info("action.file: ${action.file}");
  if (state.selection!.contains(action.file)) {
    state.selection!.remove(action.file);
  } else {
    state.selection!.add(action.file);
  }
  // if (action.windowIndex == 1) {
  //   if (state.selectedFilesFirst!.contains(action.file)) {
  //     state.selectedFilesFirst!.remove(action.file);
  //   } else {
  //     state.selectedFilesFirst!.add(action.file);
  //   }
  //   return state.copyWith(
  //     selectedFirst: state.selectedFilesFirst,
  //   );
  // } else {
  //   if (state.selectedFilesSecond!.contains(action.file)) {
  //     state.selectedFilesSecond!.remove(action.file);
  //   } else {
  //     state.selectedFilesSecond!.add(action.file);
  //   }
  //   return state.copyWith(
  //     selectedSecond: state.selectedFilesSecond,
  //   );
  // }
  return state.copyWith(selectedFiles: state.selection);
}

AppState _handleSelectDeselctFileAction(AppState state, action) {
  _log.info("SelectDeselctFileAction reducer");
  _log.info("action.file: ${action.file}");
  _log.info("action.windowIndex: ${action.windowIndex}");

  List<FileSystemEntity> combinedList =
      getUpdatedSelectedFiles(state, action, action.windowIndex);

  if (action.windowIndex == 1) {
    return state.copyWith(selectedFirst: combinedList);
  } else if (action.windowIndex == 2) {
    return state.copyWith(selectedSecond: combinedList);
  }
  return state;
}

AppState _handleClearClipBoardAction(AppState state, action) {
  _log.info("ClearClipBoardAction reducer");
  // _log.info("action.windowIndex: ${action.windowIndex}");

  // if (action.windowIndex == 1) {
  return state.copyWith(
    filesCopiedForFirst: [],
    filesCopiedForSecond: [],
  );
  // } else if (action.windowIndex == 2) {
  //   return state.copyWith(filesCopiedForSecond: []);
  // }
  // _log.info("state is $state");
  // return state;
}

AppState _handleDeSelectAllFilesForWindowAction(AppState state, action) {
  _log.info("DeSelectAllFilesForWindowAction reducer");
  _log.info("action.windowIndex: ${action.windowIndex}");

  if (action.windowIndex == 1) {
    return state.copyWith(selectedFirst: []);
  } else if (action.windowIndex == 2) {
    return state.copyWith(selectedSecond: []);
  }
  _log.info("state is $state");
  return state;
}

AppState _handleCopyFilesToClipboard(AppState state, action) {
  _log.info("CopyFilesToClipBoardyAction reducer");
  _log.info("action.files: ${action.files}");
  _log.info("action.windowIndex: ${action.windowIndex}");

  List<FileSystemEntity> combinedList =
      getCombinedList(state, action, action.windowIndex);

  if (action.windowIndex == 1) {
    _log.info("Clipboard 1, combinedList: $combinedList");
    return state.copyWith(filesCopiedForFirst: combinedList);
  } else if (action.windowIndex == 2) {
    _log.info("Clipboard 2, combinedList: $combinedList");
    return state.copyWith(filesCopiedForSecond: combinedList);
  }
  _log.info("state is $state");
  return state;
}

AppState _handleSelectFileAction(AppState state, action) {
  _log.info("SelectFileAction reducer");
  _log.info("action.file: ${action.file}");
  _log.info("action.windowIndex: ${action.windowIndex}");

  List<FileSystemEntity> combinedList =
      getUpdatedSelectedFiles(state, action, action.windowIndex);

  if (action.windowIndex == 1) {
    return state.copyWith(selectedFirst: combinedList);
  } else if (action.windowIndex == 2) {
    return state.copyWith(selectedSecond: combinedList);
  }
  return state;
}

AppState _handleCopyFilesToClipboardAction(AppState state, action) {
  _log.info("CopyFilesToClipBoardAction reducer");

  List<FileSystemEntity> clipboardFirst =
      updateClipboard(state.selectedFilesFirst!, state.clipboardFirst!);
  List<FileSystemEntity> clipboardSecond =
      updateClipboard(state.selectedFilesSecond!, state.clipboardSecond!);

  return state.copyWith(
      filesCopiedForFirst: clipboardFirst,
      filesCopiedForSecond: clipboardSecond);
}

AppState _handleRemoveFileFromClipboardAction(
    AppState state, RemoveFileFromClipBoardAction action) {
  _log.info("RemoveFileFromClipBoardAction reducer");
  _log.info("action.file: ${action.file}");
  _log.info("action.windowIndex: ${action.windowIndex}");

  List<FileSystemEntity> combinedList;
  if (action.windowIndex == 1) {
    combinedList = List.from(state.clipboardFirst!);
  } else if (action.windowIndex == 2) {
    combinedList = List.from(state.clipboardSecond!);
  } else {
    _log.info("handleRemoveFileFromClipboardAction, returning state");
    return state;
  }

  combinedList.remove(action.file);

  if (action.windowIndex == 1) {
    _log.info("RemoveFileFromClipBoardAction, combinedList: $combinedList");
    return state.copyWith(filesCopiedForFirst: combinedList);
  } else if (action.windowIndex == 2) {
    _log.info("RemoveFileFromClipBoardAction, combinedList: $combinedList");
    return state.copyWith(filesCopiedForSecond: combinedList);
  }
  _log.info("state is $state");
  return state;
}

// Helper functions

List<FileSystemEntity> getCombinedList(
    AppState state, action, int windowIndex) {
  if (windowIndex == 1) {
    return state.clipboardFirst! + action.files;
  } else if (windowIndex == 2) {
    return state.clipboardSecond! + action.files;
  }
  _log.info("getCombinedList, windowIndex: $windowIndex");
  return [];
}

List<FileSystemEntity> getUpdatedSelectedFiles(
    AppState state, action, int windowIndex) {
  List<FileSystemEntity> selectedFiles = (windowIndex == 1)
      ? state.selectedFilesFirst!
      : state.selectedFilesSecond!;
  if (selectedFiles.contains(action.file)) {
    selectedFiles.remove(action.file);
  } else {
    selectedFiles.add(action.file);
  }
  return selectedFiles;
}

List<FileSystemEntity> updateClipboard(
    List<FileSystemEntity> selectedFiles, List<FileSystemEntity> clipboard) {
  for (var element in selectedFiles) {
    if (!clipboard.contains(element)) {
      clipboard.add(element);
    }
  }
  return clipboard;
}
