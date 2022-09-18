import 'package:flutter/material.dart';

class City {
  String id;
  String name;

  City({@required this.id, @required this.name});

  City.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
