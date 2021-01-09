import 'dart:convert';

import 'package:jiffy/jiffy.dart';
import 'package:scrapy/scrapy.dart';

class Flight extends Item {
  String code;
  String datetimeStr;
  String destination;
  String operator;
  String status;
  String type;

  Flight({
    this.code,
    this.datetimeStr,
    this.destination,
    this.operator,
    this.status,
    this.type,
  });

  @override
  String toString() {
    return "Flight : { code : $code, datetime : $datetimeStr, destination : $destination, operator : $operator, status : $status, type : $type }";
  }

  @override
  Map<String, dynamic> toJson() => {
        "code": code == null ? null : code,
        "datetime": datetimeStr == null ? null : datetimeStr,
        "destination": destination == null ? null : destination,
        "operator": operator == null ? null : operator,
        "status": status == null ? null : status,
        "type": type == null ? null : type
      };

  DateTime get datetime {
    var jiffy = Jiffy(this.datetimeStr, "EEEE d' of 'MMMM yyyy kk:mm");
    jiffy.add(
        hours: 1); // this is an ugly adjustment of time zone, but whatever
    return jiffy.dateTime;
  }

  factory Flight.fromJson(String str) => Flight.fromMap(json.decode(str));

  factory Flight.fromMap(Map<String, dynamic> json) => Flight(
        code: json["code"] == null ? null : json["code"],
        datetimeStr: json["datetime"] == null ? null : json["datetime"],
        destination: json["destination"] == null ? null : json["destination"],
        operator: json["operator"] == null ? null : json["operator"],
        status: json["status"] == null ? null : json["status"],
        type: json["type"] == null ? null : json["type"],
      );
}
