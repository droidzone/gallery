import 'dart:io';

import 'package:gallery/structure/directory_bunch.dart';

class AppState {
  String? currentView;
  String? mainviewDefaultTab;
  String? mainviewCurrentTab;
  String? viewFolderAs;
  bool? isSplit;
  List<FileSystemEntity>? selectedFilesFirst;
  List<FileSystemEntity>? selectedFilesSecond;
  List<File>? filteredFiles;
  int? activeChildWindow;
  String? selectedPath;
  String? currentDirectoryFirst;
  String? currentDirectorySecond;
  DirectoryBunch? firstBunch;
  DirectoryBunch? secondBunch;
  List<FileSystemEntity>? firstFiles;
  List<FileSystemEntity>? secondFiles;
  List<FileSystemEntity>? clipboardFirst;
  List<FileSystemEntity>? clipboardSecond;
  int? filesLeftToCopy;

  AppState({
    this.currentView,
    this.mainviewDefaultTab,
    this.mainviewCurrentTab,
    this.viewFolderAs,
    this.isSplit,
    this.selectedFilesFirst,
    this.selectedFilesSecond,
    this.filteredFiles,
    this.activeChildWindow,
    this.selectedPath,
    this.currentDirectoryFirst,
    this.currentDirectorySecond,
    this.firstBunch,
    this.secondBunch,
    this.firstFiles,
    this.secondFiles,
    this.clipboardFirst,
    this.clipboardSecond,
    this.filesLeftToCopy,
  });

  AppState copyWith({
    String? view,
    String? tab,
    String? folderViewType,
    bool? split,
    List<File>? selected,
    List<File>? filtered,
    int? childWindowSelected,
    String? pathSelected,
    String? currentDirFirst,
    String? currentDirSecond,
    DirectoryBunch? bunchFirst,
    DirectoryBunch? bunchSecond,
    List<FileSystemEntity>? filesFirst,
    List<FileSystemEntity>? filesSecond,
    List<FileSystemEntity>? filesCopiedForFirst,
    List<FileSystemEntity>? filesCopiedForSecond,
    List<FileSystemEntity>? selectedFirst,
    List<FileSystemEntity>? selectedSecond,
  }) {
    // print("Before copyWith, current firstFiles is $firstFiles");
    return AppState(
      currentView: view ?? currentView,
      mainviewCurrentTab: tab ?? mainviewCurrentTab,
      mainviewDefaultTab: tab ?? mainviewDefaultTab,
      viewFolderAs: folderViewType ?? viewFolderAs,
      isSplit: split ?? isSplit,
      selectedFilesFirst: selectedFirst ?? selectedFilesFirst,
      selectedFilesSecond: selectedSecond ?? selectedFilesSecond,
      filteredFiles: filtered ?? filteredFiles,
      activeChildWindow: childWindowSelected ?? activeChildWindow,
      selectedPath: pathSelected ?? selectedPath,
      currentDirectoryFirst: currentDirFirst ?? currentDirectoryFirst,
      currentDirectorySecond: currentDirSecond ?? currentDirectorySecond,
      firstBunch: bunchFirst ?? firstBunch,
      secondBunch: bunchSecond ?? secondBunch,
      firstFiles: filesFirst != null ? List.from(filesFirst) : firstFiles,
      secondFiles: filesSecond != null ? List.from(filesSecond) : secondFiles,
      clipboardFirst: filesCopiedForFirst ?? clipboardFirst,
      clipboardSecond: filesCopiedForSecond ?? clipboardSecond,
    );
  }

  List<FileSystemEntity> get combinedClipboard {
    List<FileSystemEntity> combined = [];
    if (clipboardFirst != null) {
      combined.addAll(clipboardFirst!);
    }
    if (clipboardSecond != null) {
      combined.addAll(clipboardSecond!);
    }
    return combined;
  }
}
