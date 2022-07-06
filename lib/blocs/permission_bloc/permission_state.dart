import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';

abstract class PermissionState extends Equatable {
  @override
  List<Object> get props => [];
}

/// initial state
class PermissionUninitializedState extends PermissionState {}

/// when user accepted location permission
class PermissionAcceptedState extends PermissionState {}

/// when user rejected location permission
class PermissionRejectedState extends PermissionState {}

///got user location
class GotUserLocationState extends PermissionState {
  final dynamic lat;
  final dynamic lng;

  GotUserLocationState({@required this.lat, @required this.lng});
}

/// loading
class PermissionLoadingState extends PermissionState {}

/// added new location in server
class AddedNewLocationPermissionState extends PermissionState {}

/// selected an address
class SelectedAnAddressPermissionState extends PermissionState {
  final String addressId;

  SelectedAnAddressPermissionState({@required this.addressId});
}

/// jwt expired
class JwtExpiredPermissionState extends PermissionState {}
