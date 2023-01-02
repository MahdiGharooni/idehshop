import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/message_card.dart';
import 'package:idehshop/models/my_notification.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/utils.dart';

class AllMessages extends StatefulWidget {
  final Role role;

  AllMessages({@required this.role});

  @override
  _AllMessagesState createState() => _AllMessagesState();
}

class _AllMessagesState extends State<AllMessages> {
  List<MyNotification> _notifications = List();
  AuthenticationBloc _authenticationBloc;
  StoreBloc _storeBloc;
  bool _loading = true;
  bool _loading2 = false;
  bool _hasMoreDataShops = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _getNotifs(REQUEST_TYPE.firstRequest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_loading
        ? _notifications.isNotEmpty
            ? NotificationListener(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    if (_loading2 && index == _notifications.length) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return MessageCard(
                        notification: _notifications[index],
                      );
                    }
                  },
                  itemCount: _loading2
                      ? (_notifications.length + 1)
                      : _notifications.length,
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
                    _getNotifs(REQUEST_TYPE.loadRequest).then((onValue) {
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
                child: Text('پیام جدیدی یافت نشد'),
              )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  _getNotifs(REQUEST_TYPE _type) async {
    String _url;
    if (widget.role == Role.customer) {
      _url = '$BASE_URI/customer/notifications/$_page';
    } else {
      _url =
          '$BASE_URI/shop/notifications/${_storeBloc.currentStore.id}/$_page';
    }
    final res = await http.get(
      _url,
      headers: {
        'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      if (_type == REQUEST_TYPE.firstRequest) {
        (wrapper.data as List).forEach((element) {
          _notifications.add(MyNotification.fromJson(element));
        });
        if (mounted) {
          setState(() {
            _page++;
            _loading = false;
          });
        }
      } else {
        final _data = wrapper.data;

        (_data as List).forEach((element) {
          _notifications.add(MyNotification.fromJson(element));
        });
        if ((_data as List).length < 25) {
          _hasMoreDataShops = false;
        }
        setState(() {
          _page++;
          _loading = false;
          _loading2 = false;
        });
      }
    }
  }
}
