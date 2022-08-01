import 'package:flutter/material.dart';
import 'package:idehshop/models/my_notification.dart';
import 'package:idehshop/utils.dart';
import 'package:shamsi_date/shamsi_date.dart';

class MessageCard extends StatelessWidget {
  final MyNotification notification;

  MessageCard({@required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 5.0,
            ),
            Container(
              child: Text(
                '${notification.faMessage}',
                style: Theme.of(context).textTheme.bodyText2,
                textDirection: TextDirection.rtl,
              ),
              alignment: Alignment.bottomRight,
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              child: Text(
                _getMessageDate() ?? '',
                style: Theme.of(context).textTheme.caption,
              ),
              alignment: Alignment.bottomLeft,
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      elevation: 1.0,
    );
  }

  String _getMessageDate() {
    DateTime adDate =
        DateTime.fromMillisecondsSinceEpoch(notification.createAt * 1000);
    final _jalali = Jalali.fromDateTime(adDate);
    String _dayName = getDateDayName(_jalali.weekDay);
    return " $_dayName ${_jalali.year}/${_jalali.month}/${_jalali.day}";
  }
}
