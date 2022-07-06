import 'package:flutter/material.dart';
import 'package:location/location.dart';

class PermissionService {
  final Location location;

  PermissionService({@required this.location});

  /// check service is enabled & isGranted
  Future<bool> checkService() async {
    bool _isEnabled = await serviceIsEnabled();
    bool _isGranted = await serviceIsGranted();
    if (_isEnabled && _isGranted) {
      return true;
    } else {
      return false;
    }
  }

  /// check service is enabled or not
  Future<bool> serviceIsEnabled() async {
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
      return true;
    } else {
      return true;
    }
  }

  /// check service is granted or not
  Future<bool> serviceIsGranted() async {
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      _permissionGranted = await location.requestPermission();
    }
    if (_permissionGranted == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}
