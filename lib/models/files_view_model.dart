import 'dart:io';

import 'package:gallery/helpers/utils.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:redux/redux.dart';

class FilesViewModel {
  final List<FileSystemEntity> files;
  final bool isSplit;
  final int activeChildWindow;

  FilesViewModel({
    required this.files,
    required this.isSplit,
    required this.activeChildWindow,
  });

  static FilesViewModel fromStore(Store<AppState> store, int windowIndex) {
    List<FileSystemEntity>? allfiles =
        windowIndex == 1 ? store.state.firstFiles : store.state.secondFiles;
    List<FileSystemEntity> mediaFiles =
        allfiles!.where((file) => isMediaFile(file)).toList();
    List<FileSystemEntity>? files =
        store.state.mainviewCurrentTab == "Media" ? mediaFiles : allfiles;

    return FilesViewModel(
      files: files,
      isSplit: store.state.isSplit!,
      activeChildWindow: store.state.activeChildWindow!,
    );
  }
}
