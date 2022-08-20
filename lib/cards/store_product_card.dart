import 'package:flutter/material.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/models/product_category.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_entities_tab/store_product_page.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_entities_tab/store_reporting_page.dart';
import 'package:idehshop/utils.dart';

class StoreProductCard extends StatelessWidget {
  StoreProductCard({
    @required this.product,
    @required this.key,
    @required this.cacheManager,
    @required this.productCategory,
  });

  final Key key;
  final Product product;
  final CacheManager cacheManager;
  final ProductCategory productCategory;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Stack(
          children: [
            (product.imageAddresses.isNotEmpty &&
                    product.imageAddresses[0] != null)
                ? Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          "http://${product.imageAddresses[0]}",
                        ),
                        fit: BoxFit.fitWidth,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  )
                : Image(
                    image: AssetImage(
                      'assets/images/default_basket.png',
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
            Positioned(
              child: Align(
                child: Container(
                  child: Text(
                    '${product.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    color: Colors.white,
                  ),
                ),
                alignment: Alignment.bottomCenter,
              ),
            ),
            (product.available && product.verified)
                ? Positioned(
                    child: IconButton(
                      icon: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      onPressed: null,
                    ),
                    top: 0.0,
                    right: 0.0,
                  )
                : Container(),
            Positioned(
              child: IconButton(
                icon: Icon(
                  Icons.insert_chart_outlined,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return StoreReportingPage(
                      product: product,
                    );
                  }),
                ),
              ),
              top: 0.0,
              left: 0.0,
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
      ),
      onTap: () => _onSelected(context),
    );
  }

  _onSelected(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreProductPage(
          type: TYPE.edit,
          product: product,
          key: Key("${TYPE.edit}${product.id}"),
          productCategory: productCategory,
        ),
      ),
    );
  }
}
