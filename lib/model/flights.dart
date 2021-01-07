import 'dart:convert';

import 'package:gibraltar_flights/model/flight.dart';
import 'package:scrapy/scrapy.dart';

class Flights extends Items {
  final List<Flight> items;

  Flights({this.items});

  factory Flights.fromJson(String str) => Flights.fromMap(json.decode(str));

  factory Flights.fromMap(Map<String, dynamic> json) => Flights(
        items: json["items"] == null
            ? null
            : List<Flight>.from(json["items"].map((x) => Flight.fromMap(x))),
      );

  @override
  String toString() {
    return 'Flights{items: $items}';
  }
}
