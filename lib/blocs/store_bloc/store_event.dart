import 'dart:io';

import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/product.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object> get props => [];
}

/// lead bloc into a stability state
class EnterIntoStabilityState extends StoreEvent {}

/// enter into store page
class EnterIntoStoreStoreEvent extends StoreEvent {}

/// submit to add new store
class SubmitAddStoreStoreEvent extends StoreEvent {
  final String startStoreTime;
  final String finishStoreTime;
  final bool defaultPayGateWay;
  final bool commission;
  final bool orderFromCity;
  final bool orderFromState;
  final bool orderFromCountry;
  final String marketerId;
  final String cityId;
  final String bankNumber;
  final String bankShaba;

  SubmitAddStoreStoreEvent({
    @required this.startStoreTime,
    @required this.finishStoreTime,
    @required this.defaultPayGateWay,
    @required this.commission,
    @required this.cityId,
    @required this.orderFromCity,
    @required this.orderFromState,
    @required this.orderFromCountry,
    this.bankNumber,
    this.bankShaba,
    this.marketerId,
  });
}

/// get provider stores
class GetStoresStoreEvent extends StoreEvent {}

/// edit product submit
class SubmitEditProductStoreEvent extends StoreEvent {
  final Product product;
  final String productCategoryId;

  SubmitEditProductStoreEvent(
      {@required this.product, @required this.productCategoryId});
}

/// add product submit
class SubmitAddProductStoreEvent extends StoreEvent {
  final String productCategoryId;

  SubmitAddProductStoreEvent({@required this.productCategoryId});
}

///  submit to show loading
class ShowLoadingStoreEvent extends StoreEvent {}

/// submit to get all store products
class GetAllProductsStoreEvent extends StoreEvent {}

/// submit to edit store info
class SubmitEditStoreEvent extends StoreEvent {}

/// submit edit store location
class SubmitEditLocationStoreEvent extends StoreEvent {
  final double lat;
  final double lng;

  SubmitEditLocationStoreEvent({@required this.lat, @required this.lng});
}

/// submit delete product image
class SubmitDeleteProductImage extends StoreEvent {
  final List<String> deletedImagesUrls;
  final Product product;

  SubmitDeleteProductImage({
    @required this.product,
    @required this.deletedImagesUrls,
  });
}

/// delete store
class SubmitDeleteStoreEvent extends StoreEvent {}

/// delete product
class SubmitDeleteProductEvent extends StoreEvent {}

/// create product category
class SubmitCreateProductCategoryEvent extends StoreEvent {
  final String title;
  final File imageFile;

  SubmitCreateProductCategoryEvent(
      {@required this.title, @required this.imageFile});
}

/// edit product category
class SubmitEditProductCategoryEvent extends StoreEvent {
  final String id;
  final String title;
  final File imageFile;

  SubmitEditProductCategoryEvent({
    @required this.id,
    @required this.title,
    @required this.imageFile,
  });
}

/// submit delete product category
class SubmitDeleteProductCategoryEvent extends StoreEvent {}

/// submit accept order
class SubmitAcceptOrderEvent extends StoreEvent {}

/// submit decline order
class SubmitDeclineOrderEvent extends StoreEvent {}

/// add provider new notifications
class AddProviderNewNotifications extends StoreEvent {
  final int notifsCount;

  AddProviderNewNotifications({@required this.notifsCount});
}

/// seen provider new notifications
class SeenProviderNewNotifications extends StoreEvent {}

/// submit to get ordering by shop (in storePage.dart)
class SubmitGetOrderingStoreEvent extends StoreEvent {}

///submit to changed store site domain
class SubmitChangedStoreSiteDomainStoreEvent extends StoreEvent {}

///submit to delete site banners
class SubmitDeleteBannersStoreEvent extends StoreEvent {
  final List<String> bannerUrls;

  SubmitDeleteBannersStoreEvent({@required this.bannerUrls});
}
