import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/customer_store_card.dart';
import 'package:idehshop/dialogs/store_info_dialog.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/models/product_category.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/routes/home_page/home_tabs/search_page.dart';
import 'package:idehshop/utils.dart';

class CustomerProductCategoryPage extends StatefulWidget {
  @override
  _CustomerProductCategoryPageState createState() =>
      _CustomerProductCategoryPageState();
}

class _CustomerProductCategoryPageState
    extends State<CustomerProductCategoryPage> {
  ShoppingBloc _shoppingBloc;
  Map<String, String> _headers = Map<String, String>();
  bool _loading = true;
  bool _loading2 = false;
  bool _hasMoreData = true;
  List<Product> _products = List();
  int _page = 1;
  ProductCategory _selectedProductCategory;
  CacheManager _cacheManager = CacheManager();
  BitmapDescriptor _mapIcon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);

      _headers = {
        'Authorization': "Bearer ${_shoppingBloc.authCode}",
      };
      _selectedProductCategory = _shoppingBloc.selectedProductCategory;
      setState(() {});
      _getProducts(REQUEST_TYPE.firstRequest);
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(
                size: Size(50, 50),
              ),
              'assets/images/store_icon.png')
          .then((d) {
        _mapIcon = d;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingBloc, ShoppingState>(
      listener: (context, state) {
        if (state is JwtExpiredShopState) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: Builder(builder: (context) {
              return InkWell(
                child: Stack(
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'assets/images/basket.png',
                        scale: 3,
                      ),
                      tooltip: 'خرید‌نهایی',
                      onPressed: null,
                    ),
                    (_shoppingBloc != null &&
                            _shoppingBloc.buyingProducts.length > 0)
                        ? Positioned(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.red,
                              ),
                              child: Text(
                                "${_shoppingBloc.buyingProducts.length}",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              alignment: Alignment.center,
                              height: 20,
                              width: 20,
                            ),
                            top: 10.0,
                            left: 10.0,
                          )
                        : Container(),
                  ],
                ),
                onTap: () => _basketClicked(context),
              );
            }),
            actions: [
              _shoppingBloc != null
                  ? IconButton(
                      icon: Icon(Icons.storefront),
                      onPressed: () {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StoreInfoDialog(
                              store: _shoppingBloc.selectedShop,
                              initialPosition: CameraPosition(
                                target: LatLng(
                                  double.parse(
                                      '${_shoppingBloc.selectedShop.lat}'),
                                  double.parse(
                                      '${_shoppingBloc.selectedShop.long}'),
                                ),
                                zoom: MAP_NORMAL_ZOOM,
                              ),
                              icon: _mapIcon,
                            );
                          },
                        );
                      })
                  : Container(),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () => _search(context),
              ),
            ],
            title: Text(
              _shoppingBloc != null
                  ? "${_shoppingBloc.selectedProductCategory.title}"
                  : '',
              style: Theme.of(context).textTheme.subtitle2.copyWith(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          body: !_loading
              ? _products.isNotEmpty
                  ? NotificationListener<ScrollNotification>(
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
                              onTap: () => _productCategorySelected(
                                  context, _products[index]),
                            );
                          }
                        },
                        itemCount: _loading2
                            ? (_products.length + 1)
                            : _products.length,
                      ),
                      onNotification: (ScrollNotification scrollInfo) {
                        if (_hasMoreData &&
                            !_loading2 &&
                            scrollInfo.metrics.extentAfter < 500) {
                          if (mounted) {
                            setState(() {
                              _loading2 = true;
                            });
                          }
                          _getProducts(REQUEST_TYPE.loadRequest)
                              .then((onValue) {
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
                      child: Container(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/without.png',
                              width: MediaQuery.of(context).size.width / 2,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('بزودی محصولات این فروشگاه اضافه خواهند شد.')
                          ],
                        ),
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 4),
                      ),
                    )
              : Center(
                  child: CircularProgressIndicator(),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => goToHomePage(context, 2),
            tooltip: 'خانه',
            child: Icon(
              Icons.home,
              size: 35,
              color: Colors.white,
            ),
            elevation: 2.0,
          ),
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            elevation: 15.0,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.list,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => goToHomePage(context, 4),
                    padding: EdgeInsets.all(0.0),
                    tooltip: 'فاکتورها',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.shopping_basket_outlined,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => goToHomePage(context, 3),
                    padding: EdgeInsets.all(0.0),
                    tooltip: 'سفارشات بازی',
                    iconSize: 25,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 5,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.favorite_outline,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => goToHomePage(context, 1),
                    padding: EdgeInsets.all(0.0),
                    tooltip: 'علاقه‌مندی‌ها',
                    iconSize: 25,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => goToHomePage(context, 0),
                    padding: EdgeInsets.all(0.0),
                    tooltip: 'تنظیمات',
                    iconSize: 25,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
      cubit: _shoppingBloc,
    );
  }


  _productCategorySelected(BuildContext context, Product p) {
    _shoppingBloc.selectedProduct = p;
    Navigator.pushNamed(context, '/customerProductPage');
  }

  _getProducts(REQUEST_TYPE _requestType) async {
    final response = await http.get(
      "$BASE_URI/shop/products/${_selectedProductCategory.id}/$_page",
      headers: _headers,
    );
    if (response.statusCode == 200) {
      ResponseWrapper responseWrapper = ResponseWrapper.fromJson(
        jsonDecode(response.body),
      );
      if (responseWrapper.code == 200) {
        if (_requestType == REQUEST_TYPE.firstRequest) {
          _products.clear();
          (responseWrapper.data as List).forEach((element) {
            _products.add(Product.fromJson(element));
          });
          if ((responseWrapper.data as List).length < 25) {
            _hasMoreData = false;
          }
          setState(() {
            _page++;
            _loading = false;
          });
        } else {
          final _data = responseWrapper.data;
          _page++;
          if (_data != null && (_data as List).isNotEmpty) {
            (responseWrapper.data as List).forEach((element) {
              _products.add(Product.fromJson(element));
            });
            if ((_data as List).length < 25) {
              _hasMoreData = false;
            }
          }
          setState(() {
            _loading = false;
            _loading2 = false;
          });
        }
      }
    } else {
      setState(() {
        _loading = false;
        _loading2 = false;
      });
    }
  }

  _search(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return SearchPage(
          hint: 'نام محصول',
          searchType: SEARCH_TYPE.productInStore,
          categoryId: _shoppingBloc.selectedShopKind.id,
        );
      },
    ));
  }
}
