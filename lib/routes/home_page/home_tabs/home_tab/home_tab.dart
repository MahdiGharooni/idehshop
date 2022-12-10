import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/home_tab_category_card.dart';
import 'package:idehshop/cards/home_tab_night_store_card.dart';
import 'package:idehshop/dialogs/home_tab_address_dialog.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/managers/connectivity_manager.dart';
import 'package:idehshop/models/shop_kind.dart';
import 'package:idehshop/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  PermissionBloc _permissionBloc;
  ShoppingBloc _shoppingBloc;
  AuthenticationBloc _authenticationBloc;
  ConnectivityManager _connectivityManager = ConnectivityManager();
  ConnectivityResult _connectionStatus = ConnectivityResult.wifi;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  CacheManager _cacheManager = CacheManager();
  List<ShopKind> _shopKinds = List();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _permissionBloc = BlocProvider.of<PermissionBloc>(context);
        _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
        _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      });

      _shoppingBloc.authCode = _authenticationBloc.user.authCode;
      _shoppingBloc.permissionBloc = _permissionBloc;
      _permissionBloc.authCode = _authenticationBloc.user.authCode;

      if (_shoppingBloc.shopKinds.isEmpty) {
        _shoppingBloc.add(SubmitAllShopKinds());
      } else {
        _shopKinds = _shoppingBloc.shopKinds;
      }
      _checkSelectedAddress();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      _connectivityManager.initConnectivity().then((connectionStatus) async {
        _connectionStatus = connectionStatus;
        if (connectionStatus == ConnectivityResult.none) {
          connectionSnackBar();
        }
      });
      _connectivitySubscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult connectionStatus) {
        if (connectionStatus == ConnectivityResult.none) {
          _connectionStatus = connectionStatus;
          connectionSnackBar();
        } else if (_connectionStatus == ConnectivityResult.none) {
          if (mounted) {
            setState(() {
              _connectionStatus = connectionStatus;
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingBloc, ShoppingState>(
      listener: (context, state) {
        if (state is JwtExpiredShopState) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        if (state is GotAllShopKindsShoppingState) {
          setState(() {
            _shopKinds.clear();
            _shopKinds.addAll(state.shopKinds);
          });
        }
      },
      builder: (context, state) {
        if (_shoppingBloc == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return _shopKinds.isNotEmpty
              ? SingleChildScrollView(
                  child: Wrap(
                    children: _getCategoriesCards(),
                    alignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    spacing: 5,
                  ),
                )
              : Center(
                  child: Text('گروه بندی وجود ندارد'),
                );
        }
      },
      cubit: _shoppingBloc,
    );
  }

  _categorySelected(BuildContext context, ShopKind _selectedShopKind) async {
    _shoppingBloc.selectedShopKind = _selectedShopKind;
    if (_permissionBloc.selectedAddress != null) {
      _permissionBloc.add(AcceptPermissionEvent());
      _shoppingBloc.selectedShopKind = _selectedShopKind;
      Navigator.pushNamed(
        context,
        '/category',
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return HomeTabAddressDialog();
        },
      );
    }
  }

  connectionSnackBar() {
    Fluttertoast.showToast(
      msg: "لطفا اتصال اینترنت خود را بررسی کنید.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
    );
  }

  _checkSelectedAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(PREF_SELECTED_ADDRESS_ID) != null) {
      _permissionBloc.add(
        SelectAnAddressPermissionEvent(
          selectedAddressId: '${prefs.getString(PREF_SELECTED_ADDRESS_ID)}',
        ),
      );
    }
  }

  List<Widget> _getCategoriesCards() {
    List<Widget> _cards = List();
    _shopKinds.asMap().forEach((index, element) {
      if (index == 0) {
        _cards.add(
          InkWell(
            child: HomeTabNightStoreCard(
              shopKind: element,
              cacheManager: _cacheManager,
            ),
            onTap: () => _categorySelected(
              context,
              element,
            ),
          ),
        );
      } else {
        _cards.add(
          InkWell(
            child: HomeTabCategoryCard(
              shopKind: element,
              cacheManager: _cacheManager,
            ),
            onTap: () => _categorySelected(
              context,
              element,
            ),
          ),
        );
      }
    });
    return _cards;
  }
}
