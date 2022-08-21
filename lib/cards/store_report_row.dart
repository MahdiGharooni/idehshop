import 'package:flutter/material.dart';

class StoreReportRow extends StatelessWidget {
  final String label;

  final String value;

  StoreReportRow({
    @required this.label,
    @required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            child: Text(
              label,
              style: Theme.of(context).textTheme.caption,
            ),
            width: 180,
          ),
          Expanded(
            child: Text(
              '$value تومان ',
            ),
          ),
        ],
      ),
      height: 30,
    );
  }
}
