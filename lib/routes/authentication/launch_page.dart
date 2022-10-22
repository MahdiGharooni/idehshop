import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/managers/connectivity_manager.dart';
import 'package:idehshop/managers/database_manager.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/user.dart';
import 'package:idehshop/utils.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchPage extends StatefulWidget {
  @override
  _LaunchPageState createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  ConnectivityManager _connectivityManager = ConnectivityManager();
  ConnectivityResult _connectionStatus = ConnectivityResult.wifi;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  PermissionBloc _permissionBloc;
  AuthenticationBloc _authenticationBloc;
  ShoppingBloc _shoppingBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _permissionBloc = BlocProvider.of<PermissionBloc>(context);
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      if (mounted) {
        _connectivityManager.initConnectivity().then((connectionStatus) async {
          _connectionStatus = connectionStatus;
          if (connectionStatus == ConnectivityResult.none) {
            connectionSnackBar();
          } else {
            getUserInfoFromPref();
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
            getUserInfoFromPref();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          body: BlocConsumer<PermissionBloc, PermissionState>(
            listener: (context, state) {
              if (state is JwtExpiredPermissionState) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            builder: (context, state) {
              return BlocConsumer<ShoppingBloc, ShoppingState>(
                listener: (context, state) {
                  if (state is JwtExpiredShopState) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/launch.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  );
                },
                cubit: _shoppingBloc,
              );
            },
            cubit: _permissionBloc,
          ),
          key: _scaffoldKey,
        );
      },
    );
  }

  connectionSnackBar() {
    _scaffoldKey.currentState.showSnackBar(
      getSnackBar(
        context,
        'لطفا اتصال اینترنت خود را بررسی کنید',
        5,
      ),
    );
  }

  Future<void> getUserInfoFromPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // _setAppRequirements(preferences);

//    final res = await _checkRemoteConfig(preferences);

    await _getAppInfo(preferences);

    if (preferences.getString(PREF_AUTH_CODE) != null) {
      String _authCode = preferences.getString(PREF_AUTH_CODE);
      if (_authenticationBloc.user == null) {
        _authenticationBloc.user = User();
      }
      _authenticationBloc.user.authCode = _authCode;
      _authenticationBloc.add(SubmitChangeProfileAuthenticationEvent());
      _shoppingBloc.add(SubmitAllShopKinds());
      await Future.delayed(Duration(seconds: 2));
      _getDataBase().then(
        (value) {
          if (_shoppingBloc.state is JwtExpiredShopState) {
            Navigator.of(context).pushReplacementNamed('/login');
          } else if (mounted) {
            Navigator.of(context).pushReplacementNamed('/homePage');
          }
        },
      );
//      await Future.delayed(Duration(seconds: 2));

    } else {
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  _showUpdateDialog(SharedPreferences _pref,
      [bool _forceUpdate = false]) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'بروزرسانی',
            textAlign: TextAlign.right,
          ),
          content: Text(
            'نسخه جدید ایده شاپ منتشر شده است. لطفا نرم افزار خود را بروزرسانی کنید.',
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.right,
          ),
          actions: [
            FlatButton(
              child: Text(
                'دانلود مستقیم از سایت',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Theme.of(context).accentColor,
                    ),
              ),
              onPressed: () async {
                final url = IDEHSHOP_URI;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            _forceUpdate
                ? Container()
                : FlatButton(
                    child: Text(
                      'بعدا',
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context).accentColor,
                          ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
          ],
          actionsPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
        );
      },
      barrierDismissible: !_forceUpdate,
    );
  }

  _showFeaturesDialog(List<dynamic> _features) async {
    List<Widget> _children = List();
    _features.forEach((feature) {
      _children.add(
        Container(
          child: Text(
            ' - $feature',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          padding: EdgeInsets.all(5),
        ),
      );
    });
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'ویژگی های اضافه شده به نسخه جدید',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.normal,
                ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: _children,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
          actions: [
            FlatButton(
              child: Text(
                'باشه',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.normal,
                    ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
        );
      },
      barrierDismissible: true,
    );
  }

  _setAppRequirements(SharedPreferences _pref) {
    _pref.setString(PREF_MARKET, CAFE_BAZZAR);
//    _pref.setString(PREF_MARKET, MAYKET);

    _pref.setString(PREF_OS, OS_ANDROID);
//    _pref.setString(PREF_OS, OS_IOS);
  }

  Future<void> _getDataBase() async {
    DataBaseManager _database = DataBaseManager();
    await _database.open().then((onValue) {
      _database.readFavoriteShops().then((shops) {
        List<Map<String, dynamic>> _shops = List();
        shops.forEach((shop) {
          Map<String, dynamic> _map = Map();
          _map['id'] = shop['id'];
          _map['favorite'] = shop['favorite'];
          _shops.add(_map);
        });
        _authenticationBloc.add(
          AddFavoriteShopIdsAuthenticationEvent(shops: _shops),
        );
      });
    });
  }

  _getAppInfo(SharedPreferences _pref) async {
    final res = await http.get(
      '$BASE_URI/application/info',
    );
    ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
    if (wrapper.code == 200) {
      Map<String, dynamic> _info = wrapper.data;

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String _versionCode = packageInfo.buildNumber; //versionCode 26

      if (_versionCode != null) {
        if (_pref.containsKey(PREF_LAST_VERSION_Code)) {
          if (_versionCode == _info[INFO_VERSION_CODE] ||
              '10$_versionCode' == _info[INFO_VERSION_CODE]) {
            if (_pref.get(PREF_LAST_VERSION_Code) == _info[INFO_VERSION_CODE]) {
              /// continue app
              /// checked
            } else {
              _pref.setString(PREF_LAST_VERSION_Code, _info[INFO_VERSION_CODE]);
              await _showFeaturesDialog(_info[INFO_VERSION_FEATURES]);
            }
          } else {
            await _showUpdateDialog(
                _pref, _info[INFO_VERSION_FORCE_UPDATE] ?? false);
          }
        } else {
          if (_versionCode == _info[INFO_VERSION_CODE] ||
              '10$_versionCode' == _info[INFO_VERSION_CODE]) {
            ///checked
            _pref.setString(PREF_LAST_VERSION_Code, _info[INFO_VERSION_CODE]);
            await _showFeaturesDialog(_info[INFO_VERSION_FEATURES]);
          } else {
            /// checked
            await _showUpdateDialog(
                _pref, _info[INFO_VERSION_FORCE_UPDATE] ?? false);
          }
        }
      }
    }
  }
}
