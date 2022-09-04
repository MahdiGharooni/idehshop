import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

class ConnectivityManager {
  static ConnectivityManager _instance;
  static final Connectivity connectivity = Connectivity();

  factory ConnectivityManager() {
    if (_instance == null) {
      _instance = ConnectivityManager._();
    }
    return _instance;
  }

  ConnectivityManager._();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<ConnectivityResult> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return result;
  }
}
