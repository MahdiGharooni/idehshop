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


}
