// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:gallery/structure/directory_chip.dart';
import 'package:redux/redux.dart';

class InfoBar extends StatelessWidget {
  InfoBar({
    super.key,
    required this.directorybunch,
    required this.windowIndex,
  });
  DirectoryBunch? directorybunch;
  int windowIndex;

  void NavigateTo(path) {
    print("Navigate to $path");
    print("Window Index: $windowIndex");
  }

  Widget pathBar(String path) {
    List<Widget> chips = [];
    String rootPath = "/";
    List<String> directories = path.split("/");

    // Check if the path starts with "/storage/emulated/0"
    if (directories.length >= 4 &&
        directories[1] == "storage" &&
        directories[2] == "emulated" &&
        directories[3] == "0") {
      // Create a single chip for "Internal Storage"
      DirectoryChip directoryChip = DirectoryChip(
        displayText: "Internal Storage",
        actualPath: "/storage/emulated/0",
        rootPath: rootPath,
      );

      chips.add(dirChip(directoryChip));

      // Add separator chip
      DirectoryChip separatorChip = DirectoryChip(
        displayText: " > ",
        actualPath: "",
        rootPath: "",
      );
      chips.add(dirChip(separatorChip));

      // Skip the first three directories ("storage", "emulated", and "0")
      directories.removeRange(1, 4);
      rootPath += "storage/emulated/0/";
    }

    for (var i = 1; i < directories.length; i++) {
      if (directories[i].isEmpty) continue;

      String displayText = directories[i];
      String actualPath = rootPath + directories[i];

      DirectoryChip directoryChip = DirectoryChip(
        displayText: displayText,
        actualPath: actualPath,
        rootPath: rootPath,
      );

      chips.add(dirChip(directoryChip));

      if (i != directories.length - 1) {
        DirectoryChip separatorChip = DirectoryChip(
          displayText: " > ",
          actualPath: "",
          rootPath: "",
        );
        chips.add(dirChip(separatorChip));
      }
      // Add icon for Navigate back

      rootPath += directories[i] + "/";
    }
    // chips.add(IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips,
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }

  Widget dirChip(DirectoryChip directoryChip) {
    if (directoryChip.displayText == " > ") {
      return InkWell(
        onTap: () {},
        child: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
          ),
        ),
      );
    }

    if (directoryChip.displayText == "Internal Storage") {
      return IconButton(
        onPressed: () {
          print('Directory Path: ${directoryChip.actualPath}');
          NavigateTo("/storage/emulated/0");
        },
        icon: Icon(
          Icons.home,
          color: Colors.black,
        ),
      );
    }

    return InkWell(
      onTap: () {
        print('Directory Path: ${directoryChip.actualPath}');
      },
      child: Text(directoryChip.displayText.toUpperCase()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Store<AppState> store = StoreProvider.of<AppState>(context, listen: false);
    print("In InfoBar, directorybunch is $directorybunch");
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        color: Colors.grey[300],
      ),
      // color: Colors.grey[300], // Change this to your desired color
      child: Align(
        alignment: Alignment.centerLeft,
        child: directorybunch != null
            ? pathBar(directorybunch!.path)
            : pathBar("/storage/emulated/0"),
      ),
    );
  }
}

// Instead of all these functions, make it tightly intergrated with the build function. Remove the functions which are used to generate the widgets, and add their logic to build function. Make it more efficient.