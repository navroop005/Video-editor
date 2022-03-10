import 'dart:io';

import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full/media_information.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:ffmpeg_kit_flutter_full/statistics.dart';
import 'package:ffmpeg_kit_flutter_full/stream_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/loading.dart';
import 'package:video_editor/trim_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'edited_info.dart';
import 'full_screen_viewer.dart';

class Editor extends StatelessWidget {
  Editor({Key? key}) : super(key: key);
  
  late final MediaInformation mediaInformation;
  final EditedInfo edited = EditedInfo();

  Future<bool> getMediaInfo(String path) async {
    await FFprobeKit.getMediaInformation(path).then((session) async {
      mediaInformation = session.getMediaInformation()!;
    });
    edited.frameRate = getFramerate();
    edited.totalLength = edited.end = Duration(
        microseconds:
            (double.parse(mediaInformation.getMediaProperties()!['duration']) *
                    1000000)
                .floor());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    edited.filepath = args.values.first;
    edited.fileName = args.values.elementAt(1);
    return Scaffold(
      appBar: AppBar(
        title: Text(args.values.elementAt(1)),
        backgroundColor: Colors.indigo[900],
        actions: [
          RawMaterialButton(
            onPressed: () => saveFile(context),
            child: const Text(
              "SAVE",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w900,
              ),
            ),
            constraints: const BoxConstraints(minHeight: 36.0),
          ),
          IconButton(
            onPressed: () => showInfo(args.values.first, context),
            icon: const Icon(
              Icons.info_outlined,
              color: Colors.white60,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
          future: getMediaInfo(args.values.first),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return VideoApp(
                editedInfo: edited,
              );
            } else {
              return const Loading();
            }
          }),
      backgroundColor: Colors.black,
    );
  }

