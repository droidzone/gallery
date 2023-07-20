import 'dart:io';

import 'package:gallery/structure/directory_bunch.dart';

class UpdateCurrentViewAction {
  final String view;
  UpdateCurrentViewAction(this.view);
}

class UpdateMainViewCurrentTabAction {
  final String tab;
  UpdateMainViewCurrentTabAction(this.tab);
}

class UpdateScreenSplitAction {
  final bool isSplit;
  UpdateScreenSplitAction(this.isSplit);
}

class UpdateActiveChildWindow {
  final int childWindowSelected;
  UpdateActiveChildWindow(this.childWindowSelected);
}

class UpdateDirectoryFirst {
  final String currentDirFirst;
  UpdateDirectoryFirst(this.currentDirFirst);
}

class UpdateDirectorySecond {
  final String currentDirSecond;
  UpdateDirectorySecond(this.currentDirSecond);
}

class UpdateDirectoryBunchFirst {
  final DirectoryBunch bunchFirst;
  UpdateDirectoryBunchFirst(this.bunchFirst);
}

class UpdateDirectoryBunchSecond {
  final DirectoryBunch bunchSecond;
  UpdateDirectoryBunchSecond(this.bunchSecond);
}

class UpdateDirectoryBunch {
  final DirectoryBunch bunch;
  final int windowIndex;
  UpdateDirectoryBunch(this.bunch, this.windowIndex);
}

class LoadFilesAction {
  final String path;
  final int windowIndex;
  LoadFilesAction(this.path, this.windowIndex);
}

class UpdateFilesAction {
  List<FileSystemEntity> files;
  final int windowIndex;
  UpdateFilesAction(this.files, this.windowIndex);
}

class ChangeDirectoryAction {
  final String path;
  final int windowIndex;
  ChangeDirectoryAction(this.path, this.windowIndex);
}

class CopyFilesToClipBoardyAction {
  final List<FileSystemEntity> files;
  int windowIndex;
  CopyFilesToClipBoardyAction(this.files, this.windowIndex);
}

class SelectFileAction {
  final FileSystemEntity file;
  final int windowIndex;
  SelectFileAction(this.file, this.windowIndex);
}

class DeSelectFileAction {
  final FileSystemEntity file;
  final int windowIndex;
  DeSelectFileAction(this.file, this.windowIndex);
}

class DeSelectAllFilesForWindowAction {
  final int windowIndex;
  DeSelectAllFilesForWindowAction(this.windowIndex);
}

class SelectDeselectFileAction {
  final FileSystemEntity file;
  final int windowIndex;
  SelectDeselectFileAction(this.file, this.windowIndex);
}

class RemoveFileFromClipBoardAction {
  final FileSystemEntity file;
  final int windowIndex;
  RemoveFileFromClipBoardAction(this.file, this.windowIndex);
}

class ClearClipBoardAction {
  // final int windowIndex;
  ClearClipBoardAction();
}

class CopyFilesToClipBoardAction {
  CopyFilesToClipBoardAction();
}

class PasteFilesFromClipBoardAction {
  PasteFilesFromClipBoardAction();
}

class UpdateFilesLeftToCopyAction {
  final int filesLeftToCopy;
  UpdateFilesLeftToCopyAction(this.filesLeftToCopy);
}

class DeleteSelectedFilesAction {
  DeleteSelectedFilesAction();
}

class ToggleFileSelectionAction {
  final FileSystemEntity file;
  // final int windowIndex;

  ToggleFileSelectionAction(this.file);
}
