import 'package:flutter/material.dart';

class FavoriteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
              child: Image.network(
                'https://www.tarafdari.com/sites/default/files/contents/user130292/news/paolo-maldini-990311.jpg',
                fit: BoxFit.fill,
              ),
              height: 120,
              width: 120,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'پاستیل شیبا',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontSize: 16,
                        ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'سوپرمارکت دریانی',
                    maxLines: 1,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'تهران میدان ولیعصر',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    child: Text(
                      '6000 تومان ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    alignment: Alignment.bottomLeft,
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        height: 150,
        padding: EdgeInsets.all(5.0),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15.0,
        ),
      ),
      elevation: 1.0,
      margin: EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 5.0,
      ),
    );
  }
}
