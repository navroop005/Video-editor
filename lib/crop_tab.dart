import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_editor/crop_box.dart';
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
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: CropPlayer(
                    controller: widget.controller,
                    cropController: cropController,
                    editedInfo: widget.editedInfo,
                  )),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 220,
          child: Column(
            children: [
              VideoPlayerControlls(
                controller: widget.controller,
                framerate: widget.editedInfo.frameRate,
              ),
              CropOptions(
                cropController: cropController,
                editedInfo: widget.editedInfo,
                aspectRatio: widget.controller.value.aspectRatio,
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

    widget.cropController.addListener(() {
      setRotate(rotation.value, pi / 2 * widget.cropController.turns);
      setFlipX(flipX.value, widget.cropController.flipX ? pi : 0);
      setFlipY(flipY.value, widget.cropController.flipY ? pi : 0);
      animController.forward(from: 0);
    });
  }

  late Animation<double> rotation;
  late Animation<double> flipX;
  late Animation<double> flipY;
  void setRotate(double before, double after) {
    if (before == pi / 2 * 3 && after == 0) {
      rotation =
          Tween<double>(begin: -pi / 2, end: after).animate(animController);
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
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: AspectRatio(
                      aspectRatio: widget.controller.value.aspectRatio,
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
      widget.cropController.onResizeStart(details.localFocalPoint);
    }

    if (details.pointerCount == 2) {
      isScale = true;
      isPan = false;
    }
    // debugPrint('$isPan $isScale ${details.pointerCount}');
  }

  void onScaleEnd(ScaleEndDetails details) {
    if (isPan) {
      widget.cropController.onResizeEnd();
    }
    isScale = false;
    isPan = false;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (isPan) {
      widget.cropController
          .onResizeUpdate(details.localFocalPoint, details.focalPointDelta);
    } else if (isScale) {
      // onScale(details);
    }
  }
}

class CropOptions extends StatefulWidget {
  const CropOptions(
      {Key? key,
      required this.cropController,
      required this.editedInfo,
      required this.aspectRatio})
      : super(key: key);
  final CropController cropController;
  final EditedInfo editedInfo;
  final double aspectRatio;
  @override
  State<CropOptions> createState() => _CropOptionsState();
}

class _CropOptionsState extends State<CropOptions> {
  Map<String, double?> ratios = {
    'Free': null,
    '1:1': 1,
    '4:3': 4 / 3,
    '16:9': 16 / 9
  };
  late String ratio = ratios.keys.first;
  late bool isLandscape;

  @override
  void initState() {
    super.initState();
    if (widget.aspectRatio > 1) {
      isLandscape = true;
      ratios["Original"] = widget.aspectRatio;
    } else {
      isLandscape = false;
      ratios["Original"] = 1 / widget.aspectRatio;
    }
  }

  ButtonStyle buttonStyle(bool selected) {
    return ElevatedButton.styleFrom(
      backgroundColor:
          selected ? Theme.of(context).colorScheme.secondaryContainer : null,
      foregroundColor: Theme.of(context).colorScheme.secondary,
      shape: const CircleBorder(),
      fixedSize: const Size.square(35),
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      elevation: 0,
    );
  }

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
              style: buttonStyle(widget.cropController.turns == 3 ||
                  widget.cropController.turns == 2),
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
              style: buttonStyle(widget.cropController.turns == 1 ||
                  widget.cropController.turns == 2),
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
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(17),
              ),
              clipBehavior: Clip.antiAlias,
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: ratio,
                        items: ratios.keys.map((String item) {
                          return DropdownMenuItem(
                            alignment: AlignmentDirectional.center,
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            ratio = newValue!;
                          });
                          if (isLandscape) {
                            widget.cropController.ratio = ratios[ratio];
                          } else {
                            if (ratios[ratio] != null) {
                              widget.cropController.ratio =
                                  1 / (ratios[ratio] ?? 1);
                            } else {
                              widget.cropController.ratio = null;
                            }
                          }
                        },
                        alignment: AlignmentDirectional.center,
                        iconSize: 0,
                        borderRadius: BorderRadius.circular(10),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        itemHeight: 48,
                        isExpanded: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 35,
                    child: RawMaterialButton(
                      onPressed: () {
                        setState(() {
                          isLandscape = !isLandscape;
                          if (isLandscape) {
                            widget.cropController.ratio = ratios[ratio];
                          } else {
                            if (ratios[ratio] != null) {
                              widget.cropController.ratio =
                                  1 / (ratios[ratio] ?? 1);
                            } else {
                              widget.cropController.ratio = null;
                            }
                          }
                        });
                      },
                      child: Icon(
                        isLandscape ^
                                (widget.cropController.turns == 1 ||
                                    widget.cropController.turns == 3)
                            ? Icons.crop_landscape
                            : Icons.crop_portrait,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  )
                ],
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
  double? _ratio;
  // Not yet implemented
  double _rotation = 0;

  late final void Function(Offset details) onResizeStart;
  late final void Function(Offset details, Offset delta) onResizeUpdate;
  late final void Function() onResizeEnd;
  late final void Function(double? ratio) onRatioChange;

  set ratio(double? r) {
    _ratio = r;
    onRatioChange(_ratio);
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
