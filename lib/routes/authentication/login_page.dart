import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/managers/connectivity_manager.dart';
import 'package:idehshop/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ConnectivityManager _connectivityManager = ConnectivityManager();
  ConnectivityResult _connectionStatus = ConnectivityResult.wifi;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  AuthenticationBloc _authenticationBloc;
  SharedPreferences _pref;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _getPref();
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
    return Scaffold(
      body: Container(
        child: Center(
          child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is ShowMessageAuthenticationState) {
                final snackBar = SnackBar(content: Text(state.message));
                Scaffold.of(context).showSnackBar(snackBar);
              }
              if (state is LoggedInAuthenticationState) {
                Navigator.pushReplacementNamed(context, '/homePage');
              }
              if (state is JwtExpiredAuthenticationState) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Form(
                  child: Column(
                    children: [
                      Container(
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: '۰۹۱۲۳۴۵۶۷۸۹',
                          ),
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.number,
                          validator: (String value) {
                            return value.isEmpty
                                ? 'فیلد موبایل اجباری است'
                                : null;
                          },
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 10.0),
                      ),
                      Container(
                        child: TextFormField(
                          autocorrect: false,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'رمز عبور *',
                          ),
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          validator: (String value) {
                            return value.isEmpty ? 'فیلد رمز اجباری است' : null;
                          },
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 10.0),
                      ),
                      RaisedButton(
                        child: (state is LoadingAuthenticationState)
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
                                'ورود',
                                style: Theme.of(context).textTheme.button,
                              ),
                        onPressed: _onPressed,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: [
                          Container(
                            child: GestureDetector(
                              child: Text(
                                'فراموشی رمز/تغییررمز',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).textTheme.button.color,
                                ),
                              ),
                              onTap: _onForgetPass,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: GestureDetector(
                              child: Text(
                                'ثبت نام',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).textTheme.button.color,
                                ),
                              ),
                              onTap: _onSignUp,
                            ),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  key: _formKey,
                ),
              );
            },
            cubit: _authenticationBloc,
          ),
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  _onPressed() async {
    if (_formKey.currentState.validate()) {
      if (mounted) {
        _authenticationBloc.context = context;
        _authenticationBloc.mobile = _usernameController.text;
        _authenticationBloc.password = _passwordController.text;
        _authenticationBloc.add(LoginSubmitAuthenticationEvent(pref: _pref));
      }
    }
  }

  _onSignUp() {
    Navigator.pushNamed(context, '/signup');
  }

  _onForgetPass() {
    Navigator.pushNamed(context, '/forgetPass');
  }

  connectionSnackBar() {
    Scaffold.of(context).showSnackBar(
      getSnackBar(
        context,
        'لطفا اتصال اینترنت خود را بررسی کنید',
        5,
      ),
    );
  }

  _getPref() async {
    _pref = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
