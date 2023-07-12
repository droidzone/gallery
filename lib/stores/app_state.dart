class AppState {
  String? currentView;
  String? mainviewDefaultTab;
  String? mainviewCurrentTab;
  String? viewFolderAs;
  bool? isSplit;

  AppState({
    this.currentView,
    this.mainviewDefaultTab,
    this.mainviewCurrentTab,
    this.viewFolderAs,
    this.isSplit,
  });

  AppState copyWith({
    String? view,
    String? tab,
    String? FolderViewType,
    bool? isSplit,
  }) {
    return AppState(
      currentView: view ?? currentView,
      mainviewCurrentTab: tab ?? mainviewCurrentTab,
      mainviewDefaultTab: tab ?? mainviewDefaultTab,
      viewFolderAs: FolderViewType ?? viewFolderAs,
      isSplit: isSplit ?? isSplit,
    );
  }
}
