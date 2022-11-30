import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/product_category_card.dart';
import 'package:idehshop/dialogs/store_info_dialog.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/product_category.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/routes/home_page/home_tabs/search_page.dart';
import 'package:idehshop/utils.dart';

class CustomerStorePage extends StatefulWidget {
  @override
  _CustomerStorePageState createState() => _CustomerStorePageState();
}

class _CustomerStorePageState extends State<CustomerStorePage> {
  ShoppingBloc _shoppingBloc;
  Map<String, String> _headers = Map<String, String>();
  bool _loading = true;
  bool _loading2 = false;
  bool _hasMoreData = true;
  List<ProductCategory> _productsCategories = List();
  int _page = 1;
  Store _selectedShop;
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
      _selectedShop = _shoppingBloc.selectedShop;
      setState(() {});
      _getShopProductCategories(REQUEST_TYPE.firstRequest);

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
                  ? "${_shoppingBloc.selectedShop.title}"
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
              ? _productsCategories.isNotEmpty
                  ? NotificationListener<ScrollNotification>(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          if (_loading2 &&
                              index == _productsCategories.length) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return InkWell(
                              child: Container(
                                child: ProductCategoryCard(
                                  productCategory: _productsCategories[index],
                                  cacheManager: _cacheManager,
                                  role: Role.customer,
                                ),
                                height: 110,
                              ),
                              onTap: () => _productCategorySelected(
                                  context, _productsCategories[index]),
                            );
                          }
                        },
                        itemCount: _loading2
                            ? (_productsCategories.length + 1)
                            : _productsCategories.length,
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
                          _getShopProductCategories(REQUEST_TYPE.loadRequest)
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
                      child: Text(
                          'هنوز دسته بندی برای این فروشگاه قرار نگرفته است'),
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

  _basketClicked(BuildContext context) {
    if (_shoppingBloc.buyingProducts.length == 0) {
      Fluttertoast.showToast(
        msg: "سبد خرید شما خالی است.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
      );
    } else {
      Navigator.pushNamed(context, '/buying');
    }
  }

  _productCategorySelected(BuildContext context, ProductCategory pc) {
    _shoppingBloc.selectedProductCategory = pc;
    Navigator.pushNamed(context, '/customerProductCategoryPage');
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
