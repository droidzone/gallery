import 'package:gallery/stores/app_state.dart';

AppState initialState = AppState(
  currentView: "Main",
  mainviewDefaultTab: "Folders",
  mainviewCurrentTab: "Folders",
  isSplit: false,
  selectedFilesFirst: [],
  selectedFilesSecond: [],
  filteredFiles: [],
  activeChildWindow: 1,
  currentDirectoryFirst: null,
  currentDirectorySecond: null,
  firstFiles: [],
  secondFiles: [],
  clipboardFirst: [],
  clipboardSecond: [],
  selection: [],
);
