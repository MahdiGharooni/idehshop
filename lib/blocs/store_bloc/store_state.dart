import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object> get props => [];
}

/// initial state , user does not have store
class WithoutStoreStoreState extends StoreState {}

/// user has store, stability state
class HasStoreStoreState extends StoreState {}

/// loading
class LoadingStoreState extends StoreState {}

/// added new product
class AddedNewProductStoreState extends StoreState {}

/// edited product
class EditedProductStoreState extends StoreState {}

/// show message
class ShowMessageStoreState extends StoreState {
  final String message;

  ShowMessageStoreState({@required this.message});
}

/// added a new store
class AddedStoreStoreState extends StoreState {
  final String role;

  AddedStoreStoreState({this.role});
}

/// jwt expired
class JwtExpiredStoreState extends StoreState {}

/// edited store
class EditedStoreState extends StoreState {}

/// edited store location, user should edit store too
class EditedLocationStoreState extends StoreState {}

/// deleted store
class DeletedStoreState extends StoreState {}

/// deleted store
class DeletedProductStoreState extends StoreState {}

/// deleted product category
class DeletedProductCategoryStoreState extends StoreState {}

/// deleted product image
class DeletedProductImageStoreState extends StoreState {}

/// added product category
class AddedProductCategoryStoreState extends StoreState {}

/// edited product category
class EditedProductCategoryStoreState extends StoreState {}

/// accepted order
class AcceptedOrderStoreState extends StoreState {}

/// declined order
class DeclinedOrderStoreState extends StoreState {}

/// provider new notifications changed
class ProviderNewNotificationsChangedState extends StoreState {}

/// updated store site
class ChangedStoreSiteStoreState extends StoreState {}

/// got store ordering
class GotOrderingStoreState extends StoreState {}
