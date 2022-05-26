import 'package:flutter/material.dart';
import 'package:video_editor/edited_info.dart';

class EnhanceTab extends StatefulWidget {
  final EditedInfo editedInfo;
  const EnhanceTab({Key? key, required this.editedInfo}) : super(key: key);

  @override
  State<EnhanceTab> createState() => _EnhanceTabState();
}

class _EnhanceTabState extends State<EnhanceTab>
    with AutomaticKeepAliveClientMixin<EnhanceTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.blue,
    );
  }
}
