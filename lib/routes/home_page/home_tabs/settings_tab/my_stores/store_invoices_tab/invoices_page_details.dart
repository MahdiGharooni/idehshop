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
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_invoices_tab/shop_rate.dart';
import 'package:idehshop/utils.dart';
import 'package:intl/intl.dart';
import 'package:persian_datepicker/persian_datepicker.dart';
import 'package:persian_datepicker/persian_datetime.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoicesPageDetails extends StatefulWidget {
  final Order order;
  final Key key;
  final Role role;

  InvoicesPageDetails({this.order, this.key, this.role});

  @override
  _InvoicesPageDetailsState createState() => _InvoicesPageDetailsState();
}

class _InvoicesPageDetailsState extends State<InvoicesPageDetails> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  AuthenticationBloc _authenticationBloc;
  StoreBloc _storeBloc;
  ShoppingBloc _shoppingBloc;
  PersianDatePickerWidget _persianDatePicker;
  TextEditingController _textEditingController = TextEditingController();
  DateTime finalDateTime = DateTime.now();
  int finalTimestamp;
  String finalJalaliDate = '';
  Order _orderDetails;
  bool _loading = true;
  bool _payLoading = false;

  bool _acceptLoading = false;
  bool _declineLoading = false;
  List<Widget> _rows = List();
  MyLocation _myLocation;
  Store _store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
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
              finalTimestamp = selectedDate.millisecondsSinceEpoch;
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
      _getOrderDetails(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: !_loading
          ? BlocConsumer<ShoppingBloc, ShoppingState>(
              listener: (context, state) {
                if (state is AddedShopRateShopState) {
                  setState(() {
                    _loading = true;
                  });
                  _getOrderDetails(context);
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
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
                                    child: Container(
                                      child: Text(
                                        'تاریخ و ساعت ارسال :',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            TextStyle(color: Colors.green[700]),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        _getFinalTime(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style:
                                            TextStyle(color: Colors.green[700]),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        15.0,
                      ),
                    ),
                    margin:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    elevation: 1.0,
                  ),
                );
              },
              cubit: _shoppingBloc,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      key: _scaffoldKey,
    );
  }

  _getOrderDetails(BuildContext context) async {
    String _url;
    if (widget.role == Role.provider) {
      _url = "$BASE_URI/shopper/order/info/${widget.order.id}";
    } else {
      _url = "$BASE_URI/customer/invoice/info/${widget.order.id}";
    }
    final res = await http.get(
      _url,
      headers: {
        'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      _orderDetails = Order.fromJson(wrapper.data);

      await _getLocationDetails(_orderDetails.locationId).then(
        (value) => _getShopDetails(_orderDetails.shopId).then(
          (value) => _setRowsList(context),
        ),
      );
    }
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

  _setRowsList(BuildContext context) {
    _rows.addAll([
      Row(
        children: <Widget>[
          Container(
            child: Text(
              'فاکتور خرید',
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
              color: Color.fromRGBO(0, 154, 226, 1.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      SizedBox(
        height: 5.0,
      ),
      (widget.role != Role.provider && widget.order.accepted)
          ? Column(
              children: [
                Divider(height: 0),
                InkWell(
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            (_orderDetails.score != null &&
                                    _orderDetails.score > 0)
                                ? 'امتیاز شما به این فروشگاه'
                                : 'شما هنوز امتیازی ثبت نکرده اید',
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      color: Theme.of(context).accentColor,
                                    ),
                          ),
                        ),
                        (_orderDetails.score != null && _orderDetails.score > 0)
                            ? Text(
                                '${_orderDetails.score}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      color: Theme.of(context).accentColor,
                                    ),
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                              ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                    color: Colors.grey[200],
                  ),
                  onTap: () {
                    if (_orderDetails.score == null ||
                        _orderDetails.score == 0) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return ShopRate(
                            order: _orderDetails,
                          );
                        }),
                      );
                    }
                  },
                ),
                Divider(height: 0),
              ],
            )
          : Container(),
      SizedBox(
        height: 15.0,
      ),
      OrderDetailsRow(
        title: 'اطلاعات خرید',
        value: '',
        titleSize: 16.0,
        titleBold: true,
      ),
      Divider(
        thickness: 1,
      ),
      Row(
        children: [
          Expanded(
            child: Text(
              'وضعیت خرید',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          _orderDetails.accepted
              ? Text(
                  'پذیرفته شده',
                  style: Theme.of(context).textTheme.caption.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                )
              : Text(
                  'رد شده',
                  style: Theme.of(context).textTheme.caption.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
        ],
      ),
      SizedBox(
        height: 5,
      ),
      OrderDetailsRow(
        title: 'مبلغ  نهایی خرید',
        value:
            '${getFormattedPrice(int.parse('${_orderDetails.totalPrice}'))}تومان ',
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
        title: 'مبلغ ارسال',
        value: _orderDetails.transportPrice == 0
            ? 'رایگان'
            : '${getFormattedPrice(int.parse('${_orderDetails.transportPrice ?? 0}'))}تومان ',
      ),
      _store != null
          ? SizedBox(
              height: 15.0,
            )
          : Container(),
      OrderDetailsRow(
        title: 'اطلاعات خریدار',
        value: '',
        titleSize: 16.0,
        titleBold: true,
      ),
      Divider(
        thickness: 1,
      ),
      widget.role != Role.provider
          ? Container()
          : OrderDetailsRow(
              title: 'نام خریدار',
              value: '${_orderDetails.customerFirstName ?? '-'}',
            ),
      widget.role != Role.provider
          ? Container()
          : SizedBox(
              height: 5.0,
            ),
      widget.role != Role.provider
          ? Container()
          : OrderDetailsRow(
              title: 'فامیلی خریدار',
              value: '${_orderDetails.customerLastName ?? '-'}',
            ),
      widget.role != Role.provider
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
      widget.role != Role.provider
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
              value: ' ${_store.title}',
            )
          : Container(),
      _store != null
          ? SizedBox(
              height: 5.0,
            )
          : Container(),
      _store != null
          ? OrderDetailsRow(
              title: 'تلفن فروشگاه',
              value: ' ${_store.accessNumbers[0]}',
            )
          : Container(),
      SizedBox(
        height: 5.0,
      ),
      OrderDetailsRow(
        title: 'نوع پرداخت',
        value: (_orderDetails.payed != null && _orderDetails.payed == true)
            ? 'اینترنتی پرداخت شده'
            : 'درب منزل',
      ),
      SizedBox(
        height: 5.0,
      ),
      _orderDetails.arrivingTime != null
          ? OrderDetailsRow(
              title: 'زمان ارسال',
              value: _getArrivingTime(),
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
                  'تعداد درخواست',
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
                  '${getFormattedPrice(int.parse('${element.price}'))}',
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
                  'توضیحات',
                  maxLines: 1,
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
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ));
    });

    if (widget.role == Role.provider) {
      _rows.add(
        Row(
          children: [
            _orderDetails.accepted
                ? Container()
                : RaisedButton(
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
            _orderDetails.accepted
                ? RaisedButton(
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
                  )
                : Container(),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      );
    }

    if (widget.role != Role.provider) {
      _rows.add(
        (('${_store.commission}' != '0' &&
                    _store.hasDefaultPaymentGateWay &&
                    !_orderDetails.payed &&
                    _orderDetails.accepted) ||
                (_store.hasDefaultPaymentGateWay &&
                    !_orderDetails.payed &&
                    _orderDetails.accepted))
            ? RaisedButton(
                onPressed: () => _pay(context),
                child: _payLoading
                    ? CircularProgressIndicator()
                    : Text(
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

  _decline(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'رد سفارش',
              textAlign: TextAlign.right,
            ),
            content: SingleChildScrollView(
              child: Text(
                'لطفا برای رد سفارش با پشتیبان ایده شاپ تماس حاصل فرمایید.',
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.right,
              ),
            ),
            actions: [
              FlatButton(
                child: Text(
                  'خیر',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Theme.of(context).accentColor,
                      ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text(
                  'تماس',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.red,
                      ),
                ),
                onPressed: () async {
                  final url = 'tel:02178125';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
            ],
            actionsPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
          );
        });
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
//            textDirection: TextDirection.rtl,
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

  String _getArrivingTime() {
    final int _timestamp = _orderDetails.arrivingTime;
    DateTime _datetime = DateTime.fromMillisecondsSinceEpoch(_timestamp * 1000);
    var format = DateFormat('HH:mm');
    Jalali _jalali = Jalali.fromDateTime(_datetime);
    String _dayName = getDateDayName(_jalali.weekDay);
    return ' $_dayName ${_jalali.year}/${_jalali.month}/${_jalali.day} - ${format.format(_datetime)}';
  }

  String _getFinalTime() {
    final DateTime _dateTime =
        DateTime.fromMillisecondsSinceEpoch(finalTimestamp);
    return '${_dateTime.hour}:${_dateTime.minute} - $finalJalaliDate';
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
}
