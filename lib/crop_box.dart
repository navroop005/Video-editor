import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_editor/crop_tab.dart';
import 'package:video_editor/edited_info.dart';

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

class _CropBoxState extends State<CropBox> with SingleTickerProviderStateMixin {
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

  final double minDistance = 20;

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
    widget.cropController.onRatioChange = setRatio;

    if (widget.aspectRatio > 1) {
      videoWidth = widget.width - 2 * widget.padding;
      videoHeight = (videoWidth) / widget.aspectRatio;
      minTop = (widget.height - videoHeight) / 2;
      minLeft = widget.padding;
      maxRight = widget.width - widget.padding;
      maxBottom = minTop + videoHeight;
    } else {
      videoHeight = widget.height - 2 * widget.padding;
      videoWidth = (videoHeight) * widget.aspectRatio;
      minTop = widget.padding;
      minLeft = (widget.width - videoWidth) / 2;
      maxRight = minLeft + videoWidth;
      maxBottom = widget.height - widget.padding;
    }

    top = minTop;
    left = minLeft;
    right = maxRight;
    bottom = maxBottom;

    animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    )..addListener(() {
        setState(() {
          top = animTop.value;
          bottom = animBottom.value;
          left = animLeft.value;
          right = animRight.value;
        });
      });
  }

  late final AnimationController animController;
  late Animation<double> animTop;
  late Animation<double> animBottom;
  late Animation<double> animLeft;
  late Animation<double> animRight;

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

  void setRatio(double? ratio) {
    if (ratio == null) {
    } else {
      double centerH = (left + right) / 2;
      double centerV = (top + bottom) / 2;
      double widthIn = right - left;
      double heightIn = bottom - top;

      double widthOut = (widthIn + (heightIn * ratio)) / 2;
      double heightOut = (heightIn + (widthIn / ratio)) / 2;

      if (widthOut > (maxRight - minLeft)) {
        widthOut = maxRight - minLeft;
        heightOut = widthOut / ratio;
      }
      if (heightOut > (maxBottom - minTop)) {
        heightOut = maxBottom - minTop;
        widthOut = heightOut * ratio;
      }

      double topf = centerV - heightOut / 2;
      double bottomf = centerV + heightOut / 2;
      double leftf = centerH - widthOut / 2;
      double rightf = centerH + widthOut / 2;

      if (topf < minTop) {
        bottomf += minTop - topf;
        topf = minTop;
      } else if (bottomf > maxBottom) {
        topf -= bottomf - maxBottom;
        bottomf = maxBottom;
      }
      if (leftf < minLeft) {
        rightf += minLeft - leftf;
        leftf = minLeft;
      } else if (rightf > maxRight) {
        leftf -= rightf - maxRight;
        rightf = maxRight;
      }

      animTop = Tween(begin: top, end: topf).animate(animController);
      animLeft = Tween(begin: left, end: leftf).animate(animController);
      animBottom = Tween(begin: bottom, end: bottomf).animate(animController);
      animRight = Tween(begin: right, end: rightf).animate(animController);
      animController.forward(from: 0);
    }
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

    double? ratoi = widget.cropController.ratio;
    switch (select) {
      case 1:
        if (ratoi == null) {
          setState(() {
            setTop(details.dy);
            setLeft(details.dx);
          });
        } else {
          double distance = delta.distance * cos(atan(ratoi) - delta.direction);
          double t = distance * cos(atan(ratoi)) + top;
          double l = distance * sin(atan(ratoi)) + left;
          if (((t) >= minTop) &&
              ((bottom - t) > minHeight) &&
              ((right - l) > minWidth) &&
              (l >= minLeft)) {
            setState(() {
              top = t;
              left = l;
            });
          }
        }
        break;
      case 2:
        if (ratoi == null) {
          setState(() {
            setBottom(details.dy);
            setLeft(details.dx);
          });
        } else {
          double distance =
              delta.distance * cos(atan(-1 / ratoi) - delta.direction);
          double b = bottom - distance * cos(atan(ratoi));
          double l = distance * sin(atan(ratoi)) + left;
          if ((b <= maxBottom) &&
              ((b - top) > minHeight) &&
              ((right - l) > minWidth) &&
              (l >= minLeft)) {
            setState(() {
              bottom = b;
              left = l;
            });
          }
        }
        break;
      case 3:
        if (ratoi == null) {
          setState(() {
            setTop(details.dy);
            setRight(details.dx);
          });
        } else {
          double distance =
              delta.distance * cos(atan(-1 / ratoi) - delta.direction);
          double t = top - distance * cos(atan(ratoi));
          double r = distance * sin(atan(ratoi)) + right;
          if (((t) >= minTop) &&
              ((bottom - t) > minHeight) &&
              ((r - left) > minWidth) &&
              (r <= maxRight)) {
            setState(() {
              top = t;
              right = r;
            });
          }
        }
        break;
      case 4:
        if (ratoi == null) {
          setState(() {
            setBottom(details.dy);
            setRight(details.dx);
          });
        } else {
          double distance = delta.distance * cos(atan(ratoi) - delta.direction);
          double b = distance * cos(atan(ratoi)) + bottom;
          double r = distance * sin(atan(ratoi)) + right;
          if ((b <= maxBottom) &&
              ((b - top) > minHeight) &&
              ((r - left) > minWidth) &&
              (r <= maxRight)) {
            setState(() {
              bottom = b;
              right = r;
            });
          }
        }
        break;
      case 5:
        if (ratoi == null) {
          setState(() {
            setLeft(details.dx);
          });
        } else {
          double l = left + delta.dx;
          double t = top + (delta.dx / ratoi) / 2;
          double b = bottom - (delta.dx / ratoi) / 2;
          if (((right - l) > minWidth) &&
              (l >= minLeft) &&
              ((b - t) >= minHeight)) {
            setState(() {
              if ((t >= minTop) && (b <= maxBottom)) {
                top = t;
                bottom = b;
                left = l;
              } else if (t < minTop && (b <= maxBottom)) {
                bottom -= delta.dx / ratoi;
                left = l;
              } else if (b > maxBottom && (t >= minTop)) {
                top += delta.dx / ratoi;
                left = l;
              }
            });
          }
        }
        break;
      case 6:
        if (ratoi == null) {
          setState(() {
            setRight(details.dx);
          });
        } else {
          double r = right + delta.dx;
          double t = top - (delta.dx / ratoi) / 2;
          double b = bottom + (delta.dx / ratoi) / 2;
          if (((r - left) > minWidth) &&
              (r <= maxRight) &&
              ((b - t) >= minHeight)) {
            setState(() {
              if ((t >= minTop) && (b <= maxBottom)) {
                top = t;
                bottom = b;
                right = r;
              } else if (t < minTop && (b <= maxBottom)) {
                bottom += delta.dx / ratoi;
                right = r;
              } else if (b > maxBottom && (t >= minTop)) {
                top -= delta.dx / ratoi;
                right = r;
              }
            });
          }
        }
        break;
      case 7:
        if (ratoi == null) {
          setState(() {
            setTop(details.dy);
          });
        } else {
          double t = top + delta.dy;
          double l = left + (delta.dy * ratoi) / 2;
          double r = right - (delta.dy * ratoi) / 2;
          if (((bottom - t) > minWidth) &&
              (t >= minTop) &&
              ((r - l) >= minHeight)) {
            setState(() {
              if ((l >= minLeft) && (r <= maxRight)) {
                left = l;
                right = r;
                top = t;
              } else if (l < minLeft && (r <= maxRight)) {
                right -= delta.dy * ratoi;
                top = t;
              } else if (r > maxRight && (l >= minLeft)) {
                left += delta.dy * ratoi;
                top = t;
              }
            });
          }
        }
        break;
      case 8:
        if (ratoi == null) {
          setState(() {
            setBottom(details.dy);
          });
        } else {
          double b = bottom + delta.dy;
          double l = left - (delta.dy * ratoi) / 2;
          double r = right + (delta.dy * ratoi) / 2;
          if (((b - top) > minHeight) &&
              (b <= maxBottom) &&
              ((r - l) >= minHeight)) {
            setState(() {
              if ((l >= minLeft) && (r <= maxRight)) {
                left = l;
                right = r;
                bottom = b;
              } else if (l < minLeft && (r <= maxRight)) {
                right += delta.dy * ratoi;
                bottom = b;
              } else if (r > maxRight && (l >= minLeft)) {
                left -= delta.dy * ratoi;
                bottom = b;
              }
            });
          }
        }
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
