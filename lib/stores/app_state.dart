class AppState {
  String? current_view;

  AppState({
    this.current_view,
  });

  AppState copyWith({
    String? current_view,
  }) {
    return AppState(
        // current_view: doctor ?? this.current_doctor,

        );
  }
}
