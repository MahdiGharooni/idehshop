import 'package:flutter/material.dart';
import 'package:idehshop/utils.dart';

class ProfileRow extends StatelessWidget {
  final Icon icon;
  final String label;
  final value;
  final String dialogTitle;

  final String dialogCaption;

  ProfileRow({
    @required this.icon,
    @required this.label,
    @required this.value,
    this.dialogTitle = '',
    this.dialogCaption = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          icon != null ? icon : Container(),
          SizedBox(
            width: 10,
          ),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  dialogTitle != ''
                      ? IconButton(
                          icon: Icon(
                            Icons.error_outline,
                            size: 15,
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(0),
                          onPressed: () => _dialog(context),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Container(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                width: MediaQuery.of(context).size.width / 2,
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 5.0,
      ),
    );
  }

  _dialog(BuildContext context) {
    showCustomDialog(context, dialogTitle, dialogCaption);
  }
}
