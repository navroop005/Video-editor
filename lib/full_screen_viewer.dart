import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_editor/utils.dart';
import 'package:video_player/video_player.dart';

class FullScreenView extends StatefulWidget {
  final VideoPlayerController controller;
  const FullScreenView({Key? key, required this.controller}) : super(key: key);

  static late OverlayEntry _overlayEntry;
  static bool isFullScreen = false;
  static void hideFullScreen() {
    _overlayEntry.remove();
    isFullScreen = false;
  }

  static void showFullScreen(
      BuildContext context, VideoPlayerController controller) {
    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
        builder: (context) => FullScreenView(controller: controller),
        opaque: true,
        maintainState: true);
    overlayState.insert(_overlayEntry);
    isFullScreen = true;
  }

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.value.aspectRatio > 1) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    total = widget.controller.value.duration;
  }

  double netOffset = 0;
  bool showPosition = false;
  Duration current = Duration.zero;
  late Duration total;
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
            onDoubleTap: () => FullScreenView.hideFullScreen(),
            onHorizontalDragStart: (details) {
              getPosition();
              setState(() {
                netOffset = 0;
                showPosition = true;
              });
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                netOffset += details.delta.dx / 10;
              });
            },
            onHorizontalDragEnd: (details) {
              changePosition();
              setState(() {
                showPosition = false;
              });
            },
            onVerticalDragDown: (details) {},
            child: Center(
              child: Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: widget.controller.value.aspectRatio,
                      child: VideoPlayer(widget.controller),
                    ),
                  ),
                  Center(
                    child: Text(
                      showPosition ? positionDragText() : "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 10,
                            )
                          ],
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.none),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  void getPosition() {
    current = widget.controller.value.position;
  }

  String positionDragText() {
    String s = '';
    if (netOffset >= 0) {
      s = "+${netOffset.toStringAsFixed(2)}s\n";
    } else {
      s = '${netOffset.toStringAsFixed(2)}s\n';
    }
    int c = current.inMilliseconds + (netOffset * 1000).toInt();
    int t = total.inMilliseconds;
    if (c > t) {
      c = t;
    }
    if (c < 0) {
      c = 0;
    }
    s += Utils.formatTime(c, true);
    s += ' / ';
    s += Utils.formatTime(t, true);
    return s;
  }

  void changePosition() {
    Duration position =
        current + Duration(milliseconds: (netOffset * 1000).toInt());
    if (position < Duration.zero) {
      widget.controller.seekTo(Duration.zero);
    } else if (position > widget.controller.value.duration) {
      widget.controller.seekTo(widget.controller.value.duration);
    } else {
      widget.controller.seekTo(position);
    }
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }
}
