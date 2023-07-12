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

  AppState({
    this.currentView,
    this.mainviewDefaultTab,
    this.mainviewCurrentTab,
    this.viewFolderAs,
    this.isSplit,
    this.selectedFiles,
    this.filteredFiles,
    this.selectedChildWindow,
  });

  AppState copyWith({
    String? view,
    String? tab,
    String? folderViewType,
    bool? split,
    List<File>? selected,
    List<File>? filtered,
    int? childWindowSelected,
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
    );
  }
}
