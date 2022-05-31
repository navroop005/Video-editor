import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/media_information.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/stream_information.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/crop_tab.dart';
import 'package:video_editor/edited_info.dart';
import 'package:video_editor/enhance_tab.dart';
import 'package:video_editor/loading.dart';
import 'package:video_editor/save_file.dart';
import 'package:video_editor/trim_tab.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class Editor extends StatefulWidget {
  const Editor({Key? key}) : super(key: key);

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late final MediaInformation mediaInformation;

  final EditedInfo editedInfo = EditedInfo();

  late VideoPlayerController _controller;

  bool isInitialized = false;
  Future<bool> initialize() async {
    if (!isInitialized) {
      isInitialized = true;
      await FFprobeKit.getMediaInformation(editedInfo.filepath)
          .then((session) async {
        mediaInformation = session.getMediaInformation()!;
      });
      editedInfo.frameRate = getFramerate();
      editedInfo.totalLength = editedInfo.end = Duration(
          microseconds: (double.parse(
                      mediaInformation.getMediaProperties()!['duration']) *
                  1000000)
              .floor());
      _controller = VideoPlayerController.file(File(editedInfo.filepath));
      await _controller.initialize();
      Wakelock.enable();
    }
    return isInitialized;
  }

  @override
  void dispose() async {
    super.dispose();
    _controller.dispose();
    Wakelock.disable();
    Directory path = await getTemporaryDirectory();
    Directory(path.path + "/thumbs").deleteSync(recursive: true);
    File(editedInfo.filepath).deleteSync(recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    editedInfo.filepath = args.values.first;
    editedInfo.fileName = args.values.elementAt(1);
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
          future: initialize(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          TrimTab(editedInfo: editedInfo, controller: _controller),
                          CropTab(editedInfo: editedInfo, controller: _controller),
                          EnhanceTab(editedInfo: editedInfo, controller: _controller),
                        ],
                      ),
                    ),
                    TabBar(
                      indicatorColor: Colors.white,
                      indicator: BoxDecoration(
                        color: Colors.grey.withAlpha(70),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      indicatorPadding: const EdgeInsets.all(5),
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                      tabs: const [
                        Tab(
                          text: "Trim",
                        ),
                        Tab(
                          text: "Crop",
                        ),
                        Tab(
                          text: "Enhance",
                        ),
                      ],
                    ),
                  ],
                ),
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
        return SavePopup(
          editedInfo: editedInfo,
        );
      },
    );
  }
}
