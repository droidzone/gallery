// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/stores/actions.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/structure/directory_bunch.dart';
import 'package:gallery/structure/directory_chip.dart';
import 'package:logging/logging.dart';
import 'package:redux/redux.dart';

final Logger _log = Logger('InfoBar');

class InfoBar extends StatelessWidget {
  InfoBar({
    super.key,
    // required this.directorybunch,
    required this.windowIndex,
  });
  DirectoryBunch? directorybunch;
  int windowIndex;
  late Store<AppState> store;

  void NavigateTo(path) async {
    _log.info("Navigating to $path");
    // _log.info("Window Index: $windowIndex");
    // if (directorybunch == null) return;
    DirectoryBunch dirbunch;
    if (windowIndex == 1) {
      dirbunch = store.state.firstBunch!;
    } else {
      dirbunch = store.state.secondBunch!;
    }
    // _log.info("Current path: ${dirbunch.path}");
    if (dirbunch.path == path) return;
    // _log.info("Navigate to $path");
    store.dispatch(ChangeDirectoryAction(path, windowIndex));
    // Also remove files selected, but not from clipboard
    store.dispatch(DeSelectAllFilesForWindowAction(windowIndex));
  }

  bool _clipboardIsLoaded() {
    if (windowIndex == 1) {
      _log.info(
          "Clipboard is loaded? ${store.state.clipboardFirst!.isNotEmpty}");
      return store.state.clipboardFirst!.isNotEmpty;
    } else {
      _log.info(
          "Clipboard is loaded? ${store.state.clipboardSecond!.isNotEmpty}");
      return store.state.clipboardSecond!.isNotEmpty;
    }
  }

  int _clipboardLength() {
    if (windowIndex == 1) {
      _log.info("Clipboard length: ${store.state.clipboardFirst!.length}");
      return store.state.clipboardFirst!.length;
    } else {
      _log.info("Clipboard length: ${store.state.clipboardSecond!.length}");
      return store.state.clipboardSecond!.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    store = StoreProvider.of<AppState>(context, listen: false);
    DirectoryBunch dirbunch;
    if (windowIndex == 1) {
      dirbunch = store.state.firstBunch!;
    } else {
      dirbunch = store.state.secondBunch!;
    }
    _log.info("windowIndex: $windowIndex dirbunch:${dirbunch.path}");
    // _log.info("store is $store");
    String path = dirbunch.path;

    // directorybunch != null ? directorybunch!.path : "/storage/emulated/0";
    List<Widget> chips = [];
    String rootPath = "/";
    List<String> directories = path.split("/");

    if (directories.length >= 4 &&
        directories[1] == "storage" &&
        directories[2] == "emulated" &&
        directories[3] == "0") {
      chips.add(
        IconButton(
          onPressed: () {
            _log.info('InfoBar: Directory Path: /storage/emulated/0');
            NavigateTo("/storage/emulated/0");
          },
          icon: Icon(
            Icons.home,
            color: Colors.black,
          ),
        ),
      );

      chips.add(
        Icon(
          Icons.chevron_right_sharp,
          color: Colors.black,
        ),
      );

      directories.removeRange(1, 4);
      rootPath += "storage/emulated/0/";
    }

    for (var i = 1; i < directories.length; i++) {
      if (directories[i].isEmpty) continue;

      String displayText = directories[i];
      String actualPath = rootPath + directories[i];

      chips.add(
        InkWell(
          onTap: () {
            NavigateTo(actualPath);
          },
          child: Text(displayText.toUpperCase()),
        ),
      );

      if (i != directories.length - 1) {
        chips.add(
          InkWell(
            onTap: () {},
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              ),
            ),
          ),
        );
      }

      rootPath += directories[i] + "/";
    }

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
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: chips,
              ),
            ),
          ),
          _clipboardIsLoaded()
              ? Positioned(
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 10),
                    child: Badge(
                      backgroundColor: Colors.blue[500],
                      label: Text(
                        _clipboardLength().toString(),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      child: Icon(
                        Icons.copy_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ), // Replace with your icon
                )
              : Container(),
        ],
      ),
    );
  }
}
