import 'dart:io';

import 'package:another_xlider/another_xlider.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/edited_info.dart';
import 'package:video_editor/loading.dart';
import 'package:video_editor/utils.dart';
import 'package:video_player/video_player.dart';

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
      return Column(
        children: [
          Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
              SizedBox(
                height: h + 5,
                width: w + 20,
                child: TrimBox(
                  h: h,
                  w: w,
                  editedInfo: widget.editedInfo,
                ),
              ),
            ],
            alignment: AlignmentDirectional.center,
          ),
          TrimText(
            editedInfo: widget.editedInfo,
            controller: widget.controller,
          )
        ],
      );
    });
  }
}

class TrimText extends StatefulWidget {
  const TrimText({Key? key, required this.editedInfo, required this.controller}) : super(key: key);
  final EditedInfo editedInfo;
  final VideoPlayerController controller;

  @override
  State<TrimText> createState() => _TrimTextState();
}

class _TrimTextState extends State<TrimText> {
  @override
  void initState() {
    super.initState();
    widget.editedInfo.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: Text(
                Utils.formatTime(widget.editedInfo.start.inMilliseconds, true)),
            onPressed: () {
              if (widget.controller.value.position < (widget.editedInfo.end - const Duration(milliseconds: 500))) {
                widget.editedInfo.start = widget.controller.value.position;
                widget.editedInfo.notify();
              }
            },
          ),
          TextButton(
            child: Text(
                Utils.formatTime(widget.editedInfo.end.inMilliseconds, true)),
            onPressed: () {
              if (widget.controller.value.position > (widget.editedInfo.start + const Duration(milliseconds: 500))) {
                widget.editedInfo.end = widget.controller.value.position;
                widget.editedInfo.notify();
              }
            },
          ),
        ],
      ),
    );
  }
}

class TrimBox extends StatefulWidget {
  final double h;
  final double w;
  final EditedInfo editedInfo;
  const TrimBox(
      {Key? key, required this.h, required this.w, required this.editedInfo})
      : super(key: key);

  @override
  _TrimBoxState createState() => _TrimBoxState();
}

class _TrimBoxState extends State<TrimBox> {

  @override
  void initState() {
    super.initState();
    widget.editedInfo.addListener(() {
      setState(() {
        start = widget.editedInfo.start.inMilliseconds.toDouble();
        end = widget.editedInfo.end.inMilliseconds.toDouble();
      });
    });
  }

  double start = 0;
  late double end = widget.editedInfo.totalLength.inMilliseconds.toDouble();
  @override
  Widget build(BuildContext context) {
    return FlutterSlider(
      values: [start, end],
      rangeSlider: true,
      max: widget.editedInfo.totalLength.inMilliseconds.toDouble(),
      min: 0,
      handlerWidth: 20,
      handlerHeight: widget.h + 5,
      handler: FlutterSliderHandler(
        child: Image.asset(
          'assets/boxleft.png',
        ),
        decoration: const BoxDecoration(),
      ),
      rightHandler: FlutterSliderHandler(
        child: Image.asset(
          'assets/boxright.png',
        ),
        decoration: const BoxDecoration(),
      ),
      handlerAnimation: const FlutterSliderHandlerAnimation(
        duration: Duration(milliseconds: 500),
        scale: 1.1,
      ),
      selectByTap: false,
      minimumDistance: 500,
      trackBar: FlutterSliderTrackBar(
        activeTrackBarHeight: widget.h + 5,
        activeTrackBar: const BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              image: AssetImage('assets/boxmid.png'),
              fit: BoxFit.fill,
            )),
        inactiveTrackBar: const BoxDecoration(
          color: Colors.transparent,
        ),
      ),
      tooltip: FlutterSliderTooltip(
        boxStyle: FlutterSliderTooltipBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
        format: (String s) {
          double t = double.tryParse(s) ?? 0;
          return Utils.formatTime(t.toInt(), true);
        },
      ),
      onDragging: (handlerIndex, lowerValue, upperValue) {
        setState(() {
          start = lowerValue;
          end = upperValue;
        });
      },
      onDragCompleted: (a, b, c) => trimRange(),
    );
  }

  void trimRange() {
    widget.editedInfo.start = Duration(milliseconds: start.round());
    widget.editedInfo.end = Duration(milliseconds: end.round());
    widget.editedInfo.notify();
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
    await FFmpegKit.executeWithArguments(arguments);
    setState(() {});
  }

  void thumbnailBuilder(double w, double h) async {
    debugPrint(w.toString() + widget.editedInfo.toString());
    Directory temp = await getTemporaryDirectory();
    if (Directory("${temp.path}/thumbs").existsSync()) {
      Directory("${temp.path}/thumbs").deleteSync(recursive: true);
    }
    Directory("${temp.path}/thumbs").createSync();
    int n = w ~/ h;
    for (var i = 0; i < n; i++) {
      String outpath = temp.path + "/thumbs/$i.png";
      list.add(File(outpath));
      debugPrint(outpath);
      List<String> arguments = [
        "-y",
        "-ss",
        (widget.editedInfo.totalLength ~/ n * i).toString(),
        "-i",
        widget.editedInfo.filepath,
        "-vf",
        "scale=320:-1",
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
