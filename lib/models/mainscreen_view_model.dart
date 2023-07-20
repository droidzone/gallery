import 'dart:io';

import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:redux/redux.dart';

class MainScreenViewModel {
  final bool isSplit;
  final List<FileSystemEntity> combinedClipboard;
  final DirectoryBunch? firstBunch;
  final DirectoryBunch? secondBunch;

  MainScreenViewModel({
    required this.isSplit,
    required this.combinedClipboard,
    required this.firstBunch,
    required this.secondBunch,
  });

  static MainScreenViewModel fromStore(Store<AppState> store) {
    return MainScreenViewModel(
      isSplit: store.state.isSplit!,
      combinedClipboard: store.state.combinedClipboard,
      firstBunch: store.state.firstBunch,
      secondBunch: store.state.secondBunch,
    );
  }
}
