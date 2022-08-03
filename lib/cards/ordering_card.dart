import 'package:flutter/material.dart';
import 'package:idehshop/models/order.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_ordering_tab/ordering_page_details.dart';
import 'package:idehshop/utils.dart';

class OrderingCard extends StatefulWidget {
  final Order order;
  final Role role;

  OrderingCard({@required this.order, @required this.role});

  @override
  _OrderingCardState createState() => _OrderingCardState();
}

class _OrderingCardState extends State<OrderingCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: SingleChildScrollView(
          child: Column(
            children: _getRows(),
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15.0,
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        elevation: 1.0,
      ),
      onTap: () => _orderCardSelected(context),
    );
  }

  List<Widget> _getRows() {
    List<Widget> _children = List();
    _children.addAll([
      Row(
        children: <Widget>[
          Container(
            child: Text(
              'خرید',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(10.0),
                bottomRight: const Radius.circular(10.0),
              ),
              color: Theme.of(context).primaryColorLight,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      SizedBox(
        height: 5.0,
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Text(
                'مبلغ خرید',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Text(
                '${getFormattedPrice(int.parse('${widget.order.totalPrice ?? 0}'))} تومان ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              alignment: Alignment.bottomLeft,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5.0,
      ),
    ]);

    /// get order products
    String _products = '';
    (widget.order.titles).asMap().forEach((index, element) {
      _products = "$_products$element";
      if (index != (widget.order.titles.length - 1)) {
        _products = '$_products , ';
      }
    });

    _children.addAll([
      Row(
        children: [
          Text('اقلام خریداری شده: '),
          Expanded(
            child: Text(
              _products,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    ]);

    _children.addAll([
      SizedBox(
        height: 10.0,
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Text(
                widget.order.accepted
                    ? 'این خرید پذیرفته شده است'
                    : 'این خرید هنوز پذیرفته نشده است',
                style: Theme.of(context).textTheme.caption.copyWith(
                      color: widget.order.accepted ? Colors.green : Colors.red,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10.0,
      ),
    ]);

    return _children;
  }

  _orderCardSelected(BuildContext context) {
//    if (widget.role == Role.provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return OrderingPageDetails(
            order: widget.order,
            key: Key(
              "${widget.order.id}",
            ),
            role: widget.role,
          );
        },
      ),
    );
//    }
  }
}
