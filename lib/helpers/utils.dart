import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void sortByName(bool ascending, List<File> filteredFiles) {
  filteredFiles.sort((a, b) {
    return ascending
        ? basename(a.path).compareTo(basename(b.path))
        : basename(b.path).compareTo(basename(a.path));
  });
  // setState(() {});
}

void sortByCreationDate(bool ascending, List<File> filteredFiles) {
  filteredFiles.sort((a, b) {
    return ascending
        ? a.statSync().changed.compareTo(b.statSync().changed)
        : b.statSync().changed.compareTo(a.statSync().changed);
  });
  // setState(() {});
}

void sortByModificationDate(bool ascending, List<File> filteredFiles) {
  filteredFiles.sort((a, b) {
    return ascending
        ? a.statSync().modified.compareTo(b.statSync().modified)
        : b.statSync().modified.compareTo(a.statSync().modified);
  });
  // setState(() {});
}

Future requestPermission(Permission permission) async {
  print("Requesting permission: $permission");
  PermissionStatus status = await permission.status;
  // print("Permission status: $status");

  if (status.isPermanentlyDenied) {
    print("Permission is permanently denied");
  } else if (status.isDenied) {
    print("Permission is DENIED!");
    status = await permission.request();
    print("Permission status on requesting again: $status");
  } else if (status.isGranted) {
    print("Permission is Granted.");
  } else {
    print("Permission status is ${status.toString()}");
    // status = await permission.request();
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
      }
      // Call setState here if this is inside a StatefulWidget
    } catch (e) {
      print('An error occurred while getting files: $e');
    }
  } else {
    print('Directory is null');
  }
}

Future<void> getRequiredPermissions(List<Permission> permissionList) async {
  for (Permission permission in permissionList) {
    await requestPermission(permission);
  }
  return Future.value();
}
