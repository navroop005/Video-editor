import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:video_editor/full_screen_viewer.dart';
import 'package:video_editor/utils.dart';
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: VideoSeek(controller: widget.controller),
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

class VideoSeek extends StatefulWidget {
  const VideoSeek({Key? key, required this.controller}) : super(key: key);
  final VideoPlayerController controller;

  @override
  State<VideoSeek> createState() => _VideoSeekState();
}

class _VideoSeekState extends State<VideoSeek> {
  double position = 0;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        position = widget.controller.value.position.inMilliseconds.toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSlider(
      values: [position],
      min: 0,
      max: widget.controller.value.duration.inMilliseconds.toDouble(),
      handlerHeight: 15,
      tooltip: FlutterSliderTooltip(
        boxStyle: FlutterSliderTooltipBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
        format: (String s) {
          double t = double.tryParse(s) ?? 0;
          return Utils.formatTime(t.toInt(), true);
        },
      ),
      trackBar: const FlutterSliderTrackBar(
        inactiveTrackBar: BoxDecoration(
          color: Colors.grey,
        ),
      ),
      handler: FlutterSliderHandler(child: const SizedBox()),
      onDragging: (handlerIndex, lowerValue, upperValue) {
        setState(() {
          position = lowerValue;
          setPosition();
        });
      },
    );
  }
  void setPosition(){
    widget.controller.seekTo(Duration(milliseconds: position.toInt()));
  }
}