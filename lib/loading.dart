import 'package:flutter/material.dart';


class Loading extends StatelessWidget {
  const Loading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x00000050),
      child: const Center(child: CircularProgressIndicator())
    );
  }
}