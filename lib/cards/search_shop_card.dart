import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/store.dart';

class SearchShopCard extends StatelessWidget {
  final Store store;
  final CacheManager cacheManager;
  final bool isOpen;

  SearchShopCard({
    @required this.store,
    @required this.cacheManager,
    @required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                child: store.imageAddress != null
                    ? (store.imageAddress.isNotEmpty &&
                            store.imageAddress[0] != null)
                        ? Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  "http://${store.imageAddress}",
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
                          )
                    : Image(
                        image: AssetImage(
                          'assets/images/default_basket.png',
                        ),
                        width: MediaQuery.of(context).size.width,
                      ),
                width: 110,
                height: 110,
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
                        '${store.title}',
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
                    height: 10,
                  ),
                  // Expanded(
                  //   child: Row(
                  //     children: [
                  //       Icon(
                  //         Icons.apps,
                  //         color: Colors.grey,
                  //         size: 20,
                  //       ),
                  //       Text(
                  //         '${store.kind}',
                  //         maxLines: 1,
                  //         overflow: TextOverflow.ellipsis,
                  //         style: Theme.of(context).textTheme.caption,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Expanded(
                    child: Container(
                      child: Text(
                        'فروشگاه هم اکنون ${isOpen ? 'باز ' : 'بسته '}است',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
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
      margin: EdgeInsets.all(
        3.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
    );
  }
}
