import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:gallery/views/folder_list_view.dart';
import 'package:gallery/widgets/bottom_nav_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

class StartView extends StatefulWidget {
  const StartView({super.key});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  List<FileSystemEntity> files = [];

  List<String> availableDirectories = [];
  List<DirectoryBunch> directories = [];

  @override
  void initState() {
    super.initState();
    listMediaDirectories();
  }

  Future requestPermission(Permission permission) async {
    print("Requesting permission: $permission");
    PermissionStatus status = await permission.status;
    print("Permission status: $status");

    if (status.isPermanentlyDenied) {
      print("Permission is permanently denied");
    } else if (status.isDenied) {
      print("Permission is denied");
      status = await permission.request();
      print("Permission status on requesting again: $status");
    } else {
      print("Permission is not permanently denied");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Super Gallery'),
      ),
      body: Center(
        child: FolderList(directories: directories),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
