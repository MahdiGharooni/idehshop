import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/category_page_shop_card.dart';
import 'package:idehshop/dialogs/home_tab_address_dialog.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/shop_kind.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/routes/home_page/home_tabs/search_page.dart';
import 'package:idehshop/utils.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  ShoppingBloc _shoppingBloc;
  PermissionBloc _permissionBloc;
  bool _loading = true;
  bool _loading2 = false;
  bool _hasMoreDataShops = true;
  int _page = 1;
  ShopKind _selectedShopKind;
  Map<String, String> _headers = Map<String, String>();
  List<Store> _stores = List();
  CacheManager _cacheManager = CacheManager();
  String _whereValue = WHERE_NEAR;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
        _permissionBloc = BlocProvider.of<PermissionBloc>(context);
        _selectedShopKind = _shoppingBloc.selectedShopKind;
      });

      _headers = {
        'Authorization': "Bearer ${_shoppingBloc.authCode}",
      };
      if (_permissionBloc != null && _permissionBloc.selectedAddress != null) {
        _getStoresAsSelectedShopKind(
            REQUEST_TYPE.firstRequest, '${_permissionBloc.selectedAddress.id}');
      } else {
        // print('init2');
        setState(() {});
        Future.delayed(Duration(seconds: 2)).then(
          (value) => _getStoresAsSelectedShopKind(REQUEST_TYPE.firstRequest,
              '${_permissionBloc.selectedAddress.id}'),
        );
      }
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
        return WillPopScope(
          child: Scaffold(
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
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _search(context),
                ),
              ],
              title: Text(
                (_shoppingBloc != null &&
                        _shoppingBloc.selectedShopKind != null)
                    ? "${_shoppingBloc.selectedShopKind.kind}"
                    : '',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.white),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 5,
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
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        child: Icon(
                                          _whereValue == WHERE_NEAR
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
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
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        child: Icon(
                                          _whereValue == WHERE_CITY
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
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
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        child: Icon(
                                          _whereValue == WHERE_STATE
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: _whereValue == WHERE_STATE
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
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        child: Icon(
                                          _whereValue == WHERE_COUNTRY
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: _whereValue == WHERE_COUNTRY
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
                                _loading = true;
                                _hasMoreDataShops = true;
                                _stores = [];
                                _page = 1;
                              });
                              _getStoresAsSelectedShopKind(
                                  REQUEST_TYPE.firstRequest,
                                  '${_permissionBloc.selectedAddress.id}');
                            },
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'محدوده',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          SizedBox(
                            width: 5,
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
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
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
                                          _permissionBloc.selectedAddress !=
                                              null)
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
              centerTitle: true,
              elevation: 0.0,
              backgroundColor: Colors.transparent,
            ),
            body: BlocBuilder<PermissionBloc, PermissionState>(
              builder: (context, state) {
                return !_loading
                    ? NotificationListener(
                        child: RefreshIndicator(
                          child: _stores.isNotEmpty
                              ? GridView.builder(
                                  itemBuilder: (context, index) {
                                    if (_loading2 && index == _stores.length) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      return InkWell(
                                        child: CategoryPageShopCard(
                                          store: _stores[index],
                                          cacheManager: _cacheManager,
                                          isOpen: isStoreOpen(_stores[index]),
                                        ),
                                        onTap: () => isStoreOpen(_stores[index])
                                            ? _shopSelected(
                                                context, _stores[index])
                                            : _checkPreOrder(
                                                context, _stores[index]),
                                      );
                                    }
                                  },
                                  itemCount: _loading2
                                      ? (_stores.length + 1)
                                      : _stores.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 3.0,
                                    crossAxisSpacing: 3.0,
                                  ),
                                  scrollDirection: Axis.vertical,
                                )
                              : ListView(
                                  children: [
                                    Center(
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              'assets/images/without_favorite.png',
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              fit: BoxFit.fitWidth,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                                'بزودی فروشگاه های این گروه بندی اضافه خواهند شد.')
                                          ],
                                        ),
                                        padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4),
                                      ),
                                    ),
                                  ],
                                ),
                          onRefresh: _onRefresh,
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
                            // print('load');
                            _getStoresAsSelectedShopKind(
                                    REQUEST_TYPE.loadRequest,
                                    '${_permissionBloc.selectedAddress.id}')
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
                        child: CircularProgressIndicator(),
                      );
              },
              cubit: _permissionBloc,
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
          ),
          onWillPop: _onWillPop,
        );
      },
      cubit: _shoppingBloc,
    );
  }

  Future<bool> _onWillPop() async {
    _shoppingBloc.selectedShopKind = null;
    return true;
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

  _getStoresAsSelectedShopKind(
      REQUEST_TYPE _requestType, String _selectedAddressId) async {
    final response = await http.get(
      "$BASE_URI/shops/$_selectedAddressId/$_page?categoryId=${_selectedShopKind.id}&where=$_whereValue",
      headers: _headers,
    );

    if (response.statusCode == 200) {
      ResponseWrapper responseWrapper = ResponseWrapper.fromJson(
        jsonDecode(response.body),
      );
      if (responseWrapper.code == 200) {
        if (_requestType == REQUEST_TYPE.firstRequest) {
          _stores.clear();
          (responseWrapper.data as List).forEach((element) {
            _stores.add(
              Store.fromJson(element),
            );
            if ((responseWrapper.data as List).length < 25) {
              _hasMoreDataShops = false;
            }
          });
          if (mounted) {
            setState(() {
              _page++;
              _loading = false;
            });
          }
        } else {
          final _data = responseWrapper.data;
          _page++;
          if (_data != null && (_data as List).isNotEmpty) {
            (_data as List).forEach((element) {
              _stores.add(
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
            if ((_data as List).length < 25) {
              _hasMoreDataShops = false;
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

  Future<String> _onRefresh() async {
    setState(() {
      _loading = true;
      _hasMoreDataShops = true;
      _stores = [];
      _page = 1;
    });
    // print('refresh');
    _getStoresAsSelectedShopKind(
        REQUEST_TYPE.firstRequest, '${_permissionBloc.selectedAddress.id}');
    return 'OK';
  }

  _search(BuildContext context) {
    if (_permissionBloc.selectedAddress != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return SearchPage(
            hint: 'نام محصول/فروشگاه',
            searchType: SEARCH_TYPE.productInNearStores,
            categoryId: _selectedShopKind.id ?? '',
          );
        },
      ));
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return HomeTabAddressDialog();
        },
      );
    }
  }

  _checkPreOrder(BuildContext context, Store _store) {
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
                  _shopSelected(context, _store);
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
