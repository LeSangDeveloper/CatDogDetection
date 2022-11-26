import 'package:object_detection_app/presentation/screen/home_screen.dart';
import 'package:flutter/material.dart';

class AppRoute {

  Route onGeneratorRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => const HomeScreen(title: 'Home Screen')
        );
      default:
        return MaterialPageRoute(
            builder: (_) => const HomeScreen(title: 'Home Screen')
        );
    }
  }

}