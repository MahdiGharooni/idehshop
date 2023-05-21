import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/profile_row.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/routes/home_page/home_page.dart';
import 'package:idehshop/utils.dart';

class StoreDetailsPage extends StatefulWidget {
  @override
  _StoreDetailsPageState createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  StoreBloc _storeBloc;
  bool _loading = true;
  Store _currentStore;
  bool _payLoading = false;
  String _commissionValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      setState(() {});
      _getStoreDetails();
      _getShopCommission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اطلاعات فروشگاه',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editSelected,
          )
        ],
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: (_currentStore != null && !_loading)
          ? BlocConsumer<StoreBloc, StoreState>(
              listener: (context, state) {
                if (state is EditedStoreState) {
                  final snackBar = SnackBar(
                    content: Text(
                      'اطلاعات فروشگاه شما با موفقیت بروزرسانی شد. لطفا منتظر تایید ادمین بمانید.',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily:
                            Theme.of(context).textTheme.bodyText1.fontFamily,
                      ),
                    ),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                  _getStoreDetails();
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _currentStore.imageAddress != null &&
                                    _currentStore.imageAddress.length > 5
                                ? NetworkImage(
                                    "http://${_currentStore.imageAddress}",
                                  )
                                : AssetImage(
                                    'assets/images/default_basket.png',
                                  ),
                            fit: BoxFit.fill,
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
                      Card(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 5,
                              ),
                              ProfileRow(
                                icon: Icon(
                                  Icons.store_mall_directory,
                                ),
                                label: 'نام فروشگاه',
                                value: "${_currentStore.title ?? '-'}",
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.apps,
                                ),
                                label: 'نوع',
                                value: "${_currentStore.kind ?? '-'}",
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.score,
                                ),
                                label: 'امتیاز مشتریان به فروشگاه',
                                value: '${_currentStore.score} از 5 ',
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.directions_sharp,
                                ),
                                label: 'ارسال محصول به',
                                value: _currentStore.orderFromCountry
                                    ? SHOP_ORDER_FROM[3]
                                    : _currentStore.orderFromState
                                        ? SHOP_ORDER_FROM[2]
                                        : _currentStore.orderFromCity
                                            ? SHOP_ORDER_FROM[1]
                                            : SHOP_ORDER_FROM[0],
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.my_location,
                                ),
                                label: 'محدوده نزدیک به فروشگاه',
                                value:
                                    "${(_currentStore.limitDistance * 3.14 * 6400 / 180 * 1000).floor() ?? '0'} متر ",
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.attach_money,
                                ),
                                label: 'هزینه ارسال به محدوده نزدیک',
                                value:
                                    "${getFormattedPrice(int.parse('${_currentStore.transportPriceNear ?? 0}'))} تومان ",
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.attach_money,
                                ),
                                label: 'هزینه ارسال به دور',
                                value:
                                    "${getFormattedPrice(int.parse('${_currentStore.transportPriceFar}'))} تومان ",
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.account_balance,
                                ),
                                label: 'شماره‌حساب فروشنده(جهت تسویه)',
                                value: _currentStore.bankAccount.number ?? '',
                                dialogTitle: 'شماره‌حساب و شبا',
                                dialogCaption:
                                    'جهت تسویه پرداخت های انلاین با فروشگاه شما وارد کردن شماره حساب به نام دارنده فروشگاه اجباری است. \n\nاین اطلاعات صرفای برای شما و تیم پشتیبانی ایده‌شاپ قابل رویت است. \n\nدر صورت اشتباه وارد کردن اطلاعات مجموعه ایده شاپ هیچ گونه مسئولیتی در قبال این امر ندارد.',
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.account_balance,
                                ),
                                label: 'شماره‌شبا فروشنده(جهت تسویه)',
                                value: (_currentStore.bankAccount.shaba != '' &&
                                        _currentStore.bankAccount.shaba != null)
                                    ? 'IR ${_currentStore.bankAccount.shaba}'
                                    : '',
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.phone,
                                ),
                                label: 'شماره تماس',
                                value:
                                    "${_currentStore.accessNumbers != null ? _currentStore.accessNumbers[0] : '-'}",
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.clear_all,
                                ),
                                label: 'کدپستی',
                                value:
                                    "${_currentStore.postalCode != '' ? _currentStore.postalCode : '-'}",
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.location_on,
                                ),
                                label: 'آدرس',
                                value: "${_currentStore.address ?? '-'}",
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.description,
                                ),
                                label: 'توضیحات',
                                value:
                                    "${_currentStore.description != '' ? _currentStore.description : '-'}",
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.watch_later,
                                ),
                                label: 'ساعت کاری',
                                value:
                                    '${_currentStore.openAt['hour'] ?? 0}:${_currentStore.openAt['min'] ?? 0} تا ${_currentStore.closeAt['hour'] ?? 0}:${_currentStore.closeAt['min'] ?? 0}',
                              ),
                              Divider(),
                              ProfileRow(
                                icon: Icon(
                                  Icons.business_center,
                                ),
                                label: 'نوع همکاری',
                                value: (_currentStore.commission != null &&
                                        '${_currentStore.commission}' != '0')
                                    ? 'بصورت کمیسیون'
                                    : 'بصورت فعالسازی فروشگاه',
                                dialogTitle: 'همکاری بصورت کمیسیون',
                                dialogCaption:
                                    ' بدین معناست که  $_commissionValueدرصد از فروش شما به ایده شاپ تعلق میگیرد و مشتریان موظف اند از درگاه اینترنتی ایده شاپ پرداخت کنند. در غیر اینصورت همکاری بصورت فعالسازی اکانت میباشد و باید مبلغی به ازای هر فروشگاه خود پرداخت نمایید تا تمام فروش از آن خودتان باشد.',
                              ),
                              Divider(),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            'وضعیت پیش سفارش',
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.error_outline,
                                              size: 15,
                                            ),
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.all(0),
                                            onPressed: () =>
                                                _preOrderDialog(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        _currentStore.hasPreOrder
                                            ? 'دارد'
                                            : 'ندارد',
                                        style: TextStyle(
                                          color: _currentStore.hasPreOrder
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            'درگاه اینترنتی ایده شاپ',
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.error_outline,
                                              size: 15,
                                            ),
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.all(0),
                                            onPressed: () =>
                                                _defaultPayDialog(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        _currentStore.hasDefaultPaymentGateWay
                                            ? 'دارد'
                                            : 'ندارد',
                                        style: TextStyle(
                                          color: _currentStore
                                                  .hasDefaultPaymentGateWay
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            'فعالسازی فروشگاه',
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.error_outline,
                                              size: 15,
                                            ),
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.all(0),
                                            onPressed: () =>
                                                _payDialog(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        _currentStore.payed
                                            ? 'انجام شده'
                                            : 'انجام نشده',
                                        style: TextStyle(
                                          color: _currentStore.payed
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
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
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'وضعیت فروشگاه',
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        _currentStore.verified
                                            ? 'تاییدشده'
                                            : 'تاییدنشده',
                                        style: TextStyle(
                                          color: _currentStore.verified
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                children: [
                                  _currentStore.payed
                                      ? Container()
                                      : FilterChip(
                                          label: _payLoading
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  'فعالسازی',
                                                ),
                                          padding: EdgeInsets.all(0.0),
                                          avatar: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onSelected: (value) =>
                                              Navigator.pushNamed(
                                                  context, '/storePay'),
                                          backgroundColor: Colors.green,
                                        ),
                                  _currentStore.payed
                                      ? Container()
                                      : SizedBox(
                                          width: 5,
                                        ),
                                  FilterChip(
                                    label: Text(
                                      'حذف فروشگاه',
                                    ),
                                    padding: EdgeInsets.all(0.0),
                                    avatar: Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onSelected: (value) =>
                                        _deleteShop(value, context),
                                    backgroundColor: Colors.red,
                                  ),
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                );
              },
              cubit: _storeBloc,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  _getStoreDetails() async {
    final response = await http.get(
      '$BASE_URI/shop/location/${_storeBloc.currentStore.id}',
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    if (response.statusCode == 200) {
      ResponseWrapper responseWrapper = ResponseWrapper.fromJson(
        jsonDecode(response.body),
      );
      if (responseWrapper.code == 200) {
        final Map<dynamic, dynamic> _data = responseWrapper.data;
        _currentStore = Store.fromJson(_data);
      }
    }
    setState(() {
      _storeBloc.currentStore = _currentStore;
      _storeBloc.add(EnterIntoStabilityState()); // save changes on currentStore
      _loading = false;
    });
  }

  _editSelected() {
    Navigator.pushNamed(context, '/storeDetailsEdit');
  }

  _deleteShop(bool value, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'حذف کردن فروشگاه',
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.right,
          ),
          content: Text(
            'آیا از حذف فروشگاه خود مطمعن هستید؟ این عمل برگشت پذیر نمیباشد',
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.right,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'خیر',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'بله، حذف شود',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.red,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                final res = await http.delete(
                  '$BASE_URI/shop/location/${_currentStore.id}',
                  headers: {
                    'Authorization': "Bearer ${_storeBloc.user.authCode}",
                  },
                );
                ResponseWrapper _wrapper =
                ResponseWrapper.fromJson(jsonDecode(res.body));
                if (_wrapper.code == 200) {
                  _storeBloc.add(SubmitDeleteStoreEvent());
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                        (Route<dynamic> route) => false,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: getMessage(_wrapper.message),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 16.0,
                    backgroundColor: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                  );
                }
              },
            ),
          ],
          contentPadding: EdgeInsets.all(10),
          actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        );
      },
    );
  }

  _getShopCommission() async {
    final res = await http.get(
      "$BASE_URI/shop/buying/commission",
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      if (wrapper.code == 200) {
        setState(() {
          _commissionValue =
          '${(double.parse(wrapper.data['commission']) * 100).round()}';
        });
      }
    }
  }

  _payDialog(BuildContext context) {
    showCustomDialog(context, 'فعالسازی فروشگاه',
        'بدون فعالسازی شما میتوانید از امکانات این برنامه بمدت محدود استفاده کنید و پس از فعالسازی، فروشگاه شما بمدت نامحدود قابل استفاده است. برای پرداخت هزینه فعالسازی میتوانید از دکمه سبز رنگ پایین صفحه استفاده کنید.');
  }

  _preOrderDialog(BuildContext context) {
    showCustomDialog(context, 'پیش سفارش',
        'با فعالسازی پیش سفارش ، مشتریان میتوانند در غیر ساعت های کاری فروشگاه نیز خرید ثبت کنند.');
  }

  _defaultPayDialog(BuildContext context) {
    showCustomDialog(context, 'درگاه اینترنتی ایده شاپ',
        'با فعالسازی این گزینه مشتریان میتوانند در هنگام خرید با استفاده از درگاه پرداخت ایده شاپ مبلغ خرید را غیرحضوری پرداخت کنند و شما میتوانید با استفاده از سایت http://my.idehshops.ir تسویه حساب کنید، در غیر اینصورت پرداخت بصورت حضوری انجام میپذیرد.');
  }

}
