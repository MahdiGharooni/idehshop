import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LocationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// user marker moved in createStorePage
class MarkerMovedLocationEvent extends LocationEvent {
  final double lat;
  final double lng;

  MarkerMovedLocationEvent({@required this.lat, @required this.lng});
}
