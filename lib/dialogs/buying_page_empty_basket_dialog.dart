import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';

class BuyingPageEmptyBasketDialog extends StatelessWidget {
  final ShoppingBloc shoppingBloc;

  BuyingPageEmptyBasketDialog({@required this.shoppingBloc});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'خالی کردن سبد خرید',
        style: Theme.of(context).textTheme.bodyText2,
        textAlign: TextAlign.right,
      ),
      content: Text(
        'آیا از حذف تمامی کالاها از سبد خرید خود اطمینان دارید؟',
        style: Theme.of(context).textTheme.bodyText1,
        textAlign: TextAlign.right,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'بله',
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Theme.of(context).accentColor,
                ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            shoppingBloc.add(SubmitToEmptyBasketShoppingEvent());
          },
        ),
        FlatButton(
          child: Text(
            'خیر',
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Theme.of(context).accentColor,
                ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      contentPadding: EdgeInsets.all(10),
      actionsPadding: EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
