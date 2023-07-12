import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';

AppState updateReducer(AppState state, action) {
  switch (action.runtimeType) {
    case UpdateCurrentViewAction:
      return state.copyWith(current_view: action.view);
  }
  return state;
}
