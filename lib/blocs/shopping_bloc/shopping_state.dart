import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/models/shop_kind.dart';
import 'package:idehshop/models/store.dart';

abstract class ShoppingState extends Equatable {
  const ShoppingState();

  @override
  List<Object> get props => [];
}

/// initial state
class UninitializedShoppingState extends ShoppingState {}

/// show loading
class LoadingShoppingState extends ShoppingState {}

/// got allShopKinds
class GotAllShopKindsShoppingState extends ShoppingState {
  final List<ShopKind> shopKinds;

  GotAllShopKindsShoppingState({@required this.shopKinds});
}

/// got shops as selected shop kind
class GotShopsAsSelectedShopKind extends ShoppingState {}

/// added new product to basket
class AddedNewProductShopState extends ShoppingState {
  final Product product;
  final String measurementIndex;

  AddedNewProductShopState(
      {@required this.product, @required this.measurementIndex});
}

/// sent new order
class SentNewOrderShopState extends ShoppingState {
  final String orderId;

  SentNewOrderShopState({@required this.orderId});
}

/// deleted product from basket
class DeletedProductFromBasketShopState extends ShoppingState {}

/// jwt expired
class JwtExpiredShopState extends ShoppingState {}

/// added shop rate
class AddedShopRateShopState extends ShoppingState {}

/// show message
class ShowMessageShopState extends ShoppingState {
  final String msg;

  ShowMessageShopState({@required this.msg});
}

/// customer new notifications changed
class CustomerNewNotificationsChangedState extends ShoppingState {}

/// buying product info changes
class BuyingProductInfoChangedState extends ShoppingState {}

/// set new selected shop
class SetNewSelectedShopState extends ShoppingState {
  final Store store;

  SetNewSelectedShopState({@required this.store});
}
