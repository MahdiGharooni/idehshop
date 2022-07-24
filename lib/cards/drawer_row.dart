import 'package:flutter/material.dart';

class DrawerRow extends StatelessWidget {
  final Icon icon;
  final String label;
  final Function() inkwellOnTap;

  DrawerRow({
    @required this.icon,
    @required this.label,
    @required this.inkwellOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Container(
          child: Row(
            children: [
              icon,
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 5.0,
            vertical: 15,
          ),
        ),
      ),
      onTap: inkwellOnTap ?? null,
    );
  }
}
