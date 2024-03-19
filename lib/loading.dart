import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final double? w;
  const Loading({super.key, this.w});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: w,
        color: const Color(0x00000050),
        child: const Center(child: CircularProgressIndicator()));
  }
}
