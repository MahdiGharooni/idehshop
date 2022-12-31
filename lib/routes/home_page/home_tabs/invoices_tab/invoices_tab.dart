import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/invoice_card.dart';
import 'package:idehshop/models/order.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/utils.dart';

class InvoicesTab extends StatefulWidget {
  @override
  _InvoicesTabState createState() => _InvoicesTabState();
}

class _InvoicesTabState extends State<InvoicesTab> {
  AuthenticationBloc _authenticationBloc;
  int _page = 1;
  List<Order> _orders = List();
  bool _loading = true;
  bool _loading2 = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _getCustomerInvoices(REQUEST_TYPE.firstRequest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is JwtExpiredAuthenticationState) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      builder: (context, state) {
        return _loading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                child: _orders.isNotEmpty
                    ? NotificationListener<ScrollNotification>(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            if (_loading2 && index == _orders.length) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return InvoiceCard(
                                order: _orders[index],
                                role: Role.customer,
                              );
                            }
                          },
                          itemCount:
                              _loading2 ? (_orders.length + 1) : _orders.length,
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
                            _getCustomerInvoices(REQUEST_TYPE.loadRequest)
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
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/without_order.png',
                              width: MediaQuery.of(context).size.width / 2,
                              fit: BoxFit.fitWidth,
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                      ),
                onRefresh: _onRefresh,
              );
      },
      cubit: _authenticationBloc,
    );
  }

  _getCustomerInvoices(REQUEST_TYPE requestType) async {
    final res = await http.get(
      '$BASE_URI/customer/invoices/$_page',
      headers: {
        'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      if (requestType == REQUEST_TYPE.firstRequest) {
        (wrapper.data as List).forEach((element) {
          _orders.add(Order.fromJson(element));
        });
        if ((wrapper.data as List).length < 25) {
          _hasMoreData = false;
        }
        if (mounted) {
          setState(() {
            _page++;
            _loading = false;
          });
        }
      } else {
        final _data = wrapper.data;
        _page++;
        if (_data != null && (_data as List).isNotEmpty) {
          (wrapper.data as List).forEach((element) {
            _orders.add(Order.fromJson(element));
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
  }

  Future<String> _onRefresh() async {
    setState(() {
      _loading = true;
      _page = 1;
      _orders.clear();
    });

    _getCustomerInvoices(REQUEST_TYPE.firstRequest);

    setState(() {
      _loading = false;
    });

    return 'OK';
  }
}
