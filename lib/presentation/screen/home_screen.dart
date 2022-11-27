import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection_app/logic/cubit/image_loader_cubit.dart';

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
                  return Stack(
                    children: [
                      state.imagePath == '' ? Image.network("https://i.imgur.com/sUFH1Aq.png") : Image.file(File(state.imagePath)),
                      state.recognitions != null ? Positioned(
                          left: state.recognitions![0].getRenderLocation(480, 480, 450).left,
                          top: state.recognitions![0].getRenderLocation(480, 480, 450).top,
                          child: Container(
                            width: state.recognitions![0].getRenderLocation(480, 480, 450).width,
                            height: state.recognitions![0].getRenderLocation(480, 480, 450).height,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 5.0,
                                  color: Colors.red,
                                )),
                          )) : Container()
                    ],
                  );
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
