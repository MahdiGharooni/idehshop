import 'package:flutter/material.dart';
import 'package:idehshop/utils.dart';

class BuyingPageWalletCard extends StatelessWidget {
  final int wallet;

  BuyingPageWalletCard({
    @required this.wallet,
    @required this.finalPrice,
  });

  final int finalPrice;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                'اعتبار کیف‌پول:',
              ),
            ),
            Text('${getFormattedPrice(wallet)} تومان'),
            finalPrice > wallet
                ? SizedBox(
                    width: 5,
                  )
                : Container(),
            finalPrice > wallet
                ? FilterChip(
                    label: Text(
                      'افزایش اعتبار',
                    ),
                    padding: EdgeInsets.all(0.0),
                    onSelected: (value) {
                      Navigator.of(context).pushNamed('/chargeWallet');
                    },
                    backgroundColor: Colors.green,
                  )
                : Container()
          ],
        ),
        padding: EdgeInsets.all(10),
      ),
      elevation: 1.0,
    );
  }
}
