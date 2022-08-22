import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class DateTimeDialog extends StatefulWidget {
  final ValueChanged<DateTime> onSelectedDate;
  final DateTime initialDate;
  final String title;

  const DateTimeDialog({
    @required this.onSelectedDate,
    @required this.initialDate,
    @required this.title,
    Key key,
  }) : super(key: key);

  @override
  _DateTimeDialogState createState() => _DateTimeDialogState();
}

class _DateTimeDialogState extends State<DateTimeDialog> {
  DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.title,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlineButton(
                  child: Text(intl.DateFormat('HH:mm').format(selectedDate)),
                  onPressed: () async {
                    final time = await _selectTime(
                      context,
                      initialDate: selectedDate,
                    );
                    if (time == null) return;

                    setState(() {
                      selectedDate = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        time.hour,
                        time.minute,
                      );
                    });

                    widget.onSelectedDate(selectedDate);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            RaisedButton(
              child: Text(
                'ثبت',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Theme.of(context).accentColor,
            ),
          ],
        ),
      );
}

Future<TimeOfDay> _selectTime(BuildContext context,
    {@required DateTime initialDate}) {
  return showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: initialDate.hour, minute: initialDate.minute),
      builder: (BuildContext context, Widget child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child,
        );
      });
}

