import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/buying_page_address_card.dart';
import 'package:idehshop/cards/buying_page_wallet_card.dart';
import 'package:idehshop/cards/error_description_row.dart';
import 'package:idehshop/models/order.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_ordering_tab/ordering_page_details.dart';
import 'package:idehshop/utils.dart';

class BuyingPagePay extends StatefulWidget {
  final int finalPrice;
  final String address;
  final Store store;

  final int wallet;

  BuyingPagePay({
    @required this.finalPrice,
    @required this.address,
    @required this.wallet,
    @required this.store,
  });

  @override
  _BuyingPagePayState createState() => _BuyingPagePayState();
}

class _BuyingPagePayState extends State<BuyingPagePay> {
  ShoppingBloc _shoppingBloc;
  TextEditingController _editingController = TextEditingController();
  AuthenticationBloc _authenticationBloc;
  PAY_WAY _payWay;
  String _offCode;
  bool _payLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingBloc, ShoppingState>(
      listener: (context, state) {
        if (state is SentNewOrderShopState) {
          _getNewOrderDetails(state.orderId);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'پرداخت',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              BuyingPageAddressCard(
                address: widget.address,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              BuyingPageWalletCard(
                finalPrice: widget.finalPrice,
                wallet: widget.wallet,
              ),
              SizedBox(
                height: 5,
              ),
              Card(
                child: Column(
                  children: [
                    Align(
                      child: Container(
                        child: Text(
                          'روش پرداخت :',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                      ),
                      alignment: Alignment.centerRight,
                    ),
                    (widget.store != null &&
                            widget.store.commission != null &&
                            widget.store.commission != 0)
                        ? Container()
                        : Container(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('درب منزل'),
                                ),
                                Switch(
                                    value: _payWay == PAY_WAY.home,
                                    onChanged: (value) {
                                      setState(() {
                                        _payWay = PAY_WAY.home;
                                      });
                                    }),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.center,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                    (widget.store != null &&
                            widget.store.commission != null &&
                            widget.store.commission != 0)
                        ? Divider()
                        : Container(),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(widget.finalPrice > widget.wallet
                                ? 'آنلاین'
                                : 'کیف پول'),
                          ),
                          Switch(
                              value: _payWay == PAY_WAY.wallet,
                              onChanged: (value) {
                                setState(() {
                                  _payWay = PAY_WAY.wallet;
                                });
                              }),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ],
                ),
                elevation: 1.0,
              ),
              SizedBox(
                height: 5,
              ),
              Card(
                child: Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('کد تخفیف:'),
                      ),
                      Container(
                        child: TextFormField(
                          autofocus: false,
                          controller: _editingController,
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          onChanged: (v) {
                            setState(() {
                              _offCode = v;
                            });
                          },
                        ),
                        width: 150,
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                elevation: 1.0,
              ),
              SizedBox(
                height: 20,
              ),
              ErrorDescriptionRow(
                description:
                    'نهایی کردن خرید به منزله اتمام خرید و ارسال سفارش به فروشگاه برای تایید یا رد آن میباشد.',
                isCaption: true,
              ),
              ErrorDescriptionRow(
                description:
                    'در صورتیکه سفارش خود را پرداخت کرده باشید و فروشگاه سفارش شما را رد کند مبلغ سفارش به کیف پول شما اضافه خواهد شد.',
                isCaption: true,
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(8.0),
            child: RaisedButton(
              onPressed: () => _setOrder(context),
              textColor: Colors.white,
              child: _payLoading
                  ? CircularProgressIndicator()
                  : Text(
                      'نهایی کردن خرید (${getFormattedPrice(widget.finalPrice)} تومان)'),
            ),
          ),
        );
      },
    );
  }

  _setOrder(BuildContext context) {
    if (!_payLoading) {
      if (_payWay == null) {
        return _payDialog(context);
      }
      setState(() {
        _payLoading = true;
      });
      _shoppingBloc.add(SubmitFinalOrderShopEvent(
        payFromWallet: _payWay == PAY_WAY.wallet ? true : false,
        offCode: _offCode ?? null,
      ));
    }
  }

  _payDialog(BuildContext context) {
    showCustomDialog(context, 'نوع پرداخت', 'لطفا روش پرداخت را مشخص کنید.');
  }

  _getNewOrderDetails(String _orderId) async {
    final res = await http.get(
      "$BASE_URI/customer/invoice/info/$_orderId",
      headers: {
        'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      Order _newOrderDetails = Order.fromJson(wrapper.data);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return OrderingPageDetails(
              order: _newOrderDetails,
              key: Key(
                "${_newOrderDetails.id}",
              ),
              role: Role.customer,
            );
          },
        ),
      );
    }
  }
}
