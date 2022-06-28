import 'package:flutter/material.dart';

class EditedInfo with ChangeNotifier {
  double frameRate = 0;
  Duration totalLength = Duration.zero;
  String filepath = '';
  String fileName = '';
  Duration start = Duration.zero;
  Duration end = Duration.zero;
  double cropTop = 0;
  double cropLeft = 0;
  double cropRight = 1;
  double cropBottom = 1;
  int turns = 0;
  bool flipX = false;
  bool flipY = false;

  EditedInfo();
  @override
  String toString() {
    return "framerate: $frameRate, totalLength: $totalLength, filepath: $filepath, start: $start, end: $end";
  }
  void notify(){
    notifyListeners();
  }
}
