import 'dart:math';

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
  CropController cropController = CropController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: CropPlayer(
                    controller: widget.controller,
                    cropController: cropController,
                    editedInfo: widget.editedInfo,
                  )),
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
                cropController: cropController,
                editedInfo: widget.editedInfo,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CropPlayer extends StatefulWidget {
  const CropPlayer(
      {Key? key,
      required this.controller,
      required this.cropController,
      required this.editedInfo})
      : super(key: key);

  final VideoPlayerController controller;
  final EditedInfo editedInfo;
  final CropController cropController;

  @override
  State<CropPlayer> createState() => _CropPlayerState();
}

class _CropPlayerState extends State<CropPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController animController;

  @override
  void initState() {
    super.initState();

    animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    rotation = Tween<double>(begin: 0, end: 0).animate(animController);
    flipX = Tween<double>(begin: 0, end: 0).animate(animController);
    flipY = Tween<double>(begin: 0, end: 0).animate(animController);
    animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setRotate(rotation.value, rotation.value);
        setFlipX(flipX.value, flipX.value);
        setFlipY(flipY.value, flipY.value);
        animController.reset();
      }
    });

    widget.cropController.addListener(() {
      setRotate(rotation.value, pi / 2 * widget.cropController.turns);
      setFlipX(flipX.value, widget.cropController.flipX ? pi : 0);
      setFlipY(flipY.value, widget.cropController.flipY ? pi : 0);
      animController.forward();
    });
  }

  late Animation<double> rotation;
  late Animation<double> flipX;
  late Animation<double> flipY;
  void setRotate(double before, double after) {
    if (after == before && after == pi / 2 * 4) {
      rotation = Tween<double>(begin: 0, end: 0).animate(animController);
    } else if (before == pi / 2 * 3 && after == 0) {
      rotation =
          Tween<double>(begin: before, end: pi / 2 * 4).animate(animController);
    } else if (before == 0 && after == pi / 2 * 3) {
      rotation =
          Tween<double>(begin: pi / 2 * 4, end: after).animate(animController);
    } else {
      rotation =
          Tween<double>(begin: before, end: after).animate(animController);
    }
  }

  void setFlipX(double before, double after) {
    flipX = Tween<double>(begin: before, end: after).animate(animController);
  }

  void setFlipY(double before, double after) {
    flipY = Tween<double>(begin: before, end: after).animate(animController);
  }

  double scale = 1;
  Offset position = Offset.zero;
  void onScale(ScaleUpdateDetails details) {
    setState(() {
      if (details.scale < 2 && details.scale > 0.8) {
        scale = details.scale;
      }
      position += details.focalPointDelta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        return Transform(
            transform: Matrix4.rotationX(flipY.value)
              ..rotateY(flipX.value)
              ..rotateZ(rotation.value)
              ..scale(scale)
              ..setTranslationRaw(position.dx, position.dy, 0),
            alignment: Alignment.center,
            child: child);
      },
      child: (widget.controller.value.isInitialized)
          ? Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: widget.controller.value.aspectRatio,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: VideoPlayer(widget.controller),
                    ),
                  ),
                ),
                LayoutBuilder(builder: (context, constraints) {
                  return CropBox(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    padding: 10,
                    aspectRatio: widget.controller.value.aspectRatio,
                    cropController: widget.cropController,
                    editedInfo: widget.editedInfo,
                  );
                }),
                GestureDetector(
                  onScaleStart: onScaleStart,
                  onScaleUpdate: onScaleUpdate,
                  onScaleEnd: onScaleEnd,
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  bool isPan = false;
  bool isScale = false;

  void onScaleStart(ScaleStartDetails details) {
    if (details.pointerCount == 1) {
      isPan = true;
      isScale = false;
      widget.cropController.onResizeStart!(details.localFocalPoint);
    }

    if (details.pointerCount == 2) {
      isScale = true;
      isPan = false;
    }
    // debugPrint('$isPan $isScale ${details.pointerCount}');
  }

  void onScaleEnd(ScaleEndDetails details) {
    if (isPan) {
      widget.cropController.onResizeEnd!();
    }
    isScale = false;
    isPan = false;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (isPan) {
      widget.cropController.onResizeUpdate!(
          details.localFocalPoint, details.focalPointDelta);
    } else if (isScale) {
      // onScale(details);
    }
  }
}

class CropBox extends StatefulWidget {
  const CropBox(
      {Key? key,
      required this.height,
      required this.width,
      required this.padding,
      required this.cropController,
      required this.aspectRatio,
      required this.editedInfo})
      : super(key: key);
  final double height;
  final double width;
  final double padding;
  final double aspectRatio;
  final CropController cropController;
  final EditedInfo editedInfo;