  Future<void> showInfo(String path, BuildContext context) async {
    List<String> vidInfo = [];

    vidInfo.add("Media Information");

    vidInfo.add("Path: ${mediaInformation.getMediaProperties()!['filename']}");
    vidInfo.add(
        "Format: ${mediaInformation.getMediaProperties()!['format_name']}");
    vidInfo
        .add("Duration: ${mediaInformation.getMediaProperties()!['duration']}");
    vidInfo.add(
        "Start time: ${mediaInformation.getMediaProperties()!['start_time']}");
    vidInfo
        .add("Bitrate: ${mediaInformation.getMediaProperties()!['bit_rate']}");
    Map<dynamic, dynamic> tags = mediaInformation.getMediaProperties()!['tags'];
    tags.forEach((key, value) {
      vidInfo.add("Tag: " + key + ":" + value + "\n");
    });

    List<StreamInformation>? streams = mediaInformation.getStreams();

    if (streams.isNotEmpty) {
      for (var stream in streams) {
        vidInfo.add("Stream id: ${stream.getAllProperties()!['index']}");
        vidInfo.add("Stream type: ${stream.getAllProperties()!['codec_type']}");
        vidInfo
            .add("Stream codec: ${stream.getAllProperties()!['codec_name']}");
        vidInfo.add(
            "Stream full codec: ${stream.getAllProperties()!['codec_long_name']}");
        vidInfo.add("Stream format: ${stream.getAllProperties()!['pix_fmt']}");
        vidInfo.add("Stream width: ${stream.getAllProperties()!['width']}");
        vidInfo.add("Stream height: ${stream.getAllProperties()!['height']}");
        vidInfo
            .add("Stream bitrate: ${stream.getAllProperties()!['bit_rate']}");
        vidInfo.add(
            "Stream sample rate: ${stream.getAllProperties()!['sample_rate']}");
        vidInfo.add(
            "Stream sample format: ${stream.getAllProperties()!['sample_fmt']}");
        vidInfo.add(
            "Stream channel layout: ${stream.getAllProperties()!['channel_layout']}");
        vidInfo.add(
            "Stream sar: ${stream.getAllProperties()!['sample_aspect_ratio']}");
        vidInfo.add(
            "Stream dar: ${stream.getAllProperties()!['display_aspect_ratio']}");
        vidInfo.add(
            "Stream average frame rate: ${stream.getAllProperties()!['avg_frame_rate']}");
        vidInfo.add(
            "Stream real frame rate: ${stream.getAllProperties()!['r_frame_rate']}");
        vidInfo.add(
            "Stream time base: ${stream.getAllProperties()!['time_base']}");
        vidInfo.add(
            "Stream codec time base: ${stream.getAllProperties()!['codec_time_base']}");

        Map<dynamic, dynamic> tags = stream.getAllProperties()!['tags'];
        tags.forEach((key, value) {
          vidInfo.add("Stream tag: " + key + ":" + value + "\n");
        });
      }
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Video Information'),
          content: SingleChildScrollView(
            child: ListBody(
              children: vidInfo.map((e) => Text(e)).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  double getFramerate() {
    List<String> a = (mediaInformation
            .getStreams()
            .firstWhere((element) =>
                element.getAllProperties()!['codec_type'] == 'video')
            .getAllProperties()!['avg_frame_rate'])
        .toString()
        .split('/');
    return double.parse(a.first) / double.parse(a.last);
  }

  void saveFile(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SavePopup(editedInfo: edited,);
      },
    );
  }
}

class SavePopup extends StatefulWidget {
  const SavePopup({Key? key, required this.editedInfo}) : super(key: key);
  final EditedInfo editedInfo;
  @override
  _SavePopupState createState() => _SavePopupState();
}

class _SavePopupState extends State<SavePopup> {
  late Duration total = widget.editedInfo.end - widget.editedInfo.start;
  Duration done = Duration.zero;
  bool _isdone = false;
  @override
  void initState(){
    super.initState();
    savefile(context);
  }

  @override
  Widget build(BuildContext context) {
    double donePercent = (done.inMilliseconds) / total.inMilliseconds;
    return AlertDialog(
      title: Center(child: _isdone? const Text('Done!', style: TextStyle(color: Colors.white),): const Text("Saving", style: TextStyle(color: Colors.white),)),
      backgroundColor: Colors.black54,
      content: _isdone? null : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: donePercent,
          ),
          const SizedBox(height: 10,),
          Text(
              "${done.inMinutes}:${done.inSeconds % 60}/${total.inMinutes}:${total.inSeconds % 60}", style: const TextStyle(color: Colors.white),)
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: _isdone? const Text("Close"): const Text('Cancel'),
          onPressed: () {
            cancel();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
  int? sessionId;
  void savefile(BuildContext context) async {
    try {
      String? uri = await FFmpegKitConfig.selectDocumentForWrite(
          widget.editedInfo.fileName, 'video/*');

      FFmpegKitConfig.getSafParameterForWrite(uri!).then((safUrl) {
        String command =
            "-ss ${widget.editedInfo.start} -to ${widget.editedInfo.end} -i ${widget.editedInfo.filepath} $safUrl";
        debugPrint(command);
        debugPrint(uri);
        FFmpegKit.executeAsync(command, completed, null, updateStatics).then((session) async {
          sessionId = session.getSessionId();
        });
      });
    } on PlatformException {
      debugPrint("canceled");
      Navigator.of(context).pop();
    }
  }
  void updateStatics(Statistics s){
    setState(() {
      done = Duration(milliseconds: s.getTime());
    });
  }
  void completed(FFmpegSession f){
    setState(() {
      _isdone = true;
    });
  }

  void cancel(){
    FFmpegKit.cancel();
  }
}

class VideoApp extends StatefulWidget {
  final EditedInfo editedInfo;
  const VideoApp({Key? key, required this.editedInfo}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.editedInfo.filepath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  late OverlayEntry overlayEntry;
  void hideFullScreen() {
    overlayEntry.remove();
  }

  void showFullScreen(BuildContext context) {
    OverlayState? overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(
        builder: (context) =>
            FullScreenView(controller: _controller, f: hideFullScreen),
        opaque: true,
        maintainState: true);
    overlayState!.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              VideoPlayerControlls(
                controller: _controller,
                fullScreen: showFullScreen,
                framerate: widget.editedInfo.frameRate,
              ),
              const SizedBox(
                height: 10,
              ),
              TrimWidget(
                controller: _controller,
                editedInfo: widget.editedInfo,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() async {
    super.dispose();
    _controller.dispose();
    Wakelock.disable();
    Directory path = await getTemporaryDirectory();
    Directory(path.path + "/thumbs").deleteSync(recursive: true);
    File(widget.editedInfo.filepath).deleteSync(recursive: true);
    debugPrint(path.path + "/thumbs");
  }
}

class VideoPlayerControlls extends StatefulWidget {
  final VideoPlayerController controller;
  final Function fullScreen;
  final double framerate;
  const VideoPlayerControlls(
      {Key? key,
      required this.controller,
      required this.fullScreen,
      required this.framerate})
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
