import 'dart:convert';

Visitor visitorFromJson(String str) => Visitor.fromJson(json.decode(str));

String visitorToJson(Visitor data) => json.encode(data.toJson());

class Visitor {
  String visitorId;
  String password;

  Visitor({
    required this.visitorId,
    required this.password,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) => Visitor(
        visitorId: json["visitor_id"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "visitor_id": visitorId,
        "password": password,
      };
}
