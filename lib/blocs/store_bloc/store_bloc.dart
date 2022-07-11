import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/my_state.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/models/product_category.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/models/user.dart';
import 'package:idehshop/utils.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final LocationBloc locationBloc;

  StoreBloc({@required this.locationBloc}) : super(null);

  User user;
  List<Store> stores = List();
  List<Product> products = List();
  List<ProductCategory> productsCategories = List();
  Store currentStore; // when user enter into his store
  String title; // add,edit product - add store
  bool available; // add,edit product
  String measurement; // add,edit product
  double measurementIndex; // add,edit product
  int price; // add,edit product
  int offPrice; // add,edit product
  String description; // add,edit product - add store
  ResponseWrapper _responseWrapper;
  String accessNumbers;
  double limitDistance;
  int transportPriceNear;
  int transportPriceFar;
  String postalCode;
  String address;
  File imageFile;
  List<File> imagesFiles = List();
  double lat;
  double lng;
  String stateValue; // add store
  String shopKindValue; // add store
  List<MyState> states = List();
  int notifsCount = 0;

  /// in storePAge.dart we should show count of ordering, but when user refresh tab we shouldn't show the previous count again
  /// so we keep oldCount to compare
  int oldOrderingCount = 0;
  int shownOrderingCount = 0;

  StoreState get initialState => WithoutStoreStoreState();

  @override
  Stream<StoreState> mapEventToState(StoreEvent event) async* {
    final Map<String, String> _headers = {
      'Authorization': "Bearer ${user.authCode}",
    };

    /// enter into stability state
    if (event is EnterIntoStabilityState) {
      yield LoadingStoreState();
      yield HasStoreStoreState();
    }

    /// enter into store page
    if (event is EnterIntoStoreStoreEvent) {
      yield LoadingStoreState();
    }

    /// submit to show loading
    if (event is ShowLoadingStoreEvent) {
      yield LoadingStoreState();
    }

    /// get all store products
    if (event is GetAllProductsStoreEvent) {
      yield LoadingStoreState();
//      _getAllProducts(_headers);
      yield HasStoreStoreState();
    }

    /// add store
    if (event is SubmitAddStoreStoreEvent) {
      yield LoadingStoreState();
      Map<String, dynamic> postBody = new Map<String, dynamic>();
      postBody['title'] = this.title;
      postBody['description'] = this.description;
      postBody['limitDistance'] = this.limitDistance;
      postBody['transportPrice_near'] = this.transportPriceNear;
      postBody['transportPrice_far'] = this.transportPriceFar;
      postBody['postalCode'] = this.postalCode;
      postBody['isCommon'] = true;
      postBody['stateId'] = stateValue;
      postBody['cityId'] = event.cityId;
      postBody['shopKindId'] = shopKindValue;
      postBody['accessNumbers'] = [accessNumbers];
      postBody['hasDefaultPaymentGateWay'] = event.defaultPayGateWay;
      postBody['commission'] = event.commission;
      postBody['location'] = {
        'long': locationBloc.lng,
        'lat': locationBloc.lat,
        'address': this.address,
      };
      postBody['workHours'] = {
        'openAt': event.startStoreTime,
        'closeAt': event.finishStoreTime,
      };
      postBody['orderFrom'] = {
        'city': event.orderFromCity ?? false,
        'state': event.orderFromState ?? false,
        'country': event.orderFromCountry ?? false,
      };
      postBody['bankAccount'] = {
        'number': (event.bankNumber != '' && event.bankNumber != ' ')
            ? event.bankNumber
            : null,
        'shaba': (event.bankShaba != '' && event.bankShaba != ' ')
            ? event.bankShaba
            : null,
      };

      if (event.marketerId != null && event.marketerId != '') {
        postBody['marketerId'] = event.marketerId.replaceAll(' ', '');
      }

      final response = await http.post(
        '$BASE_URI/shop/location',
        headers: _headers,
        body: jsonEncode(postBody),
      );

      _responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
      if (response.statusCode == 200) {
        if (_responseWrapper.code == 200) {
          /// upload new store image
          if (imageFile != null) {
            _uploadNewStoreImage("${_responseWrapper.data['id']}");
          }
          stores = [];
          add(GetStoresStoreEvent());
        } else {
          yield ShowMessageStoreState(message: _responseWrapper.message);
          yield HasStoreStoreState();
        }
      } else if (response.statusCode == 401 || response.statusCode == 531) {
        yield JwtExpiredStoreState();
      } else {
        yield ShowMessageStoreState(message: _responseWrapper.message);
        yield HasStoreStoreState();
      }
    }

    /// add product
    if (event is SubmitAddProductStoreEvent) {
      Map<String, dynamic> postBody = new Map<String, dynamic>();
      postBody['title'] = title;
      postBody['available'] = available;
      postBody['measurement'] = measurement;
      postBody['measurementIndex'] = measurementIndex;
      postBody['price'] = price;
      postBody['offPrice'] = offPrice;
      postBody['description'] = description;

      final response = await http.post(
        '$BASE_URI/shop/product/${event.productCategoryId}',
        headers: _headers,
        body: jsonEncode(postBody),
      );
      _responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
      if (response.statusCode == 200) {
        if (_responseWrapper.code == 200) {
          yield AddedNewProductStoreState();
          add(GetAllProductsStoreEvent());
          if (imagesFiles.isNotEmpty) {
            _uploadProductImage(_responseWrapper.data['id']);
          }
        } else {
          yield ShowMessageStoreState(message: _responseWrapper.message);
        }
      } else if (response.statusCode == 401 || response.statusCode == 531) {
        yield JwtExpiredStoreState();
      } else {
        yield ShowMessageStoreState(message: _responseWrapper.message);
      }
    }

    /// get all stores
    if (event is GetStoresStoreEvent) {
      yield LoadingStoreState();
      _getUserStores(_headers);
      yield AddedStoreStoreState();
    }

    /// edit product
    if (event is SubmitEditProductStoreEvent) {
      yield LoadingStoreState();
      Map<String, dynamic> postBody = new Map<String, dynamic>();
      postBody['title'] = title;
      postBody['available'] = available;
      postBody['measurement'] = measurement;
      postBody['measurementIndex'] = measurementIndex;
      postBody['price'] = price;
      postBody['offPrice'] = offPrice;
      postBody['description'] = description;
      postBody['productKindId'] = event.productCategoryId;

      final response = await http.put(
        '$BASE_URI/shop/product/${event.product.id}',
        headers: _headers,
        body: jsonEncode(postBody),
      );

      _responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
      if (response.statusCode == 200) {
        if (_responseWrapper.code == 200) {
          yield EditedProductStoreState();
          add(GetAllProductsStoreEvent());
          if (imagesFiles.isNotEmpty) {
            _uploadProductImage('${event.product.id}');
          }
        } else {
          yield ShowMessageStoreState(message: _responseWrapper.message);
        }
      } else if (response.statusCode == 401 || response.statusCode == 531) {
        yield JwtExpiredStoreState();
      } else {
        yield ShowMessageStoreState(message: _responseWrapper.message);
      }
    }

    ///change store info
    if (event is SubmitEditStoreEvent) {
      yield LoadingStoreState();
      lat = null;
      lng = null;
//      _getStoreDetails();
      yield EditedStoreState();
    }

    /// edit location
    if (event is SubmitEditLocationStoreEvent) {
      yield LoadingStoreState();
      lat = event.lat;
      lng = event.lng;
      yield EditedLocationStoreState();
    }

    /// delete product image
    if (event is SubmitDeleteProductImage) {
      yield LoadingStoreState();

      Map<String, dynamic> postBody = new Map<String, dynamic>();
      postBody['resources'] = event.deletedImagesUrls;

      await http.post(
        '$BASE_URI/shop/product/image/delete/${event.product.id}',
        headers: _headers,
        body: jsonEncode(postBody),
      );

      yield DeletedProductImageStoreState();
    }

    /// delete store
    if (event is SubmitDeleteStoreEvent) {
      yield LoadingStoreState();
      add(GetStoresStoreEvent());
      yield DeletedStoreState();
    }

    /// delete product
    if (event is SubmitDeleteProductEvent) {
      yield LoadingStoreState();
      yield DeletedProductStoreState();
    }

    /// add product category
    if (event is SubmitCreateProductCategoryEvent) {
      yield LoadingStoreState();
      FormData formData = FormData.fromMap({
        'title': event.title,
        'file': event.imageFile != null
            ? await MultipartFile.fromFile(
                event.imageFile.path,
                filename: event.imageFile.path.split('/').last,
                contentType: MediaType.parse('image/jpeg'),
              )
            : null,
      });

      Dio dio = Dio();
      final response = await dio.post(
        "$BASE_URI/shop/products/category/${currentStore.id}",
        options: Options(
          headers: {
            'Authorization': "Bearer ${user.authCode}",
            'contentType': 'multipart/form-data',
          },
        ),
        data: formData,
      );
      ResponseWrapper _wrapper = ResponseWrapper.fromJson(response.data);
      if (_wrapper.code == 200) {
        yield AddedProductCategoryStoreState();
      } else {
        yield ShowMessageStoreState(message: _wrapper.message);
        yield HasStoreStoreState();
      }
    }

    /// edit product category
    if (event is SubmitEditProductCategoryEvent) {
      yield LoadingStoreState();
//      FormData formData = FormData();
//      formData.fields.add(MapEntry('title', 'value'));
      FormData formData = FormData.fromMap({
        'title': event.title,
        'file': event.imageFile != null
            ? await MultipartFile.fromFile(
                event.imageFile.path,
                filename: event.imageFile.path.split('/').last,
                contentType: MediaType.parse('image/jpeg'),
              )
            : null,
      });
      Dio dio = Dio();
      final response = await dio.post(
        "$BASE_URI/shop/products/category/edit/${event.id}",
        options: Options(
          headers: {
            'Authorization': "Bearer ${user.authCode}",
            'contentType': 'multipart/form-data',
          },
        ),
        data: formData,
      );
//      print(response.data);
      ResponseWrapper _wrapper = ResponseWrapper.fromJson(response.data);
      if (_wrapper.code == 200) {
        yield EditedProductCategoryStoreState();
      } else {
        yield ShowMessageStoreState(message: _wrapper.message);
        yield HasStoreStoreState();
      }
    }

    /// accept order
    if (event is SubmitAcceptOrderEvent) {
      yield LoadingStoreState();
      yield AcceptedOrderStoreState();
    }

    /// decline order
    if (event is SubmitDeclineOrderEvent) {
      yield LoadingStoreState();
      yield DeclinedOrderStoreState();
    }

    /// add provider new notifs
    if (event is AddProviderNewNotifications) {
      yield LoadingStoreState();
      notifsCount = event.notifsCount;
      yield ProviderNewNotificationsChangedState();
    }

    /// seen provider new notifs
    if (event is SeenProviderNewNotifications) {
      yield LoadingStoreState();
      notifsCount = 0;
      yield ProviderNewNotificationsChangedState();
    }

    /// submit to get ordering
    if (event is SubmitGetOrderingStoreEvent) {
      yield LoadingStoreState();
      yield GotOrderingStoreState();
      yield HasStoreStoreState();
    }

    /// changed store site domain
    if (event is SubmitChangedStoreSiteDomainStoreEvent) {
      yield LoadingStoreState();
      yield ShowMessageStoreState(message: 'سایت شما با موفقیت تغییر یافت.');
      yield ChangedStoreSiteStoreState();
    }

    /// delete site banners
    if (event is SubmitDeleteBannersStoreEvent) {
      yield LoadingStoreState();

      Map<String, dynamic> postBody = new Map<String, dynamic>();
      postBody['resources'] = event.bannerUrls;

      await http.post(
        '$BASE_URI/delete/shop/personal/site/banners/${currentStore.id}',
        headers: _headers,
        body: jsonEncode(postBody),
      );

      yield ChangedStoreSiteStoreState();
    }
  }

  _getUserStores(Map<String, dynamic> _headers) async {
    final response = await http.get(
      '$BASE_URI/shop/locations',
      headers: _headers,
    );
    if (response.statusCode == 200) {
      _responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
      if (_responseWrapper.code == 200) {
        if (_responseWrapper.data != null &&
            (_responseWrapper.data as List).isNotEmpty) {
          stores.clear();
          (_responseWrapper.data as List).forEach((element) {
            stores.add(Store.fromJson(element));
          });
        }
      }
    }
  }

  _uploadProductImage(String _productId) async {
    imagesFiles.forEach((element) async {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          element.path,
          filename: element.path.split('/').last,
          contentType: MediaType.parse('image/jpeg'),
        ),
      });

      Dio dio = Dio();
      await dio.post(
        "$BASE_URI/shop/product/image/$_productId",
        options: Options(
          headers: {
            'Authorization': "Bearer ${user.authCode}",
            'contentType': 'multipart/form-data',
          },
        ),
        data: formData,
      );
      sleep(Duration(seconds: 1));
    });
    imagesFiles.clear();
  }

  _uploadNewStoreImage(String _shopId) async {
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
        contentType: MediaType.parse('image/jpeg'),
      ),
    });

    Dio dio = Dio();
    await dio.post(
      "$BASE_URI/shop/img/$_shopId",
      options: Options(
        headers: {
          'Authorization': "Bearer ${user.authCode}",
          'contentType': 'multipart/form-data',
        },
      ),
      data: formData,
    );
  }
}
