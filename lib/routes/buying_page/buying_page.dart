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
