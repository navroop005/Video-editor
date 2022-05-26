import 'package:flutter/material.dart';
import 'package:video_editor/full_screen_viewer.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerControlls extends StatefulWidget {
  final VideoPlayerController controller;
  final double framerate;
  const VideoPlayerControlls(
      {Key? key, required this.controller, required this.framerate})
      : super(key: key);

  @override
  State<VideoPlayerControlls> createState() => _VideoPlayerControllsState();
}

class _VideoPlayerControllsState extends State<VideoPlayerControlls> {
  bool _ismuted = false;
  @override
  void initState() {
    super.initState();
    _ismuted = widget.controller.value.volume == 0;
  }

  void setPosition(bool next) {
    setState(() {
      if (next) {
        widget.controller.seekTo(widget.controller.value.position +
            Duration(milliseconds: 1000 ~/ widget.framerate));
      } else {
        widget.controller.seekTo(widget.controller.value.position -
            Duration(milliseconds: 1000 ~/ widget.framerate));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VideoProgressIndicator(
          widget.controller,
          allowScrubbing: true,
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _ismuted
                      ? widget.controller.setVolume(1)
                      : widget.controller.setVolume(0);
                });
                _ismuted = !_ismuted;
              },
              child: Icon(
                _ismuted ? Icons.volume_mute : Icons.volume_up,
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[500],
                shape: const CircleBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.controller.pause();
                setPosition(false);
              },
              child: const Icon(Icons.navigate_before),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[500],
                shape: const CircleBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                widget.controller.value.isPlaying
                    ? widget.controller.pause()
                    : widget.controller.play();
              }),
              child: Icon(
                widget.controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 30,
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[500],
                shape: const CircleBorder(),
                fixedSize: const Size.fromRadius(25),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.controller.pause();
                setPosition(true);
              },
              child: const Icon(Icons.navigate_next),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[500],
                shape: const CircleBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  FullScreenView.showFullScreen(context, widget.controller),
              child: const Icon(Icons.fullscreen_rounded),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[500],
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
