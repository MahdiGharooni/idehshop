import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/store_product_card.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/models/product_category.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_entities_tab/store_product_category_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_entities_tab/store_product_page.dart';
import 'package:idehshop/utils.dart';

class StoreProductsTab extends StatefulWidget {
  final ProductCategory productCategory;

  StoreProductsTab({@required this.productCategory});

  @override
  _StoreProductsTabState createState() => _StoreProductsTabState();
}

class _StoreProductsTabState extends State<StoreProductsTab> {
  StoreBloc _storeBloc;
  List<Product> _products = List();
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
      _getAllProducts(REQUEST_TYPE.firstRequest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' محصولات ${widget.productCategory.title}',
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return StoreProductCategoryPage(
                  type: TYPE.edit,
                  productCategory: widget.productCategory,
                  key: Key(
                    'EDIT${widget.productCategory}',
                  ),
                );
              }),
            ),
          ),
        ],
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
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
              state is EditedProductStoreState) {
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
              _products.clear();
            });
            _getAllProducts(REQUEST_TYPE.firstRequest);
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
                        child: _products.isEmpty
                            ? Center(
                                child: Text('شما هنوز محصولی اضافه نکرده اید'),
                              )
                            : GridView.builder(
                                itemBuilder: (context, index) {
                                  if (_loading2 && index == _products.length) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    return StoreProductCard(
                                      product: _products[index],
                                      key: Key("${_products[index]}"),
                                      cacheManager: _cacheManager,
                                      productCategory: widget.productCategory,
                                    );
                                  }
                                },
                                itemCount: _loading2
                                    ? (_products.length + 1)
                                    : _products.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 5.0,
                                  crossAxisSpacing: 5.0,
                                ),
                                scrollDirection: Axis.vertical,
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
                            _getAllProducts(REQUEST_TYPE.loadRequest)
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text(
          'اضافه کردن محصول',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  _addProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreProductPage(
          type: TYPE.create,
          key: Key('addProduct'),
          productCategory: widget.productCategory,
        ),
      ),
    );
  }

  Future<void> _getAllProducts(REQUEST_TYPE _type) async {
    final Map<String, String> _headers = {
      'Authorization': "Bearer ${_storeBloc.user.authCode}",
    };
    final response = await http.get(
      '$BASE_URI/shopper/products/${widget.productCategory.id}/$_page',
      headers: _headers,
    );
    ResponseWrapper responseWrapper = ResponseWrapper.fromJson(
      jsonDecode(response.body),
    );
    if (response.statusCode == 200 && responseWrapper.code == 200) {
      if (_type == REQUEST_TYPE.firstRequest) {
        final _data = responseWrapper.data;
        _page++;
        _products.clear();
        _storeBloc.products.clear();
        if (_data != null && (_data as List).isNotEmpty) {
          (_data as List).forEach((element) {
            _products.add(Product.fromJson(element));
            _storeBloc.products.add(Product.fromJson(element));
          });
          if ((_data as List).length < 25) {
            _hasMoreData = false;
          }
        }
        _storeBloc.add(EnterIntoStabilityState());
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      } else {
        final _data = responseWrapper.data;
        _page++;
        if (_data != null && (_data as List).isNotEmpty) {
          (_data as List).forEach((element) {
            _products.add(Product.fromJson(element));
            _storeBloc.products.add(Product.fromJson(element));
          });
          if ((_data as List).length < 25) {
            _hasMoreData = false;
          }
        }
        if (mounted) {
          setState(() {
            _loading = false;
            _loading2 = false;
          });
        }
      }
    }
  }

  Future<dynamic> _onRefresh() async {
    setState(() {
      _loading = true;
      _page = 1;
      _products.clear();
    });
    await _getAllProducts(REQUEST_TYPE.firstRequest);
    setState(() {
      _loading = false;
    });
    return '';
  }
}
