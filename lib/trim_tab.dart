import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/trim_widget.dart';
import 'package:video_editor/video_controls.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'edited_info.dart';
import 'full_screen_viewer.dart';

class TrimTab extends StatefulWidget {
  final EditedInfo editedInfo;
  const TrimTab({Key? key, required this.editedInfo}) : super(key: key);

  @override
  _TrimTabState createState() => _TrimTabState();
}

class _TrimTabState extends State<TrimTab>
    with AutomaticKeepAliveClientMixin<TrimTab> {
  late VideoPlayerController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.editedInfo.filepath))
      ..initialize().then((_) {
        setState(() {});
      });
    Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: GestureDetector(
                onDoubleTap: () =>
                    FullScreenView.showFullScreen(context, _controller),
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
          flex: 2,
          child: Column(
            children: [
              VideoPlayerControlls(
                controller: _controller,
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
