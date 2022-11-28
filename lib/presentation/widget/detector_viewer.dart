import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../logic/detector/recognition.dart';

class DetectorViewer extends StatefulWidget {
  const DetectorViewer({Key? key, required this.imagePath, required this.recognitions}) : super(key: key);

  final String imagePath;
  final List<Recognition>? recognitions;

  @override
  State<DetectorViewer> createState() => _DetectorViewerState();
}

class _DetectorViewerState extends State<DetectorViewer> {

  @override
  Widget build(BuildContext context) {

    List<Widget> results = [];
    results.add(widget.imagePath == '' ? Image.network("https://i.imgur.com/sUFH1Aq.png") : Image.file(File(widget.imagePath)));

    if (widget.recognitions != null) {
      for (int i = 0; i < widget.recognitions!.length; ++i) {
        results.add(Positioned(
            left: widget.recognitions![i].getRenderLocation(480, 480, 450).left,
            top: widget.recognitions![i].getRenderLocation(480, 480, 450).top,
            child: Container(
              width: widget.recognitions![i].getRenderLocation(480, 480, 450).width,
              height: widget.recognitions![i].getRenderLocation(480, 480, 450).height,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 5.0,
                    color: Colors.red,
                  )),
            )));
      }
    }

    return Stack(
      children: results,
    );
  }
}
