import 'package:gallery/stores/app_state.dart';

AppState initialState = AppState(
  currentView: "Main",
  mainviewDefaultTab: "Folders",
  mainviewCurrentTab: "Folders",
  isSplit: false,
  selectedFilesFirst: [],
  selectedFilesSecond: [],
  filteredFiles: [],
  activeChildWindow: 0,
  currentDirectoryFirst: null,
  currentDirectorySecond: null,
  firstFiles: [],
  secondFiles: [],
  clipboardFirst: [],
  clipboardSecond: [],
);
