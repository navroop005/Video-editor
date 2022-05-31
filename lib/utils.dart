class Utils {
  static String formatTime(int millisec, bool splitSecs) {
    String s = "";
    if (millisec ~/ 3600000 > 0) {
      s += "${millisec ~/ 3600000}";
    }
    s += ((millisec % 3600000) ~/ 60000).toString().padLeft(2, '0') +
        ":" +
        ((millisec % 60000) ~/ 1000).toString().padLeft(2, '0');
    if (splitSecs) {
      s += "." + ((millisec % 1000) ~/ 10).toString().padLeft(2, '0');
    }

    return s;
  }
}
