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
          padding: const EdgeInsets.symmetric(horizontal: 15),
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
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
              child: Icon(
                _ismuted ? Icons.volume_mute : Icons.volume_up,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.controller.pause();
                setPosition(false);
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.navigate_before),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                widget.controller.value.isPlaying
                    ? widget.controller.pause()
                    : widget.controller.play();
              }),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                fixedSize: const Size.fromRadius(25),
              ),
              child: Icon(
                widget.controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 30,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.controller.pause();
                setPosition(true);
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.navigate_next),
            ),
            ElevatedButton(
              onPressed: () =>
                  FullScreenView.showFullScreen(context, widget.controller),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.fullscreen_rounded),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Utils.formatTime(position, true),
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 12,
              ),
            ),
            Text(
              Utils.formatTime(
                widget.controller.value.duration.inMilliseconds,
                true,
              ),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
        FlutterSlider(
          values: [position],
          min: 0,
          max: widget.controller.value.duration.inMilliseconds.toDouble(),
          handlerHeight: 15,
          tooltip: FlutterSliderTooltip(
            boxStyle: FlutterSliderTooltipBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.tertiaryContainer,
              ),
            ),
            format: (String s) {
              double t = double.tryParse(s) ?? 0;
              return Utils.formatTime(t, true);
            },
            textStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
          trackBar: FlutterSliderTrackBar(
              inactiveTrackBar: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              activeTrackBar: const BoxDecoration(
                  gradient:
                      LinearGradient(colors: [Colors.blue, Colors.purple]))),
          handler: FlutterSliderHandler(child: const SizedBox()),
          onDragging: (handlerIndex, lowerValue, upperValue) {
            setState(() {
              position = lowerValue;
              setPosition();
            });
          },
        ),
      ],
    );
  }

  void setPosition() {
    widget.controller.seekTo(Duration(milliseconds: position.toInt()));
  }
}
