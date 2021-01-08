import 'dart:convert';

import 'package:html/parser.dart' as html;
import 'package:http/http.dart';
import 'package:scrapy/scrapy.dart';

import '../model/flight.dart';
import '../model/flights.dart';

class AirportSpider extends Spider<Flight, Flights> {
  @override
  Stream<String> parse(Response response) async* {
    final document = html.parse(response.body);

    // Departures
    final departuresElements =
        document.querySelectorAll(".tab-departures .flight-info-tables");

    for (var node in departuresElements) {
      for (var element in node.querySelectorAll("h2.pt.bt-light")) {
        Flight _flight = Flight();
        var _dateString = element.text.trim();

        for (var tr in node.querySelectorAll(".mt tbody tr")) {
          _flight.type = "departure";
          var _timeString = "${tr.querySelectorAll("td")[0].text}".trim();
          _flight.datetimeStr = "$_dateString $_timeString";
          _flight.code = tr.querySelectorAll("td")[1].text.trim();
          _flight.operator = tr.querySelectorAll("td")[2].text.trim();
          _flight.destination = tr.querySelectorAll("td")[3].text.trim();
          _flight.status = tr.querySelectorAll("td")[4].text.trim();

          yield json.encode(_flight);
        }
      }
    }

    // Arrivals
    final arrivalsElements =
        document.querySelectorAll(".tab-arrivals .flight-info-tables");
    for (var node in arrivalsElements) {
      for (var element in node.querySelectorAll("h2.pt.bt-light")) {
        Flight _flight = Flight();
        var _dateString = element.text.trim();

        for (var tr in node.querySelectorAll(".mt tbody tr")) {
          _flight.type = "arrival";
          var _timeString = "${tr.querySelectorAll("td")[0].text}".trim();
          _flight.datetimeStr = "$_dateString $_timeString";
          _flight.code = tr.querySelectorAll("td")[1].text.trim();
          _flight.operator = tr.querySelectorAll("td")[2].text.trim();
          _flight.destination = tr.querySelectorAll("td")[3].text.trim();
          _flight.status = tr.querySelectorAll("td")[4].text.trim();

          yield json.encode(_flight);
        }
      }
    }
  }

  @override
  Stream<String> transform(Stream<String> stream) async* {
    await for (String parsed in stream) {
      final transformed = parsed;
      yield transformed;
    }
  }

  @override
  Stream<Flight> save(Stream<String> stream) async* {
    await for (String transformed in stream) {
      final flight = Flight.fromJson(transformed);
      yield flight;
    }
  }
}
