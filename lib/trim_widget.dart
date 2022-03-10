import 'dart:io';

import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/loading.dart';
import 'package:video_player/video_player.dart';

import 'edited_info.dart';

class TrimWidget extends StatefulWidget {
  final VideoPlayerController controller;
  final EditedInfo editedInfo;
  const TrimWidget(
      {Key? key, required this.controller, required this.editedInfo})
      : super(key: key);

  @override
  State<TrimWidget> createState() => _TrimWidgetState();
}

class _TrimWidgetState extends State<TrimWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double h = 60;
      double w = constraints.maxWidth - constraints.maxWidth % h;
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Center(
              child: Container(
                height: h,
                width: w,
                color: Colors.grey[900],
                child: Thumbnails(
                  w: w,
                  h: h,
                  editedInfo: widget.editedInfo,
                ),
              ),
            ),
          ),
          TrimBox(
            h: h,
            maxw: constraints.maxWidth,
            editedInfo: widget.editedInfo,
          ),
        ],
        alignment: AlignmentDirectional.center,
      );
    });
  }
}

class TrimBox extends StatefulWidget {
  final double h;
  final double maxw;
  final EditedInfo editedInfo;
  const TrimBox(
      {Key? key, required this.h, required this.maxw, required this.editedInfo})
      : super(key: key);

  @override
  _TrimBoxState createState() => _TrimBoxState();
}

class _TrimBoxState extends State<TrimBox> {
  RangeValues t = const RangeValues(0, 1);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /*Image.asset(
          'assets/boxleft.png',
          height: widget.h + 5,
        ),
        Image.asset(
          'assets/boxmid.png',
          height: widget.h + 5,
          fit: BoxFit.fill,
        ),
        Image.asset(
          'assets/boxright.png',
          height: widget.h + 5,
        ),*/
        Expanded(
          child: SliderTheme(
            data: const SliderThemeData(),
            child: RangeSlider(
              values: t,
              onChanged: (RangeValues values) {
                setState(() {
                  t = values;
                });
              },
              onChangeEnd: (value) => trimRange(),
            ),
          ),
        ),
      ],
    );
  }

  void trimRange() {
    widget.editedInfo.start = widget.editedInfo.totalLength * t.start;
    widget.editedInfo.end = widget.editedInfo.totalLength * t.end;
    debugPrint(
        "Start: ${widget.editedInfo.start}  end: ${widget.editedInfo.end}");
  }
}

class Thumbnails extends StatefulWidget {
  const Thumbnails(
      {Key? key, required this.h, required this.w, required this.editedInfo})
      : super(key: key);
  final double w, h;
  final EditedInfo editedInfo;
  @override
  _ThumbnailsState createState() => _ThumbnailsState();
}

class _ThumbnailsState extends State<Thumbnails> {
  List<File> list = [];

  @override
  void initState() {
    super.initState();
    thumbnailBuilder(widget.w, widget.h);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: list.map((f) {
        return f.existsSync()
            ? Image.file(
                f,
                width: widget.h,
                height: widget.h,
                fit: BoxFit.cover,
              )
            : Loading(w: widget.h);
      }).toList(),
    );
  }

  Future<void> ffexecute(int i, List<String> arguments, String fpath) async {
    list.insert(i, File(fpath));
    FFmpegKit.executeWithArguments(arguments).then((session) async {
      final ReturnCode? returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode) && mounted) {
        setState(() {});
      }
    });
  }

  void thumbnailBuilder(double w, double h) async {
    debugPrint(w.toString() + widget.editedInfo.toString());

    Directory temp = await getTemporaryDirectory();
    Directory("${temp.path}/thumbs").createSync();
    int n = w ~/ h;
    for (var i = 0; i < n; i++) {
      String outpath = temp.path + "/thumbs/$i.png";
      debugPrint(outpath);
      List<String> arguments = [
        "-y",
        "-ss",
        (widget.editedInfo.totalLength ~/ n * i).toString(),
        "-i",
        widget.editedInfo.filepath,
        "-frames:v",
        "1",
        outpath
      ];
      await ffexecute(i, arguments, outpath);
    }
  }

  @override
  void dispose() async {
    super.dispose();
  }
}
