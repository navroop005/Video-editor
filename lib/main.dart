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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: Center(
          child: VideoApp(),
        ),
      ),
    );
  }
}

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/BigBuckBunny.mp4")
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {

    final bool _ismuted = _controller.value.volume == 0;
    final double _seek = _controller.value.isInitialized?(_controller.value.position.inMilliseconds/_controller.value.duration.inMilliseconds) : 0;

    void setPosition(double seek){
      setState(() {
        _controller.seekTo(Duration(milliseconds: (seek*_controller.value.duration.inMilliseconds).toInt()));
      });
    }

    return Column(children: [
      Center(
        child: VideoPlayerWidget(controller: _controller),
      ),
      VideoProgressIndicator(
        _controller,
        allowScrubbing: true
      ),
     /* Slider(
        value: _seek, 
        onChanged: setPosition,
        min: 0,
        max: 1,
      ),*/
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.red[500],
              shape: CircleBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _ismuted
                    ? _controller.setVolume(1)
                    : _controller.setVolume(0);
              });
            },
            child: Icon(
              _ismuted ? Icons.volume_mute : Icons.volume_up,
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.red[500],
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
        
      ],
    );
  }
}
