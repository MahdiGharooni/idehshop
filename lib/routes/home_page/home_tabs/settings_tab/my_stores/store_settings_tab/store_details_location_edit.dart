import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/create_store_location.dart';
import 'package:idehshop/utils.dart';

class StoreDetailsLocationEdit extends StatefulWidget {
  @override
  _StoreDetailsLocationEditState createState() =>
      _StoreDetailsLocationEditState();
}

class _StoreDetailsLocationEditState extends State<StoreDetailsLocationEdit> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  StoreBloc _storeBloc;
  CameraPosition _initialPosition;
  bool _loading = true;
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeBloc = BlocProvider.of<StoreBloc>(context);

      _getStoreDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          return _loading
              ? Center(child: CircularProgressIndicator())
              : Container(
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
                                _storeBloc.add(SubmitEditLocationStoreEvent(
                                  lat: cameraPosition.target.latitude,
                                  lng: cameraPosition.target.longitude,
                                ));
                              },
                            ),
                            Positioned(
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: (state is LoadingStoreState)
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Text(
                                        'تایید و بازگشت',
                                        style:
                                            Theme.of(context).textTheme.button,
                                      ),
                              ),
                              bottom: 10.0,
                              left: 10.0,
                            ),
                            Positioned(
                              child: Container(
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
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
        cubit: _storeBloc,
      ),
    );
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

  _getStoreDetails() {
    Store _store = _storeBloc.currentStore;
    _initialPosition = CameraPosition(
      target: LatLng(
        double.parse('${_store.lat}'),
        double.parse('${_store.long}'),
      ),
      zoom: MAP_NORMAL_ZOOM,
    );

    _addMarker(
      double.parse('${_store.lat}'),
      double.parse('${_store.long}'),
    );

    setState(() {
      _loading = false;
    });
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
