import 'package:flutter/material.dart';

import 'page/flights_page.dart';
import 'util/colors.dart';

void main() {
  runApp(MyApp());
}

class Palette {
  static const Color primary = Color(0xFF2F4D7D);
}

class IconNames {
  static const String arrivals = "assets/arrivals.svg";
  static const String departures = "assets/departures.svg";
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Gibraltar Flights';

    return MaterialApp(
      title: title,
      theme: ThemeData(
          primarySwatch: generateMaterialColor(Palette.primary),
          fontFamily: 'Georgia'),
      home: FlightsPage(title: title),
    );
  }
}
