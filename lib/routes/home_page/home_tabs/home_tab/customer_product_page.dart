import 'dart:convert';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/product_count.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/utils.dart';

class CustomerProductPage extends StatefulWidget {
  @override
  _CustomerProductPageState createState() => _CustomerProductPageState();
}

class _CustomerProductPageState extends State<CustomerProductPage> {
  ShoppingBloc _shoppingBloc;
  ScrollController _controller = ScrollController();
  bool _showSliverAppBarTitle = false;
  bool _overLayed = false;
  Product _productDetails;
  List<dynamic> _images = List();
  OverlayState _overlayState;

  OverlayEntry _overLayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
      _overlayState = Overlay.of(context);
      _getProductDetails();
      _controller.addListener(() {
        if (_controller.position.extentBefore < 80) {
          if (mounted) {
            setState(() {
              _showSliverAppBarTitle = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _showSliverAppBarTitle = true;
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ShoppingBloc, ShoppingState>(
        listener: (context, state) {
          if (state is ShowMessageShopState) {
            final snackBar = SnackBar(
              content: Text(
                state.msg,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: Theme.of(context).textTheme.bodyText1.fontFamily,
                ),
              ),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          }
          if (state is JwtExpiredShopState) {
            Navigator.pushReplacementNamed(context, '/login');
          }
          // if (state is DeletedProductFromBasketShopState ||
          //     state is AddedNewProductShopState) {
          //   _getProductDetails();
          // }
        },
        builder: (context, state) {
          return _shoppingBloc != null
              ? WillPopScope(
                  child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        _getSliverAppBar(_shoppingBloc.selectedProduct),
                      ];
                    },
                    body: _productDetails != null
                        ? SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Text('نام محصول:'),
                                    Expanded(
                                      child: Text(
                                        "${_productDetails.title}",
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  children: [
                                    Text('قیمت:'),
                                    Expanded(
                                      child: Text(
                                        "${getFormattedPrice(int.parse('${_productDetails.price}'))} تومان",
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              decoration: (_productDetails
                                                              .offPrice !=
                                                          null &&
                                                      '${_productDetails.offPrice}' !=
                                                          '0')
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              decorationColor: (_productDetails
                                                              .offPrice !=
                                                          null &&
                                                      '${_productDetails.offPrice}' !=
                                                          '0')
                                                  ? Theme.of(context).errorColor
                                                  : Colors.green[700],
                                              decorationThickness: 2,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                '${_productDetails.offPrice}' != '0'
                                    ? Row(
                                        children: [
                                          Text('قیمت با تخفیف:'),
                                          Expanded(
                                            child: Text(
                                              "${getFormattedPrice(int.parse('${_productDetails.offPrice}'))} تومان",
                                              textAlign: TextAlign.left,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                '${_productDetails.offPrice}' != '0'
                                    ? Divider()
                                    : Container(),
                                Row(
                                  children: [
                                    Text('واحد:'),
                                    Expanded(
                                      child: Text(
                                        "${_productDetails.measurementIndex} ${_productDetails.measurement}",
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                (_productDetails.description != null &&
                                        _productDetails.description != '')
                                    ? Row(
                                        children: [
                                          Text('توضیحات:'),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(
                                              "${_productDetails.description}",
                                              textAlign: TextAlign.left,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                (_productDetails.description != null &&
                                        _productDetails.description != '')
                                    ? Divider()
                                    : Container(),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'تعداد درخواستی:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    ProductCount(
                                      product: _productDetails,
                                      iconSize: 22,
                                      distance: 10,
                                    ),
                                  ],
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                            ),
                            padding: EdgeInsets.all(15),
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                    controller: _controller,
                  ),
                  onWillPop: _onWillPop,
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
        cubit: _shoppingBloc,
      ),
    );
  }

  Widget _getSliverAppBar(Product _product) {
    return SliverAppBar(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      leading: Builder(
        builder: (context) {
          return InkWell(
            child: Stack(
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/images/basket.png',
                    scale: 3,
                  ),
                  tooltip: 'خرید‌نهایی',
                  onPressed: null,
                ),
                (_shoppingBloc != null &&
                    _shoppingBloc.buyingProducts.length > 0)
                    ? Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.red,
                    ),
                    child: Text(
                      "${_shoppingBloc.buyingProducts.length}",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    alignment: Alignment.center,
                    height: 20,
                    width: 20,
                  ),
                  top: 10.0,
                  left: 10.0,
                )
                    : Container(),
              ],
            ),
            onTap: () => _basketClicked(context),
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedOpacity(
          opacity: _showSliverAppBarTitle ? 1.0 : 0.0,
          duration: Duration(milliseconds: 150),
          child: Container(
            child: Text(
              _product.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.subtitle2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            width: MediaQuery.of(context).size.width - 80,
          ),
        ),
        background: _product.imageAddresses.isNotEmpty
            ? Carousel(
          images: _images,
          defaultImage: Image(
            image: AssetImage(
              'assets/images/default_basket.png',
            ),
            fit: BoxFit.fitWidth,
          ),
          autoplay: false,
          dotBgColor: Colors.black26,
          dotSize: 8,
        )
            : Image(
          image: AssetImage(
            'assets/images/default_basket.png',
          ),
          fit: BoxFit.fitWidth,
        ),
      ),
      centerTitle: true,
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
    );
  }

  _basketClicked(BuildContext context) {
    if (_shoppingBloc.buyingProducts.length == 0) {
      Fluttertoast.showToast(
        msg: "سبد خرید شما خالی است.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
      );
    } else {
      Navigator.pushNamed(context, '/buying');
    }
  }

  _getProductDetails() async {
    final res = await http.get(
      '$BASE_URI/product/info/${_shoppingBloc.selectedProduct.id}',
      headers: {
        'Authorization': "Bearer ${_shoppingBloc.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper _wrapper = ResponseWrapper.fromJson(
        jsonDecode(res.body),
      );
      if (_wrapper.code == 200) {
        _productDetails = Product.fromJson(_wrapper.data);

        setState(() {
          _shoppingBloc.selectedProduct = _productDetails;
        });
        _getProductImages();
      }
    }
  }

  _getProductImages() {
    _productDetails.imageAddresses.forEach((element) {
      _images.add(
        InkWell(
          child: Image.network(
            'http://$element',
            fit: BoxFit.fitWidth,
          ),
          onTap: () {
            if (mounted) {
              setState(() {
                _overLayed = true;
              });
            }
            _overLayEntry = OverlayEntry(builder: (context) {
              return Container(
                child: GestureDetector(
                  child: Image.network(
                    'http://$element',
                    fit: BoxFit.fitWidth,
                  ),
                  onTap: () {
                    _overLayEntry.remove();
                    setState(() {
                      _overLayed = false;
                    });
                  },
                ),
                color: Colors.black,
              );
            });
            _overlayState.insert(_overLayEntry);
          },
        ),
      );
    });
  }

  Future<bool> _onWillPop() async {
    if (_overLayed) {
      if (mounted) {
        setState(() {
          _overLayed = false;
        });
      }
      _overLayEntry.remove();
    } else {
      Navigator.of(context).pop();
    }

    return false;
  }
}
