import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/order_details_row.dart';
import 'package:idehshop/datetime_picker/datetime_dialog.dart';
import 'package:idehshop/models/my_location.dart';
import 'package:idehshop/models/order.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/routes/home_page/home_page.dart';
import 'package:idehshop/utils.dart';
import 'package:persian_datepicker/persian_datepicker.dart';
import 'package:persian_datepicker/persian_datetime.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderingPageDetails extends StatefulWidget {
  final Order order;
  final Key key;
  final Role role;

  OrderingPageDetails({this.order, this.key, this.role});

  @override
  _OrderingPageDetailsState createState() => _OrderingPageDetailsState();
}

class _OrderingPageDetailsState extends State<OrderingPageDetails> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  AuthenticationBloc _authenticationBloc;
  PersianDatePickerWidget _persianDatePicker;
  TextEditingController _textEditingController = TextEditingController();
  DateTime finalDateTime = DateTime.now();
  int finalTimestamp;
  String finalJalaliDate = '';
  StoreBloc _storeBloc;
  Order _orderDetails;
  bool _loading = true;
  bool _acceptLoading = false;
  bool _declineLoading = false;
  bool _payLoading = false;
  List<Widget> _rows = List();
  MyLocation _myLocation;
  Store _store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _persianDatePicker = PersianDatePicker(
        controller: _textEditingController,
        currentDayBackgroundColor: Theme.of(context).accentColor,
        currentDayBorderColor: Theme.of(context).accentColor,
        currentDayTextStyle: Theme.of(context).textTheme.bodyText2.copyWith(
              color: Colors.white,
            ),
        datetime: '$finalJalaliDate',
        daysBackgroundColor: Colors.white,
        fontFamily: 'Shabnam-Light-FD',
        headerBackgroundColor: Theme.of(context).accentColor,
        headerTextStyle: Theme.of(context).textTheme.bodyText2.copyWith(
              color: Colors.white,
            ),
        headerTodayBackgroundColor: Colors.white,
        headerTodayCaption: '',
        headerTodayIcon: Icon(
          Icons.calendar_today,
          color: Theme.of(context).accentColor,
        ),
        monthSelectionBackgroundColor: Colors.white,
        monthSelectionHighlightBackgroundColor: Theme.of(context).accentColor,
        monthSelectionHighlightTextStyle:
            Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.white,
                ),
        onChange: (String oldKickoffDate, String newKickoffDate) {
          DateTime _dateTime =
              PersianDateTime(jalaaliDateTime: newKickoffDate).datetime;
          setState(() {
            finalJalaliDate = '$newKickoffDate';
            finalDateTime = _dateTime;

            Navigator.of(context).pop();
          });
          showDateTimeDialog(context,
              initialDate: _dateTime,
              title: 'انتخاب ساعت', onSelectedDate: (selectedDate) {
            setState(() {
              finalDateTime = selectedDate;
              finalTimestamp = selectedDate.millisecondsSinceEpoch ~/ 1000;
            });
          });
        },
        selectedDayBackgroundColor: Theme.of(context).accentColor,
        selectedDayBorderColor: Theme.of(context).accentColor,
        selectedDayTextStyle: Theme.of(context).textTheme.bodyText2.copyWith(
              color: Colors.white,
            ),
        weekCaptionsBackgroundColor: Theme.of(context).accentColor,
        yearSelectionBackgroundColor: Colors.white,
        yearSelectionHighlightBackgroundColor: Theme.of(context).accentColor,
        yearSelectionHighlightTextStyle:
            Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.white,
                ),
      ).init();
      _getOrderDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        body: !_loading
            ? SingleChildScrollView(
                child: Card(
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          children: _rows,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 0.0),
                      ),
                      (widget.role == Role.provider && finalTimestamp != null)
                          ? Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.watch_later,
                                    size: 20,
                                    color: Colors.green[700],
                                  ),
                                  padding: EdgeInsets.all(0),
                                  onPressed: _selectDateTime,
                                ),
                                Expanded(
                                  child: Text(
                                    'تاریخ و ساعت ارسال :',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.green[700]),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _getFinalTime(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Colors.green[700]),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15.0,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  elevation: 1.0,
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
        key: _scaffoldKey,
      ),
      onWillPop: _onWillPop,
    );
  }

  _getOrderDetails() async {
    String _url;
    if (widget.role == Role.provider) {
      _url = "$BASE_URI/shopper/order/info/${widget.order.id}";
    } else if (widget.role == Role.customer) {
      _url = "$BASE_URI/customer/invoice/info/${widget.order.id}";
    }
    final _res = await http.get(
      _url,
      headers: {
        'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
      },
    );
    if (_res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(_res.body));
      _orderDetails = Order.fromJson(wrapper.data);
      await _getLocationDetails(_orderDetails.locationId).then(
        (value) => _getShopDetails(_orderDetails.shopId).then(
          (value) => _setRowsList(),
        ),
      );
    }
  }

  _setRowsList() {
    _rows.addAll([
      Row(
        children: <Widget>[
          Container(
            child: Text(
              'خرید',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(10.0),
                bottomRight: const Radius.circular(10.0),
              ),
              color: Theme.of(context).primaryColorLight,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      SizedBox(
        height: 15.0,
      ), ////
      OrderDetailsRow(
        title: 'اطلاعات خرید',
        value: '',
        titleSize: 16.0,
        titleBold: true,
      ),
      Divider(
        thickness: 1,
      ),
      OrderDetailsRow(
        title: 'مبلغ نهایی خرید',
        value:
            '${getFormattedPrice(int.parse('${_orderDetails.totalPrice}'))}تومان ',
      ),
      SizedBox(
        height: 5.0,
      ),
      OrderDetailsRow(
        title: 'مبلغ ارسال',
        value: _orderDetails.transportPrice == 0
            ? 'رایگان'
            : '${getFormattedPrice(int.parse('${_orderDetails.transportPrice}'))}تومان ',
      ),
      SizedBox(
        height: 5.0,
      ),
      '${_orderDetails.offPrice}' != '0'
          ? OrderDetailsRow(
              title: 'مبلغ کسر شده با تخفیف',
              value:
                  '${getFormattedPrice(int.parse('${_orderDetails.offPrice ?? 0}'))}تومان ',
            )
          : Container(),
      '${_orderDetails.offPrice}' != '0'
          ? SizedBox(
              height: 5.0,
            )
          : Container(),
      OrderDetailsRow(
        title: 'نوع پرداخت',
        value: _orderDetails.payed ? 'پرداخت شده' : 'درب منزل',
      ),
      SizedBox(
        height: 15.0,
      ),
      ////
      OrderDetailsRow(
        title: 'اطلاعات خریدار',
        value: '',
        titleSize: 15.0,
        titleBold: true,
      ),
      Divider(
        thickness: 1,
      ),
      widget.role == Role.customer
          ? Container()
          : OrderDetailsRow(
              title: 'نام خریدار',
              value: '${_orderDetails.customerFirstName ?? '-'}',
            ),
      widget.role == Role.customer
          ? Container()
          : SizedBox(
              height: 5.0,
            ),
      widget.role == Role.customer
          ? Container()
          : OrderDetailsRow(
              title: 'فامیلی خریدار',
              value: '${_orderDetails.customerLastName ?? '-'}',
            ),
      widget.role == Role.customer
          ? Container()
          : SizedBox(
              height: 5.0,
            ),
      widget.role == Role.customer
          ? Container()
          : OrderDetailsRow(
              title: 'شماره خریدار',
              value: _orderDetails.customerNumbers != null
                  ? '${_orderDetails.customerNumbers[0] ?? '-'}'
                  : '-',
            ),
      widget.role == Role.customer
          ? Container()
          : SizedBox(
              height: 5.0,
            ),
      OrderDetailsRow(
        title: (_myLocation != null || _orderDetails.address != null)
            ? 'آدرس خریدار'
            : '',
        value: _myLocation != null
            ? ' ${_myLocation.address}'
            : _orderDetails.address != null
                ? ' ${_orderDetails.address}'
                : '',
      ),
      SizedBox(
        height: 15.0,
      ),

      ////
      _store != null
          ? OrderDetailsRow(
              title: 'اطلاعات فروشگاه',
              value: '',
              titleSize: 16.0,
              titleBold: true,
            )
          : Container(),

      _store != null
          ? Divider(
              thickness: 1,
            )
          : Container(),
      _store != null
          ? OrderDetailsRow(
              title: 'نام فروشگاه',
              value: '${_store.title}',
            )
          : Container(),
      SizedBox(
        height: 5.0,
      ),
      _store != null
          ? OrderDetailsRow(
              title: 'تلفن فروشگاه',
              value: '${_store.accessNumbers[0]}',
            )
          : Container(),
      SizedBox(
        height: 15.0,
      ),
      OrderDetailsRow(
        title: 'لیست خرید',
        value: '',
        titleSize: 16.0,
        titleBold: true,
      ),
      Divider(
        thickness: 1,
      ),
    ]);

    _orderDetails.products.forEach((element) {
      _rows.add(Column(
        children: [
          SizedBox(
            height: 5.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${element.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'تعداد درخواستی',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
              Expanded(
                child: Text(
                  '${element.measurementIndex} ${element.measurement}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'قیمت',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
              Expanded(
                child: Text(
                  '${getFormattedPrice(int.parse('${element.price}'))}تومان ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          (element.description != null && element.description != '')
              ? Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'توضیحات',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        element.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                )
              : Container(),
          (element.description != null && element.description != '')
              ? SizedBox(
                  height: 10.0,
                )
              : Container(),
        ],
      ));
    });

    if (widget.role == Role.provider) {
      _rows.add(Divider());
      _rows.add(
        Row(
          children: [
            RaisedButton(
              onPressed: () => _decline(context),
              child: _declineLoading
                  ? CircularProgressIndicator()
                  : Text(
                      'رد کردن',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
              color: Colors.red,
            ),
            SizedBox(
              width: 20,
            ),
            RaisedButton(
              onPressed: () => _accept(context),
              child: _acceptLoading
                  ? CircularProgressIndicator()
                  : Text(
                      'قبول کردن',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
              color: Colors.green,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      );
    }

    if (widget.role != Role.provider) {
      _rows.add(
        (('${_store.commission}' != '0' &&
                    _store.hasDefaultPaymentGateWay &&
                    !_orderDetails.payed) ||
                (_store.hasDefaultPaymentGateWay && !_orderDetails.payed))
            ? RaisedButton(
                onPressed: () =>
                    _payLoading ? CircularProgressIndicator() : _pay(context),
                child: Text(
                  'پرداخت اینترنتی',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.green,
              )
            : Container(),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  _pay(BuildContext context) async {
    setState(() {
      _payLoading = true;
    });

    final res = await http.get(
      '$BASE_URI/customer/pay/order/price/${_orderDetails.id}',
      headers: {
        'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
      },
    );
    ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
    if (wrapper.code == 200) {
      final url = '${wrapper.data['content']}';
//      print(url);
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    setState(() {
      _payLoading = false;
    });
  }

  _decline(BuildContext context) async {
    setState(() {
      _declineLoading = true;
    });

    final res = await http.get(
      '$BASE_URI/order/decline/${_orderDetails.id}',
      headers: {
        'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200 && mounted) {
      _storeBloc.add(SubmitDeclineOrderEvent());
      setState(() {
        _declineLoading = false;
      });

      final snackBar = SnackBar(
        content: Text(
          'این خرید با موفقیت رد شد.',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: Theme.of(context).textTheme.bodyText1.fontFamily,
          ),
        ),
        backgroundColor: Colors.red,
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  _accept(BuildContext context) async {
    setState(() {
      _acceptLoading = true;
    });

    if (finalTimestamp != null) {
      final res = await http.get(
        '$BASE_URI/order/accept/${_orderDetails.id}?arrivingTime=$finalTimestamp',
        headers: {
          'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
        },
      );
      if (res.statusCode == 200) {
        _storeBloc.add(SubmitAcceptOrderEvent());
        setState(() {
          _acceptLoading = false;
        });

        final snackBar = SnackBar(
          content: Text(
            'این خرید با موفقیت پذیرفته شد.',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.bodyText1.fontFamily,
            ),
          ),
          backgroundColor: Colors.green,
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    } else {
      _selectDateTime();
    }
  }

  _selectDateTime() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: _persianDatePicker,
        );
      },
    );
  }

  Future<void> _getLocationDetails(String locationId) async {
    if (locationId != null) {
      final res = await http.get(
        '$BASE_URI/customer/location/$locationId',
        headers: {
          'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
        },
      );

      if (res.statusCode == 200) {
        ResponseWrapper wrapper =
            ResponseWrapper.fromJson(jsonDecode(res.body));
        if (wrapper.code == 200) {
          _myLocation = MyLocation.fromJson(wrapper.data);
          setState(() {});
        }
      }
    }
  }

  Future<void> _getShopDetails(String shopId) async {
    if (widget.role != Role.provider) {
      final res = await http.get(
        '$BASE_URI/shop/info/$shopId',
        headers: {
          'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
        },
      );

      if (res.statusCode == 200) {
        ResponseWrapper wrapper =
            ResponseWrapper.fromJson(jsonDecode(res.body));
        if (wrapper.code == 200) {
          _store = Store.fromJson(wrapper.data);
          setState(() {});
        }
      }
    }
  }

  String _getFinalTime() {
    final DateTime _dateTime =
        DateTime.fromMillisecondsSinceEpoch(finalTimestamp);

    return '${_dateTime.hour}:${_dateTime.minute} - $finalJalaliDate';
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return HomePage(
        index: 3,
      );
    }));
    return false;
  }
}
