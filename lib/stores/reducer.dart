import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';

AppState updateReducer(AppState state, action) {
  switch (action.runtimeType) {
    case UpdateCurrentViewAction:
      return state.copyWith(view: action.view);
    case UpdateMainViewCurrentTabAction:
      print("UpdateMainViewCurrentTabAction reducer");
      print("action.tab: ${action.tab}");
      print("store.state.firstFiles: ${state.firstFiles}");
      print("store.state.secondFiles: ${state.secondFiles}");
      print("state is $state");
      print("A kitkat break");
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
      print("UpdateDirectoryBunchFirst reducer");
      print("action.bunchFirst: ${action.bunchFirst.path}");
      return state.copyWith(bunchFirst: action.bunchFirst);
    case UpdateDirectoryBunchSecond:
      print("UpdateDirectoryBunchSecond reducer");
      print("action.bunchSecond: ${action.bunchSecond.path}");
      return state.copyWith(bunchSecond: action.bunchSecond);
    case UpdateDirectoryBunch:
      print("UpdateDirectoryBunch reducer");
      print("action.bunch: ${action.bunch.path}");
      print("action.windowIndex: ${action.windowIndex}");

      if (action.windowIndex == 1) {
        return state.copyWith(bunchFirst: action.bunch);
      } else if (action.windowIndex == 2) {
        return state.copyWith(bunchSecond: action.bunch);
      }
    case UpdateFilesAction:
      print("UpdateFilesAction reducer");
      print("action.files: ${action.files}");
      print("action.windowIndex: ${action.windowIndex}");
      if (action.windowIndex == 1) {
        return state.copyWith(filesFirst: action.files);
      } else if (action.windowIndex == 2) {
        return state.copyWith(filesSecond: action.files);
      }
  }
  return state;
}
