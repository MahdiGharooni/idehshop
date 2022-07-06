import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object> get props => [];
}

/// when user accept location permission
class AcceptPermissionEvent extends PermissionEvent {}

/// add location
class AddLocationPermissionEvent extends PermissionEvent {
  final dynamic lat;
  final dynamic lng;
  final String address;
  final String postalCode;
  final String stateId;
  final String cityId;

  AddLocationPermissionEvent({
    @required this.lat,
    @required this.lng,
    @required this.address,
    @required this.postalCode,
    @required this.stateId,
    @required this.cityId,
  });
}

/// select an address
class SelectAnAddressPermissionEvent extends PermissionEvent {
  final String selectedAddressId;

  SelectAnAddressPermissionEvent({@required this.selectedAddressId});
}
