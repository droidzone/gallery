import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoView extends StatefulWidget {
  final String videoPath;

  FullScreenVideoView({required this.videoPath});

  @override
  _FullScreenVideoViewState createState() => _FullScreenVideoViewState();
}

class _FullScreenVideoViewState extends State<FullScreenVideoView> {
  late VideoPlayerController _controller;
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
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Column(
                  children: <Widget>[
                    Expanded(child: VideoPlayer(_controller)),
                    ValueListenableBuilder<double>(
                      valueListenable: _progress,
                      builder: (context, value, child) {
                        return Slider(
                          value: value,
                          min: 0.0,
                          max: _controller.value.duration.inSeconds.toDouble(),
                          onChanged: (double newValue) {
                            _controller
                                .seekTo(Duration(seconds: newValue.toInt()));
                          },
                        );
                      },
                    ),
                  ],
                ),
              )
            : CircularProgressIndicator(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Row(
                  children: [
                    Text(_controller.value.isPlaying ? 'Pause' : 'Play'),
                    Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

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
