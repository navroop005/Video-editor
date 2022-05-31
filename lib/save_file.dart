import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/edited_info.dart';
import 'package:video_editor/utils.dart';

class SavePopup extends StatefulWidget {
  const SavePopup({Key? key, required this.editedInfo}) : super(key: key);
  final EditedInfo editedInfo;

  @override
  State<SavePopup> createState() => _SavePopupState();
}

class _SavePopupState extends State<SavePopup> {
  late String fileName;
  List<String> extensions = ['.mp4', '.webm', '.mov', '.avi'];
  late String extension;
  List<String> videocodecs = ['h264', 'hevc', 'vp8', 'vp9', 'av1'];
  late String videocodec;
  List<String> audiocodecs = ['aac', 'mp3', 'opus', 'vorbis'];
  late String audiocodec;

  @override
  void initState() {
    super.initState();
    fileName = widget.editedInfo.fileName.split('.').first;
    extension = extensions[0];
    videocodec = videocodecs[0];
    audiocodec = audiocodecs[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text("Save File")),
      titleTextStyle:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      backgroundColor: Colors.black54,
      actions: <Widget>[
        TextButton(
          child: const Text('SAVE'),
          onPressed: () {
            Navigator.of(context).pop();
            onsave();
          },
        ),
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Name: "),
          TextFormField(
            initialValue: fileName,
            onChanged: (value) => fileName = value,
          ),
          Row(
            children: [
              const Text("File extension: "),
                DropdownButton(
                value: extension,
                items: extensions.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    extension = newValue!;
                  });
                },
                dropdownColor: Colors.grey[800],
              ),            ],
          ),
          Row(
            children: [
              const Text("Video codec: "),
              DropdownButton(
                value: videocodec,
                items: videocodecs.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    videocodec = newValue!;
                  });
                },
                dropdownColor: Colors.grey[800],
              ),
            ],
          ),
          Row(
            children: [
              const Text("Audio codec: "),
              DropdownButton(
                value: audiocodec,
                items: audiocodecs.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    audiocodec = newValue!;
                  });
                },
                dropdownColor: Colors.grey[800],
              ),            ],
          ),
        ],
      ),
    );
  }

  void onsave() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SavingPopup(
          editedInfo: widget.editedInfo,
          audiocodec: audiocodec,
          extension: extension,
          fileName: fileName,
          videocodec: videocodec,
        );
      },
    );
  }
}

class SavingPopup extends StatefulWidget {
  const SavingPopup(
      {Key? key,
      required this.editedInfo,
      required this.fileName,
      required this.extension,
      required this.videocodec,
      required this.audiocodec})
      : super(key: key);
  final EditedInfo editedInfo;
  final String fileName;
  final String extension;
  final String videocodec;
  final String audiocodec;
  @override
  _SavingPopupState createState() => _SavingPopupState();
}

class _SavingPopupState extends State<SavingPopup> {
  late Duration total = widget.editedInfo.end - widget.editedInfo.start;
  Duration done = Duration.zero;
  bool _isdone = false;
  String doneStr = "";
  String? tempfile;
  @override
  void initState() {
    super.initState();
    savefile(context);
  }

  @override
  Widget build(BuildContext context) {
    double donePercent = (done.inMilliseconds) / total.inMilliseconds;
    return AlertDialog(
      title: Center(
          child: _isdone
              ? Text(
                  doneStr,
                  style: const TextStyle(color: Colors.white),
                )
              : const Text(
                  "Saving",
                  style: TextStyle(color: Colors.white),
                )),
      backgroundColor: Colors.black54,
      content: _isdone
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: donePercent,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "${Utils.formatTime(done.inMilliseconds, false)}/${Utils.formatTime(total.inMilliseconds, false)}",
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
      actions: <Widget>[
        TextButton(
          child: _isdone ? const Text("Close") : const Text('Cancel'),
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
      Directory? tmp = await getTemporaryDirectory();
      String temp = tmp.path;
      tempfile = temp+'/'+ widget.fileName + widget.extension;
      debugPrint(tempfile);
      List<String> commands = [
        "-hwaccel",
        "mediacodec",
        "-y",
        "-ss",
        "${widget.editedInfo.start}",
        "-to",
        "${widget.editedInfo.end}",
        "-i",
        (widget.editedInfo.filepath),
        "-c:v",
        widget.videocodec,
        "-c:a",
        widget.audiocodec,
        tempfile!
      ];
      debugPrint(commands.toString());
      FFmpegKit.executeWithArgumentsAsync(
          commands, completed, null, updateStatics);
    } on PlatformException {
      debugPrint("canceled");
      Navigator.of(context).pop();
    }
  }

  void updateStatics(Statistics s) {
    if (mounted) {
      setState(() {
        done = Duration(milliseconds: s.getTime());
      });
    }

    debugPrint(
        "Time: ${s.getTime()}, Bitrate: ${s.getBitrate()}, Quality: ${s.getVideoQuality()}, Speed: ${s.getSpeed()}");
  }

  void completed(FFmpegSession f) async {
    _isdone = true;
    ReturnCode? returnCode = await f.getReturnCode();
    debugPrint(returnCode!.getValue().toString());
    if (ReturnCode.isSuccess(returnCode) && mounted) {
      setState(() {
        GallerySaver.saveVideo(tempfile!, albumName: "Video Editor");
        doneStr = "Completed!";
      });
    } else {
      if (mounted) {
        setState(() {
          doneStr = "Error";
        });
      }
    }
    debugPrint(doneStr);
  }

  void cancel() {
    FFmpegKit.cancel();
  }
}
