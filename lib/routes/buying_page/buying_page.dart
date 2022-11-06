import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/buying_card.dart';
import 'package:idehshop/cards/buying_page_address_card.dart';
import 'package:idehshop/cards/buying_page_prices_card.dart';
import 'package:idehshop/dialogs/buying_page_empty_basket_dialog.dart';
import 'package:idehshop/models/my_location.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/routes/buying_page/buying_page_pay.dart';
import 'package:idehshop/utils.dart';

class BuyingPage extends StatefulWidget {
  @override
  _BuyingPageState createState() => _BuyingPageState();
}

class _BuyingPageState extends State<BuyingPage> {
  ShoppingBloc _shoppingBloc;
  TextEditingController _editingController = TextEditingController();
  MyLocation _location;
  AuthenticationBloc _authenticationBloc;
  PermissionBloc _permissionBloc;
  int _transferPrice = 0;
  num finalPrice = 0;
  PAY_WAY _payWay;
  String _offCode;
  Store _store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _permissionBloc = BlocProvider.of<PermissionBloc>(context);
      _getFinalPrice();
      _getShopDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingBloc, ShoppingState>(
      listener: (context, state) {
        if (state is JwtExpiredShopState) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        if (state is SentNewOrderShopState) {
          // _getNewOrderDetails(state.orderId);
        }
        if (state is DeletedProductFromBasketShopState ||
            state is AddedNewProductShopState) {
          _getFinalPrice();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'سبد خرید',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            actions: [
              (_shoppingBloc != null && _shoppingBloc.buyingProducts.isNotEmpty)
                  ? IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return BuyingPageEmptyBasketDialog(
                                    shoppingBloc: _shoppingBloc);
                              },
                            )
                          })
                  : Container()
            ],
          ),
          body: (_shoppingBloc == null || _authenticationBloc == null)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _shoppingBloc.buyingProducts.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        if (_shoppingBloc.buyingProducts.length == 1) {
                          return Column(
                            children: [
                              BuyingPageAddressCard(
                                address: (_permissionBloc != null &&
                                        _permissionBloc.selectedAddress != null)
                                    ? '${_permissionBloc.selectedAddress.address}'
                                    : '',
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              BuyingCard(
                                shoppingBloc: _shoppingBloc,
                                product: _shoppingBloc.buyingProducts[index],
                                measurementIndex: _shoppingBloc
                                    .finalBuyingMeasurementIndexes[index],
                                descriptionController: _getProductDescription(
                                    _shoppingBloc.buyingProducts[index].id),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              BuyingPagePricesCard(
                                transferPrice: _transferPrice,
                                finalPrice: finalPrice,
                              ),
                            ],
                          );
                        } else if (index == 0) {
                          return Column(
                            children: [
                              BuyingPageAddressCard(
                                address: (_permissionBloc != null &&
                                        _permissionBloc.selectedAddress != null)
                                    ? '${_permissionBloc.selectedAddress.address}'
                                    : '',
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              BuyingCard(
                                shoppingBloc: _shoppingBloc,
                                product: _shoppingBloc.buyingProducts[index],
                                measurementIndex: _shoppingBloc
                                    .finalBuyingMeasurementIndexes[index],
                                descriptionController: _getProductDescription(
                                    _shoppingBloc.buyingProducts[index].id),
                              ),
                            ],
                          );
                        } else if (index ==
                            _shoppingBloc.buyingProducts.length - 1) {
                          return Column(
                            children: [
                              BuyingCard(
                                shoppingBloc: _shoppingBloc,
                                product: _shoppingBloc.buyingProducts[index],
                                measurementIndex: _shoppingBloc
                                    .finalBuyingMeasurementIndexes[index],
                                descriptionController: _getProductDescription(
                                    _shoppingBloc.buyingProducts[index].id),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              BuyingPagePricesCard(
                                transferPrice: _transferPrice,
                                finalPrice: finalPrice,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          );
                        } else {
                          return BuyingCard(
                            shoppingBloc: _shoppingBloc,
                            product: _shoppingBloc.buyingProducts[index],
                            measurementIndex: _shoppingBloc
                                .finalBuyingMeasurementIndexes[index],
                            descriptionController: _getProductDescription(
                                _shoppingBloc.buyingProducts[index].id),
                          );
                        }
                      },
                      itemCount: _shoppingBloc.buyingProducts.length ?? 0,
                    )
                  : Center(
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
                          Text('سبد خرید شما خالی است.'),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
          bottomNavigationBar:
              (_shoppingBloc != null && _shoppingBloc.buyingProducts.isNotEmpty)
                  ? Padding(
                      padding: EdgeInsets.all(8.0),
                      child: RaisedButton(
                        onPressed: () => _setOrder(context),
                        textColor: Colors.white,
                        child: state is LoadingShoppingState
                            ? CircularProgressIndicator(
                                backgroundColor: Theme.of(context).primaryColor,
                              )
                            : Text(
                                'پرداخت (${getFormattedPrice(_transferPrice + finalPrice)} تومان)'),
                      ),
                    )
                  : Container(
                      height: 1,
                    ),
        );
      },
      cubit: _shoppingBloc,
    );
  }

  _setOrder(BuildContext context) {
    if (_authenticationBloc != null) {
      if (_authenticationBloc.user.firstName == null ||
          _authenticationBloc.user.firstName == ' ' ||
          _authenticationBloc.user.firstName == '' ||
          _authenticationBloc.user.lastName == null ||
          _authenticationBloc.user.lastName == '' ||
          _authenticationBloc.user.lastName == ' ') {
        return _showUserInfoDialog(
            'برای ادامه خرید لطفا اطلاعات کاربری خود را تکمیل کنید.', context);
      } else if (_authenticationBloc.user.accessNumbers != null &&
          _authenticationBloc.user.accessNumbers.isEmpty) {
        return _showUserInfoDialog(
            'برای ادامه خرید لطفا شماره تماس خود را وارد کنید.', context);
      }
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return BuyingPagePay(
          address: (_permissionBloc != null &&
                  _permissionBloc.selectedAddress != null)
              ? '${_permissionBloc.selectedAddress.address}'
              : '',
          finalPrice: (_transferPrice + finalPrice).round(),
          wallet: _authenticationBloc.user.wallet,
          store: _store,
        );
      },
    ));
  }

  _showUserInfoDialog(String msg, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'تکمیل اطلاعات کاربری',
            textAlign: TextAlign.right,
          ),
          content: Text(
            msg,
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.right,
          ),
          actions: [
            FlatButton(
              child: Text(
                'ویرایش اطلاعات',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Theme.of(context).accentColor,
                    ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/profile');
              },
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

  _getFinalPrice() {
    num _finalPrice = 0;
    _shoppingBloc.buyingProducts.asMap().forEach((index, element) {
      if (element.offPrice != null && '${element.offPrice}' != '0') {
        _finalPrice = _finalPrice +
            (int.parse('${element.offPrice}') *
                double.parse(
                    _shoppingBloc.finalBuyingMeasurementIndexes[index]));
      } else {
        _finalPrice = _finalPrice +
            (int.parse('${element.price}') *
                double.parse(
                    _shoppingBloc.finalBuyingMeasurementIndexes[index]));
      }
    });

    setState(() {
      finalPrice = _finalPrice;
    });
  }

  _getShopDetails() async {
    final res = await http.get(
      '$BASE_URI/shop/info/${_shoppingBloc.selectedShop.id}',
      headers: {
        'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
      },
    );

    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      if (wrapper.code == 200) {
        setState(() {
          _store = Store.fromJson(wrapper.data);
        });
        _getTransferPrice();
      }
    }
  }

  _getTransferPrice() {
    _location = _permissionBloc.selectedAddress;
    double latDif = (_store.lat - _location.lat);
    double lngDif = (_store.long - _location.lng);
    double latPow = pow(latDif, 2);
    double lngPow = pow(lngDif, 2);
    double addPows = lngPow + latPow;
    double squareRoot = sqrt(addPows);
    if (squareRoot <= _store.limitDistance) {
      _transferPrice = _store.transportPriceNear;
    } else {
      _transferPrice = _store.transportPriceFar;
    }
    setState(() {});
  }

  TextEditingController _getProductDescription(String _productId) {
    String des;
    _shoppingBloc.buyingProductsInfo.forEach((element) {
      if (element.containsKey(PRODUCT_ID) &&
          element[PRODUCT_ID] == _productId) {
        des = element[PRODUCT_DESCRIPTION];
      }
    });

    if (des != null && des != '') {
      return TextEditingController(text: des);
    } else {
      return TextEditingController();
    }
  }
}
