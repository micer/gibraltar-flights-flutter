import 'dart:io';

import 'package:gibraltar_flights/model/flights.dart';
import 'package:path_provider/path_provider.dart';

class FlightStorage {
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await localPath;
    return File('$path/data.json');
  }

  Future<Flights> getFlights() async {
    final file = await _localFile;
    final contents = await file.readAsString();
    return Flights.fromJson(contents);
  }
}
