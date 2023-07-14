import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';

AppState updateReducer(AppState state, action) {
  switch (action.runtimeType) {
    case UpdateCurrentViewAction:
      return state.copyWith(view: action.view);
    case UpdateMainViewCurrentTabAction:
      return state.copyWith(tab: action.tab);
    case UpdateScreenSplitAction:
      return state.copyWith(split: action.isSplit);
    case UpdateActiveChildWindow:
      return state.copyWith(childWindowSelected: action.childWindowSelected);
  }
  return state;
}
