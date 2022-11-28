import 'dart:io';
import 'dart:math';

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

    // Define all colors you want here
    const predefinedColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.deepOrangeAccent
    ];

    Random random = Random();

    if (widget.recognitions != null) {
      for (int i = 0; i < widget.recognitions!.length; ++i) {
        Color color = predefinedColors[random.nextInt(predefinedColors.length)];
        results.add(Positioned(
            left: widget.recognitions![i].location.left,
            top: widget.recognitions![i].location.top,
            child: Container(
              width: widget.recognitions![i].location.width,
              height: widget.recognitions![i].location.height,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 5.0,
                    color: color,
                  )),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: FittedBox(
                    child: Container(
                      color: color,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(widget.recognitions![i].label),
                          Text(" ${widget.recognitions![i].confidence.toStringAsFixed(2)}"),
                        ],
                      ),
                    ),
                  )
              ),
            )));
      }
    }

    return Stack(
      children: results,
    );
  }
}
