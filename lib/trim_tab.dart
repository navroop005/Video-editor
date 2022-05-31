import 'package:flutter/material.dart';
import 'package:video_editor/edited_info.dart';
import 'package:video_editor/full_screen_viewer.dart';
import 'package:video_editor/trim_widget.dart';
import 'package:video_editor/video_controls.dart';
import 'package:video_player/video_player.dart';

class TrimTab extends StatefulWidget {
  final EditedInfo editedInfo;
  final VideoPlayerController controller;
  const TrimTab({Key? key, required this.editedInfo, required this.controller}) : super(key: key);

  @override
  _TrimTabState createState() => _TrimTabState();
}

class _TrimTabState extends State<TrimTab>
    with AutomaticKeepAliveClientMixin<TrimTab> {

  @override
  bool get wantKeepAlive => true;

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
                    FullScreenView.showFullScreen(context, widget.controller),
                onTap: () => setState(() {
                  widget.controller.value.isPlaying
                      ? widget.controller.pause()
                      : widget.controller.play();
                }),
                child: (widget.controller.value.isInitialized)
                    ? AspectRatio(
                        aspectRatio: widget.controller.value.aspectRatio,
                        child: VideoPlayer(widget.controller),
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
                controller: widget.controller,
                framerate: widget.editedInfo.frameRate,
              ),
              const SizedBox(
                height: 10,
              ),
              TrimWidget(
                controller: widget.controller,
                editedInfo: widget.editedInfo,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
