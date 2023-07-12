class AppState {
  String? current_view;
  String? mainview_defaulttab;
  String? mainview_currenttab;

  AppState({
    this.current_view,
    this.mainview_defaulttab,
    this.mainview_currenttab,
  });

  AppState copyWith({
    String? view,
    String? tab,
  }) {
    return AppState(
      current_view: view ?? this.current_view,
      mainview_currenttab: tab ?? this.mainview_currenttab,
    );
  }
}
