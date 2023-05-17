import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/profile_edit_row.dart';
import 'package:idehshop/datetime_picker/datetime_dialog.dart';
import 'package:idehshop/models/city.dart';
import 'package:idehshop/models/my_state.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/shop_kind.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class StoreDetailsEditPage extends StatefulWidget {
  @override
  _StoreDetailsEditPageState createState() => _StoreDetailsEditPageState();
}

class _StoreDetailsEditPageState extends State<StoreDetailsEditPage> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  List<ShopKind> _shopKinds = List();
  List<MyState> _states = List();
  List<City> _cities = List();
  StoreBloc _storeBloc;
  Store _currentStore;
  TextEditingController _titleController;
  TextEditingController _descriptionController;
  TextEditingController _transportPriceNearController;
  TextEditingController _transportPriceFarController;
  TextEditingController _postalCodeController;
  TextEditingController _phoneController;
  TextEditingController _addressController;
  TextEditingController _limitDistanceController;
  TextEditingController _bankNumberController;
  TextEditingController _bankShabaController;
  bool _loading = false;
  bool _hasPreOrder = false;
  bool _hasDefaultGateWay = false;
  File _imageFile;
  String _stateId;
  String _cityId;
  String _shopKindValue;
  String _orderFromValue;
  bool _orderFromCity = false;

  bool _orderFromState = false;

  bool _orderFromCountry = false;
  DateTime startStoreDateTime = DateTime.parse('2012-02-27 00:00:00');

  DateTime closeStoreDateTime = DateTime.parse('2012-02-27 00:00:00');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _currentStore = _storeBloc.currentStore;
      if (_storeBloc.states.isNotEmpty) {
        _states = _storeBloc.states;
        _findShopStateValue();
      } else {
        _getStates();
      }
      _storeBloc.lat = null;
      _storeBloc.lng = null;
      _findShopKindValue();
      _titleController =
          TextEditingController(text: '${_currentStore.title ?? ' '}');
      _descriptionController = TextEditingController(
          text:
              '${_currentStore.description.length > 0 ? _currentStore.description : ' '}');
      _transportPriceNearController = TextEditingController(
          text: '${_currentStore.transportPriceNear ?? '0'}');
      _transportPriceFarController = TextEditingController(
          text: '${_currentStore.transportPriceFar ?? '0'}');
      _postalCodeController = TextEditingController(
          text:
              '${_currentStore.postalCode.length > 0 ? _currentStore.postalCode : ' '}');

      _addressController =
          TextEditingController(text: '${_currentStore.address ?? ' '}');
      _bankNumberController = TextEditingController(
          text: '${_currentStore.bankAccount.number ?? ''}');
      _bankShabaController = TextEditingController(
          text: '${_currentStore.bankAccount.shaba ?? ''}');
      _limitDistanceController = TextEditingController(
          text:
              '${(_currentStore.limitDistance * 3.14 * 6400 / 180 * 1000).floor() ?? '0'}');
      _phoneController = TextEditingController(
          text:
              '${_currentStore.accessNumbers != null && _currentStore.accessNumbers.isNotEmpty ? _currentStore.accessNumbers[0] : ' '}');
      startStoreDateTime = DateTime.parse(
          '2012-02-27 ${getTimeInCorrectFormat('${_currentStore.openAt['hour']}')}:${getTimeInCorrectFormat('${_currentStore.openAt['min']}')}:00');
      closeStoreDateTime = DateTime.parse(
          '2012-02-27 ${getTimeInCorrectFormat('${_currentStore.closeAt['hour']}')}:${getTimeInCorrectFormat('${_currentStore.openAt['min']}')}:00');
      _hasPreOrder = _currentStore.hasPreOrder;
      _hasDefaultGateWay = _currentStore.hasDefaultPaymentGateWay;
      _orderFromValue = _currentStore.orderFromCountry
          ? SHOP_ORDER_FROM[3]
          : _currentStore.orderFromState
              ? SHOP_ORDER_FROM[2]
              : _currentStore.orderFromCity
                  ? SHOP_ORDER_FROM[1]
                  : SHOP_ORDER_FROM[0];
      if (_currentStore.orderFromCountry) {
        _orderFromCountry = true;
      } else if (_currentStore.orderFromState) {
        _orderFromState = true;
      } else if (_currentStore.orderFromCity) {
        _orderFromCity = true;
      }
      _cityId = _currentStore.cityId;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ویرایش فروشگاه',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<StoreBloc, StoreState>(
        listener: (context, state) {
          if (state is EditedStoreState) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return _storeBloc != null
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: Container(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_enhance,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () => _showAlertDialog(context),
                          ),
                        ),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _imageFile != null
                                ? FileImage(_imageFile)
                                : _currentStore.imageAddress != null &&
                                        _currentStore.imageAddress.length > 5
                                    ? NetworkImage(
                                        'http://${_currentStore.imageAddress}',
                                      )
                                    : AssetImage(
                                        'assets/images/default_basket.png',
                                      ),
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 5,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white,
                        ),
                        height: 100,
                        width: 100,
                        padding: EdgeInsets.all(5.0),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        child: RaisedButton(
                          child: Text(
                            'ویرایش موقعیت فروشگاه روی نقشه',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => Navigator.pushNamed(
                              context, '/storeLocationEdit'),
                        ),
                      ),
                      _storeBloc.lat != null
                          ? Center(
                              child: Text(
                                'موقعیت فروشگاه تغییر کرده است. لطفا جهت تایید نهایی روی دکمه ثبت تغییرات کلیک کنید. ',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                      color: Colors.green,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        child: Card(
                          child: Container(
                            child: Form(
                              child: Column(
                                children: <Widget>[
                                  ProfileEditRow(
                                    controller: _titleController,
                                    prefixText: 'نام:*',
                                    keyboardType: TextInputType.text,
                                    validator: (String value) {
                                      return value.isEmpty
                                          ? 'فیلد نام اجباری است'
                                          : null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  ProfileEditRow(
                                    controller: _phoneController,
                                    prefixText: 'شماره ثابت:*',
                                    keyboardType: TextInputType.number,
                                    validator: (String value) {
                                      return value.isEmpty
                                          ? 'فیلد شماره اجباری است'
                                          : null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  ProfileEditRow(
                                    controller: _limitDistanceController,
                                    prefixText: 'محدوده ی نزدیک (متر):*',
                                    keyboardType: TextInputType.number,
                                    validator: (String value) {
                                      return value.isEmpty
                                          ? 'فیلد محدوده اجباری است'
                                          : null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  ProfileEditRow(
                                    controller: _transportPriceNearController,
                                    prefixText:
                                        'هزینه ارسال به محدوده نزدیک(تومان)',
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  ProfileEditRow(
                                    controller: _transportPriceFarController,
                                    prefixText: 'هزینه ارسال به دور(تومان):',
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  ProfileEditRow(
                                    controller: _bankNumberController,
                                    prefixText: 'شماره حساب فروشنده',
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        child: TextFormField(
                                          autofocus: false,
                                          controller: _bankShabaController,
                                          decoration: InputDecoration(
                                            labelText: 'شماره شبا فروشنده',
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                ),
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          keyboardType: TextInputType.number,
                                          maxLines: 2,
                                          minLines: 1,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                          vertical: 5.0,
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                80,
                                      ),
                                      Text('IR'),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(
                                    children: [
                                      Align(
                                        child: Container(
                                          child: Text(
                                            'انتخاب استان',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption,
                                          ),
                                          padding: EdgeInsets.only(right: 10),
                                        ),
                                        alignment: Alignment.bottomRight,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: DropdownButton(
                                            items:
                                                _states.map((MyState _state) {
                                              return DropdownMenuItem(
                                                child: Container(
                                                  child: Text(
                                                    _state.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerRight,
                                                ),
                                                key: Key(_state.id),
                                                value: _state.id,
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _cities.clear();
                                                _cityId = null;
                                                _stateId = value;
                                              });
                                              _getCities();
                                            },
                                            hint: Container(
                                              child: Text(
                                                'انتخاب استان',
                                                textAlign: TextAlign.center,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                              ),
                                            ),
                                            isExpanded: true,
                                            value: _stateId,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(
                                    children: [
                                      Align(
                                        child: Container(
                                          child: Text(
                                            'انتخاب شهر',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption,
                                          ),
                                          padding: EdgeInsets.only(right: 10),
                                        ),
                                        alignment: Alignment.bottomRight,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: DropdownButton(
                                            items: _cities.map((City _city) {
                                              return DropdownMenuItem(
                                                child: Container(
                                                  child: Text(
                                                    _city.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerRight,
                                                ),
                                                key: Key(_city.id),
                                                value: _city.id,
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _cityId = value;
                                              });
                                            },
                                            hint: Container(
                                              child: Text(
                                                'انتخاب شهر',
                                                textAlign: TextAlign.center,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                              ),
                                            ),
                                            isExpanded: true,
                                            value: _cityId,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  ProfileEditRow(
                                    controller: _addressController,
                                    prefixText: 'آدرس:',
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 3,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  ProfileEditRow(
                                    controller: _postalCodeController,
                                    prefixText: 'کدپستی:',
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  ProfileEditRow(
                                    controller: _descriptionController,
                                    prefixText: 'توضیحات:',
                                    keyboardType: TextInputType.text,
                                    maxLines: 3,
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    children: [
                                      Align(
                                        child: Container(
                                          child: Text(
                                            'امکان ارسال به',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption,
                                          ),
                                          padding: EdgeInsets.only(right: 10),
                                        ),
                                        alignment: Alignment.bottomRight,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: DropdownButton(
                                            items: SHOP_ORDER_FROM
                                                .map((String _orderFrom) {
                                              return DropdownMenuItem(
                                                child: Container(
                                                  child: Text(
                                                    _orderFrom,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerRight,
                                                ),
                                                key: Key(_orderFrom),
                                                value: _orderFrom,
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value == SHOP_ORDER_FROM[1]) {
                                                _orderFromCity = true;
                                                _orderFromState = false;
                                                _orderFromCountry = false;
                                              } else if (value ==
                                                  SHOP_ORDER_FROM[2]) {
                                                _orderFromCity = false;
                                                _orderFromState = true;
                                                _orderFromCountry = false;
                                              } else if (value ==
                                                  SHOP_ORDER_FROM[3]) {
                                                _orderFromCity = false;
                                                _orderFromState = false;
                                                _orderFromCountry = true;
                                              } else {
                                                _orderFromCity = false;
                                                _orderFromState = false;
                                                _orderFromCountry = false;
                                              }
                                              setState(() {
                                                _orderFromValue = value;
                                              });
                                            },
                                            hint: Container(
                                              child: Text(
                                                'امکان ارسال‌ به',
                                                textAlign: TextAlign.center,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                              ),
                                            ),
                                            isExpanded: true,
                                            value: _orderFromValue,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        OutlineButton(
                                          onPressed: _setStartStoreDateTime,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.watch_later,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'ساعت کاری',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                ),
                                              ),
                                            ],
                                            mainAxisSize: MainAxisSize.min,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            OutlineButton(
                                              onPressed: _setStartStoreDateTime,
                                              child: Text(
                                                '${startStoreDateTime.hour}:${startStoreDateTime.minute}',
                                              ),
                                            ),
                                            Text(' تا '),
                                            OutlineButton(
                                              onPressed: _setCloseStoreDateTime,
                                              child: Text(
                                                '${closeStoreDateTime.hour}:${closeStoreDateTime.minute}',
                                              ),
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                        ),
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                      vertical: 5.0,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'پیش سفارش',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          onChanged: switchOnChanged,
                                          value: _hasPreOrder,
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 5.0),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'درگاه اینترنتی ایده شاپ',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          onChanged: (value) {
                                            setState(() {
                                              _hasDefaultGateWay = value;
                                            });
                                            if (value == true) {
                                              showCustomDialog(
                                                  context,
                                                  'درگاه اینترنتی ایده شاپ',
                                                  'با فعالسازی این گزینه مشتریان میتوانند در هنگام خرید با استفاده از درگاه پرداخت ایده شاپ مبلغ خرید را غیرحضوری پرداخت کنند و شما میتوانید با استفاده از سایت http://my.idehshops.ir تسویه حساب کنید، در غیر اینصورت پرداخت بصورت حضوری انجام میپذیرد.');
                                            }
                                          },
                                          value: _hasDefaultGateWay,
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 5.0),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.center,
                              ),
                              key: _formKey,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              20.0,
                            ),
                          ),
                          margin: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 5.0),
                          elevation: 1.0,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        child: RaisedButton(
                          child: _loading
                              ? Container(
                                  child: CircularProgressIndicator(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                )
                              : Text(
                                  'ثبت تغییرات',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                          onPressed: () => _saveChanges(context),
                        ),
                        width: 150,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
        cubit: _storeBloc,
      ),
    );
  }

  Future<void> _showAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text(
                    'گالری',
                  ),
                  onTap: () =>
                      _imageSourceSelected(context, ImageSource.gallery),
                ),
                SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  child: Text(
                    'دوربین',
                  ),
                  onTap: () =>
                      _imageSourceSelected(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _imageSourceSelected(BuildContext context, ImageSource _imageSource) async {
    final pickedFile = await picker.getImage(source: _imageSource);

    File _cropped = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 512,
      maxWidth: 512,
      compressQuality: 50,
      cropStyle: CropStyle.circle,
    );

    this.setState(() {
      _imageFile = File(_cropped.path);
    });
    Navigator.of(context).pop();
  }

  _saveChanges(BuildContext context) async {
    if (_stateId == null || _cityId == null) {
      Scaffold.of(context).showSnackBar(
        getSnackBar(context, 'لطفا شهر و استان فروشگاه خود را انتخاب کنید', 3),
      );
    } else if (_formKey.currentState.validate()) {
      setState(() {
        _loading = true;
      });
      final Map<String, String> _headers = {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      };

      Map<String, dynamic> postBody = new Map<String, dynamic>();
      postBody['title'] = _titleController.text;
      postBody['description'] = _descriptionController.text;
      double _limitDistance = double.parse("${_limitDistanceController.text}");
      postBody['limitDistance'] = (_limitDistance / 1000 * 180 / 6400 / 3.14);
      postBody['transportPrice_near'] =
          int.parse(_transportPriceNearController.text);
      postBody['transportPrice_far'] =
          int.parse(_transportPriceFarController.text);
      postBody['postalCode'] = _postalCodeController.text;
      postBody['isCommon'] = true;
      postBody['stateId'] = _stateId;
      postBody['cityId'] = _cityId;
      postBody['shopKindId'] = _shopKindValue;
      postBody['accessNumbers'] = [_phoneController.text];
      postBody['hasPreOrder'] = _hasPreOrder;
      postBody['hasDefaultPaymentGateWay'] = _hasDefaultGateWay;
      postBody['location'] = {
        'long': _storeBloc.lng != null ? _storeBloc.lng : _currentStore.long,
        'lat': _storeBloc.lat != null ? _storeBloc.lat : _currentStore.lat,
        'address': _addressController.text,
      };
      postBody['workHours'] = {
        'openAt': '${startStoreDateTime.hour}:${startStoreDateTime.minute}',
        'closeAt': '${closeStoreDateTime.hour}:${closeStoreDateTime.minute}',
      };
      postBody['orderFrom'] = {
        'city': _orderFromCity ?? false,
        'state': _orderFromState ?? false,
        'country': _orderFromCountry ?? false,
      };
      postBody['bankAccount'] = {
        'number': (_bankNumberController.text != '' &&
                _bankNumberController.text != ' ')
            ? _bankNumberController.text
            : null,
        'shaba': (_bankShabaController.text != '' &&
                _bankShabaController.text != ' ')
            ? _bankShabaController.text
            : null,
      };

      final response = await http.put(
        '$BASE_URI/shop/location/${_currentStore.id}',
        headers: _headers,
        body: jsonEncode(postBody),
      );
      ResponseWrapper wrapper = ResponseWrapper.fromJson(
        jsonDecode(response.body),
      );
      if (response.statusCode == 200) {
        if (wrapper.code == 200) {
          if (_imageFile != null) {
            /// upload store image
            FormData formData = FormData.fromMap({
              'file': await MultipartFile.fromFile(
                _imageFile.path,
                filename: _imageFile.path.split('/').last,
                contentType: MediaType.parse('image/jpeg'),
              ),
            });

            Dio dio = Dio();
            await dio.post(
              "$BASE_URI/shop/img/${_currentStore.id}",
              options: Options(
                headers: {
                  'Authorization': "Bearer ${_storeBloc.user.authCode}",
                  'contentType': 'multipart/form-data',
                },
              ),
              data: formData,
            );
          }

          setState(() {
            _loading = false;
          });
          if (response.statusCode == 200) {
            _storeBloc.add(SubmitEditStoreEvent());
          }
        }
      } else {
        final snackBar = SnackBar(
          content: Text(
            'متاسفانه درخواست شما با مشکل مواجه شد. لطفا مجددا تلاش کنید.',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.bodyText1.fontFamily,
            ),
          ),
        );
        Scaffold.of(context).showSnackBar(snackBar);
        setState(() {
          _loading = false;
        });
      }
    }
  }

  _getStates() async {
    final res = await http.get(
      '$BASE_URI/states',
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      if (wrapper.code == 200) {
        (wrapper.data as List).forEach((element) {
          _states.add(MyState.fromJson(element));
        });
        _findShopStateValue();
      }
    }
  }

  _getCities() async {
    final res = await http.get(
      '$BASE_URI/cities/$_stateId',
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      if (wrapper.code == 200) {
        (wrapper.data as List).forEach((element) {
          _cities.add(City.fromJson(element));
        });
        setState(() {});
      }
    }
  }

  _findShopStateValue() {
    _states.forEach((element) {
      if (element.id == _currentStore.stateId) {
        _stateId = element.id;
        _getCities();
      }
    });
    setState(() {});
  }

  _findShopKindValue() async {
    final res = await http.get(
      '$BASE_URI/shop/kinds/1?limit=100',
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      if (wrapper.code == 200) {
        (wrapper.data as List).forEach((element) {
          _shopKinds.add(ShopKind.fromJson(element));
        });
        _shopKinds.forEach((element) {
          if (_currentStore.kind == element.kind) {
            _shopKindValue = element.id;
          }
        });
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _transportPriceNearController.dispose();
    _transportPriceFarController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _limitDistanceController.dispose();
    _bankNumberController.dispose();
    _bankShabaController.dispose();
    super.dispose();
  }

  _setStartStoreDateTime() {
    showDateTimeDialog(
      context,
      initialDate: startStoreDateTime,
      title: 'ساعت شروع کار فروشگاه',
      onSelectedDate: (selectedDate) {
        setState(() {
          startStoreDateTime = selectedDate;
        });
      },
    );
  }

  switchOnChanged(bool value) {
    setState(() {
      _hasPreOrder = value;
    });
  }

  _setCloseStoreDateTime() {
    showDateTimeDialog(
      context,
      initialDate: closeStoreDateTime,
      title: 'ساعت اتمام کار فروشگاه',
      onSelectedDate: (selectedDate) {
        setState(() {
          closeStoreDateTime = selectedDate;
        });
      },
    );
  }
}
