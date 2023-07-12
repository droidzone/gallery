// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:gallery/views/folder_view.dart';

class FolderList extends StatelessWidget {
  FolderList({super.key, required this.directories});
  List<DirectoryBunch> directories;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // This creates two columns
      ),
      itemCount: directories.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FolderView(
                directoryBunch: directories[index],
              );
            }));
          },
          title: Column(
            children: [
              directories[index].getThumbnail(),
              Text(directories[index].name),
            ],
          ),
        );
      },
    );
  }
}
