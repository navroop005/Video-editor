import 'package:flutter/material.dart';
import 'package:video_editor/edited_info.dart';
import 'package:video_player/video_player.dart';

class CropTab extends StatefulWidget {
  final EditedInfo editedInfo;
  final VideoPlayerController controller;

  const CropTab({Key? key, required this.editedInfo, required this.controller}) : super(key: key);

  @override
  State<CropTab> createState() => _CropTabState();
}

class _CropTabState extends State<CropTab>
    with AutomaticKeepAliveClientMixin<CropTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.red,
    );
  }
}
