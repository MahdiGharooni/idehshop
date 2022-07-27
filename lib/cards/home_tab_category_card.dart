import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/shop_kind.dart';

class HomeTabCategoryCard extends StatelessWidget {
  final ShopKind shopKind;
  final CacheManager cacheManager;

  HomeTabCategoryCard({
    @required this.shopKind,
    @required this.cacheManager,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Stack(
          children: [
            shopKind.imageAddress != null
                ? CachedNetworkImage(
                    imageUrl: "http://${shopKind.imageAddress}",
                    errorWidget: (context, url, error) => Center(
                      child: Image(
                        image: AssetImage(
                          'assets/images/default_basket.png',
                        ),
                      ),
                    ),
                    placeholder: (context, string) => Center(
                      child: Image(
                        image: AssetImage(
                          'assets/images/default_basket.png',
                        ),
                      ),
                    ),
                    cacheManager: cacheManager,
                    fit: BoxFit.fitHeight,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    key: Key('${shopKind.imageAddress}'),
                    filterQuality: FilterQuality.none,
                    useOldImageOnUrlChange: true,
                  )
                : AssetImage(
                    'assets/images/default_basket.png',
                  ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  color: Colors.black,
                ),
              ),
              key: Key('${shopKind.imageAddress}BLUR'),
            ),
            Positioned(
              child: Center(
                child: Container(
                  child: Text(
                    shopKind.kind,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              key: Key('${shopKind.kind}'),
            ),
          ],
          key: Key('$shopKind STACK'),
        ),
        width: MediaQuery.of(context).size.width / 2 - 10,
        height: MediaQuery.of(context).size.width / 2 - 10,
      ),
      margin: EdgeInsets.all(
        3.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      key: key,
      color: Colors.transparent,
    );
  }
}
