import 'dart:convert';

Animal animalFromJson(String str) => Animal.fromJson(json.decode(str));

String animalToJson(Animal data) => json.encode(data.toJson());

class Animal {
  final int id;
  final String type;
  final String breed;
  final String gender;
  final int age;
  final DateTime dateOfBirth;
  final String color;
  final String physicalCharacteristics;
  final dynamic qrCode;

  Animal({
    required this.id,
    required this.type,
    required this.breed,
    required this.gender,
    required this.age,
    required this.dateOfBirth,
    required this.color,
    required this.physicalCharacteristics,
    required this.qrCode,
  });

  factory Animal.fromJson(Map<String, dynamic> json) => Animal(
        id: json["id"],
        type: json["type"],
        breed: json["breed"],
        gender: json["gender"],
        age: json["age"],
        dateOfBirth: DateTime.parse(json["dateOfBirth"]),
        color: json["color"],
        physicalCharacteristics: json["physicalCharacteristics"],
        qrCode: json["qr_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "breed": breed,
        "gender": gender,
        "age": age,
        "dateOfBirth": dateOfBirth.toIso8601String(),
        "color": color,
        "physicalCharacteristics": physicalCharacteristics,
        "qr_code": qrCode,
      };
}
