import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/product_category_card.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/product_category.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_entities_tab/store_product_category_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_entities_tab/store_products_tab.dart';
import 'package:idehshop/utils.dart';

class StoreProductsCategoriesTab extends StatefulWidget {
  @override
  _StoreProductsCategoriesTabState createState() =>
      _StoreProductsCategoriesTabState();
}

class _StoreProductsCategoriesTabState
    extends State<StoreProductsCategoriesTab> {
  StoreBloc _storeBloc;
  List<ProductCategory> _productCategories = List();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _loading = true;
  bool _loading2 = false;
  bool _payLoading = false;
  int _page = 1;
  bool _hasMoreData = true;
  bool _userShouldPay = false;
  CacheManager _cacheManager = CacheManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _getProductCategories(REQUEST_TYPE.firstRequest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<StoreBloc, StoreState>(
        listener: (context, state) {
          if (_storeBloc == null || state is LoadingStoreState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is JwtExpiredPermissionState) {
            Navigator.pushReplacementNamed(context, '/login');
          }
          if (state is AddedNewProductStoreState ||
              state is EditedProductStoreState ||
              state is AddedProductCategoryStoreState ||
              state is EditedProductCategoryStoreState) {
            Fluttertoast.showToast(
              msg: 'درخواست شما ثبت گردید. لطفا منتظر تایید ادمین باشید.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 16.0,
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
            );
            setState(() {
              _loading = true;
              _page = 1;
              _productCategories.clear();
            });
            _getProductCategories(REQUEST_TYPE.firstRequest);
            setState(() {
              _loading = false;
            });
          }
          if (state is DeletedProductStoreState) {
            Fluttertoast.showToast(
              msg: 'محصول شما با موفقیت حذف گردید.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 16.0,
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            child: _userShouldPay
                ? Center(
                    child: Container(
                      child: Column(
                        children: [
                          Text(
                              'اشتراک شما به اتمام رسیده است. لطفا اشتراک ویژه تهیه نمایید.'),
                          SizedBox(
                            height: 10,
                          ),
                          FilterChip(
                            label: _payLoading
                                ? Container(
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                    width: 50,
                                  )
                                : Text(
                                    'خرید اشتراک',
                                  ),
                            padding: EdgeInsets.all(0.0),
                            avatar: Icon(
                              Icons.attach_money,
                              color: Colors.white,
                              size: 20,
                            ),
                            onSelected: (value) =>
                                Navigator.of(context).pushNamed('/storePay'),
                            backgroundColor: Colors.green,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(15),
                    ),
                  )
                : (_storeBloc == null || _loading)
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : NotificationListener<ScrollNotification>(
                        child: _productCategories.isEmpty
                            ? Center(
                                child:
                                    Text('شما هنوز دسته بندی اضافه نکرده اید'),
                              )
                            : ListView.builder(
                                itemBuilder: (context, index) {
                                  return (_loading2 &&
                                          index == _productCategories.length)
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : InkWell(
                                          child: ProductCategoryCard(
                                            productCategory:
                                                _productCategories[index],
                                            cacheManager: _cacheManager,
                                            role: Role.provider,
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                return StoreProductsTab(
                                                  productCategory:
                                                      _productCategories[index],
                                                );
                                              }),
                                            );
                                          },
                                        );
                                },
                                itemCount: _loading2
                                    ? (_productCategories.length + 1)
                                    : _productCategories.length,
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
                            _getProductCategories(REQUEST_TYPE.loadRequest)
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
                      ),
            onRefresh: _onRefresh,
          );
        },
        cubit: _storeBloc,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProductCategory,
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text(
          'اضافه کردن دسته بندی',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      key: _key,
    );
  }

  _addProductCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreProductCategoryPage(
          key: Key('add'),
          type: TYPE.create,
        ),
      ),
    );
  }

  Future<void> _getProductCategories(REQUEST_TYPE _type) async {
    final Map<String, String> _headers = {
      'Authorization': "Bearer ${_storeBloc.user.authCode}",
    };
    final response = await http.get(
      '$BASE_URI/shop/products/categories/${_storeBloc.currentStore.id}/$_page',
      headers: _headers,
    );
    ResponseWrapper responseWrapper = ResponseWrapper.fromJson(
      jsonDecode(response.body),
    );
    if (response.statusCode == 200 && responseWrapper.code == 200) {
      if (_type == REQUEST_TYPE.firstRequest) {
        final _data = responseWrapper.data;
        _page++;
        _productCategories.clear();
        _storeBloc.products.clear();
        if (_data != null && (_data as List).isNotEmpty) {
          (_data as List).forEach((element) {
            _productCategories.add(ProductCategory.fromJson(element));
            _storeBloc.productsCategories
                .add(ProductCategory.fromJson(element));
          });
          if ((_data as List).length < 25) {
            _hasMoreData = false;
          }
        }
        _storeBloc.add(EnterIntoStabilityState());
        setState(() {
          _loading = false;
        });
      } else {
        final _data = responseWrapper.data;
        _page++;
        if (_data != null && (_data as List).isNotEmpty) {
          (_data as List).forEach((element) {
            _productCategories.add(ProductCategory.fromJson(element));
            _storeBloc.productsCategories
                .add(ProductCategory.fromJson(element));
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
    } else if (response.statusCode == 403 &&
        (responseWrapper.message.contains('pay application cost please') ||
            responseWrapper.message.contains('پرداخت'))) {
      /// provider should pay

      _loading = false;
      _userShouldPay = true;
    }

    setState(() {});
  }

  Future<dynamic> _onRefresh() async {
    setState(() {
      _loading = true;
      _page = 1;
      _productCategories.clear();
    });
    await _getProductCategories(REQUEST_TYPE.firstRequest);
    setState(() {
      _loading = false;
    });
    return '';
  }
}
