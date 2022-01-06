import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenView extends StatefulWidget {
  final VideoPlayerController controller;
  final Function f;
  const FullScreenView({Key? key, required this.controller, required this.f})
      : super(key: key);

  @override
  _FullScreenViewState createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  @override
  Widget build(BuildContext context) {
    return (widget.controller.value.isInitialized == false)
        ? Container(
            width: 0,
          )
        : GestureDetector(
            onTap: () => setState(() {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
            }),
            onDoubleTap: () => widget.f(),
            child: Center(
              child: RotatedBox(
                quarterTurns: widget.controller.value.aspectRatio > 1 ? 1 : 0,
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: VideoPlayer(widget.controller),
                ),
              ),
            ),
          );
  }
}
