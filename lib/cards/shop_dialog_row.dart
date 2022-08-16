import 'package:flutter/material.dart';

class ShopDialogRow extends StatelessWidget {
  final String title;
  final String value;

  ShopDialogRow({
    @required this.title,
    @required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$title',
          style: Theme.of(context).textTheme.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          '$value',
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}
