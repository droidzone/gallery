// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:ui' as ui;
// import 'package:media_store/media_store.dart';

class FullScreenVideoView extends StatefulWidget {
  final String videoPath;

  const FullScreenVideoView({super.key, required this.videoPath});

  @override
  _FullScreenVideoViewState createState() => _FullScreenVideoViewState();
}

class _FullScreenVideoViewState extends State<FullScreenVideoView> {
  late VideoPlayerController _controller;
  late TextEditingController _filenameController;
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.addListener(_updateProgress);
    _filenameController = TextEditingController();
  }

  void _updateProgress() {
    if (!mounted) return;
    _progress.value = _controller.value.position.inSeconds.toDouble();
  }

  // Future<void> _captureAndShareFrame2() async {
  //   RenderRepaintBoundary boundary =
  //       _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //   var image = await FlutterWidgetToImage.repaintBoundaryToImage(boundary);

  //   // Now you have the image data. You can use it as per your requirement.
  // }

  Future<void> _captureAndShareFrame1() async {
    final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: widget.videoPath,
      imageFormat: ImageFormat.PNG,
      maxWidth:
          1024, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
      timeMs: _controller.value.position.inMilliseconds,
    );

    if (thumbnailPath == null) return;
    await Share.shareXFiles([XFile(thumbnailPath)], text: 'Screenshot');

    // ... rest of your code
  }

  Future<void> _captureAndShareFrame(GlobalKey key) async {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.png').create();
    await file.writeAsBytes(pngBytes);

    // await Share.shareFiles([file.path], text: 'Screenshot');
    await Share.shareXFiles([XFile(file.path)], text: 'Screenshot');
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

  Future<File> changeFileNameOnly(File file, String newFileName) async {
    print("In changeFileNameOnly...");
    await requestPermission(Permission.photos);
    await requestPermission(Permission.videos);
    await requestPermission(Permission.manageExternalStorage);
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }

  // Future<void> _captureAndShareFrame1() async {
  //   final Uint8List? imageData = await _controller.value.captureFrame();
  //   if (imageData == null) return;

  //   final String dirPath = (await getTemporaryDirectory()).path;
  //   final String filePath = '$dirPath/captured_frame.jpg';

  //   final File file = File(filePath);
  //   await file.writeAsBytes(imageData);

  //   // Compress the image
  //   final List<int>? compressedImage =
  //       await FlutterImageCompress.compressWithFile(
  //     file.absolute.path,
  //     minWidth: 2300,
  //     minHeight: 1500,
  //     quality: 94,
  //   );

  //   // Write the compressed image to disk
  //   final File compressedFile = File('$dirPath/compressed_frame.jpg');
  //   await compressedFile.writeAsBytes(compressedImage!);

  //   // Share the image
  //   Share.shareFiles([compressedFile.path]);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
      body: Container(
        alignment: Alignment.center,
        height: double.infinity,
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  children: <Widget>[
                    RepaintBoundary(
                      key: _globalKey,
                      child: InteractiveViewer(
                        boundaryMargin: EdgeInsets.all(20),
                        minScale: 0.1,
                        maxScale: 4.6,
                        child: VideoPlayer(
                          _controller,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      // top: 0,
                      child: Column(
                        children: [
                          Text(
                            File(widget.videoPath).path.split('/').last,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          FutureBuilder(
                            future: File(widget.videoPath).lastModified(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DateTime> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                // The Future is complete and data is available.
                                String formattedDate =
                                    DateFormat('dd, MMMM yyyy h:mm a')
                                        .format(snapshot.data!);
                                return Text(
                                  "Modified: $formattedDate",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                );
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // The Future is still running.
                                return CircularProgressIndicator();
                              } else {
                                // Something went wrong.
                                return Text('Error: ${snapshot.error}');
                              }
                            },
                          ),
                          VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Colors.blue[900]!,
                              bufferedColor: Colors.blue[900]!.withOpacity(0.5),
                              backgroundColor: Colors.grey[300]!,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                                icon: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.blue[900],
                                    size: 40,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    _controller.value.volume == 0
                                        ? Icons.volume_off
                                        : Icons.volume_up,
                                    color: _controller.value.volume == 0
                                        ? Colors.red
                                        : Colors.blue[900],
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_controller.value.volume == 0) {
                                      _controller.setVolume(1);
                                    } else {
                                      _controller.setVolume(0);
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.screenshot),
                                ), // Three vertically aligned dots.
                                onPressed: () {
                                  _captureAndShareFrame(_globalKey);
                                },
                              ),
                              IconButton(
                                icon: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.share),
                                ), // Three vertically aligned dots.
                                onPressed: () {
                                  Share.shareXFiles(
                                    [XFile(widget.videoPath)],
                                    text: 'Sharing video...',
                                  );
                                  // Handle the button press here.
                                },
                              ),
                              IconButton(
                                icon: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                      Icons.drive_file_rename_outline_sharp),
                                ), // Three vertically aligned dots.
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Rename File'),
                                        content: TextField(
                                          controller: _filenameController
                                            ..text = File(widget.videoPath)
                                                .path
                                                .split('/')
                                                .last, // prefill with filename
                                          decoration: InputDecoration(
                                              hintText: "Enter new name"),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Rename'),
                                            onPressed: () async {
                                              File f = await changeFileNameOnly(
                                                  File(widget.videoPath),
                                                  _filenameController.text);
                                              print(
                                                  "After renaming, new file path is ${f.path}");
                                              // String newPath = widget.videoPath
                                              //     .replaceFirst(
                                              //         RegExp(r'[^/]*$'),
                                              //         _filenameController.text);
                                              // print("Renaming to $newPath");
                                              // await File(widget.videoPath)
                                              //     .rename(newPath);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.more_vert),
                                ), // Three vertically aligned dots.
                                onPressed: () {
                                  // Handle the button press here.
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : CircularProgressIndicator(),
      ),
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: SingleChildScrollView(
      //     scrollDirection: Axis.horizontal,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       children: [
      //         InkWell(
      //           onTap: () {
      //             setState(() {
      //               _controller.value.isPlaying
      //                   ? _controller.pause()
      //                   : _controller.play();
      //             });
      //           },
      //           child: Row(
      //             children: [
      //               Text(_controller.value.isPlaying ? 'Pause' : 'Play'),
      //               Icon(
      //                 _controller.value.isPlaying
      //                     ? Icons.pause
      //                     : Icons.play_arrow,
      //               ),
      //             ],
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       _controller.value.isPlaying
      //           ? _controller.pause()
      //           : _controller.play();
      //     });
      //   },
      //   child: Icon(
      //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    super.dispose();
  }
}
