import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/product_count.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/utils.dart';

class CustomerProductCard extends StatelessWidget {
  final Product product;
  final CacheManager cacheManager;
  final ShoppingBloc shoppingBloc;

  CustomerProductCard({
    @required this.product,
    @required this.cacheManager,
    @required this.shoppingBloc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          (product.imageAddresses.isNotEmpty &&
                  product.imageAddresses[0] != null)
              ? Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        "http://${product.imageAddresses[0]}",
                        cacheManager: cacheManager,
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: const Radius.circular(8.0),
                      bottomRight: const Radius.circular(8.0),
                    ),
                  ),
                  height: 110,
                  width: 110,
                )
              : Image(
                  image: AssetImage(
                    'assets/images/default_basket.png',
                  ),
                  width: 110,
                  height: 110,
                  fit: BoxFit.fill,
                ),
          SizedBox(
            width: 10,
          ),
          Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    '${product.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  width: MediaQuery.of(context).size.width - 130,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  '${product.measurementIndex ?? ''} ${product.measurement ?? ''}',
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          '${getFormattedPrice(int.parse('${product.price}'))} تومان ',
                          style: TextStyle(
                            decoration: (product.offPrice != null &&
                                    '${product.offPrice}' != '0')
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: (product.offPrice != null &&
                                    '${product.offPrice}' != '0')
                                ? Theme.of(context).errorColor
                                : Colors.green[700],
                            decorationThickness: 2,
                            fontSize: (product.offPrice != null &&
                                    '${product.offPrice}' != '0')
                                ? 10.0
                                : 13.0,
                            color: (product.offPrice != null &&
                                    '${product.offPrice}' != '0')
                                ? Theme.of(context).textTheme.bodyText1.color
                                : Colors.green[700],
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        (product.offPrice != null &&
                                '${product.offPrice}' != '0')
                            ? Text(
                                '${getFormattedPrice(int.parse('${product.offPrice}'))} تومان ',
                                style: TextStyle(
                                  color: Colors.green[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Container(),
                      ],
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    ProductCount(
                      product: product,
                      iconSize: 20,
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width - 130,
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
