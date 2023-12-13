import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/my_location.dart';
import 'package:idehshop/utils.dart';

const marker_key = 'createNewStore';

class CreateStoreLocation extends StatefulWidget {
  @override
  _CreateStoreLocationState createState() => _CreateStoreLocationState();
}

class _CreateStoreLocationState extends State<CreateStoreLocation> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  PermissionBloc _permissionBloc;
  LocationBloc _locationBloc;
  CameraPosition _initialPosition;
  MapType _mapType = MapType.normal;
  double _currentLat;
  double _currentLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _permissionBloc = BlocProvider.of<PermissionBloc>(context);
      _locationBloc = BlocProvider.of<LocationBloc>(context);
      _getInitialPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, state) {
          return Container(
            child: _initialPosition != null
                ? Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: _initialPosition,
                        mapType: _mapType,
                        markers: Set<Marker>.of(_markers.values),
                        zoomControlsEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        onCameraMove: (cameraPosition) {
                          _addMarker(cameraPosition.target.latitude,
                              cameraPosition.target.longitude);
                          _currentLat = cameraPosition.target.latitude;
                          _currentLng = cameraPosition.target.longitude;
                        },
                      ),
                      Positioned(
                        child: RaisedButton(
                          onPressed: () {
                            _locationBloc.add(
                              MarkerMovedLocationEvent(
                                lat: _currentLat,
                                lng: _currentLng,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            'تایید و بازگشت',
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                        bottom: 10.0,
                        left: 10.0,
                      ),
                      Positioned(
                        child: Container(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              child: IconButton(
                                onPressed: () {
                                  _permissionBloc.locationService.location
                                      .getLocation()
                                      .then((value) async {
                                    _permissionBloc.myLocation = MyLocation(
                                      lng: value.longitude,
                                      lat: value.latitude,
                                    );
                                    final GoogleMapController controller =
                                        await _controller.future;

                                    controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(
                                            value.latitude,
                                            value.longitude,
                                          ),
                                          zoom: MAP_MORE_ZOOM,
                                        ),
                                      ),
                                    );

                                    _addMarker(value.latitude, value.longitude);

                                    setState(() {
                                      _currentLat = value.latitude;
                                      _currentLng = value.longitude;
                                    });
                                  });
                                },
                                icon: Icon(
                                  Icons.my_location,
                                  size: 30.0,
                                  color: _mapType == MapType.hybrid
                                      ? Colors.white
                                      : Theme.of(context).accentColor,
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                color: Colors.black12,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.only(
                            left: 15,
                            top: 15,
                          ),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back,
                                size: 30.0,
                                color: _mapType == MapType.hybrid
                                    ? Colors.white
                                    : Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.only(
                            right: 15,
                            top: 15,
                          ),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              child: IconButton(
                                onPressed: _toggleMapType,
                                icon: Icon(
                                  Icons.autorenew,
                                  size: 30.0,
                                  color: _mapType == MapType.hybrid
                                      ? Colors.white
                                      : Theme.of(context).accentColor,
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                color: Colors.black12,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.only(
                            right: 15,
                            bottom: 15,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          );
        },
        cubit: _permissionBloc,
      ),
    );
  }

  _getInitialPosition() async {
    do {
      _getLatLng();
      await Future.delayed(Duration(seconds: 5));
    } while (_initialPosition == null);
  }

  _getLatLng() async {
    _permissionBloc.locationService.location.getLocation().then((value) {
      _permissionBloc.myLocation =
          MyLocation(lng: value.longitude, lat: value.latitude);

      _initialPosition = CameraPosition(
        target: LatLng(
          value.latitude,
          value.longitude,
        ),
        zoom: MAP_NORMAL_ZOOM,
      );

      _addMarker(value.latitude, value.longitude);

      setState(() {
        _currentLat = value.latitude;
        _currentLng = value.longitude;
      });
    });
  }

  _addMarker(double latitude, double longitude) {
    _markers.clear();
    MarkerId _markerId = MarkerId(marker_key);
    _markers[_markerId] = Marker(
      markerId: _markerId,
      visible: true,
      draggable: false,
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
    setState(() {});
  }

  _toggleMapType() {
    if (_mapType == MapType.normal) {
      setState(() {
        _mapType = MapType.hybrid;
      });
    } else {
      setState(() {
        _mapType = MapType.normal;
      });
    }
  }
}
