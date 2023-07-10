// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoView extends StatefulWidget {
  final String videoPath;

  FullScreenVideoView({required this.videoPath});

  @override
  _FullScreenVideoViewState createState() => _FullScreenVideoViewState();
}

class _FullScreenVideoViewState extends State<FullScreenVideoView> {
  late VideoPlayerController _controller;
  late TextEditingController _filenameController;
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (!mounted) return;
    _progress.value = _controller.value.position.inSeconds.toDouble();
  }

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
                    VideoPlayer(
                      _controller,
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
                                    DateFormat('dd, MMMM yyyy')
                                        .format(snapshot.data!);
                                return Text(
                                  formattedDate,
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
                                              String newPath = widget.videoPath
                                                  .replaceFirst(
                                                      RegExp(r'[^/]*$'),
                                                      _filenameController.text);
                                              await File(widget.videoPath)
                                                  .rename(newPath);
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
