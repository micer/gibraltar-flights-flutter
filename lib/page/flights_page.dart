import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gibraltar_flights/main.dart';
import 'package:gibraltar_flights/model/flight.dart';
import 'package:gibraltar_flights/model/flights.dart';
import 'package:gibraltar_flights/util/extensions.dart';
import 'package:gibraltar_flights/util/scrappy.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class FlightsPage extends StatefulWidget {
  const FlightsPage({Key key, @required this.title}) : super(key: key);
  final title;

  @override
  _FlightsPageState createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  Flights flights;
  RefreshController _refreshController =
  RefreshController(initialRefresh: true);
  double _refreshButtonOpacity = 1;
  BannerAd _bannerAd;

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: "ca-app-pub-3670766355752604/4950986030",
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    flights = Flights(items: []);
    FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
    _bannerAd = createBannerAd()..load()..show();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                ),
                onPressed: () =>
                    Alert(
                      context: context,
                      title: "Thanks for using this app!",
                      desc: "Made with ❤️ during 2020/21 pandemic times.",
                      image: Image.asset("assets/launcher/ic_launcher_foreground.png"),
                      buttons: [
                        DialogButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "CLOSE",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                      ]
                    ).show()
            )
          ],
        ),
        body: Center(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: _refreshController,
              onRefresh: () => _onRefresh(context),
              child: _listView(),
            )));
  }

  Widget _listView() {
    if (flights.items.isNotEmpty) {
      List<ListItem> _items = processData(flights.items);
      return ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: _buildListTile(item, context));
        },
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("There are no flights in the list."),
          Container(
            margin: EdgeInsetsDirectional.only(top: 16),
            child: Opacity(
              opacity: _refreshButtonOpacity,
              child: TextButton(
                  onPressed: () => _refreshController.requestRefresh(),
                  child: Text("refresh".toUpperCase()),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Theme
                        .of(context)
                        .accentColor,
                    onSurface: Colors.grey,
                  )),
            ),
          )
        ],
      );
    }
  }

  ListTile _buildListTile(ListItem item, BuildContext context) {
    if (item is AdItem) {
      return item.buildAd(context);
    } else {
      return ListTile(
        title: item.buildTitle(context),
        subtitle: item.buildSubtitle(context),
        leading: item.buildIcon(context),
        trailing: item.buildStatusData(context),
      );
    }
  }

  Future<void> _onRefresh(BuildContext context) async {
    setState(() {
      _refreshButtonOpacity = 0;
    });
    Future<Flights> _freshFutureFlights = Scrapper.scrapeData();
    _freshFutureFlights.catchError((e) {
      setState(() {
        _refreshButtonOpacity = 1;
      });
      _refreshController.refreshFailed();
      _showError(context, "Couldn't load data, please try again.");
    });
    Flights _freshFlights = await _freshFutureFlights;
    setState(() {
      flights = _freshFlights;
      if (flights.items.isEmpty) {
        _refreshButtonOpacity = 1;
      }
    });
    _refreshController.refreshCompleted();
  }

  List<ListItem> processData(List<Flight> flightList) {
    flightList.sort((a, b) => a.datetime.compareTo(b.datetime));
    List<ListItem> result = [];

    var dt;
    var addAd = false;
    flightList.forEach((flight) {
      final DateTime flightDT = flight.datetime;
      if (dt == null || !flightDT.isSameDate(dt)) {
        dt = flight.datetime;

        // TODO use this once inline AdMob is possible
        // if (addAd) {
        //   result.add(AdItem(_bannerAd));
        //   addAd = false;
        // }
        result.add(HeadingItem(
            "${_getWeekDayName(dt)} ${dt.day}/${dt.month}/${dt.year}"));
        addAd = true;
      }
      result.add(FlightItem(flight.code, flight.destination, flight.status,
          "${DateFormat("HH:mm").format(flight.datetime)}", flight.type));
    });
    return result;
  }

  String _getWeekDayName(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "";
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message), backgroundColor: Theme
        .of(context)
        .errorColor));
  }
}

abstract class ListItem {
  Widget buildTitle(BuildContext context);

  Widget buildSubtitle(BuildContext context);

  Widget buildIcon(BuildContext context);

  Widget buildStatusData(BuildContext context);

  Widget buildAd(BuildContext context);
}

class AdItem implements ListItem {
  BannerAd _bannerAd;

  AdItem(this._bannerAd);

  @override
  Widget buildAd(BuildContext context) {
    return ListTile(
      title: Container(
        // TODO implement inline Ad once available, see https://github.com/flutter/flutter/issues/12114#issuecomment-725731427
        child: SizedBox.shrink(),
        // child: RaisedButton(
        //     child: const Text('SHOW BANNER'),
        //     onPressed: () {
        //       _bannerAd ??= _FlightsPageState.createBannerAd();
        //       _bannerAd
        //         ..load()
        //         ..show();
        //     }),
      ),
    );
  }

  @override
  Widget buildIcon(BuildContext context) => null;

  @override
  Widget buildStatusData(BuildContext context) => null;

  @override
  Widget buildSubtitle(BuildContext context) => null;

  @override
  Widget buildTitle(BuildContext context) => null;
}

class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  Widget buildTitle(BuildContext context) {
    return Container(
      child: Text(
        heading,
        style: Theme
            .of(context)
            .textTheme
            .headline5,
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Theme
              .of(context)
              .primaryColorLight,
          border: Border.all(color: Theme
              .of(context)
              .accentColor),
          borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget buildSubtitle(BuildContext context) => null;

  @override
  Widget buildIcon(BuildContext context) => null;

  @override
  Widget buildStatusData(BuildContext context) => null;

  @override
  Widget buildAd(BuildContext context) => null;
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
            color: Theme
                .of(context)
                .accentColor,
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
          Text(time, style: Theme
              .of(context)
              .textTheme
              .headline5),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(4)),
            child: Text(status,
                style: Theme
                    .of(context)
                    .textTheme
                    .caption
                    .apply(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (RegExp("arrived|departed").hasMatch(status.toLowerCase())) {
      return Colors.green;
    }

    switch (status.toLowerCase()) {
      case "delayed":
        return Colors.orange;
      case "canceled":
        return ThemeData().errorColor;
      default:
        return ThemeData().accentColor;
    }
  }

  @override
  Widget buildAd(BuildContext context) => null;
}
