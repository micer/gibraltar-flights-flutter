import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gibraltar_flights/main.dart';
import 'package:gibraltar_flights/model/flight.dart';
import 'package:gibraltar_flights/model/flights.dart';
import 'package:gibraltar_flights/util/extensions.dart';
import 'package:gibraltar_flights/util/scrappy.dart';

class FlightsPage extends StatefulWidget {
  const FlightsPage({Key key, @required this.title}) : super(key: key);
  final title;

  @override
  _FlightsPageState createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  Future<Flights> futureFlights;

  @override
  void initState() {
    super.initState();
    futureFlights = Scrapper.scrapeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: FutureBuilder(
                future: futureFlights,
                builder: (context, snapshot) {
                  return RefreshIndicator(
                    child: _listView(snapshot),
                    onRefresh: _pullRefresh,
                  );
                })));
  }

  Widget _listView(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      List<ListItem> _items = processData(snapshot.data.items);
      return ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: ListTile(
              title: item.buildTitle(context),
              subtitle: item.buildSubtitle(context),
              leading: item.buildIcon(context),
              trailing: item.buildStatusData(context),
            ),
          );
        },
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  Future<void> _pullRefresh() async {
    Future<Flights> freshFutureFlights = Scrapper.scrapeData();
    setState(() {
      futureFlights = Future.value(freshFutureFlights);
    });
  }

  List<ListItem> processData(List<Flight> flightList) {
    flightList.sort((a, b) => a.datetime.compareTo(b.datetime));
    List<ListItem> result = [];

    var dt;
    flightList.forEach((flight) {
      final DateTime flightDT = flight.datetime;
      if (dt == null || !flightDT.isSameDate(dt)) {
        dt = flight.datetime;
        result.add(HeadingItem("${dt.day}/${dt.month}/${dt.year}"));
      }
      result.add(FlightItem(flight.code, flight.destination, flight.status,
          "${flight.datetime.hour}:${flight.datetime.minute}", flight.type));
    });
    return result;
  }
}

abstract class ListItem {
  Widget buildTitle(BuildContext context);

  Widget buildSubtitle(BuildContext context);

  Widget buildIcon(BuildContext context);

  Widget buildStatusData(BuildContext context);
}

class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  Widget buildTitle(BuildContext context) {
    return Container(
      child: Text(
        heading,
        style: Theme.of(context).textTheme.headline5,
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          border: Border.all(color: Theme.of(context).accentColor),
          borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget buildSubtitle(BuildContext context) => null;

  @override
  Widget buildIcon(BuildContext context) => null;

  @override
  Widget buildStatusData(BuildContext context) => null;
}

class FlightItem implements ListItem {
  final String code;
  final String destination;
  final String status;
  final String time;
  final String type;

  FlightItem(this.code, this.destination, this.status, this.time, this.type);

  Widget buildTitle(BuildContext context) => Text(destination);

  Widget buildSubtitle(BuildContext context) => Text(code);

  @override
  Widget buildIcon(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: SvgPicture.asset(
            type == "arrival" ? IconNames.arrivals : IconNames.departures,
            color: Theme.of(context).accentColor,
            matchTextDirection: true,
          )),
    );
  }

  @override
  Widget buildStatusData(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(time, style: Theme.of(context).textTheme.headline5),
          Text(status, style: Theme.of(context).textTheme.caption)
        ],
      ),
    );
  }
}
