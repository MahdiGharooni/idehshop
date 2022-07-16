import 'package:flutter/material.dart';

class BuyingPageAddressCard extends StatelessWidget {
  final String address;

  BuyingPageAddressCard({@required this.address});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Row(
          children: [
            Icon(Icons.location_on),
            SizedBox(
              width: 5,
            ),
            Text(
              'آدرس مقصد:',
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                address,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.normal),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
      ),
      elevation: 1.0,
    );
  }
}
