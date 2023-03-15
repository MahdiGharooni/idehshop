import 'dart:convert';
import 'dart:ui';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/error_description_row.dart';
import 'package:idehshop/cards/store_report_row.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/models/product_report_model.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/utils.dart';
import 'package:persian_datepicker/persian_datepicker.dart';
import 'package:persian_datepicker/persian_datetime.dart';
import 'package:shamsi_date/shamsi_date.dart';

class StoreReportingPage extends StatefulWidget {
  final Product product; // product report else store report from all products

  StoreReportingPage({this.product});

  @override
  _StoreReportingPageState createState() => _StoreReportingPageState();
}

class _StoreReportingPageState extends State<StoreReportingPage> {
  String _reportingMode;
  String _reportingModeEn;
  PersianDatePickerWidget _persianDatePicker;
  TextEditingController _textEditingController = TextEditingController();
  StoreBloc _storeBloc;
  DateTime startStoreDateTime;
  int _startTimeStamp;
  int _finishTimeStamp;
  charts.Series<dynamic, dynamic> _series;
  DateTime finishStoreDateTime;
  List<ProductReportModel> _chartModels = List();
  bool _startDaySelecting = false;
  bool _finishDaySelecting = false;
  bool _loading = false;
  bool _withoutChart = false;
  Map<String, dynamic> _reports = Map();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _persianDatePicker = PersianDatePicker(
        controller: _textEditingController,
        currentDayBackgroundColor: Theme.of(context).accentColor,
        currentDayBorderColor: Theme.of(context).accentColor,
        currentDayTextStyle: Theme.of(context).textTheme.bodyText2.copyWith(
              color: Colors.white,
            ),
        datetime: '',
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
            if (_startDaySelecting) {
              startStoreDateTime = _dateTime;
              _startTimeStamp = _dateTime.millisecondsSinceEpoch ~/ 1000;
            } else if (_finishDaySelecting) {
              finishStoreDateTime = _dateTime;
              _finishTimeStamp = _dateTime.millisecondsSinceEpoch ~/ 1000;
            }
            _startDaySelecting = false;
            _finishDaySelecting = false;
            Navigator.of(context).pop();
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
    });
  }

  // final customTickFormatter =
  // charts.BasicNumericTickFormatterSpec((num value) {
  //   _chartModels.forEach((element) {
  //     if (element.)
  //   });
  // });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product != null
              ? 'گزارش‌گیری محصول'
              : 'گزارش گیری‌ همه محصولات',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Card(
          child: Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      child: Text('نوع گزارش'),
                      width: 100,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: DropdownButton(
                        items: REPORTING_MODES_FA.map((String _mode) {
                          return DropdownMenuItem(
                            child: Container(
                              child: Text(_mode),
                              alignment: Alignment.centerRight,
                            ),
                            key: Key(_mode),
                            value: _mode,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _reportingMode = value;
                            REPORTING_MODES_FA
                                .asMap()
                                .forEach((index, element) {
                              if (element == value) {
                                _reportingModeEn = REPORTING_MODES_EN[index];
                              }
                            });
                          });
                        },
                        hint: Container(
                          child: Text(
                            'نوع گزارش',
                            textAlign: TextAlign.center,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                        ),
                        isExpanded: true,
                        value: _reportingMode,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      child: Text('از تاریخ'),
                      width: 100,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: OutlineButton(
                        onPressed: () {
                          setState(() {
                            _finishDaySelecting = false;
                            _startDaySelecting = true;
                          });
                          _setStartStoreDateTime();
                        },
                        child: Text(
                          startStoreDateTime != null
                              ? _getJalaliFromDateTime(startStoreDateTime)
                              : '-',
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Container(
                      child: Text('تا تاریخ'),
                      width: 100,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: OutlineButton(
                        onPressed: () {
                          setState(() {
                            _startDaySelecting = false;
                            _finishDaySelecting = true;
                          });
                          _setStartStoreDateTime();
                        },
                        child: Text(
                          finishStoreDateTime != null
                              ? _getJalaliFromDateTime(finishStoreDateTime)
                              : '-',
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: RaisedButton(
                    child: _loading
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )
                        : Text(
                            'محاسبه',
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      color: Colors.white,
                                    ),
                          ),
                    onPressed: _getReports,
                  ),
                  width: 100,
                ),
                SizedBox(
                  height: 20,
                ),
                _chartModels.isNotEmpty
                    ? widget.product != null
                        ? Container(
                            child: charts.BarChart(
                              ([_series as charts.Series<dynamic, String>]
                                  .toList()),
                              animate: true,
                              barRendererDecorator:
                                  charts.BarLabelDecorator<String>(),
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                          )
                        : Column(
                            children: [
                              StoreReportRow(
                                label: 'خالص فروش محصولات',
                                value: getFormattedPrice(
                                    (_chartModels[0].cost) -
                                        (_chartModels[0].transportPrice)),
                              ),
                              Divider(),
                              StoreReportRow(
                                label: 'هزینه‌های ارسال',
                                value: getFormattedPrice(
                                    _chartModels[0].transportPrice),
                              ),
                              Divider(),
                              StoreReportRow(
                                label: 'مجموع',
                                value: getFormattedPrice(_chartModels[0].cost),
                              ),
                            ],
                          )
                    : _withoutChart
                        ? Text('داده ای یافت نشد')
                        : Container(),
                SizedBox(
                  height: 20,
                ),
                widget.product != null
                    ? Container()
                    : ErrorDescriptionRow(
                        description:
                            'برای گزارش‌گیری از هر محصول بصورت جداگانه میتوانید از لیست دسته‌بندی‌ها، دسته موردنظر را انتخاب کرده و گزارش هر محصول را مشاهده کنید.',
                        isCaption: true,
                      ),
              ],
            ),
            padding: EdgeInsets.all(10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
          elevation: 1.0,
        ),
      ),
    );
  }

  _setStartStoreDateTime() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: _persianDatePicker,
        );
      },
    );
  }

  _getReports() async {
    if (!_loading) {
      setState(() {
        _loading = true;
        _chartModels.clear();
        _withoutChart = false;
      });
      if (widget.product != null) {
        final res = await http.get(
          '$BASE_URI/sold/product/report/${widget.product.id}?fromDate=$_startTimeStamp&toDate=$_finishTimeStamp&mode=$_reportingModeEn',
          headers: {
            'Authorization': "Bearer ${_storeBloc.user.authCode}",
          },
        );
        if (res.statusCode == 200) {
          ResponseWrapper wrapper =
              ResponseWrapper.fromJson(jsonDecode(res.body));
          if ((wrapper.data is Map) && (wrapper.data as Map).isNotEmpty) {
            _reports = (wrapper.data as Map);
            _reports.forEach((key, value) {
              _chartModels.add(ProductReportModel.fromMap(key, value));
            });
            _series = charts.Series<ProductReportModel, String>(
              id: 'Sales',
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (ProductReportModel sales, _) => sales.date,
              measureFn: (ProductReportModel sales, _) => sales.price,
              labelAccessorFn: (ProductReportModel sales, _) =>
                  '${sales.price} تومان ',
              outsideLabelStyleAccessorFn: (model, value) {
                return charts.TextStyleSpec(
                  color: charts.ColorUtil.fromDartColor(
                    Colors.black,
                  ),
                  fontSize: 13,
                );
              },
              insideLabelStyleAccessorFn: (model, value) {
                return charts.TextStyleSpec(
                  color: charts.ColorUtil.fromDartColor(
                    Colors.black,
                  ),
                  fontSize: 13,
                );
              },
              data: _chartModels,
            );
          } else {
            _withoutChart = true;
          }
        }
      } else {
        final res = await http.get(
          '$BASE_URI/financial/report/${_storeBloc.currentStore.id}?fromDate=$_startTimeStamp&toDate=$_finishTimeStamp&mode=$_reportingModeEn',
          headers: {
            'Authorization': "Bearer ${_storeBloc.user.authCode}",
          },
        );
        if (res.statusCode == 200) {
          ResponseWrapper wrapper =
              ResponseWrapper.fromJson(jsonDecode(res.body));
          if ((wrapper.data is Map) && (wrapper.data as Map).isNotEmpty) {
            _chartModels.add(
                ProductReportModel.fromMap('StoreReportKey', wrapper.data));
          } else {
            _withoutChart = true;
          }
        }
      }
      setState(() {
        _loading = false;
      });
    }
  }

  String _getJalaliFromDateTime(DateTime _dateTime) {
    final _jalali = Jalali.fromDateTime(_dateTime);
    String _dayName = getDateDayName(_jalali.weekDay);
    return " $_dayName ${_jalali.year}/${_jalali.month}/${_jalali.day}";
  }
}
