import 'package:flutter/material.dart';

class User {
  @required
  String authCode;
  String username;
  String mobileNumber;
  String email;
  String password;
  String firstName;
  String lastName;
  String nationalCode;
  String imageAddress;
  String role;
  int wallet;

  List<dynamic> accessNumbers;

  User(
      {this.authCode,
      this.mobileNumber,
      this.username,
      this.email,
      this.password,
      this.firstName,
      this.lastName,
      this.nationalCode,
      this.imageAddress,
      this.wallet,
      this.accessNumbers});

  User.fromData(String _authCode, String _pass, Map<String, dynamic> _data,
      String _role) {
    this.authCode = _authCode;
    mobileNumber = _data['mobileNumber'];
    username = _data['username'];
    email = _data['email'] ?? '';
    password = _pass ?? '';
    firstName = _data['firstName'];
    lastName = _data['lastName'];
    nationalCode = _data['nationalCode'];
    imageAddress = _data['imageAddress'];
    accessNumbers = _data['accessNumbers'];
    role = _role;
  }

  User.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        mobileNumber = json['mobileNumber'],
        email = json['email'],
        password = json['password'],
        firstName = json['firstName'] ?? '',
        lastName = json['lastName'] ?? '',
        nationalCode = json['nationalCode'] ?? '',
        imageAddress = json['imageAddress'] ?? '',
        wallet = json['wallet'] ?? 0,
        accessNumbers = json['accessNumbers'];
}
