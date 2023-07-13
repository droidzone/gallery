import 'dart:io';

class AppState {
  String? currentView;
  String? mainviewDefaultTab;
  String? mainviewCurrentTab;
  String? viewFolderAs;
  bool? isSplit;
  List<File>? selectedFiles;
  List<File>? filteredFiles;
  int? selectedChildWindow;
  String? selectedPath;

  AppState({
    this.currentView,
    this.mainviewDefaultTab,
    this.mainviewCurrentTab,
    this.viewFolderAs,
    this.isSplit,
    this.selectedFiles,
    this.filteredFiles,
    this.selectedChildWindow,
    this.selectedPath,
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
  }) {
    return AppState(
      currentView: view ?? currentView,
      mainviewCurrentTab: tab ?? mainviewCurrentTab,
      mainviewDefaultTab: tab ?? mainviewDefaultTab,
      viewFolderAs: folderViewType ?? viewFolderAs,
      isSplit: split ?? isSplit,
      selectedFiles: selected ?? selectedFiles,
      filteredFiles: filtered ?? filteredFiles,
      selectedChildWindow: childWindowSelected ?? selectedChildWindow,
      selectedPath: pathSelected ?? selectedPath,
    );
  }
}
