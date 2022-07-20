import 'package:flutter/material.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/managers/cache_manager.dart';
import 'package:idehshop/managers/database_manager.dart';
import 'package:idehshop/models/store.dart';

class CategoryPageShopCard extends StatefulWidget {
  final Store store;
  final CacheManager cacheManager;
  final bool isOpen;

  CategoryPageShopCard({
    @required this.store,
    @required this.cacheManager,
    this.isOpen,
  });

  @override
  _CategoryPageShopCardState createState() => _CategoryPageShopCardState();
}

class _CategoryPageShopCardState extends State<CategoryPageShopCard> {
  bool _isFavorite = false;
  AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      _checkShopFavorite();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          widget.store.imageAddress != null
              ? Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "http://${widget.store.imageAddress}",
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
                  '${widget.store.title}',
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
          widget.isOpen
              ? Container()
              : Positioned.fill(
                  child: Opacity(
                    opacity: 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
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
                        alignment: Alignment.topCenter,
                      ),
                      padding: EdgeInsets.only(top: 5),
                    ),
                  ),
                ),
          Positioned(
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: _createUpdateShopFavorite,
            ),
            top: 0.0,
            right: 0.0,
          ),
          (widget.store.score != null && '${widget.store.score}' != '0')
              ? Positioned(
                  child: Container(
                    child: Text(
                      '${widget.store.score}',
                      style: Theme.of(context).textTheme.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      color: Colors.green,
                    ),
                    padding: EdgeInsets.all(2),
                  ),
                  top: 4.0,
                  left: 4.0,
                )
              : Container(),
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

  _checkShopFavorite() {
    List<Map<String, dynamic>> _shops = _authenticationBloc.favoriteShops;
    _shops.forEach((shop) {
      if (shop['id'] == widget.store.id && shop['favorite'] == 1) {
        setState(() {
          _isFavorite = true;
        });
      }
    });
  }

  _createUpdateShopFavorite() {
    List<Map<String, dynamic>> _shops = _authenticationBloc.favoriteShops;
    bool _itExcised = false;
    _shops.forEach((shop) {
      if (shop['id'] == widget.store.id && shop['favorite'] == 1) {
        _itExcised = true;
      }
    });

    if (_itExcised) {
      if (_isFavorite) {
        setState(() {
          _isFavorite = false;
        });
        _updateShopFavorite('${widget.store.id}', 0);
        _updateShopFavoriteInBloc('${widget.store.id}', 0);
      } else {
        setState(() {
          _isFavorite = true;
        });
        _updateShopFavorite('${widget.store.id}', 1);
        _updateShopFavoriteInBloc('${widget.store.id}', 1);
      }
    } else {
      setState(() {
        _isFavorite = true;
      });
      _createShopFavorite(widget.store.id, 1);
      _authenticationBloc.allFavoriteShopsDetails.add(widget.store);
      Map<String, dynamic> _map = Map();
      _map['id'] = widget.store.id;
      _map['favorite'] = 1;
      _authenticationBloc.favoriteShops.add(_map);
    }
  }

  _updateShopFavorite(String _id, int _favorite) {
    DataBaseManager _dataBase = DataBaseManager();
    _dataBase.open().then(
          (value) =>
              _dataBase.updateFavoriteShop(_id, _favorite).then((value) => {}),
        );
  }

  _updateShopFavoriteInBloc(String _id, int _favorite) {
    _authenticationBloc.favoriteShops
        .removeWhere((element) => element['id'] == _id);
    Map<String, dynamic> _map = Map();
    _map['id'] = _id;
    _map['favorite'] = _favorite;
    _authenticationBloc.favoriteShops.add(_map);
    if (_favorite == 1) {
      _authenticationBloc.allFavoriteShopsDetails.add(widget.store);
    } else if (_favorite == 0) {
      _authenticationBloc.allFavoriteShopsDetails
          .removeWhere((element) => element.id == _id);
    }
  }

  _createShopFavorite(String _id, int _favorite) {
    DataBaseManager _dataBase = DataBaseManager();
    _dataBase.open().then(
          (value) =>
              _dataBase.createFavoriteShop(_id, _favorite).then((value) => {}),
        );
  }
}
