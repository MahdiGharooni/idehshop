import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:idehshop/cards/shop_dialog_row.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/utils.dart';

class StoreInfoDialog extends StatefulWidget {
  final Store store;
  final CameraPosition initialPosition;
  final BitmapDescriptor icon;

  StoreInfoDialog({
    @required this.store,
    @required this.initialPosition,
    @required this.icon,
  });

  @override
  _StoreInfoDialogState createState() => _StoreInfoDialogState();
}

class _StoreInfoDialogState extends State<StoreInfoDialog> {
  final Completer<GoogleMapController> _controller = Completer();
  dynamic _googleMap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _googleMap = GoogleMap(
          initialCameraPosition: widget.initialPosition,
          mapType: MapType.normal,
          markers: {
            Marker(
              markerId: MarkerId('YOU'),
              visible: true,
              draggable: false,
              position: LatLng(widget.store.lat, widget.store.long),
              icon: widget.icon,
            ),
          },
          zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'اطلاعات فروشگاه',
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.bodyText2.copyWith(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold,
            ),
      ),
      content: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              ShopDialogRow(
                title: 'نام فروشگاه',
                value: widget.store.title,
              ),
              SizedBox(
                height: 10,
              ),
              widget.store.accessNumbers != null
                  ? ShopDialogRow(
                      title: 'شماره',
                      value: widget.store.accessNumbers[0],
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              widget.store.transportPriceNear != null
                  ? ShopDialogRow(
                      title: 'هزینه ارسال به محدوده نزدیک',
                      value: "${widget.store.transportPriceNear}" == '0'
                          ? 'رایگان'
                          : "${getFormattedPrice(int.parse('${widget.store.transportPriceNear ?? 0}')) ?? '0'} تومان ",
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              widget.store.transportPriceFar != null
                  ? ShopDialogRow(
                      title: 'هزینه ارسال به محدوده دور',
                      value: "${widget.store.transportPriceFar}" == '0'
                          ? 'رایگان'
                          : "${getFormattedPrice(int.parse('${widget.store.transportPriceFar ?? 0}')) ?? '0'} تومان ",
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              (widget.store.openAt != null &&
                      widget.store.closeAt != null &&
                      (widget.store.openAt is Map) &&
                      (widget.store.openAt as Map).isNotEmpty)
                  ? ShopDialogRow(
                      title: 'ساعت کاری',
                      value:
                          '${widget.store.openAt['hour'] ?? '-'}:${widget.store.openAt['min'] ?? '-'} تا ${widget.store.closeAt['hour'] ?? '-'}:${widget.store.closeAt['min'] ?? '-'}',
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              widget.store.address != ''
                  ? ShopDialogRow(
                      title: 'آدرس',
                      value: widget.store.address ?? '',
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              (widget.store.description != "" &&
                      widget.store.description != " ")
                  ? ShopDialogRow(
                      title: 'توضیحات',
                      value: widget.store.description ?? '',
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              Container(
                child: _googleMap != null ? _googleMap : Container(),
                width: MediaQuery.of(context).size.width - 50,
                height: 150,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 5),
        ),
      ),
      actions: [
        FlatButton(
          child: Text(
            'باشه',
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Theme.of(context).accentColor,
                ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      actionsPadding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
    );
  }
}
