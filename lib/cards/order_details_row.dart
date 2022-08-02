import 'package:flutter/material.dart';

class OrderDetailsRow extends StatelessWidget {
  final String title;

  final String value;

  final double titleSize;
  final bool titleBold;

  OrderDetailsRow({
    @required this.title,
    @required this.value,
    this.titleSize,
    this.titleBold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.caption.copyWith(
                    fontSize: titleSize ?? 13.0,
                    fontWeight: (titleBold ?? false)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            alignment: Alignment.bottomLeft,
          ),
        ),
      ],
    );
  }
}