  @override
  State<CropBox> createState() => _CropBoxState();
}

class _CropBoxState extends State<CropBox> {
  late double top;
  late double left;
  late double right;
  late double bottom;
  late final double minTop;
  late final double minLeft;
  late final double maxRight;
  late final double maxBottom;
  late final double videoHeight;
  late final double videoWidth;

  final double minDistance = 40;

  Widget corner = const Icon(
    Icons.circle,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();

    widget.cropController.onResizeStart = onStart;
    widget.cropController.onResizeUpdate = onUpdate;
    widget.cropController.onResizeEnd = onEnd;

    if (widget.aspectRatio > 1) {
      videoWidth = widget.width - 2 * widget.padding;
      videoHeight = (widget.width) / widget.aspectRatio - 2 * widget.padding;
      minTop = (widget.height - videoHeight) / 2;
      minLeft = widget.padding;
      maxRight = widget.width - widget.padding;
      maxBottom = minTop + videoHeight;
    } else {
      videoWidth = (widget.height) * widget.aspectRatio - 2 * widget.padding;
      videoHeight = widget.height - 2 * widget.padding;
      minTop = widget.padding;
      minLeft = (widget.width - videoWidth) / 2;
      maxRight = minLeft + videoWidth;
      maxBottom = widget.height - widget.padding;
    }

    top = minTop;
    left = minLeft;
    right = maxRight;
    bottom = maxBottom;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: top, color: Colors.black38),
              left: BorderSide(width: left, color: Colors.black38),
              right: BorderSide(
                  width: widget.width - right, color: Colors.black38),
              bottom: BorderSide(
                  width: widget.height - bottom, color: Colors.black38),
            ),
            color: Colors.transparent,
          ),
        ),
        Positioned(
          top: top,
          left: left,
          width: right - left,
          height: bottom - top,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
              color: Colors.white,
              width: 2,
            )),
          ),
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
      ],
    );
  }

  int select = 0;
  void onStart(Offset details) {
    bool isTop =
        (details.dy < top + minDistance) && (details.dy > top - minDistance);
    bool isBottom = (details.dy < bottom + minDistance) &&
        (details.dy > bottom - minDistance);
    bool isLeft =
        (details.dx < left + minDistance) && (details.dx > left - minDistance);
    bool isRight = (details.dx < right + minDistance) &&
        (details.dx > right - minDistance);

    // debugPrint("l:$isLeft r:$isRight t:$isTop b:$isBottom");
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
      if ((details.dy < bottom) && (details.dy > top)) {
        select = 5;
      }
    } else if (isRight) {
      // right only
      if ((details.dy < bottom) && (details.dy > top)) {
        select = 6;
      }
    } else if (isTop) {
      // top only
      if ((details.dx < right) && (details.dx > left)) {
        select = 7;
      }
    } else if (isBottom) {
      // bottom only
      if ((details.dx < right) && (details.dx > left)) {
        select = 8;
      }
    }
  }

  double minHeight = 50;
  double minWidth = 50;

  void onUpdate(Offset details, Offset delta) {
    void setTop(double y) {
      if ((bottom - y) < minHeight) {
        top = bottom - minHeight;
      } else {
        if (y >= minTop) {
          top = y;
        } else {
          top = minTop;
        }
      }
    }

    void setLeft(double x) {
      if ((right - x) < minWidth) {
        left = right - minWidth;
      } else {
        if (x >= minLeft) {
          left = x;
        } else {
          left = minLeft;
        }
      }
    }

    void setBottom(double y) {
      if ((y - top) < minHeight) {
        bottom = top + minHeight;
      } else {
        if (y <= maxBottom) {
          bottom = y;
        } else {
          bottom = maxBottom;
        }
      }
    }

    void setRight(double x) {
      if ((x - left) < minWidth) {
        right = left + minWidth;
      } else {
        if (x <= maxRight) {
          right = x;
        } else {
          right = maxRight;
        }
      }
    }

    void move(Offset offset) {
      double _top = top + offset.dy;
      double _left = left + offset.dx;
      double _right = right + offset.dx;
      double _bottom = bottom + offset.dy;
      if (_top < minTop) {
        top = minTop;
        bottom += top - _top + offset.dy;
      } else if (_bottom > maxBottom) {
        bottom = maxBottom;
        top += bottom - _bottom + offset.dy;
      } else {
        top = _top;
        bottom = _bottom;
      }
      if (_left < minLeft) {
        left = minLeft;
        right += left - _left + offset.dx;
      } else if (_right > maxRight) {
        right = maxRight;
        left += right - _right + offset.dx;
      } else {
        left = _left;
        right = _right;
      }
    }

    switch (select) {
      case 1:
        setState(() {
          setTop(details.dy);
          setLeft(details.dx);
        });
        break;
      case 2:
        setState(() {
          setBottom(details.dy);
          setLeft(details.dx);
        });
        break;
      case 3:
        setState(() {
          setTop(details.dy);
          setRight(details.dx);
        });
        break;
      case 4:
        setState(() {
          setBottom(details.dy);
          setRight(details.dx);
        });
        break;
      case 5:
        setState(() {
          setLeft(details.dx);
        });
        break;
      case 6:
        setState(() {
          setRight(details.dx);
        });
        break;
      case 7:
        setState(() {
          setTop(details.dy);
        });
        break;
      case 8:
        setState(() {
          setBottom(details.dy);
        });
        break;
      default:
        setState(() {
          move(delta);
        });
        break;
    }
  }

  void onEnd() {
    select = 0;
    widget.editedInfo.cropTop = (top - minTop) / videoHeight;
    widget.editedInfo.cropLeft = (left - minLeft) / videoWidth;
    widget.editedInfo.cropRight = (right - minLeft) / videoWidth;
    widget.editedInfo.cropBottom = (bottom - minTop) / videoHeight;
    debugPrint(
        't: ${widget.editedInfo.cropTop}, b: ${widget.editedInfo.cropBottom}, l: ${widget.editedInfo.cropLeft}, r: ${widget.editedInfo.cropRight}');
  }
}

