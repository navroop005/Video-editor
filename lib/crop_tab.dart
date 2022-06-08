import 'package:flutter/material.dart';
import 'package:video_editor/edited_info.dart';
import 'package:video_editor/video_controls.dart';
import 'package:video_player/video_player.dart';

class CropTab extends StatefulWidget {
  final EditedInfo editedInfo;
  final VideoPlayerController controller;

  const CropTab({Key? key, required this.editedInfo, required this.controller})
      : super(key: key);

  @override
  State<CropTab> createState() => _CropTabState();
}

class _CropTabState extends State<CropTab>
    with AutomaticKeepAliveClientMixin<CropTab> {
  @override
  bool get wantKeepAlive => true;
  CropSettings settings = CropSettings();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: (widget.controller.value.isInitialized)
                  ? AspectRatio(
                      aspectRatio: widget.controller.value.aspectRatio,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: VideoPlayer(widget.controller),
                          ),
                          LayoutBuilder(builder: (context, constraints) {
                            return CropBox(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth,
                              padding: 10,
                            );
                          }),
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              VideoPlayerControlls(
                controller: widget.controller,
                framerate: widget.editedInfo.frameRate,
              ),
              CropOptions(
                settings: settings,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CropBox extends StatefulWidget {
  const CropBox(
      {Key? key,
      required this.height,
      required this.width,
      required this.padding})
      : super(key: key);
  final double height;
  final double width;
  final double padding;

  @override
  State<CropBox> createState() => _CropBoxState();
}

class _CropBoxState extends State<CropBox> {
  late double top;
  late double left;
  late double right;
  late double bottom;

  final double offset = 40;

  Widget corner = const Icon(
    Icons.circle,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    top = widget.padding;
    left = widget.padding;
    right = widget.width - widget.padding;
    bottom = widget.height - widget.padding;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: top, color: Colors.black38),
                left: BorderSide(width: left, color: Colors.black38),
                right: BorderSide(
                    width: constraints.maxWidth - right, color: Colors.black38),
                bottom: BorderSide(
                    width: constraints.maxHeight - bottom,
                    color: Colors.black38),
              ),
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: top,
            left: left,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.white,
                width: 2,
              )),
            ),
            width: right - left,
            height: bottom - top,
          ),
          Positioned(
            top: top - 10,
            left: left - 10,
            child: corner,
          ),
          Positioned(
            top: top - 10,
            left: right - 13,
            child: corner,
          ),
          Positioned(
            top: bottom - 13,
            left: left - 10,
            child: corner,
          ),
          Positioned(
            top: bottom - 13,
            left: right - 13,
            child: corner,
          ),
          GestureDetector(
            onPanUpdate: onUpdate,
            onPanDown: onStart,
            onPanEnd: onEnd,
          ),
        ],
      );
    });
  }

  int select = 0;

  void onStart(DragDownDetails details) {
    bool isTop = (details.localPosition.dy < top + offset) &&
        (details.localPosition.dy > top - offset);
    bool isBottom = (details.localPosition.dy < bottom + offset) &&
        (details.localPosition.dy > bottom - offset);
    bool isLeft = (details.localPosition.dx < left + offset) &&
        (details.localPosition.dx > left - offset);
    bool isRight = (details.localPosition.dx < right + offset) &&
        (details.localPosition.dx > right - offset);

    debugPrint(
        "l:$isLeft r:$isRight t:$isTop b:$isBottom ${details.runtimeType}");
    if (isTop && isLeft) {
      // top left
      select = 1;
    } else if (isBottom && isLeft) {
      // botton left
      select = 2;
    } else if (isTop && isRight) {
      // top right
      select = 3;
    } else if (isBottom && isRight) {
      // botton right
      select = 4;
    } else if (isLeft) {
      //left only
      if ((details.localPosition.dy < bottom) &&
          (details.localPosition.dy > top)) {
        select = 5;
      }
    } else if (isRight) {
      // right only
      if ((details.localPosition.dy < bottom) &&
          (details.localPosition.dy > top)) {
        select = 6;
      }
    } else if (isTop) {
      // top only
      if ((details.localPosition.dx < right) &&
          (details.localPosition.dx > left)) {
        select = 7;
      }
    } else if (isBottom) {
      // bottom only
      if ((details.localPosition.dx < right) &&
          (details.localPosition.dx > left)) {
        select = 8;
      }
    }
  }

  double minHeight = 50;
  double minWidth = 50;

  void onUpdate(DragUpdateDetails details) {
    void setTop(double y) {
      if ((bottom - y) < minHeight) {
        top = bottom - minHeight;
      } else {
        if (y >= widget.padding) {
          top = y;
        } else {
          top = widget.padding;
        }
      }
    }

    void setLeft(double x) {
      if ((right - x) < minWidth) {
        left = right - minWidth;
      } else {
        if (x >= widget.padding) {
          left = x;
        } else {
          left = widget.padding;
        }
      }
    }

    void setBottom(double y) {
      if ((y - top) < minHeight) {
        bottom = top + minHeight;
      } else {
        if (y <= widget.height - widget.padding) {
          bottom = y;
        } else {
          bottom = widget.height - widget.padding;
        }
      }
    }

    void setRight(double x) {
      if ((x - left) < minWidth) {
        right = left + minWidth;
      } else {
        if (x <= widget.width - widget.padding) {
          right = x;
        } else {
          right = widget.width - widget.padding;
        }
      }
    }

    void move(Offset offset) {
      double _top = top + offset.dy;
      double _left = left + offset.dx;
      double _right = right + offset.dx;
      double _bottom = bottom + offset.dy;
      if (_top < widget.padding) {
        top = widget.padding;
        bottom += top - _top + offset.dy;
      } else if (_bottom > widget.height - widget.padding) {
        bottom = widget.height - widget.padding;
        top += bottom - _bottom + offset.dy;
      } else {
        top = _top;
        bottom = _bottom;
      }
      if (_left < widget.padding) {
        left = widget.padding;
        right += left - _left + offset.dx;
      } else if (_right > widget.width - widget.padding) {
        right = widget.width - widget.padding;
        left += right - _right + offset.dx;
      } else {
        left = _left;
        right = _right;
      }
    }

    switch (select) {
      case 1:
        setState(() {
          setTop(details.localPosition.dy);
          setLeft(details.localPosition.dx);
        });
        break;
      case 2:
        setState(() {
          setBottom(details.localPosition.dy);
          setLeft(details.localPosition.dx);
        });
        break;
      case 3:
        setState(() {
          setTop(details.localPosition.dy);
          setRight(details.localPosition.dx);
        });
        break;
      case 4:
        setState(() {
          setBottom(details.localPosition.dy);
          setRight(details.localPosition.dx);
        });
        break;
      case 5:
        setState(() {
          setLeft(details.localPosition.dx);
        });
        break;
      case 6:
        setState(() {
          setRight(details.localPosition.dx);
        });
        break;
      case 7:
        setState(() {
          setTop(details.localPosition.dy);
        });
        break;
      case 8:
        setState(() {
          setBottom(details.localPosition.dy);
        });
        break;
      default:
        setState(() {
          move(details.delta);
        });
        break;
    }
  }

  void onEnd(DragEndDetails details) {
    select = 0;
  }
}

class CropOptions extends StatefulWidget {
  const CropOptions({Key? key, required this.settings}) : super(key: key);
  final CropSettings settings;
  @override
  State<CropOptions> createState() => _CropOptionsState();
}

class _CropOptionsState extends State<CropOptions> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [],
    );
  }
}

class CropSettings with ChangeNotifier {
  double ratio = 1;
  double rotation = 0;
  bool flipX = false;
  bool flipY = false;
}
