import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection_app/logic/cubit/image_loader_cubit.dart';
import 'package:object_detection_app/presentation/router/app_route.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppRoute _router = AppRoute();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImageLoaderCubit>(
        create: (context) => ImageLoaderCubit(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          onGenerateRoute: _router.onGeneratorRoute,
        )
    );
  }
}