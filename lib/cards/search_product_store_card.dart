import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/product_and_store_info.dart';
import 'package:idehshop/utils.dart';

class SearchProductStoreCard extends StatelessWidget {
  final CacheManager cacheManager;
  final ProductAndStoreInfo productAndStoreInfo;
  final bool isOpen;

  SearchProductStoreCard({
    @required this.cacheManager,
    @required this.productAndStoreInfo,
    @required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Row(
            children: [
              (productAndStoreInfo.imageAddresses.isNotEmpty &&
                      productAndStoreInfo.imageAddresses[0] != null)
                  ? Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            "http://${productAndStoreInfo.imageAddresses[0]}",
                            cacheManager: cacheManager,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: const Radius.circular(8.0),
                          bottomRight: const Radius.circular(8.0),
                        ),
                      ),
                      height: 130,
                      width: 110,
                    )
                  : Image(
                      image: AssetImage(
                        'assets/images/default_basket.png',
                      ),
                      fit: BoxFit.fill,
                    ),
              SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        '${productAndStoreInfo.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      width: MediaQuery.of(context).size.width - 140,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      '${productAndStoreInfo.measurementIndex ?? ''} ${productAndStoreInfo.measurement ?? ''}',
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${productAndStoreInfo.shopTitle ?? ''}',
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        '${getFormattedPrice(int.parse(productAndStoreInfo.price))} تومان ',
                        style: TextStyle(
                          decoration: (productAndStoreInfo.offPrice != null &&
                                  '${productAndStoreInfo.offPrice}' != '0')
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor:
                              (productAndStoreInfo.offPrice != null &&
                                      '${productAndStoreInfo.offPrice}' != '0')
                                  ? Theme.of(context).errorColor
                                  : Colors.green[700],
                          decorationThickness: 2,
                          fontSize: (productAndStoreInfo.offPrice != null &&
                                  '${productAndStoreInfo.offPrice}' != '0')
                              ? 11.0
                              : 13.0,
                          color: (productAndStoreInfo.offPrice != null &&
                                  '${productAndStoreInfo.offPrice}' != '0')
                              ? Theme.of(context).textTheme.bodyText1.color
                              : Colors.green[700],
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      (productAndStoreInfo.offPrice != null &&
                              '${productAndStoreInfo.offPrice}' != '0')
                          ? Text(
                              '${getFormattedPrice(int.parse(productAndStoreInfo.offPrice))} تومان ',
                              style: TextStyle(
                                color: Colors.green[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Container(),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          ),
          isOpen
              ? Container()
              : Positioned.fill(
                  child: Opacity(
                    opacity: 0.3,
                    child: Container(
                      child: Align(
                        child: Container(
                          child: Text(
                            'بسته',
                            style: Theme.of(context).textTheme.caption.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(2),
                        ),
                        alignment: Alignment.topLeft,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: EdgeInsets.only(top: 5, left: 5),
                    ),
                  ),
                ),
        ],
      ),
      margin: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 3.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
