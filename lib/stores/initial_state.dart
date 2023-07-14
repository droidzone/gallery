import 'package:gallery/stores/app_state.dart';

AppState initialState = AppState(
  currentView: "Main",
  mainviewDefaultTab: "Folders",
  mainviewCurrentTab: "Folders",
  isSplit: false,
  selectedFiles: [],
  filteredFiles: [],
  activeChildWindow: 0,
);
