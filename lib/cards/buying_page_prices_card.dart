import 'package:flutter/material.dart';
import 'package:idehshop/utils.dart';

class BuyingPagePricesCard extends StatelessWidget {
  final int transferPrice;

  final num finalPrice;

  BuyingPagePricesCard({
    @required this.transferPrice,
    @required this.finalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'مبلغ خالص خرید:',
                    ),
                  ),
                  Text(
                    '${getFormattedPrice(finalPrice)} تومان',
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
              ),
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            Divider(),
            transferPrice != null
                ? Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'مبلغ ارسال:',
                          ),
                        ),
                        Text(
                          '$transferPrice' == '0'
                              ? 'رایگان'
                              : '${getFormattedPrice(transferPrice)} تومان'
                                  '',
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5),
                  )
                : Container(),
            Divider(),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: Text('مبلغ نهایی:'),
                  ),
                  Text(
                    '${getFormattedPrice(transferPrice + finalPrice)} تومان',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Colors.green),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
              ),
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
      ),
      elevation: 1.0,
    );
  }
}
