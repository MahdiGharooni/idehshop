import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsRow extends StatelessWidget {
  final String title;
  final String description;
  final Icon icon;
  final String url;

  AboutUsRow({
    @required this.title,
    @required this.description,
    @required this.icon,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          icon,
          SizedBox(
            width: 10,
          ),
          Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                child: Container(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ),
                  width: MediaQuery.of(context).size.width / 2,
                ),
                onTap: () => url != null ? _launch() : null,
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
      width: MediaQuery.of(context).size.width,
    );
  }

  _launch() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
