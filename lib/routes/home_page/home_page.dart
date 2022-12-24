import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/dialogs/home_tab_address_dialog.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/routes/home_page/home_tabs/favorites_tab/favorites_tab.dart';
import 'package:idehshop/routes/home_page/home_tabs/home_tab/home_tab.dart';
import 'package:idehshop/routes/home_page/home_tabs/invoices_tab/invoices_tab.dart';
import 'package:idehshop/routes/home_page/home_tabs/ordering_tab/ordering_tab.dart';
import 'package:idehshop/routes/home_page/home_tabs/search_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/settings_tab.dart';
import 'package:idehshop/utils.dart';

class HomePage extends StatefulWidget {
  final int index;

  HomePage({this.index});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  PermissionBloc _permissionBloc;
  ShoppingBloc _shoppingBloc;
  StoreBloc _storeBloc;
  int _index = 2;
  int _customerNewNotifsCount = 0;
  String _title = 'ایده‌شاپ';
  DateTime _backPressedTime;

  static List<Widget> _screens = <Widget>[
    SettingsTab(),
    FavoritesTab(),
    HomeTab(),
    OrderingTab(),
    InvoicesTab(),
  ];

  static List<String> _titles = [
    'تنظیمات',
    'علاقه‌مندی‌ها',
    'ایده‌شاپ',
    'سفارشات باز',
    'فاکتورها',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      _index = widget.index;
      if (_index == 3) {
        _title = _titles[3];
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _permissionBloc = BlocProvider.of<PermissionBloc>(context);
      _getNewNotifs();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingBloc, ShoppingState>(
      listener: (context, state) {
        if (state is JwtExpiredShopState) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: WillPopScope(
            child: Scaffold(
              appBar: AppBar(
                leading: Builder(builder: (context) {
                  return InkWell(
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/images/basket.png',
                            scale: 3,
                          ),
                          tooltip: 'خرید‌نهایی',
                          onPressed: null,
                        ),
                        (_shoppingBloc != null &&
                                _shoppingBloc.buyingProducts.length > 0)
                            ? Positioned(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.red,
                                  ),
                                  child: Text(
                                    "${_shoppingBloc.buyingProducts.length}",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  height: 20,
                                  width: 20,
                                ),
                                top: 10.0,
                                left: 10.0,
                              )
                            : Container(),
                      ],
                    ),
                    onTap: () => _basketClicked(context),
                  );
                }),
                actions: [
                  _index == 2
                      ? IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () => _search(context),
                        )
                      : _index == 3
                          ? IconButton(
                              icon: Icon(Icons.error_outline),
                              onPressed: () => showCustomDialog(
                                context,
                                'سفارش باز',
                                'منظور از سفارش باز، سفارشی است که توسط کاربر برای فروشگاه ارسال شده است ولی هنوز فروشنده آنرا تایید یا رد نکرده است .',
                              ),
                            )
                          : _index == 4
                              ? IconButton(
                                  icon: Icon(Icons.error_outline),
                                  onPressed: () => showCustomDialog(
                                    context,
                                    'فاکتور',
                                    'منظور از فاکتور، سفارشی است که توسط فروشنده تایید یا رد شده است.',
                                  ),
                                )
                              : _index == 0
                                  ? IconButton(
                                      icon: Icon(Icons.privacy_tip_outlined),
                                      onPressed: () => Navigator.of(context)
                                          .pushNamed('/aboutUs'),
                                    )
                                  : Container(),
                ],
                title: Text(
                  _title,
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
                  if (state is DeletedStoreState) {
                    Fluttertoast.showToast(
                      msg: "فروشگاه شما با موفقیت حذف گردید",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      fontSize: 16.0,
                      backgroundColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                    );
                  }
                  if (state is AddedStoreStoreState) {
                    Fluttertoast.showToast(
                      msg: "فروشگاه شما با موفقیت اضافه گردید",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      fontSize: 16.0,
                      backgroundColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                    );
                  }
                },
                builder: (context, state) {
                  return _screens.elementAt(_index);
                },
                cubit: _storeBloc,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _tabSelected(2),
                tooltip: 'خانه',
                child: Icon(
                  Icons.home,
                  size: 35,
                  color: Colors.white,
                ),
                elevation: 2.0,
              ),
              bottomNavigationBar: BottomAppBar(
                shape: CircularNotchedRectangle(),
                elevation: 15.0,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.list,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () => _tabSelected(4),
                        padding: EdgeInsets.all(0.0),
                        tooltip: 'فاکتورها',
                        iconSize: _index == 4 ? 30 : 25,
                      ),
                      IconButton(
                        icon: _index == 3
                            ? Icon(
                                Icons.shopping_basket,
                                color: Theme.of(context).iconTheme.color,
                              )
                            : Icon(
                                Icons.shopping_basket_outlined,
                                color: Theme.of(context).iconTheme.color,
                              ),
                        onPressed: () => _tabSelected(3),
                        padding: EdgeInsets.all(0.0),
                        tooltip: 'سفارشات بازی',
                        iconSize: _index == 3 ? 30 : 25,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                      ),
                      IconButton(
                        icon: _index == 1
                            ? Icon(
                                Icons.favorite,
                                color: Theme.of(context).iconTheme.color,
                              )
                            : Icon(
                                Icons.favorite_outline,
                                color: Theme.of(context).iconTheme.color,
                              ),
                        onPressed: () => _tabSelected(1),
                        padding: EdgeInsets.all(0.0),
                        tooltip: 'علاقه‌مندی‌ها',
                        iconSize: _index == 1 ? 30 : 25,
                      ),
                      _customerNewNotifsCount == 0
                          ? IconButton(
                              icon: _index == 0
                                  ? Icon(
                                      Icons.settings,
                                      color: Theme.of(context).iconTheme.color,
                                    )
                                  : Icon(
                                      Icons.settings_outlined,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                              onPressed: () => _tabSelected(0),
                              padding: EdgeInsets.all(0.0),
                              tooltip: 'تنظیمات',
                              iconSize: _index == 0 ? 30 : 25,
                            )
                          : InkWell(
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.settings,
                                      color: _index == 0
                                          ? Theme.of(context).iconTheme.color
                                          : Colors.grey,
                                    ),
                                    onPressed: () => _tabSelected(0),
                                    padding: EdgeInsets.all(0.0),
                                    tooltip: 'تنظیمات',
                                    iconSize: _index == 0 ? 30 : 25,
                                  ),
                                  Positioned(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.red,
                                      ),
                                      child: Text(
                                        "$_customerNewNotifsCount",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      height: 20,
                                      width: 20,
                                    ),
                                    top: 10.0,
                                    left: 10.0,
                                  ),
                                ],
                              ),
                              onTap: () => _tabSelected(0),
                            ),
                    ],
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              key: _scaffoldKey,
            ),
            onWillPop: _onWillPop,
          ),
          bottom: true,
        );
      },
      cubit: _shoppingBloc,
    );
  }

  _tabSelected(int index) {
    if (index == 0) {
      _customerNewNotifsCount = 0;
    }
    setState(() {
      _index = index;
      _title = _titles[index];
    });
  }

  _basketClicked(BuildContext context) {
    if (_shoppingBloc.buyingProducts.length == 0) {
      Fluttertoast.showToast(
        msg: "سبد خرید شما خالی است.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
      );
    } else {
      Navigator.pushNamed(context, '/buying');
    }
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();

    bool backButton = (_backPressedTime == null) ||
        (now.difference(_backPressedTime) > Duration(seconds: 1));
    if (backButton) {
      _backPressedTime = now;
      Fluttertoast.showToast(
        msg: "برای خروج دوبار کلیک کنید",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
      );
      return false;
    } else {
      return true;
    }
  }

  _getNewNotifs() async {
    final res = await http.get(
      '$BASE_URI/customer/new/notifications/count',
      headers: {
        'Authorization': "Bearer ${_shoppingBloc.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      _customerNewNotifsCount = wrapper.data['count'];
      _shoppingBloc
          .add(AddCustomerNewNotifications(notifs: _customerNewNotifsCount));
      if (mounted) {
        setState(() {});
      }
    }
  }

  _search(BuildContext context) {
    if (_permissionBloc.selectedAddress != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return SearchPage(
            hint: 'نام محصول/فروشگاه',
            searchType: SEARCH_TYPE.productInNearStores,
          );
        },
      ));
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return HomeTabAddressDialog();
        },
      );
    }
  }
}
