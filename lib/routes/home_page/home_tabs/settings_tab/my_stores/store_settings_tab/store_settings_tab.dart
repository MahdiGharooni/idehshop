import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/messages/messages.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/settings_row.dart';
import 'package:idehshop/utils.dart';

class StoreSettingsTab extends StatefulWidget {
  @override
  _StoreSettingsTabState createState() => _StoreSettingsTabState();
}

class _StoreSettingsTabState extends State<StoreSettingsTab> {
  AuthenticationBloc _authenticationBloc;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  StoreBloc _storeBloc;
  List<Widget> _rowsList = List<Widget>();
  int _notifsCount = 0;
  bool _loading = true;
  List<Store> _stores = List();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _stores = _storeBloc.stores;
      _createRowsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is JwtExpiredAuthenticationState) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        builder: (context, state) {
          return (_rowsList.isNotEmpty || !_loading)
              ? RefreshIndicator(
                  child: SafeArea(
                    child: ListView(
                      children: _rowsList,
                    ),
                  ),
                  onRefresh: _onRefresh,
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
        cubit: _authenticationBloc,
      ),
      key: _key,
    );
  }

  _createRowsList() {
    /// adding profile, messages,my stores
    _notifsCount = _storeBloc.notifsCount;
    _rowsList.addAll([
      SettingsRow(
        hasInkwellOnTap: true,
        hasOptionIconColor: false,
        hasOptionTextColor: false,
        optionIconColor: Theme.of(context).accentColor,
        hasSwitch: false,
        inkwellOnTap: () {
          Navigator.pushNamed(context, '/profile');
        },
        optionIcon: Icons.person_outline,
        optionText: 'اطلاعات کاربری',
      ),
      Divider(
        thickness: 1,
        height: 2.0,
      ),
      Stack(
        children: [
          SettingsRow(
            hasInkwellOnTap: true,
            hasOptionIconColor: false,
            hasOptionTextColor: false,
            optionIconColor: Theme.of(context).accentColor,
            hasSwitch: false,
            inkwellOnTap: () {
              setState(() {
                _notifsCount = 0;
                _storeBloc.add(SeenProviderNewNotifications());
              });
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return Messages(role: Role.provider);
                },
              ));
            },
            optionIcon: Icons.message_outlined,
            optionText: 'پیام‌ها',
          ),
          _notifsCount > 0
              ? Positioned(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.red,
              ),
              child: Text(
                "$_notifsCount",
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
      Divider(
        thickness: 1,
        height: 2.0,
      ),
      SettingsRow(
        hasInkwellOnTap: true,
        hasOptionIconColor: false,
        hasOptionTextColor: true,
        optionIconColor: Theme.of(context).accentColor,
        hasSwitch: false,
        inkwellOnTap: null,
        optionIcon: Icons.store_outlined,
        optionText: 'فروشگاه های من',
        optionTextColor: Colors.grey,
      ),
    ]);

    if (_authenticationBloc.user.role == PROVIDER_ROLE &&
        _storeBloc.stores.isNotEmpty) {
      _storeBloc.stores.forEach((element) {
        _rowsList.add(
          SettingsRow(
            hasInkwellOnTap: true,
            hasOptionIconColor: false,
            hasOptionTextColor: false,
            optionIconColor: Theme.of(context).accentColor,
            hasSwitch: false,
            storeVerified: element.verified,
            inkwellOnTap: () {
              _storeBloc.currentStore = element;
              _storeBloc.user = _authenticationBloc.user;
              _storeBloc.products = [];
              _storeBloc.add(EnterIntoStoreStoreEvent());
              Navigator.pushNamed(context, '/store');
            },
            optionIcon: null,
            optionText: "${element.title}",
          ),
        );
      });
    }

    ///adding create store
    _rowsList.addAll([
      Card(
        child: Container(
          child: RaisedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/createstore');
            },
            child: Text(
              'ساخت فروشگاه',
              style: TextStyle(
                color: Theme.of(context).textTheme.button.color,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10.0,
              ),
            ),
          ),
          height: 40.0,
          width: 50.0,
          margin: EdgeInsets.symmetric(horizontal: 80, vertical: 5),
        ),
      ),
      Divider(
        height: 2.0,
      ),
    ]);

    setState(() {
      _loading = false;
    });
  }

  Future<void> _onRefresh() async {
    /// get stores
    setState(() {
      _loading = true;
      _stores.clear();
      _rowsList.clear();
    });
    final response = await http.get(
      '$BASE_URI/shop/locations',
      headers: {
        'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
      },
    );
    if (response.statusCode == 200) {
      _stores.clear();
      ResponseWrapper _responseWrapper =
      ResponseWrapper.fromJson(jsonDecode(response.body));
      if (_responseWrapper.code == 200) {
        if (_responseWrapper.data != null &&
            (_responseWrapper.data as List).isNotEmpty) {
          (_responseWrapper.data as List).forEach((element) {
            _stores.add(Store.fromJson(element));
          });
        }
      }
    }
    await _createRowsList();
    return 'OK';
  }
}
