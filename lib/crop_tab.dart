import 'package:flutter/material.dart';
import 'package:video_editor/edited_info.dart';

class CropTab extends StatefulWidget {
  final EditedInfo editedInfo;
  const CropTab({Key? key, required this.editedInfo}) : super(key: key);

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
