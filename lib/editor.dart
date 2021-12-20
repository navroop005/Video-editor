import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Editor extends StatelessWidget {
  
  const Editor({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
          backgroundColor: Colors.indigo[900],
        ),
        body: Container(
          color: Colors.black,
          child: VideoApp(filepath: args,),
        ),
      );
  }
}

class VideoApp extends StatefulWidget {
  final String filepath;
  const VideoApp({Key? key, required this.filepath}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  bool fullScreen= false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filepath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  late OverlayEntry overlayEntry;
  void hideFullScreen(){
    overlayEntry.remove();
  }

  void showFullScreen( BuildContext context) {
    OverlayState? overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(
      builder: (context)=> FullScreenView(controller: _controller , f: hideFullScreen),
      opaque: true,
      maintainState: false
    );
    overlayState!.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 400 ),
          child: GestureDetector(
            onDoubleTap: () => showFullScreen(context),
            onTap: () => setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            }),
            child: (_controller.value.isInitialized)
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                  ),
              ),
        )
        ),   
      VideoPlayerControlls(controller: _controller, fullScreen: showFullScreen,),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class VideoPlayerControlls extends StatefulWidget {
  final VideoPlayerController controller;
  final Function fullScreen;
  const VideoPlayerControlls({Key? key, required this.controller, required this.fullScreen})
      : super(key: key);

  @override
  State<VideoPlayerControlls> createState() => _VideoPlayerControllsState();
}

class _VideoPlayerControllsState extends State<VideoPlayerControlls> {
  bool _ismuted = false;
  //double _seek = 0;
  @override
  void initState() {
    super.initState();
    _ismuted = widget.controller.value.volume == 0;
    //_seek = widget.controller.value.isInitialized ? (widget.controller.value.position.inMilliseconds / widget.controller.value.duration.inMilliseconds) : 0;
  }

  /*void setPosition(double seek) {
    setState(() {
      widget.controller.seekTo(Duration(
          milliseconds: (seek * widget.controller.value.duration.inMilliseconds).toInt()));
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VideoProgressIndicator(widget.controller, allowScrubbing: true,
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),),
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
              onPressed: () =>
                setState(() {
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
              onPressed: () => widget.fullScreen(context),
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

class FullScreenView extends StatefulWidget {
  final VideoPlayerController controller;
  final Function f;
  const FullScreenView({Key? key, required this.controller, required this.f}) : super(key: key);

  @override
  _FullScreenViewState createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.f();
        return false;
      },
      child: (widget.controller.value.isInitialized == false)
          ? Container(
              width: 0,
            )
          : GestureDetector(
              onTap: () => setState(() {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
            }),
              onDoubleTap: ()=>widget.f(),
              child: Center(
                child: RotatedBox(
                  quarterTurns: widget.controller.value.aspectRatio > 1 ? 1 : 0,
                  child: AspectRatio(
                    aspectRatio: widget.controller.value.aspectRatio,
                    child: VideoPlayer(widget.controller),
                  ),
                ),
              )
      ),
    );
  }
}

