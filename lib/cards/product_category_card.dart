import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/product_category.dart';
import 'package:idehshop/utils.dart';

class ProductCategoryCard extends StatelessWidget {
  final ProductCategory productCategory;
  final CacheManager cacheManager;
  final Role role;

  ProductCategoryCard({
    @required this.productCategory,
    @required this.cacheManager,
    @required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Stack(
          children: [
            productCategory.imageAddress != null
                ? CachedNetworkImage(
                    imageUrl: "http://${productCategory.imageAddress}",
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
                    fit: BoxFit.fitWidth,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    key: Key('${productCategory.imageAddress}'),
                    filterQuality: FilterQuality.none,
                    useOldImageOnUrlChange: true,
                  )
                : AssetImage(
                    'assets/images/default_basket.png',
                  ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  color: Colors.black,
                ),
              ),
              key: Key('${productCategory.imageAddress}BLUR'),
            ),
            Positioned(
              child: Center(
                  child: Text(
                productCategory.title,
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.visible,
              )),
              key: Key('${productCategory.title}'),
            ),
            role == Role.customer
                ? Container()
                : Positioned(
                    child: Container(
                      child: productCategory.verified
                          ? Text(
                              'تایید شده',
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        color: Colors.green,
                                      ),
                            )
                          : Text(
                              'تایید نشده',
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        color: Colors.red,
                                      ),
                            ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: EdgeInsets.all(2),
                    ),
                    top: 0,
                    left: 0,
                  ),
          ],
        ),
        height: 100,
        width: MediaQuery.of(context).size.width,
      ),
      margin: EdgeInsets.all(
        3.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.transparent,
    );
  }
}
