import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/product.dart';

abstract class ShoppingEvent extends Equatable {
  const ShoppingEvent();

  @override
  List<Object> get props => [];
}

/// get all shop kinds
class SubmitAllShopKinds extends ShoppingEvent {}

/// get shops as selected shopKind
class SubmitGetShopsAsSelectedShopKind extends ShoppingEvent {
  final int page;
  final String locationId;

  SubmitGetShopsAsSelectedShopKind({
    @required this.page,
    @required this.locationId,
  });
}

/// submit to add new product into basket
class SubmitNewProductToBasketShopEvent extends ShoppingEvent {
  final Product product;
  final String measurementIndex;

  SubmitNewProductToBasketShopEvent({
    @required this.product,
    @required this.measurementIndex,
  });
}

/// submit final order
class SubmitFinalOrderShopEvent extends ShoppingEvent {
  final bool payFromWallet;

  final dynamic offCode;

  SubmitFinalOrderShopEvent({@required this.payFromWallet, this.offCode});
}

/// add shop rate
class AddShopRateShopEvent extends ShoppingEvent {
  final String orderId;
  final int score;

  AddShopRateShopEvent({@required this.orderId, @required this.score});
}

/// delete product from basket
class DeleteProductFromBasketShopEvent extends ShoppingEvent {
  final Product product;

  DeleteProductFromBasketShopEvent({@required this.product});
}

/// add customer new notifications
class AddCustomerNewNotifications extends ShoppingEvent {
  final int notifs;

  AddCustomerNewNotifications({@required this.notifs});
}

/// seen customer new notifications
class SeenCustomerNewNotifications extends ShoppingEvent {}

/// delete all product from basket
class SubmitToEmptyBasketShoppingEvent extends ShoppingEvent {}

/// add product info to list
class AddProductInfoToListShopEvent extends ShoppingEvent {
  final String productId;

  final String description;

  AddProductInfoToListShopEvent({
    @required this.productId,
    @required this.description,
  });
}

/// set new shop as selectedShop
class SetNewShopAsSelectedShopEvent extends ShoppingEvent {
  final String shopId;

  SetNewShopAsSelectedShopEvent({@required this.shopId});
}
