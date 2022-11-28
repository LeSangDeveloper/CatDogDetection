import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection_app/logic/cubit/image_loader_cubit.dart';
import 'package:object_detection_app/presentation/widget/detector_viewer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.black38, offset: Offset(1, 1))
                ]
              ),
              child: BlocBuilder<ImageLoaderCubit, ImageLoaderState>(
                builder: (context, state) {
                  return DetectorViewer(imagePath: state.imagePath, recognitions: state.recognitions);
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  BlocProvider.of<ImageLoaderCubit>(context).loadImage();
                  },
                child: const Icon(Icons.image))
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
