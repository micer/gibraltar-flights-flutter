import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart';
import 'package:scrapy/scrapy.dart';

import '../model/flight.dart';
import '../model/flights.dart';

class AirportSpider extends Spider<Flight, Flights> {
  static const String DEPARTURE = "departure";
  static const String ARRIVAL = "arrival";

  @override
  Stream<String> parse(Response response) async* {
    final document = html.parse(response.body);

    // Departures
    for (var _flight in _parseFlightData(document, DEPARTURE)) {
      yield json.encode(_flight);
    }

    // Arrivals
    for (var _flight in _parseFlightData(document, ARRIVAL)) {
      yield json.encode(_flight);
    }
  }

  List<Flight> _parseFlightData(Document document, String flightType) {
    List<Flight> _flights = [];
    var tabSelector;
    if (flightType == DEPARTURE) {
      tabSelector = ".tab-departures";
    } else {
      tabSelector = ".tab-arrivals";
    }
    final departuresElements =
        document.querySelectorAll("$tabSelector .flight-info-tables");

    for (var node in departuresElements) {
      for (var element in node.querySelectorAll("h2.pt.bt-light")) {
        var _dateString = element.text.trim();

        for (var tr in node.querySelectorAll(".mt tbody tr")) {
          Flight _flight = Flight(type: flightType);
          var _timeString = "${tr.querySelectorAll("td")[0].text}".trim();
          _flight.datetimeStr = "$_dateString $_timeString";
          _flight.code = tr.querySelectorAll("td")[1].text.trim();
          _flight.operator = tr.querySelectorAll("td")[2].text.trim();

          // Destination can have 'via route', i.e.:
          // <td>London Gatwick<br><span class="via-route">via London Gatwick</span></td>
          _flight.destination = tr.querySelectorAll("td")[3].text.trim();
          var _viaRoute = tr.querySelectorAll("td .via-route");
          if (_viaRoute.isNotEmpty) {
            var _viaRouteStr = _viaRoute[0].text.trim();
            _flight.destination = _flight.destination
                .replaceAll(_viaRouteStr, " ($_viaRouteStr)");
          }

          _flight.status = tr.querySelectorAll("td")[4].text.trim();

          _flights.add(_flight);
        }
      }
    }
    return _flights;
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