class CropOptions extends StatefulWidget {
  const CropOptions(
      {Key? key, required this.cropController, required this.editedInfo})
      : super(key: key);
  final CropController cropController;
  final EditedInfo editedInfo;
  @override
  State<CropOptions> createState() => _CropOptionsState();
}

class _CropOptionsState extends State<CropOptions> {
  ButtonStyle buttonStyle(bool selected) {
    return ElevatedButton.styleFrom(
        primary: selected ? Colors.blue[800] : Colors.grey[850],
        shape: const CircleBorder(),
        fixedSize: const Size.square(35),
        minimumSize: Size.zero,
        padding: EdgeInsets.zero);
  }

  List<String> ratios = ['Free', '1:1', '4:3', '16:9'];
  late String ratio = ratios[0];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.cropController.turns = widget.cropController.turns - 1;
                });
                widget.editedInfo.turns = widget.cropController.turns;
              },
              style: buttonStyle(widget.cropController.turns != 0),
              child: const Icon(
                Icons.rotate_left,
                size: 28,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.cropController.turns = widget.cropController.turns + 1;
                });
                widget.editedInfo.turns = widget.cropController.turns;
              },
              style: buttonStyle(widget.cropController.turns != 0),
              child: const Icon(
                Icons.rotate_right,
                size: 28,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.cropController.flipHorizontal();
                });
                widget.editedInfo.flipX = widget.cropController.flipX;
              },
              style: buttonStyle(widget.cropController.flipX),
              child: const Icon(Icons.flip),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.cropController.flipVertical();
                });
                widget.editedInfo.flipY = widget.cropController.flipY;
              },
              style: buttonStyle(widget.cropController.flipY),
              child: const RotatedBox(
                quarterTurns: 1,
                child: Icon(
                  Icons.flip,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(17)),
              height: 35,
              width: 60,
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  // Not Functional
                  value: ratio,
                  items: ratios.map((String item) {
                    return DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      ratio = newValue!;
                    });
                  },
                  alignment: AlignmentDirectional.center,
                  dropdownColor: Colors.grey[850],
                  iconSize: 0,
                  borderRadius: BorderRadius.circular(10),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                  itemHeight: 48,
                  isExpanded: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CropController with ChangeNotifier {
  int _turns = 0;
  bool flipX = false;
  bool flipY = false;
  // Not yet implemented
  double? _ratio;
  double _rotation = 0;

  void Function(Offset details)? onResizeStart;
  void Function(Offset details, Offset delta)? onResizeUpdate;
  void Function()? onResizeEnd;

  set ratio(double? r) {
    _ratio = r;
    notifyListeners();
  }

  double? get ratio {
    return _ratio;
  }

  set turns(int t) {
    _turns = t % 4;
    notifyListeners();
  }

  int get turns {
    return _turns;
  }

  set rotation(double r) {
    _rotation = r % 360;
    notifyListeners();
  }

  double get rotation {
    return _rotation;
  }

  void flipHorizontal() {
    flipX = !flipX;
    notifyListeners();
  }

  void flipVertical() {
    flipY = !flipY;
    notifyListeners();
  }
}
