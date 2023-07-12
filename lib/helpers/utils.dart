import 'dart:io';
import 'package:path/path.dart';

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
