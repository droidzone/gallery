import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:gallery/views/folder_list_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StartView extends StatefulWidget {
  const StartView({super.key});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  List<FileSystemEntity> files = [];
  String _activeBottomNavItemLabel = "Folders";
  List<String> availableDirectories = [];
  List<DirectoryBunch> directories = [];

  @override
  void initState() {
    super.initState();
    listMediaDirectories();
    // getFiles();
  }

  List<BottomNavigationBarItem> _buildBottomNavBarItems() {
    const List<Map<String, dynamic>> navBarItemsData = [
      {'icon': Icons.photo, 'label': 'Media'},
      {'icon': Icons.folder, 'label': 'Folders'},
      {'icon': Icons.favorite, 'label': 'Favorites'},
      // {'icon': Icons.person_add, 'label': 'Registration'},
    ];
    return navBarItemsData.map((itemData) {
      return BottomNavigationBarItem(
        icon: Icon(itemData['icon']),
        label: itemData['label'],
      );
    }).toList();
  }

  Future requestPermission(Permission permission) async {
    print("Requesting permission: $permission");
    PermissionStatus status = await permission.status;
    print("Permission status: $status");

    if (status.isPermanentlyDenied) {
      print("Permission is permanently denied");
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    } else if (status.isDenied) {
      print("Permission is denied");
      // The user did not grant the permission.
      // You can display the permission dialog again and ask the user for
      // permission.
      status = await permission.request();
      print("Permission status on requesting again: $status");
    } else {
      print("Permission is not permanently denied");
      // You can request the permission again.
      status = await permission.request();
    }
  }

  void listMediaDirectories() async {
    Directory? dir = await getExternalStorageDirectory();
    List<String> tmpFolderList = [];
    List<DirectoryBunch> tmpDirectoryList = [];

    if (dir != null) {
      List<String> mediaDirectories = [
        'DCIM',
        'Pictures',
        'Movies',
        'Music',
        'Downloads'
      ];

      await requestPermission(Permission.photos);
      await requestPermission(Permission.videos);
      for (String directory in mediaDirectories) {
        String path = "${dir.path.split("Android")[0]}$directory";
        try {
          List<FileSystemEntity> files = await Directory(path).list().toList();
          print('Files in $directory: $files');
          // tmpFolderList.add(directory);
          tmpDirectoryList.add(DirectoryBunch(
            path: path,
            name: directory,
            imgPath: files[0].path,
          ));
        } catch (e) {
          print('An error occurred while getting files from $directory: $e');
        }
      }
      setState(() {
        directories = tmpDirectoryList;
      });
    } else {
      print('Directory is null');
    }
  }

  void getFiles() async {
    Directory? dir = await getExternalStorageDirectory();
    if (dir != null) {
      String path = "${dir.path.split("Android")[0]}DCIM";
      print('Path: $path'); // Debug line

      try {
        List<FileSystemEntity> files = await Directory(path).list().toList();
        if (files.isEmpty) {
          print('No files found in the directory');
        } else {
          print("files: $files");
        }
        // Call setState here if this is inside a StatefulWidget
      } catch (e) {
        print('An error occurred while getting files: $e');
      }
    } else {
      print('Directory is null');
    }
  }

  int _getIndexOfActiveLabel() {
    return _buildBottomNavBarItems()
        .indexWhere((item) => item.label == _activeBottomNavItemLabel);
  }

  void _onBottomNavItemTapped(int index) {
    // Store<AppState> store = StoreProvider.of<AppState>(context, listen: false);
    // store.dispatch(UpdateDefaultTabAction(_activeBottomNavItemLabel));
    setState(() {
      _activeBottomNavItemLabel = _buildBottomNavBarItems()[index].label!;
    });
    // _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: const Text('Super Gallery'),
      // ),
      body: Center(
        child: FolderList(directories: directories),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _buildBottomNavBarItems(),
        currentIndex: _getIndexOfActiveLabel(),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onTap: _onBottomNavItemTapped,
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
