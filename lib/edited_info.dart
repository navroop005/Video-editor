import 'package:flutter/material.dart';

class EditedInfo with ChangeNotifier {
  double frameRate = 0;
  Duration totalLength = Duration.zero;
  String filepath = '';
  String fileName = '';
  Duration start = Duration.zero;
  Duration end = Duration.zero;
  EditedInfo();
  @override
  String toString() {
    return "framerate: $frameRate, totalLength: $totalLength, filepath: $filepath, start: $start, end: $end";
  }
  void notify(){
    notifyListeners();
  }
}
