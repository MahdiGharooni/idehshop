import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/product.dart';

class ProductCount extends StatefulWidget {
  final Product product;
  final double iconSize;
  final double distance;

  ProductCount({
    @required this.product,
    this.iconSize = 16.0,
    this.distance = 5.0,
  });

  @override
  _ProductCountState createState() => _ProductCountState();
}

class _ProductCountState extends State<ProductCount> {
  ShoppingBloc _shoppingBloc;
  int _productCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
      _shoppingBloc.buyingProducts.asMap().forEach((index, value) {
        if (value.id == widget.product.id) {
          setState(() {
            _productCount = int.parse(
                '${_shoppingBloc.finalBuyingMeasurementIndexes[index]}');
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingBloc, ShoppingState>(
      listener: (context, state) {
        if (state is AddedNewProductShopState) {
          if (state.product.id == widget.product.id) {
            setState(() {
              _productCount = int.parse(state.measurementIndex);
            });
          }
        }
        if (state is DeletedProductFromBasketShopState ||
            state is AddedNewProductShopState ||
            state is BuyingProductInfoChangedState) {
          _productCount = 0;
          _shoppingBloc.buyingProducts.asMap().forEach((index, value) {
            if (value.id == widget.product.id) {
              _productCount = int.parse(
                  '${_shoppingBloc.finalBuyingMeasurementIndexes[index]}');
            }
          });
        }
      },
      builder: (context, state) {
        return Align(
          child: Container(
            child: Row(
              children: [
                InkWell(
                  child: Container(
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.green,
                      size: widget.iconSize,
                    ),
                    // padding: EdgeInsets.all(5),
                  ),
                  onTap: () {
                    setState(() {
                      _productCount++;
                    });
                    _shoppingBloc.add(
                      SubmitNewProductToBasketShopEvent(
                        product: widget.product,
                        measurementIndex: '$_productCount',
                      ),
                    );
                  },
                ),
                SizedBox(
                  width: widget.distance,
                ),
                _productCount > 0 ? Text('$_productCount') : Container(),
                SizedBox(
                  width: widget.distance,
                ),
                _productCount > 0
                    ? InkWell(
                        child: Container(
                          child: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                            size: widget.iconSize,
                          ),
                          // padding: EdgeInsets.all(5),
                        ),
                        onTap: () {
                          if (_productCount > 0) {
                            setState(() {
                              _productCount--;
                            });
                            _shoppingBloc.add(
                              SubmitNewProductToBasketShopEvent(
                                product: widget.product,
                                measurementIndex: '$_productCount',
                              ),
                            );
                          }
                        },
                      )
                    : Container(),
                SizedBox(
                  width: 5,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            alignment: Alignment.bottomLeft,
            width: 120,
          ),
          alignment: Alignment.centerLeft,
        );
      },
      cubit: _shoppingBloc,
    );
  }
}
