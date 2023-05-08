import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/ordering_card.dart';
import 'package:idehshop/models/order.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/utils.dart';

class StoreOrderingTab extends StatefulWidget {
  @override
  _StoreOrderingTabState createState() => _StoreOrderingTabState();
}

class _StoreOrderingTabState extends State<StoreOrderingTab> {
  StoreBloc _storeBloc;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  int _orderingsPage = 1;
  List<Order> _orders = List();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _getProviderOrders(REQUEST_TYPE.firstRequest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoreBloc, StoreState>(
      listener: (context, state) {
        if (state is JwtExpiredPermissionState) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        if ((state is AcceptedOrderStoreState ||
                state is DeclinedOrderStoreState ||
                state is GotOrderingStoreState) &&
            !_loading) {
          _onRefresh();
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          child: (_loading || (state is LoadingStoreState))
              ? Center(child: CircularProgressIndicator())
              : _orders.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        return OrderingCard(
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

  _getProviderOrders(REQUEST_TYPE requestType) async {
    final res = await http.get(
      '$BASE_URI/orders/new/${_storeBloc.currentStore.id}/$_orderingsPage',
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      _orders.clear();
      (wrapper.data as List).forEach((element) {
        _orders.add(Order.fromJson(element));
      });
      if (_orders.length > _storeBloc.oldOrderingCount) {
        _storeBloc.oldOrderingCount = _orders.length;
        _storeBloc.shownOrderingCount = _orders.length;
      }
      setState(() {
        _loading = false;
      });
    }
  }

  Future<String> _onRefresh() async {
    setState(() {
      _loading = true;
      _orderingsPage = 1;
      _orders.clear();
    });

    _getProviderOrders(REQUEST_TYPE.firstRequest);

    setState(() {
      _loading = false;
    });

    return 'OK';
  }
}
