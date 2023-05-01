import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/invoice_card.dart';
import 'package:idehshop/models/order.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/utils.dart';

class StoreInvoicesTab extends StatefulWidget {
  @override
  _StoreInvoicesTabState createState() => _StoreInvoicesTabState();
}

class _StoreInvoicesTabState extends State<StoreInvoicesTab> {
  StoreBloc _storeBloc;
  int _invoicesPage = 1;
  List<Order> _orders = List();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _getProviderInvoices(REQUEST_TYPE.firstRequest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoreBloc, StoreState>(
      listener: (context, state) {
        if (state is JwtExpiredPermissionState) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        if (state is AcceptedOrderStoreState ||
            state is DeclinedOrderStoreState) {
          _onRefresh();
        }
      },
      builder: (context, state) {
        return _loading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                child: _orders.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: (context, index) {
                          return InvoiceCard(
                            order: _orders[index],
                            role: Role.provider,
                          );
                        },
                        itemCount: _orders.length,
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
      cubit: _storeBloc,
    );
  }

  _getProviderInvoices(REQUEST_TYPE requestType) async {
    final res = await http.get(
      '$BASE_URI/shop/invoices/${_storeBloc.currentStore.id}/$_invoicesPage',
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      (wrapper.data as List).forEach((element) {
        _orders.add(Order.fromJson(element));
      });
      setState(() {
        _loading = false;
      });
    }
  }

  Future<String> _onRefresh() async {
    setState(() {
      _loading = true;
      _invoicesPage = 1;
      _orders.clear();
    });

    _getProviderInvoices(REQUEST_TYPE.firstRequest);

    setState(() {
      _loading = false;
    });

    return 'OK';
  }
}
