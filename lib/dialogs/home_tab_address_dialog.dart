import 'package:flutter/material.dart';

class HomeTabAddressDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'انتخاب آدرس',
        style: Theme.of(context).textTheme.bodyText2,
        textAlign: TextAlign.right,
      ),
      content: Text(
        'برای نمایش فروشگاه های اطرافتان ،لطفا آدرس مدنظرتان را انتخاب کنید.',
        style: Theme.of(context).textTheme.bodyText1,
        textAlign: TextAlign.right,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'انتخاب آدرس',
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Theme.of(context).accentColor,
                ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/addressesList');
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
