import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/my_location.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/utils.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final PermissionService locationService;
  String authCode;
  MyLocation myLocation;
  List<MyLocation> addressesList = List(); // list of all addresses
  MyLocation selectedAddress;
  ResponseWrapper responseWrapper;

  PermissionBloc({@required this.locationService}) : super(null);

  PermissionState get initialState => PermissionUninitializedState();

  @override
  Stream<PermissionState> mapEventToState(PermissionEvent event) async* {
    /// accept permission
    if (event is AcceptPermissionEvent) {
      yield PermissionAcceptedState();
    }

    /// add new location in server
    if (event is AddLocationPermissionEvent) {
      yield PermissionLoadingState();
      var result = _addLocation(
        event.lat,
        event.lng,
        event.address,
        event.postalCode,
        event.stateId,
        event.cityId,
      );
      if (result != null && result == ERROR.jwtExpired) {
        yield JwtExpiredPermissionState();
      }
      yield AddedNewLocationPermissionState();
    }

    /// selecting an address
    if (event is SelectAnAddressPermissionEvent) {
      yield PermissionLoadingState();
      var result = await _getLocationInfo(event.selectedAddressId);
      if (result != null && result == ERROR.jwtExpired) {
        yield JwtExpiredPermissionState();
      }
//      await setDataInSharedPreferences(
//          PREF_SELECTED_ADDRESS_ID, event.selectedAddressId);
      yield SelectedAnAddressPermissionState(
          addressId: event.selectedAddressId);
    }
  }

  dynamic _addLocation(dynamic lat, dynamic lng, String address,
      [String postalCode = '', String stateId, String _cityId]) async {
    Map<String, dynamic> postBody = new Map<String, dynamic>();
    postBody['location'] = {
      'long': lng,
      'lat': lat,
      'address': address,
    };
    postBody['postalCode'] = postalCode;
    postBody['stateId'] = stateId;
    postBody['cityId'] = _cityId;

    final response = await http.post(
      "$BASE_URI/customer/location",
      body: jsonEncode(postBody),
      headers: {
        'Authorization': "Bearer $authCode",
      },
    );

    if (response.statusCode == 200) {
      responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
      this.addressesList.add(
            MyLocation(
              id: responseWrapper.data['id'],
              lat: lat,
              lng: lng,
              address: address,
              postalCode: postalCode,
            ),
          );
    } else if (response.statusCode == 401 || response.statusCode == 531) {
      return ERROR.jwtExpired;
    }
  }

  dynamic _getLocationInfo(String _addressId) async {
    final res = await http.get(
      '$BASE_URI/customer/location/$_addressId',
      headers: {
        'Authorization': "Bearer $authCode",
      },
    );
    if (res.statusCode == 200) {
      responseWrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      if (responseWrapper.code == 200) {
        selectedAddress = MyLocation(
          id: responseWrapper.data['id'],
          lng: responseWrapper.data['long'],
          lat: responseWrapper.data['lat'],
          address: responseWrapper.data['address'],
          postalCode: responseWrapper.data['postalCode'],
        );
      }
    } else if (res.statusCode == 401 || res.statusCode == 531) {
      return ERROR.jwtExpired;
    }
  }
}
