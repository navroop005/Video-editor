import 'package:flutter/material.dart';
import 'package:video_editor/edited_info.dart';
import 'package:video_player/video_player.dart';

class TextTab extends StatefulWidget {
  final EditedInfo editedInfo;
  final VideoPlayerController controller;

  const TextTab({Key? key, required this.editedInfo, required this.controller}) : super(key: key);

  @override
  State<TextTab> createState() => _TextTabState();
}

class _TextTabState extends State<TextTab>
    with AutomaticKeepAliveClientMixin<TextTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.green,
    );
  }
}
