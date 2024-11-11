// To parse this JSON data, do
//
//     final checkInCheckOut = checkInCheckOutFromJson(jsonString);

import 'dart:convert';

CheckInCheckOut checkInCheckOutFromJson(String str) =>
    CheckInCheckOut.fromJson(json.decode(str));

String checkInCheckOutToJson(CheckInCheckOut data) =>
    json.encode(data.toJson());

class CheckInCheckOut {
  String visitorId;
  String password;
  String action;

  CheckInCheckOut({
    required this.visitorId,
    required this.password,
    required this.action,
  });

  factory CheckInCheckOut.fromJson(Map<String, dynamic> json) =>
      CheckInCheckOut(
        visitorId: json["visitor_id"],
        password: json["password"],
        action: json["action"],
      );

  Map<String, dynamic> toJson() => {
        "visitor_id": visitorId,
        "password": password,
        "action": action,
      };
}
