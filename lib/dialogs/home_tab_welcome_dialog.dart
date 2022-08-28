import 'package:flutter/material.dart';

class HomeTabWelcomeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Image.asset(
                  'assets/images/basket.png',
                  scale: 3,
                ),
                SizedBox(height: 15.0),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'سلام، به اپلیکیشن فروشگاه ساز آنلاین خودتون خوش آمدید!',
                      ),
                    ],
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Colors.black,
                        ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.0),
                Row(
                  children: [
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'ادامه',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            padding: EdgeInsets.all(5),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
    );
  }
}
