import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileEditRow extends StatelessWidget {
  final TextEditingController controller;
  final String prefixText;
  final TextInputType keyboardType;
  final Function(String) validator;
  final int maxLines;
  final String hintText;

  ProfileEditRow({
    @required this.controller,
    @required this.prefixText,
    @required this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        autofocus: false,
        controller: controller,
        decoration: InputDecoration(
          labelText: prefixText,
          labelStyle: Theme.of(context).textTheme.bodyText1.copyWith(
                color: Theme.of(context).accentColor,
              ),
          hintText: hintText != null ? hintText : null,
        ),
        style: Theme.of(context).textTheme.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: 1,
        validator: validator ?? null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 5.0,
      ),
    );
  }
}
