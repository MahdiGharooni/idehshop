import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

/// initial state - sign out state
class SignedOutAuthenticationState extends AuthenticationState {}

/// user signed up without verified code
class SignedUpAuthenticationState extends AuthenticationState {}

/// user verified code
class VerifiedAuthenticationState extends AuthenticationState {
  final bool userShouldChangePass;

  VerifiedAuthenticationState({this.userShouldChangePass = false});
}

/// user should login, after forget pass & change pass
class ShouldLoginAuthenticationState extends AuthenticationState {}

/// user verified code & logged in
class LoggedInAuthenticationState extends AuthenticationState {}

/// user forgotten password
class ForgottenPassAuthenticationState extends AuthenticationState {}

/// user changed profile
class ChangedProfileAuthenticationState extends AuthenticationState {}

/// loading
class LoadingAuthenticationState extends AuthenticationState {}

/// show message
class ShowMessageAuthenticationState extends AuthenticationState {
  final String message;

  ShowMessageAuthenticationState({@required this.message});
}

/// jwt expired
class JwtExpiredAuthenticationState extends AuthenticationState {}

/// added favorite shop ids
class AddedFavoriteShopIdsAuthenticationState extends AuthenticationState {}
