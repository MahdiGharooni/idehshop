import 'package:flutter/material.dart';

class ErrorDescriptionRow extends StatelessWidget {
  final String description;

  final bool isCaption;

  ErrorDescriptionRow({@required this.description, this.isCaption = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              description,
              style: isCaption
                  ? Theme.of(context).textTheme.caption
                  : Theme.of(context).textTheme.bodyText1,
            ),
          )
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    );
  }
}
