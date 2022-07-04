import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

/// user submit sign up
class SignUpSubmitAuthenticationEvent extends AuthenticationEvent {}

/// user submit verify code
class VerifySubmitAuthenticationEvent extends AuthenticationEvent {
  final SharedPreferences pref;

  VerifySubmitAuthenticationEvent({@required this.pref});
}

/// user submit login
class LoginSubmitAuthenticationEvent extends AuthenticationEvent {
  final SharedPreferences pref;

  LoginSubmitAuthenticationEvent({@required this.pref});
}

/// user submit forget password
class ForgetPassSubmitAuthenticationEvent extends AuthenticationEvent {
  final SharedPreferences pref;

  ForgetPassSubmitAuthenticationEvent({@required this.pref});
}

/// user submit change password
class ChangePassSubmitAuthenticationEvent extends AuthenticationEvent {}

/// user submit change profile
class SubmitChangeProfileAuthenticationEvent extends AuthenticationEvent {}

/// user submit sign out
class SignOutAuthenticationEvent extends AuthenticationEvent {
  final PermissionBloc permissionBloc;
  final ShoppingBloc shoppingBloc;
  final StoreBloc storeBloc;

  final SharedPreferences pref;

  SignOutAuthenticationEvent({
    @required this.permissionBloc,
    @required this.pref,
    @required this.shoppingBloc,
    @required this.storeBloc,
  });
}

/// add favorite shops ids
class AddFavoriteShopIdsAuthenticationEvent extends AuthenticationEvent {
  final List<Map<String, dynamic>> shops;

  AddFavoriteShopIdsAuthenticationEvent({@required this.shops});
}
