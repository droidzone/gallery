import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as p;

final Logger _log = Logger('Utils');

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
  _log.info("Requesting permission: $permission");
  PermissionStatus status = await permission.status;
  // _log.info("Permission status: $status");

  if (status.isPermanentlyDenied) {
    _log.info("Permission is permanently denied");
  } else if (status.isDenied) {
    _log.info("Permission is DENIED!");
    status = await permission.request();
    _log.info("Permission status on requesting again: $status");
  } else if (status.isGranted) {
    _log.info("Permission is Granted.");
  } else {
    _log.info("Permission status is ${status.toString()}");
    // status = await permission.request();
  }
}

void getFiles() async {
  Directory? dir = await getExternalStorageDirectory();
  if (dir != null) {
    String path = "${dir.path.split("Android")[0]}DCIM";
    _log.info('Path: $path'); // Debug line

    try {
      List<FileSystemEntity> files = await Directory(path).list().toList();
      if (files.isEmpty) {
        _log.info('No files found in the directory');
      }
      // Call setState here if this is inside a StatefulWidget
    } catch (e) {
      _log.info('An error occurred while getting files: $e');
    }
  } else {
    _log.info('Directory is null');
  }
}

Future<void> getRequiredPermissions(List<Permission> permissionList) async {
  for (Permission permission in permissionList) {
    await requestPermission(permission);
  }
  return Future.value();
}

String _formattedDate(file) {
  DateTime modificationDate = file.statSync().modified;

  String formattedDate = DateFormat('dd-MM-yyyy').format(modificationDate);
  return formattedDate;
}

String formattedDD(_file) {
  DateTime modificationDate = _file.statSync().modified;

  String formattedDate = DateFormat('dd').format(modificationDate);
  return formattedDate;
}

String formattedMonth(file) {
  DateTime modificationDate = file.statSync().modified;

  String formattedDate = DateFormat('MMM').format(modificationDate);
  return formattedDate;
}

Future<Uint8List> getThumbnail(String path) async {
  String extension = p.extension(path).toLowerCase();
  if (extension == '.mp4') {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    return uint8list!;
  } else {
    final file = File(path);
    return file.readAsBytesSync();
  }
}

String formatFileName(String fileName) {
  if (fileName.length > 15) {
    String first = fileName.substring(0, 7);
    String last = fileName.substring(fileName.length - 8);
    return '$first..$last';
  }
  return fileName;
}

bool isMediaFile(FileSystemEntity file) {
  if (file is Directory) {
    return false;
  } else {
    final RegExp regExp =
        RegExp(r"\.(gif|jpe?g|tiff?|png|webp|bmp|mp4)$", caseSensitive: false);
    return regExp.hasMatch(file.path);
  }
}

// Future<void> copyFiles(List<File> files, Directory targetDirectory, Function(int, int) onProgress) async {
//   for (var i = 0; i < files.length; i++) {
//     final file = files[i];
//     final newFile = File('${targetDirectory.path}/${file.basename}');
//     await file.copy(newFile.path);
//     onProgress(i + 1, files.length); // Call the onProgress callback after each file is copied
//   }
// }

Future<bool> copyFile(String source, String destination) async {
  final file = File(source);
  final newFile = File(destination);
  await file.copy(newFile.path);
  return true;
}
