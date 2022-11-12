import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/customer_store_card.dart';
import 'package:idehshop/cards/search_product_store_card.dart';
import 'package:idehshop/cards/search_shop_card.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/models/product_and_store_info.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/utils.dart';

class SearchPage extends StatefulWidget {
  final String hint;
  final SEARCH_TYPE searchType;
  final String categoryId;

  SearchPage({
    @required this.hint,
    @required this.searchType,
    this.categoryId,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _editingController = TextEditingController();
  bool _searchingLoading = false;
  bool _loading2 = false;
  bool _hasMoreDataShops = true;
  ShoppingBloc _shoppingBloc;
  PermissionBloc _permissionBloc;
  List<Product> _products = List();
  List<ProductAndStoreInfo> _productAndStoreList = List();
  List<Store> _stores = List();
  CacheManager _cacheManager = CacheManager();
  String _value;
  int _page = 1;
  ScrollController _scrollController = ScrollController();
  SEARCH_ITEM _searchItem = SEARCH_ITEM.product;
  String _whereValue = WHERE_NEAR;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
      _permissionBloc = BlocProvider.of<PermissionBloc>(context);
      _scrollController.addListener(() {
        if (_scrollController.offset > 1) {
          FocusScope.of(context).unfocus();
        }
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          cursorColor: Colors.black,
          keyboardType: TextInputType.text,
          controller: _editingController,
          autofocus: true,
          onChanged: (v) {
            setState(() {
              _value = v;
              _hasMoreDataShops = true;
              _page = 1;
            });
          },
          decoration: InputDecoration(
            hintText: widget.hint,
          ),
        ),
        actions: [
          Container(
            child: RaisedButton(
              child: Text(
                'جستجو',
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () => (_value != null && _value != '')
                  ? {
                      _page = 1,
                      FocusScope.of(context).unfocus(),
                      _search(REQUEST_TYPE.firstRequest),
                    }
                  : null,
            ),
            // padding: EdgeInsets.all(5),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          ),
        ],
        titleSpacing: 1,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: widget.searchType == SEARCH_TYPE.productInNearStores
              ? const Size.fromHeight(80.0)
              : const Size.fromHeight(30.0),
          child: Theme(
            data: Theme.of(context).copyWith(accentColor: Colors.white),
            child: Column(
              children: [
                widget.searchType == SEARCH_TYPE.productInNearStores
                    ? Row(
                        children: [
                          // Icon(Icons.filter_alt),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'جستجو در',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      _searchItem == SEARCH_ITEM.product
                                          ? 'محصولات'
                                          : 'فروشگاه‌ها',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                PopupMenuButton(
                                  tooltip: 'جستجوی در',
                                  child: Icon(
                                    Icons.category,
                                  ),
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuItem<String>>[
                                      PopupMenuItem<String>(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                'محصولات',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              child: Icon(
                                                _searchItem ==
                                                        SEARCH_ITEM.product
                                                    ? Icons.check_circle
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color: _searchItem ==
                                                        SEARCH_ITEM.product
                                                    ? Colors.green
                                                    : Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                size: 24.0,
                                              ),
                                              height: 24.0,
                                              width: 24.0,
                                            )
                                          ],
                                        ),
                                        value: '${SEARCH_ITEM.product}',
                                      ),
                                      PopupMenuItem<String>(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                'فروشگاه‌ها',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              child: Icon(
                                                _searchItem == SEARCH_ITEM.shop
                                                    ? Icons.check_circle
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color: _searchItem ==
                                                        SEARCH_ITEM.shop
                                                    ? Colors.green
                                                    : Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                size: 24.0,
                                              ),
                                              height: 24.0,
                                              width: 24.0,
                                            )
                                          ],
                                        ),
                                        value: '${SEARCH_ITEM.shop}',
                                      ),
                                    ];
                                  },
                                  onSelected: (String value) {
                                    if (value == '${SEARCH_ITEM.product}') {
                                      _searchItem = SEARCH_ITEM.product;
                                    } else {
                                      _searchItem = SEARCH_ITEM.shop;
                                    }
                                    setState(() {
                                      _page = 1;
                                      _hasMoreDataShops = true;
                                    });
                                    if (_value != null && _value != '') {
                                      _search(REQUEST_TYPE.firstRequest);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: Colors.black45,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'محدوده',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      _whereValue == WHERE_NEAR
                                          ? 'محله'
                                          : _whereValue == WHERE_CITY
                                              ? 'شهر'
                                              : _whereValue == WHERE_STATE
                                                  ? 'استان'
                                                  : _whereValue == WHERE_COUNTRY
                                                      ? 'کشور'
                                                      : _whereValue,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                PopupMenuButton(
                                  tooltip: 'محدوده',
                                  child: Icon(
                                    Icons.filter_alt,
                                  ),
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuItem<String>>[
                                      PopupMenuItem<String>(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                'محله',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              child: Icon(
                                                _whereValue == WHERE_NEAR
                                                    ? Icons.check_circle
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color: _whereValue == WHERE_NEAR
                                                    ? Colors.green
                                                    : Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                size: 24.0,
                                              ),
                                              height: 24.0,
                                              width: 24.0,
                                            )
                                          ],
                                        ),
                                        value: WHERE_NEAR,
                                      ),
                                      PopupMenuItem<String>(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                'شهر',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              child: Icon(
                                                _whereValue == WHERE_CITY
                                                    ? Icons.check_circle
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color: _whereValue == WHERE_CITY
                                                    ? Colors.green
                                                    : Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                size: 24.0,
                                              ),
                                              height: 24.0,
                                              width: 24.0,
                                            )
                                          ],
                                        ),
                                        value: WHERE_CITY,
                                      ),
                                      PopupMenuItem<String>(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                'استان',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              child: Icon(
                                                _whereValue == WHERE_STATE
                                                    ? Icons.check_circle
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color:
                                                    _whereValue == WHERE_STATE
                                                        ? Colors.green
                                                        : Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                size: 24.0,
                                              ),
                                              height: 24.0,
                                              width: 24.0,
                                            )
                                          ],
                                        ),
                                        value: WHERE_STATE,
                                      ),
                                      PopupMenuItem<String>(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                'کشور',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              child: Icon(
                                                _whereValue == WHERE_COUNTRY
                                                    ? Icons.check_circle
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color:
                                                    _whereValue == WHERE_COUNTRY
                                                        ? Colors.green
                                                        : Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                size: 24.0,
                                              ),
                                              height: 24.0,
                                              width: 24.0,
                                            )
                                          ],
                                        ),
                                        value: WHERE_COUNTRY,
                                      ),
                                    ];
                                  },
                                  onSelected: (String value) {
                                    _whereValue = value;
                                    setState(() {
                                      _page = 1;
                                      _hasMoreDataShops = true;
                                    });
                                    if (_value != null && _value != '') {
                                      _search(REQUEST_TYPE.firstRequest);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      )
                    : Container(),
                Container(
                  height: 35.0,
                  alignment: Alignment.center,
                  color: Colors.blue[100],
                  child: InkWell(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.location_on),
                        Expanded(
                          child: Text(
                            (_permissionBloc != null &&
                                    _permissionBloc.selectedAddress != null)
                                ? '${_permissionBloc.selectedAddress.address ?? ''}'
                                : '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                    onTap: () => Navigator.pushReplacementNamed(
                        context, '/addressesList'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _searchingLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _products.isNotEmpty
              ? NotificationListener(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      if (_loading2 && index == _products.length) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return InkWell(
                          child: Container(
                            child: CustomerProductCard(
                              product: _products[index],
                              cacheManager: _cacheManager,
                              shoppingBloc: _shoppingBloc,
                            ),
                            height: 110,
                          ),
                          onTap: () {
                            _shoppingBloc.selectedProduct = _products[index];
                            Navigator.pushNamed(
                                context, '/customerProductPage');
                          },
                        );
                      }
                    },
                    controller: _scrollController,
                    itemCount:
                        _loading2 ? (_products.length + 1) : _products.length,
                  ),
                  onNotification: (ScrollNotification scrollInfo) {
                    if (_hasMoreDataShops &&
                        !_loading2 &&
                        scrollInfo.metrics.extentAfter < 500) {
                      if (mounted) {
                        setState(() {
                          _loading2 = true;
                        });
                      }
                      _search(REQUEST_TYPE.loadRequest).then((onValue) {
                        if (mounted) {
                          setState(() {
                            _loading2 = false;
                          });
                        }
                      });
                    }
                    return _loading2;
                  },
                )
              : _productAndStoreList.isNotEmpty
                  ? NotificationListener(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          if (_loading2 &&
                              index == _productAndStoreList.length) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            Store _store = Store.fromProductStoreInfo(
                                _productAndStoreList[index]);
                            return InkWell(
                              child: Container(
                                child: SearchProductStoreCard(
                                  productAndStoreInfo:
                                      _productAndStoreList[index],
                                  cacheManager: _cacheManager,
                                  isOpen: isStoreOpen(
                                    _store,
                                  ),
                                ),
                                height: 130,
                              ),
                              onTap: () => isStoreOpen(_store)
                                  ? _productStoreInfoCardSelected(
                                      context, _productAndStoreList[index])
                                  : _checkPreOrder(context, _store,
                                      _productAndStoreList[index]),
                              // _productStoreInfoCardSelected(
                              // context, _productAndStoreList[index]),
                            );
                          }
                        },
                        controller: _scrollController,
                        itemCount: _loading2
                            ? (_productAndStoreList.length + 1)
                            : _productAndStoreList.length,
                      ),
                      onNotification: (ScrollNotification scrollInfo) {
                        if (_hasMoreDataShops &&
                            !_loading2 &&
                            scrollInfo.metrics.extentAfter < 500) {
                          if (mounted) {
                            setState(() {
                              _loading2 = true;
                            });
                          }
                          _search(REQUEST_TYPE.loadRequest).then((onValue) {
                            if (mounted) {
                              setState(() {
                                _loading2 = false;
                              });
                            }
                          });
                        }
                        return _loading2;
                      },
                    )
                  : (_stores.isNotEmpty && _searchItem == SEARCH_ITEM.shop)
                      ? NotificationListener(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              if (_loading2 && index == _stores.length) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return InkWell(
                                  child: Container(
                                    child: SearchShopCard(
                                      store: _stores[index],
                                      cacheManager: _cacheManager,
                                      isOpen: isStoreOpen(_stores[index]),
                                    ),
                                    height: 110,
                                  ),
                                  onTap: () => isStoreOpen(_stores[index])
                                      ? _shopSelected(context, _stores[index])
                                      : _checkPreOrder(context, _stores[index]),
                                );
                              }
                            },
                            controller: _scrollController,
                            itemCount: _loading2
                                ? (_stores.length + 1)
                                : _stores.length,
                          ),
                          onNotification: (ScrollNotification scrollInfo) {
                            if (_hasMoreDataShops &&
                                !_loading2 &&
                                scrollInfo.metrics.extentAfter < 500) {
                              if (mounted) {
                                setState(() {
                                  _loading2 = true;
                                });
                              }
                              _search(REQUEST_TYPE.loadRequest).then((onValue) {
                                if (mounted) {
                                  setState(() {
                                    _loading2 = false;
                                  });
                                }
                              });
                            }
                            return _loading2;
                          },
                        )
                      : Center(
                          child: Text('موردی یافت نشد'),
                        ),
    );
  }

  _productStoreInfoCardSelected(BuildContext context, ProductAndStoreInfo _p) {
    _shoppingBloc.selectedProduct = Product(
        id: _p.id,
        title: _p.title,
        price: _p.price,
        offPrice: _p.offPrice,
        imageAddresses: _p.imageAddresses,
        measurement: _p.measurement,
        measurementIndex: _p.measurementIndex);

    if (_shoppingBloc.buyingProducts.isNotEmpty &&
        _shoppingBloc.selectedShop != null &&
        "${_shoppingBloc.selectedShop.title}" != "${_p.shopTitle}") {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'تغییر فروشگاه',
              textAlign: TextAlign.right,
            ),
            content: Text(
              'با تغییر فروشگاه، اقلام خریداری شده حذف میشوند',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.right,
            ),
            actions: [
              FlatButton(
                child: Text(
                  'کالای های قبلی حذف شوند',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () {
                  _shoppingBloc.buyingProducts.clear();
                  _shoppingBloc.finalBuyingMeasurementIndexes.clear();
                  _shoppingBloc.selectedShop = Store.fromProductStoreInfo(_p);
                  _shoppingBloc
                      .add(SetNewShopAsSelectedShopEvent(shopId: _p.id));
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/customerProductPage');
                },
              ),
              FlatButton(
                child: Text(
                  'ادامه خرید',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            actionsPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
          );
        },
      );
    } else {
      _shoppingBloc.selectedShop = Store(title: _p.shopTitle);
      _shoppingBloc.add(SetNewShopAsSelectedShopEvent(shopId: _p.id));
      Navigator.pushNamed(context, '/customerProductPage');
    }
  }

  _search(REQUEST_TYPE _requestType) async {
    if (_requestType == REQUEST_TYPE.firstRequest) {
      setState(() {
        _searchingLoading = true;
      });
    }
    String _url = '';
    var res;

    /// search product in a shop
    if (widget.searchType == SEARCH_TYPE.productInStore) {
      _url =
      '$BASE_URI/shop/product/search/${_shoppingBloc.selectedShop.id}?title=$_value';
      res = await http.get(
        _url,
        headers: {
          'Authorization': "Bearer ${_shoppingBloc.authCode}",
        },
      );

      /// search a shop by title in near
      /// todo : add category id
    } else if (widget.searchType == SEARCH_TYPE.productInNearStores &&
        _searchItem == SEARCH_ITEM.shop) {
      _url =
      '$BASE_URI/shop/search/${_permissionBloc.selectedAddress.id}/$_page?title=$_value&where=$_whereValue';
      if (widget.categoryId != null && widget.categoryId != '') {
        _url += '&categoryId=${widget.categoryId}';
      }
      res = await http.get(
        _url,
        headers: {
          'Authorization': "Bearer ${_shoppingBloc.authCode}",
        },
        // body: jsonEncode(
        //     {"sortByScore": _searchOrder == SEARCH_ORDER.score ? true : false}),
      );

      /// search product in shops
    } else if (widget.searchType == SEARCH_TYPE.productInNearStores) {
      _url =
      '$BASE_URI/product/search/${_permissionBloc.selectedAddress.id}/$_page?title=$_value&where=$_whereValue';
      if (widget.categoryId != null && widget.categoryId != '') {
        _url += '&categoryId=${widget.categoryId}';
      }
      res = await http.get(
        _url,
        headers: {
          'Authorization': "Bearer ${_shoppingBloc.authCode}",
        },
        // body: jsonEncode(
        //     {"sortByScore": _searchOrder == SEARCH_ORDER.score ? true : false}),
      );
    }
    ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
    if (res.statusCode == 200 && _requestType == REQUEST_TYPE.firstRequest) {
      setState(() {
        _page++;
        _searchingLoading = true;
        _products.clear();
        _productAndStoreList.clear();
        _stores.clear();
      });
      if ((wrapper.data as List).length < 25) {
        _hasMoreDataShops = false;
      }
      if (widget.searchType == SEARCH_TYPE.productInStore) {
        if (wrapper.data != null && wrapper.data is List) {
          wrapper.data.forEach((element) {
            _products.add(Product.fromJson(element));
          });
        }
      } else if (widget.searchType == SEARCH_TYPE.productInNearStores &&
          _searchItem == SEARCH_ITEM.shop) {
        if (wrapper.data != null && wrapper.data is List) {
          wrapper.data.forEach((element) {
            _stores.add(Store.fromJson(element));
          });
        }
      } else if (widget.searchType == SEARCH_TYPE.productInNearStores) {
        if (wrapper.data != null && wrapper.data is List) {
          wrapper.data.forEach((element) {
            _productAndStoreList.add(ProductAndStoreInfo.fromJson(element));
          });
        }
      }
      setState(() {
        _searchingLoading = false;
      });

      ///
    } else if (_requestType == REQUEST_TYPE.loadRequest) {
      if (widget.searchType == SEARCH_TYPE.productInStore) {
        if (wrapper.data != null && wrapper.data is List) {
          wrapper.data.forEach((element) {
            _products.add(Product.fromJson(element));
          });
        }
      } else if (widget.searchType == SEARCH_TYPE.productInNearStores &&
          _searchItem == SEARCH_ITEM.shop) {
        if (wrapper.data != null && wrapper.data is List) {
          wrapper.data.forEach((element) {
            _stores.add(Store.fromJson(element));
          });
        }
      } else if (widget.searchType == SEARCH_TYPE.productInNearStores) {
        if (wrapper.data != null && wrapper.data is List) {
          wrapper.data.forEach((element) {
            _productAndStoreList.add(ProductAndStoreInfo.fromJson(element));
          });
        }
      }
      if ((wrapper.data as List).length < 25) {
        _hasMoreDataShops = false;
      }
      setState(() {
        _page++;
        _loading2 = false;
      });
    } else {
      setState(() {
        _searchingLoading = false;
      });
    }
  }

  _shopSelected(BuildContext context, Store _selectedShop) {
    if (_shoppingBloc.buyingProducts.isNotEmpty &&
        ("${_shoppingBloc.selectedShop.id}" != "${_selectedShop.id}" &&
            _shoppingBloc.selectedShop.title != _selectedShop.title)) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'تغییر فروشگاه',
              textAlign: TextAlign.right,
            ),
            content: Text(
              'با تغییر فروشگاه، اقلام خریداری شده حذف میشوند',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.right,
            ),
            actions: [
              FlatButton(
                child: Text(
                  'کالای های قبلی حذف شوند',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () {
                  _shoppingBloc.buyingProducts.clear();
                  _shoppingBloc.finalBuyingMeasurementIndexes.clear();
                  _shoppingBloc.selectedShop = _selectedShop;
                  _shoppingBloc.add(
                      SetNewShopAsSelectedShopEvent(shopId: _selectedShop.id));
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/customerStorePage');
                },
              ),
              FlatButton(
                child: Text(
                  'ادامه خرید',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            actionsPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
          );
        },
      );
    } else {
      _shoppingBloc.selectedShop = _selectedShop;
      _shoppingBloc
          .add(SetNewShopAsSelectedShopEvent(shopId: _selectedShop.id));
      Navigator.pushNamed(context, '/customerStorePage');
    }
  }

  _checkPreOrder(BuildContext context, Store _store,
      [ProductAndStoreInfo _productStoreInfo]) {
    if (_store.hasPreOrder) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'پیش سفارش',
              textAlign: TextAlign.right,
            ),
            content: Text(
              'این فروشگاه قابلیت پیش سفارش دارد و شما میتوانید هم اکنون سفارش خود را ثبت کرده ولی در ساعت کاری فروشگاه آنرا تحویل بگیرید.',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.right,
            ),
            actions: [
              FlatButton(
                child: Text(
                  'ثبت پیش سفارش',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (_productStoreInfo != null) {
                    _productStoreInfoCardSelected(context, _productStoreInfo);
                  } else {
                    _shopSelected(context, _store);
                  }
                },
              ),
              FlatButton(
                child: Text(
                  'خیر',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            actionsPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
          );
        },
      );
    }
  }
}
