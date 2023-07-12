import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late String _activeBottomNavItemLabel;
  late Store<AppState> store;

  @override
  void initState() {
    super.initState();
    store = StoreProvider.of<AppState>(context, listen: false);
    _activeBottomNavItemLabel = store.state.mainviewDefaultTab!;
  }

  int _getIndexOfActiveLabel() {
    return _buildBottomNavBarItems()
        .indexWhere((item) => item.label == _activeBottomNavItemLabel);
  }

  List<BottomNavigationBarItem> _buildBottomNavBarItems() {
    const List<Map<String, dynamic>> navBarItemsData = [
      {'icon': Icons.photo, 'label': 'Media'},
      {'icon': Icons.folder, 'label': 'Folders'},
      {'icon': Icons.favorite, 'label': 'Favorites'},
    ];
    return navBarItemsData.map((itemData) {
      return BottomNavigationBarItem(
        icon: Icon(itemData['icon']),
        label: itemData['label'],
      );
    }).toList();
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      print(
          "Dispatching current tab to ${_buildBottomNavBarItems()[index].label!}");
      store.dispatch(UpdateMainViewCurrentTabAction(
          _buildBottomNavBarItems()[index].label!));
      _activeBottomNavItemLabel = _buildBottomNavBarItems()[index].label!;
      print("store is $store");
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: _buildBottomNavBarItems(),
      currentIndex: _getIndexOfActiveLabel(),
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onTap: _onBottomNavItemTapped,
    );
  }
}
