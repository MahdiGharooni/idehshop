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


}
