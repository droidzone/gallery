class UpdateCurrentViewAction {
  final String view;
  UpdateCurrentViewAction(this.view);
}

class UpdateMainViewCurrentTabAction {
  final String tab;
  UpdateMainViewCurrentTabAction(this.tab);
}

class UpdateScreenSplitAction {
  final bool isSplit;
  UpdateScreenSplitAction(this.isSplit);
}

class UpdateActiveChildWindow {
  final int childWindowSelected;
  UpdateActiveChildWindow(this.childWindowSelected);
}
