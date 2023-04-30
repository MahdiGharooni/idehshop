import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/models/order.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_invoices_tab/invoices_page_details.dart';
import 'package:idehshop/utils.dart';

class ShopRate extends StatefulWidget {
  final Order order;

  ShopRate({@required this.order});

  @override
  _ShopRateState createState() => _ShopRateState();
}

class _ShopRateState extends State<ShopRate> {
  int _score = 0;
  AuthenticationBloc _authenticationBloc;
  bool _loading = true;
  ShoppingBloc _shoppingBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
        _shoppingBloc = BlocProvider.of<ShoppingBloc>(context);
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'نظرسنجی',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: _authenticationBloc != null
          ? BlocConsumer(
              listener: (context, state) {
                if (state is AddedShopRateShopState) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      return InvoicesPageDetails(
                        order: widget.order,
                        role: Role.customer,
                      );
                    }),
                  );
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Center(
                    child: Card(
                      child: Container(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              ' ${_authenticationBloc.user.firstName ?? 'کاربر'} عزیز ، با ثبت نظر خود به انتخاب دیگران کمک کنید ',
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                InkWell(
                                  child: Icon(
                                    _score >= 1
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.yellow[600],
                                    size: 30,
                                  ),
                                  onTap: () => _setScore(1),
                                ),
                                InkWell(
                                  child: Icon(
                                    _score >= 2
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.yellow[600],
                                    size: 30,
                                  ),
                                  onTap: () => _setScore(2),
                                ),
                                InkWell(
                                  child: Icon(
                                    _score >= 3
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.yellow[600],
                                    size: 30,
                                  ),
                                  onTap: () => _setScore(3),
                                ),
                                InkWell(
                                  child: Icon(
                                    _score >= 4
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.yellow[600],
                                    size: 30,
                                  ),
                                  onTap: () => _setScore(4),
                                ),
                                InkWell(
                                  child: Icon(
                                    _score >= 5
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.yellow[600],
                                    size: 30,
                                  ),
                                  onTap: () => _setScore(5),
                                ),
                              ],
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Center(
                                child: Text('$_score'),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: EdgeInsets.all(10),
                              height: 50,
                              width: 50,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RaisedButton(
                              onPressed: () {
                                if (_score == 0) {
                                  return null;
                                } else {
                                  setState(() {
                                    _loading = true;
                                  });
                                  _shoppingBloc.add(AddShopRateShopEvent(
                                    orderId: widget.order.id,
                                    score: _score,
                                  ));
                                }
                              },
                              child: _loading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'ثبت نظر',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .button
                                            .color,
                                      ),
                                    ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10.0,
                                ),
                              ),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 0.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          15.0,
                        ),
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                      elevation: 1.0,
                    ),
                  ),
                );
              },
              cubit: _shoppingBloc,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  _setScore(int i) {
    setState(() {
      _score = i;
    });
  }
}
