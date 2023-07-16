import 'dart:io';

import 'package:gallery/structure/directory_bunch.dart';

class AppState {
  String? currentView;
  String? mainviewDefaultTab;
  String? mainviewCurrentTab;
  String? viewFolderAs;
  bool? isSplit;
  List<File>? selectedFiles;
  List<File>? filteredFiles;
  int? activeChildWindow;
  String? selectedPath;
  String? currentDirectoryFirst;
  String? currentDirectorySecond;
  DirectoryBunch? firstBunch;
  DirectoryBunch? secondBunch;
  List<FileSystemEntity>? firstFiles;
  List<FileSystemEntity>? secondFiles;

  AppState({
    this.currentView,
    this.mainviewDefaultTab,
    this.mainviewCurrentTab,
    this.viewFolderAs,
    this.isSplit,
    this.selectedFiles,
    this.filteredFiles,
    this.activeChildWindow,
    this.selectedPath,
    this.currentDirectoryFirst,
    this.currentDirectorySecond,
    this.firstBunch,
    this.secondBunch,
    this.firstFiles,
    this.secondFiles,
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
  }) {
    // print("Before copyWith, current firstFiles is $firstFiles");
    return AppState(
      currentView: view ?? currentView,
      mainviewCurrentTab: tab ?? mainviewCurrentTab,
      mainviewDefaultTab: tab ?? mainviewDefaultTab,
      viewFolderAs: folderViewType ?? viewFolderAs,
      isSplit: split ?? isSplit,
      selectedFiles: selected ?? selectedFiles,
      filteredFiles: filtered ?? filteredFiles,
      activeChildWindow: childWindowSelected ?? activeChildWindow,
      selectedPath: pathSelected ?? selectedPath,
      currentDirectoryFirst: currentDirFirst ?? currentDirectoryFirst,
      currentDirectorySecond: currentDirSecond ?? currentDirectorySecond,
      firstBunch: bunchFirst ?? firstBunch,
      secondBunch: bunchSecond ?? secondBunch,
      firstFiles: filesFirst != null ? List.from(filesFirst) : firstFiles,
      secondFiles: filesSecond != null ? List.from(filesSecond) : secondFiles,
    );
  }
}
