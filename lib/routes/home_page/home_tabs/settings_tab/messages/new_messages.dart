import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/message_card.dart';
import 'package:idehshop/models/my_notification.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/utils.dart';

class NewMessages extends StatefulWidget {
  final Role role;

  NewMessages({@required this.role});

  @override
  _NewMessagesState createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  bool _loading = true;
  List<MyNotification> _notifications = List();
  StoreBloc _storeBloc;
  AuthenticationBloc _authenticationBloc;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      _getNotifs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_loading
        ? _notifications.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return MessageCard(
                    notification: _notifications[index],
                  );
                },
                itemCount: _notifications.length,
              )
            : Center(
                child: Text('پیام جدیدی یافت نشد'),
              )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  _getNotifs() async {
    String _url;
    if (widget.role == Role.customer) {
      _url = '$BASE_URI/customer/notifications/new/$_page';
    } else {
      _url =
          '$BASE_URI/shop/notifications/new/${_storeBloc.currentStore.id}/$_page';
    }
    final res = await http.get(
      _url,
      headers: {
        'Authorization': "Bearer ${_authenticationBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper wrapper = ResponseWrapper.fromJson(jsonDecode(res.body));
      (wrapper.data as List).forEach((element) {
        _notifications.add(MyNotification.fromJson(element));
      });
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
}
