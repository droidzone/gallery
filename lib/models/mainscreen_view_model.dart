import 'dart:io';

import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:redux/redux.dart';

class MainScreenViewModel {
  final bool isSplit;
  final List<FileSystemEntity> combinedClipboard;
  final DirectoryBunch? firstBunch;
  final DirectoryBunch? secondBunch;
  final int? activeChildWindow;
  final int? filesLeftToCopy;
  final bool areFilesSelected;
  final bool isClipBoardEmpty;
  final List<FileSystemEntity> selection;

  MainScreenViewModel({
    required this.isSplit,
    required this.combinedClipboard,
    required this.firstBunch,
    required this.secondBunch,
    required this.activeChildWindow,
    required this.filesLeftToCopy,
    required this.areFilesSelected,
    required this.isClipBoardEmpty,
    required this.selection,
  });

  static bool anyFilesSelected(store) {
    if (store.state.activeChildWindow == 1) {
      return store.state.selectedFilesFirst!.isNotEmpty;
    } else {
      return store.state.selectedFilesSecond!.isNotEmpty;
    }
  }

  static bool isEmptyClipBoard(store) {
    if (store.state.activeChildWindow == 1) {
      return store.state.clipboardFirst!.isEmpty;
    } else {
      return store.state.clipboardSecond!.isEmpty;
    }
  }

  static List<FileSystemEntity> selectedFiles(store) {
    if (store.state.activeChildWindow == 1) {
      return store.state.selectedFilesFirst!;
    } else {
      return store.state.selectedFilesSecond!;
    }
  }

  static MainScreenViewModel fromStore(Store<AppState> store) {
    return MainScreenViewModel(
      isSplit: store.state.isSplit!,
      combinedClipboard: store.state.combinedClipboard,
      firstBunch: store.state.firstBunch,
      secondBunch: store.state.secondBunch,
      activeChildWindow: store.state.activeChildWindow,
      filesLeftToCopy: store.state.filesLeftToCopy,
      areFilesSelected: anyFilesSelected(store),
      isClipBoardEmpty: isEmptyClipBoard(store),
      selection: selectedFiles(store),
    );
  }
}
