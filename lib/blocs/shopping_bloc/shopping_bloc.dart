import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/models/product_category.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/shop_kind.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/utils.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  List<ShopKind> shopKinds = [];
  final AuthenticationBloc authenticationBloc;
  PermissionBloc permissionBloc;
  String authCode;
  bool hasMoreShopKinds = true;
  ResponseWrapper responseWrapper;
  ShopKind selectedShopKind;
  Product selectedProduct;
  ProductCategory selectedProductCategory;
  Store selectedShop;
  int _getNearShopsAsSelectedShopKindPage = 1;
  List<Store> stores = List();
  List<Product> buyingProducts = List();
  List<String> finalBuyingMeasurementIndexes = List();
  List<Map<String, dynamic>> buyingProductsInfo = List();
  int customerNewNotificationsCount = 0;

  ShoppingBloc({@required this.authenticationBloc}) : super(null);

  ShoppingState get initialState => UninitializedShoppingState();

  @override
  Stream<ShoppingState> mapEventToState(ShoppingEvent event) async* {
    final Map<String, String> _headers = {
      'Authorization': "Bearer $authCode",
    };

    /// getting all shoKinds
    if (event is SubmitAllShopKinds) {
      yield LoadingShoppingState();

      if (authenticationBloc.user.authCode != null) {
        authCode = authenticationBloc.user.authCode;

        String url = '$BASE_URI/shop/kinds/1?limit=100';
        final response = await http.get(
          url,
          headers: {
            'Authorization': "Bearer $authCode",
          },
        );
        responseWrapper = ResponseWrapper.fromJson(jsonDecode(response.body));
        if (response.statusCode == 200) {
          if (responseWrapper.code == 200) {
            shopKinds.clear();
            (responseWrapper.data as List<dynamic>).forEach((element) {
              shopKinds.add(
                ShopKind.fromJson(element),
              );
            });
            yield GotAllShopKindsShoppingState(shopKinds: shopKinds);
          } else {}
        } else if (response.statusCode == 401 ||
            response.statusCode == 531 ||
            responseWrapper.message.contains('jwt expired')) {
          yield JwtExpiredShopState();
        }
      }
    }

    /// getting shops as shopKind
    if (event is SubmitGetShopsAsSelectedShopKind) {
      stores.clear();
      final response = await http.post(
        "$BASE_URI/shops/near/${event.locationId}/$_getNearShopsAsSelectedShopKindPage?kind=${selectedShopKind.kind}",
        headers: _headers,
        body: jsonEncode({"sortByScore": true}),
      );
      if (response.statusCode == 200) {
        responseWrapper = ResponseWrapper.fromJson(
          jsonDecode(response.body),
        );
        if (responseWrapper.code == 200) {
          (responseWrapper.data as List).forEach((element) {
            stores.add(
              Store(
                id: element['id'],
                kind: element['kind'],
                title: element['title'],
                imageAddress: element['imageAddress'],
                score: element['score'] ?? 0,
                lat: null,
                long: null,
              ),
            );
          });
          yield GotShopsAsSelectedShopKind();
        } else if (response.statusCode == 401 || response.statusCode == 531) {
          yield JwtExpiredShopState();
        }
      }
    }

    /// add product to basket
    if (event is SubmitNewProductToBasketShopEvent) {
      yield LoadingShoppingState();
      int _index = -1;
      buyingProducts.asMap().forEach((index, element) {
        if (element.id == event.product.id) {
          finalBuyingMeasurementIndexes[index] =
              "${event.measurementIndex ?? '0'}";
          _index = index;
        }
      });

      /// add product to list
      if (_index == -1) {
        buyingProducts.add(event.product);
        finalBuyingMeasurementIndexes.add("${event.measurementIndex ?? '0'}");
      }

      /// remove product if it doesn't exist
      if (_index > -1 && "${event.measurementIndex}" == '0') {
        buyingProducts.removeAt(_index);
        finalBuyingMeasurementIndexes.removeAt(_index);
      }

      yield AddedNewProductShopState(
          product: event.product, measurementIndex: event.measurementIndex);
    }

    /// delete product from basket
    if (event is DeleteProductFromBasketShopEvent) {
      yield LoadingShoppingState();
      int _deletedIndex; // index of product & its measurementIndex
      buyingProducts.asMap().forEach((index, value) {
        if ('${value.id}' == '${event.product.id}') {
          // we can modify buying Products list while foreach
          _deletedIndex = index;
        }
      });
      if (_deletedIndex != null) {
        buyingProducts.removeAt(_deletedIndex);
        finalBuyingMeasurementIndexes.removeAt(_deletedIndex);
      }
      buyingProductsInfo.asMap().forEach((index, value) {
        if ('${value[PRODUCT_ID]}' == '${event.product.id}') {
          value[PRODUCT_DESCRIPTION] = '';
        }
      });
      yield DeletedProductFromBasketShopState();
    }

    /// final order
    if (event is SubmitFinalOrderShopEvent) {
      yield LoadingShoppingState();
      List<Map<String, dynamic>> _finalList = List();
      buyingProducts.asMap().forEach((index, value) {
        Map<String, dynamic> _map = Map();
        _map['productId'] = '${value.id}';
        _map['number'] = '${finalBuyingMeasurementIndexes[index]}';

        // get product description
        buyingProductsInfo.forEach((element) {
          if (element.containsKey(PRODUCT_ID) &&
              element[PRODUCT_ID] == '${value.id}') {
            _map['description'] = element[PRODUCT_DESCRIPTION] ?? '';
          }
        });
        _finalList.add(_map);
      });
      Map<String, dynamic> _body = {
        'shopId': "${selectedShop.id}",
        'payFromWallet': event.payFromWallet,
        'products': _finalList,
      };
      if (event.offCode != null) {
        _body['offCode'] = event.offCode;
      }

      final res = await http.post(
        "$BASE_URI/order/${permissionBloc.selectedAddress.id}",
        headers: _headers,
        body: jsonEncode(_body),
      );
      if (res.statusCode == 200) {
        responseWrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
        if (responseWrapper.code == 200) {
          buyingProducts.clear();
          finalBuyingMeasurementIndexes.clear();
          yield SentNewOrderShopState(orderId: responseWrapper.data['id']);
        }
      } else if (res.statusCode == 401 || res.statusCode == 531) {
        yield JwtExpiredShopState();
      }
//      selectedProduct = null;
//      selectedShop = null;
//      selectedShopKind = null;
//      yield SentNewOrderShopState();
    }

    /// add shop rate
    if (event is AddShopRateShopEvent) {
      yield LoadingShoppingState();
      final response = await http.post(
        "$BASE_URI/shop/rate/${event.orderId}",
        headers: _headers,
        body: jsonEncode({'score': event.score}),
      );
//      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        responseWrapper = ResponseWrapper.fromJson(
          jsonDecode(response.body),
        );
        if (responseWrapper.code == 200) {
          yield AddedShopRateShopState();
        } else if (response.statusCode == 401 || response.statusCode == 531) {
          yield JwtExpiredShopState();
        }
      }
      yield AddedShopRateShopState();
    }

    /// add customer new notifs
    if (event is AddCustomerNewNotifications) {
      yield LoadingShoppingState();
      customerNewNotificationsCount = event.notifs;
      yield CustomerNewNotificationsChangedState();
    }

    /// seen customer new notifs
    if (event is SeenCustomerNewNotifications) {
      yield LoadingShoppingState();
      customerNewNotificationsCount = 0;
      yield CustomerNewNotificationsChangedState();
    }

    /// add product info list
    if (event is AddProductInfoToListShopEvent) {
      Map<String, dynamic> _map = Map();
      buyingProductsInfo.forEach((element) {
        if (element.containsKey(PRODUCT_ID) &&
            element[PRODUCT_ID] == event.productId) {
          element[PRODUCT_DESCRIPTION] = event.description ?? '';
          _map = element;
        }
      });

      // add new description
      if (_map.isEmpty &&
          !_map.containsKey(PRODUCT_ID) &&
          event.description.length > 0) {
        _map[PRODUCT_ID] = event.productId;
        _map[PRODUCT_DESCRIPTION] = event.description;
        buyingProductsInfo.add(_map);
      }

      yield BuyingProductInfoChangedState();
    }

    /// empty basket
    if (event is SubmitToEmptyBasketShoppingEvent) {
      yield LoadingShoppingState();
      buyingProducts.clear();
      finalBuyingMeasurementIndexes.clear();
      buyingProductsInfo.clear();
      selectedShopKind = null;
      yield BuyingProductInfoChangedState();
    }

    /// set a new shop as selectedShop
    if (event is SetNewShopAsSelectedShopEvent) {
      yield LoadingShoppingState();
      final res = await http.get(
        '$BASE_URI/shop/info/${event.shopId}',
        headers: {
          'Authorization': "Bearer $authCode",
        },
      );

      Store _store;
      if (res.statusCode == 200) {
        ResponseWrapper wrapper =
            ResponseWrapper.fromJson(jsonDecode(res.body));
        if (wrapper.code == 200) {
          _store = Store.fromJson(wrapper.data);
          selectedShop = _store;
          yield SetNewSelectedShopState(store: _store);
        } else {
          yield UninitializedShoppingState();
        }
      }
    }
  }
}
