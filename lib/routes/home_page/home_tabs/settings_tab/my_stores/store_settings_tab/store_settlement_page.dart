import 'package:flutter/material.dart';
import 'package:idehshop/cards/error_description_row.dart';
import 'package:idehshop/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreSettlementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تسویه ‌حساب',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Card(
        child: Center(
          child: Container(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                ErrorDescriptionRow(
                    description:
                        'در این قسمت میتوانید مبالغ سفارشاتی که بصورت آنلاین پرداخت شده را دریافت کرده و تسویه حساب کنید.'),
                SizedBox(
                  height: 20,
                ),
                ErrorDescriptionRow(
                    description:
                        'شما میتوانید با ورود به نسخه وب تسویه کنید. این قابلیت در نسخه های بعدی به برنامه اضافه خواهد شد.'),
                SizedBox(
                  height: 40,
                ),
                RaisedButton(
                  onPressed: () => _launch(),
                  child: Text(
                    'درخواست تسویه',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.button.color,
                    ),
                  ),
                ),
              ],
            ),
            padding: EdgeInsets.all(10),
          ),
        ),
      ),
    );
  }

  _launch() async {
    final url = MY_IDEHSHOP_URI;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
