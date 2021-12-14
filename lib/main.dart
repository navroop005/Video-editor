import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Welcome to Flutter'),
              backgroundColor: Colors.indigo[900],
            ),
            body: Container(
              color: Colors.black,
              child: const VideoApp(),
            ),
          ),
          const FullScreenView(),
        ],
      ),
    );
  }
}

class VideoApp extends StatefulWidget {
  const VideoApp({Key? key}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  bool fullScreen= false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/BigBuckBunny.mp4")
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: GestureDetector(
          onDoubleTap: () =>(_fullScreenViewState.setController(_controller)),
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
            )
        ),   
      VideoPlayerControlls(controller: _controller),
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

  const VideoPlayerControlls({Key? key, required this.controller})
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
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child:
              VideoProgressIndicator(widget.controller, allowScrubbing: true),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              onPressed: () {
                setState(() {
                  _ismuted
                      ? widget.controller.setVolume(1)
                      : widget.controller.setVolume(0);
                });
              },
              child: Icon(
                _ismuted ? Icons.volume_mute : Icons.volume_up,
              ),
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

_FullScreenViewState _fullScreenViewState = _FullScreenViewState();

class FullScreenView extends StatefulWidget {
  const FullScreenView({ Key? key }) : super(key: key);

  @override
  _FullScreenViewState createState() => _fullScreenViewState;
}

class _FullScreenViewState extends State<FullScreenView> {
  VideoPlayerController _controller = VideoPlayerController.asset("");
  double _right = 10;
  void setController(VideoPlayerController c) async {
    setState(() {
      _controller = c;
    });
  }
  void destroyController(){
    setState(() {
      _controller = VideoPlayerController.asset("");
    });
  }
  @override
  Widget build(BuildContext context) {
    return (_controller.value.isInitialized == false)
        ? Container(
            width: 0,
          )
        : GestureDetector(
            onTap: () => setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          }),
            onDoubleTap: destroyController,
            child: Container(
              color: Colors.black,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            )
    );
  }
}
