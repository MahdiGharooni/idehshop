import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/category_page_shop_card.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/managers/database_manager.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/utils.dart';

class FavoritesTab extends StatefulWidget {
  @override
  _FavoritesTabState createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  AuthenticationBloc _authenticationBloc;
  ShoppingBloc _shoppingBloc;
  CacheManager _cacheManager = CacheManager();
  DataBaseManager _dataBaseManager = DataBaseManager();
  bool _loading = true;
  List<dynamic> _shopIds = List();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
      if (_authenticationBloc.allFavoriteShopsDetails.isEmpty) {
        _getShopsFromDB();
      } else {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : _authenticationBloc.allFavoriteShopsDetails.isNotEmpty
            ? GridView.builder(
                itemBuilder: (context, index) {
                  return InkWell(
                    child: CategoryPageShopCard(
                      store: _authenticationBloc.allFavoriteShopsDetails[index],
                      cacheManager: _cacheManager,
                      isOpen: isStoreOpen(
                          _authenticationBloc.allFavoriteShopsDetails[index]),
                    ),
                    onTap: () => isStoreOpen(
                            _authenticationBloc.allFavoriteShopsDetails[index])
                        ? _shopSelected(context,
                            _authenticationBloc.allFavoriteShopsDetails[index])
                        : null,
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 3.0,
                  crossAxisSpacing: 3.0,
                ),
                scrollDirection: Axis.vertical,
                itemCount: _authenticationBloc.allFavoriteShopsDetails.length,
              )
            : Center(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/without_favorite.png',
                        width: MediaQuery.of(context).size.width / 2,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'هنوز فروشگاهی به علاقه مندی ها اضافه نکرده اید',
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ),
              );
  }

  _getShopsFromDB() async {
    _authenticationBloc.allFavoriteShopsDetails.clear();
    await _dataBaseManager.open().then((onValue) async {
      await _dataBaseManager.readFavoriteShops().then((_shops) async {
//        print(_shops);
        if (_shops.isNotEmpty || _shops != null) {
          _shops.forEach((element) {
            if (element['favorite'] == 1) {
              _shopIds.add(element['id']);
            }
          });
          _getShopsInfo();
        } else {
          setState(() {
            _loading = false;
          });
        }
      });
    });
  }

  _getShopsInfo() async {
    _shopIds.forEach((_shopId) async {
      final res = await http.get(
        '$BASE_URI/shop/info/$_shopId',
        headers: {
          'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
        },
      );
      if (res.statusCode == 200) {
        ResponseWrapper wrapper =
            ResponseWrapper.fromJson(jsonDecode(res.body));
        _authenticationBloc.allFavoriteShopsDetails
            .add(Store.fromJson(wrapper.data));

        setState(() {
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
      }
    });
    setState(() {
      _loading = false;
    });
  }

  _shopSelected(BuildContext context, Store _selectedShop) {
    if (_shoppingBloc.buyingProducts.isNotEmpty &&
        "${_shoppingBloc.selectedShop.id}" != "${_selectedShop.id}") {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'تغییر فروشگاه',
              textAlign: TextAlign.right,
            ),
            content: Text(
              'با تغییر فروشگاه، ،اقلام خریداری شده حذف میشوند',
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
      Navigator.pushNamed(context, '/customerStorePage');
    }
  }
}
