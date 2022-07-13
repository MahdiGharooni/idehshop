import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/product_count.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/utils.dart';

class BuyingCard extends StatelessWidget {
  final Product product;
  final String measurementIndex;
  final ShoppingBloc shoppingBloc;
  final TextEditingController descriptionController;

  BuyingCard({
    @required this.shoppingBloc,
    @required this.product,
    @required this.measurementIndex,
    @required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            // Container(
            //   child: (product.imageAddresses.isNotEmpty &&
            //           product.imageAddresses[0] != null)
            //       ? Image.network(
            //           'http://${product.imageAddresses[0]}',
            //           fit: BoxFit.fitWidth,
            //         )
            //       : Image(
            //           image: AssetImage(
            //             'assets/images/default_basket.png',
            //           ),
            //           fit: BoxFit.fitWidth,
            //         ),
            //   height: 100,
            //   width: MediaQuery.of(context).size.width,
            // ),
            // Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'نام محصول:',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                  flex: 1,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    "${product.title}",
                    style: Theme.of(context).textTheme.bodyText2,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.left,
                  ),
                  flex: 2,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${product.offPrice}' != '0' ? 'قیمت با تخفیف:' : 'قیمت:',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    '${product.offPrice}' != '0'
                        ? "${getFormattedPrice(int.parse('${product.offPrice}'))}" +
                            " تومان"
                        : "${getFormattedPrice(int.parse('${product.price}'))}" +
                            " تومان",
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'واحد:',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                  flex: 1,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    "${product.measurementIndex ?? ''} ${product.measurement ?? ''}",
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                  ),
                  flex: 2,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'تعداد درخواستی شما:',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                ProductCount(
                  product: product,
                  iconSize: 22,
                  distance: 10,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText:
                    "اگر ویژگی خاصی مانند رنگ و سایز مدنظر دارید اینجا بنویسید .",
                hintStyle: Theme.of(context).textTheme.subtitle2,
                contentPadding: const EdgeInsets.all(10.0),
                fillColor: Colors.white,
                filled: true,
              ),
              controller: descriptionController,
              onChanged: (v) => shoppingBloc.add(
                AddProductInfoToListShopEvent(
                  productId: product.id,
                  description: v,
                ),
              ),
              minLines: 2,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(
              height: 10,
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      ),
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(
      //     5.0,
      //   ),
      // ),
      margin: EdgeInsets.symmetric(vertical: 2.0),
      elevation: 1.0,
    );
  }

  _deleteProduct(Product buyingProduct) {
    shoppingBloc.add(DeleteProductFromBasketShopEvent(product: buyingProduct));
  }
}
