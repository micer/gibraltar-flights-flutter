import 'package:gibraltar_flights/model/flights.dart';
import 'package:http/http.dart';

import 'spider.dart';
import 'storage.dart';

class Scrapper {

  static final storage = FlightStorage();

  static Future<Flights> scrapeData() async {
    final spider = AirportSpider();
    spider.name = "myspider";
    final path = await storage.localPath;
    spider.path = "$path/data.json";
    spider.client = Client();
    spider.startUrls = [
      "https://www.gibraltarairport.gi/content/live-flight-info"
    ];

    final stopw = Stopwatch()..start();

    await spider.startRequests();
    await spider.saveResult();
    final elapsed = stopw.elapsed;

    print("the program took $elapsed");

    print(await storage.getFlights());
    return storage.getFlights();
  }
}
