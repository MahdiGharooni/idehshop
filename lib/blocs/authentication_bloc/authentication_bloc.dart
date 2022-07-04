import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/managers/database_manager.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/models/user.dart';
import 'package:idehshop/utils.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({@required this.storeBloc}) : super(null);

  StoreBloc storeBloc;
  ResponseWrapper responseWrapper;
  User user;
  BuildContext context;
  String username;
  String firstName; // profile
  String lastName; // profile
  String nationalCode; // profile
  List<dynamic> accessNumbers; // profile
  File imageFile; // profile
  String password;
  String mobile;
  String confirmPass;
  String verifyCode;
  String newPass; // for resetPass
  bool userShouldChangePass = false; // change pass
  bool userSignedUp = false; // check first time

  List<Map<String, dynamic>> favoriteShops = List();
  List<Store> allFavoriteShopsDetails = List();

  AuthenticationState get initialState => SignedOutAuthenticationState();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    ///sign up
    if (event is SignUpSubmitAuthenticationEvent) {
      yield LoadingAuthenticationState();
      Map<String, dynamic> postBody = new Map<String, dynamic>();
      postBody['username'] = '';
      postBody['mobileNumber'] = mobile;
      postBody['password'] = password;
      postBody['confirmPassword'] = '';
      postBody['email'] = '';

      final response = await http.post(
        "$BASE_URI/signup",
        body: jsonEncode(postBody),
      );

      responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
      if (response.statusCode == 200) {
        if (responseWrapper.code == 200 && responseWrapper.data != null) {
          user = User(
            authCode: responseWrapper.data ??
                (responseWrapper.data[0] != null
                    ? responseWrapper.data[0]
                    : null),
            username: username,
            password: password,
            mobileNumber: mobile,
          );
          userSignedUp = true;
          yield SignedUpAuthenticationState();
        }
      } else if (response.statusCode == 401 || response.statusCode == 531) {
        yield JwtExpiredAuthenticationState();
      } else {
        yield ShowMessageAuthenticationState(message: responseWrapper.message);
        yield SignedOutAuthenticationState();
      }
    }

    /// login
    if (event is LoginSubmitAuthenticationEvent) {
      yield LoadingAuthenticationState();
      Map<String, String> postBody = Map<String, String>();
      postBody['ident'] = mobile;
      postBody['password'] = password;

      final response = await http.post(
        "$BASE_URI/login",
        body: jsonEncode(postBody),
      );
      responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
      if (response.statusCode == 200 &&
          responseWrapper.code == 200 &&
          responseWrapper.data != null) {
        if (user == null) {
          user = User();
        }
        if (event.pref != null) {
          event.pref.setString(PREF_AUTH_CODE, responseWrapper.data);
          event.pref.setString(PREF_MOBILE, mobile);
          event.pref.setString(PREF_PASSWORD, password);
        }
        user.authCode = responseWrapper.data;
        user.username = username;
        user.password = password;
        yield LoggedInAuthenticationState();
        _getUserCompleteInfo();
        _getDataBase();
      } else if (responseWrapper.message.contains('not verified yet') ||
          responseWrapper.message.contains('تایید')) {
        yield ShowMessageAuthenticationState(
            message:
                'شما هنوز شماره خود را تایید نکرده اید. لطفا از طریق فراموشی رمز اقدام کنید.');
        yield SignedOutAuthenticationState();
      } else if (responseWrapper.code == 401 || responseWrapper.code == 531) {
        yield JwtExpiredAuthenticationState();
      } else {
        yield ShowMessageAuthenticationState(message: responseWrapper.message);
        yield SignedOutAuthenticationState();
      }
    }

    /// verify code
    if (event is VerifySubmitAuthenticationEvent) {
      yield LoadingAuthenticationState();

      checkUserHasAuthCode();

      final Map<String, String> _headers = {
        'Authorization': "Bearer ${user.authCode}",
      };

      final response = await http.get(
        "$BASE_URI/verify/$verifyCode",
        headers: _headers,
      );
      responseWrapper = ResponseWrapper.fromJson(
        jsonDecode(response.body),
      );
      if (response.statusCode == 200) {
        if (responseWrapper.code == 200) {
          if (userShouldChangePass) {
            yield VerifiedAuthenticationState(userShouldChangePass: true);
          } else {
            /// we login instead of user after sign up
            Map<String, String> postBody = Map<String, String>();
            postBody['ident'] = mobile;
            postBody['password'] = password;

            final response = await http.post(
              "$BASE_URI/login",
              body: jsonEncode(postBody),
            );
            responseWrapper =
                ResponseWrapper.fromJson(jsonDecode(response.body));
            if (response.statusCode == 200 &&
                responseWrapper.code == 200 &&
                responseWrapper.data != null) {
              if (user == null) {
                user = User();
              }
              if (event.pref != null) {
                event.pref.setString(PREF_AUTH_CODE, responseWrapper.data);
                event.pref.setString(PREF_MOBILE, mobile);
                event.pref.setString(PREF_PASSWORD, password);
              }
              user.authCode = responseWrapper.data;
              user.username = username;
              user.password = password;
              yield LoggedInAuthenticationState();
              _getUserCompleteInfo();
              _getDataBase();
            }

            ///
            // yield VerifiedAuthenticationState(userShouldChangePass: false);
          }
        }
      } else if (response.statusCode == 401 || response.statusCode == 531) {
        yield JwtExpiredAuthenticationState();
      } else {
        yield ShowMessageAuthenticationState(message: responseWrapper.message);
        yield SignedOutAuthenticationState();
      }
    }

    ///forget pass
    if (event is ForgetPassSubmitAuthenticationEvent) {
      yield LoadingAuthenticationState();

      Map<String, String> postBody = Map<String, String>();
      postBody['mobileNumber'] = mobile;

      final response = await http.post(
        "$BASE_URI/forgot/password",
        body: jsonEncode(postBody),
      );
      responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
      if (response.statusCode == 200) {
        if (responseWrapper.code == 200 && responseWrapper.data != null) {
          if (user == null) {
            user = User();
          }
          user.authCode = responseWrapper.data;
          if (responseWrapper.data != null && responseWrapper.data != '') {
            event.pref.setString(PREF_AUTH_CODE, responseWrapper.data);
          }
        }
        yield VerifiedAuthenticationState(userShouldChangePass: true);
      } else if (response.statusCode == 401 || response.statusCode == 531) {
        yield JwtExpiredAuthenticationState();
      } else {
        yield ShowMessageAuthenticationState(message: responseWrapper.message);
        yield SignedOutAuthenticationState();
      }
    }

    ///change pass
    if (event is ChangePassSubmitAuthenticationEvent) {
      yield LoadingAuthenticationState();

      checkUserHasAuthCode();

      Map<String, dynamic> postBody = new Map<String, dynamic>();
      postBody['password'] = newPass;
      postBody['confirmPassword'] = '';

      final Map<String, String> _headers = {
        'Authorization': "Bearer ${user.authCode}",
      };

      final response = await http.post(
        "$BASE_URI/change/password",
        headers: _headers,
        body: jsonEncode(postBody),
      );
      if (response.statusCode == 200) {
        responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
        if (responseWrapper.code == 200 && responseWrapper.data != null) {
          yield ShouldLoginAuthenticationState();
        }
      } else if (response.statusCode == 401 || response.statusCode == 531) {
        yield JwtExpiredAuthenticationState();
      } else {
        yield ShowMessageAuthenticationState(message: responseWrapper.message);
        yield SignedOutAuthenticationState();
      }
    }

    ///change profile info
    if (event is SubmitChangeProfileAuthenticationEvent) {
      yield LoadingAuthenticationState();
      _getUserCompleteInfo();
      yield ChangedProfileAuthenticationState();
    }

    /// add favorite shop ids
    if (event is AddFavoriteShopIdsAuthenticationEvent) {
      yield LoadingAuthenticationState();
      favoriteShops = event.shops ?? [];
      yield AddedFavoriteShopIdsAuthenticationState();
    }

    ///sign out
    if (event is SignOutAuthenticationEvent) {
      event.shoppingBloc.add(SubmitToEmptyBasketShoppingEvent());
      event.permissionBloc.selectedAddress = null;
      event.pref.remove(PREF_AUTH_CODE);
      event.pref.remove(PREF_MOBILE);
      event.pref.remove(PREF_USER_NAME);
      event.pref.remove(PREF_PASSWORD);
      event.pref.remove(PREF_SELECTED_ADDRESS_ID);
      event.pref.clear();
      event.storeBloc.stores.clear();
      user = User();
      yield SignedOutAuthenticationState();
    }
  }

  checkUserHasAuthCode() async {
    if (user == null || user.authCode == null) {
      // get auth code from shared pref
      dynamic authCode = await getDataFromSharedPreferences(PREF_AUTH_CODE);
      if (authCode != null) {
        if (user == null) {
          user = User(authCode: authCode);
        } else {
          user.authCode = authCode;
        }
      }
    }
  }

  _getUserCompleteInfo() async {
    final response = await http.get(
      '$BASE_URI/profile',
      headers: {
        'Authorization': "Bearer ${user.authCode}",
      },
    );
    if (response.statusCode == 200) {
      responseWrapper = ResponseWrapper.fromJson(
        jsonDecode(response.body),
      );
      if (responseWrapper.code == 200) {
        final Map<dynamic, dynamic> _data = responseWrapper.data;
        user.username = _data['username'];
        user.mobileNumber = _data['mobileNumber'];
        user.firstName = _data['firstName'];
        user.lastName = _data['lastName'];
        user.accessNumbers = _data['accessNumbers'];
        user.nationalCode = _data['nationalCode'];
        user.imageAddress = _data['imageAddress'];
        user.mobileNumber = _data['mobileNumber'];
        user.wallet = _data['wallet'];
        user.role = responseWrapper.role;
      }
      _getUserStores();
    }
  }

  _getUserStores() async {
    final response = await http.get(
      '$BASE_URI/shop/locations',
      headers: {
        'Authorization': "Bearer ${user.authCode}",
      },
    );
    if (response.statusCode == 200) {
      responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
      if (responseWrapper.code == 200) {
        if (responseWrapper.data != null &&
            (responseWrapper.data as List).isNotEmpty) {
          storeBloc.stores.clear();
          (responseWrapper.data as List).forEach((element) {
            storeBloc.stores.add(Store.fromJson(element));
          });
        }
      }
    }
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
        add(
          AddFavoriteShopIdsAuthenticationEvent(shops: _shops),
        );
      });
    });
  }
}
