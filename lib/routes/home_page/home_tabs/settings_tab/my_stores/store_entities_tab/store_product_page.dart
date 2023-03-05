import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/profile_edit_row.dart';
import 'package:idehshop/models/product.dart';
import 'package:idehshop/models/product_category.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class StoreProductPage extends StatefulWidget {
  final TYPE type;
  final Product product;
  final Key key;
  final ProductCategory productCategory;

  StoreProductPage(
      {@required this.type,
      @required this.productCategory,
      this.product,
      @required this.key});

  @override
  _StoreProductPageState createState() => _StoreProductPageState();
}

class _StoreProductPageState extends State<StoreProductPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController;
  TextEditingController _priceController;
  TextEditingController _offPriceController;
  TextEditingController _measurementIndexController;
  TextEditingController _descriptionController;
  String _measurementValue;
  String _productCategoryTitle;
  String _productCategoryId;
  Map<String, File> _imagesFiles = Map();
  Map<String, String> _imagesUrls = Map();
  List<String> _productsMeasurements = List();
  List<String> _deletedImagesUrls = List();
  List<ProductCategory> _allProductCategories = List();
  List<String> _productCategoriesTitles = List();
  bool _available = false;
  bool _verified = false;
  bool _loading = false;
  StoreBloc _storeBloc;
  int _imagesCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      if (widget.type == TYPE.edit) {
        _getProductInfo();

        if (widget.product != null) {
          _available = widget.product.available;
          _verified = widget.product.verified;
          (widget.product.imageAddresses ?? []).forEach(
            (element) {
              _imagesCount++;
              _imagesUrls['$_imagesCount'] = "http://$element";
            },
          );
        }
      } else {
        _titleController = TextEditingController();
        _descriptionController = TextEditingController();
        _priceController = TextEditingController();
        _offPriceController = TextEditingController(text: ' 0');
        _measurementIndexController = TextEditingController();
        _productsMeasurements.addAll(PRODUCT_MEASUREMENTS);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == TYPE.edit ? 'ویرایش محصول' : 'اضافه کردن محصول',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          widget.type == TYPE.edit
              ? IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: _deleteProduct,
                )
              : Container(),
        ],
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<StoreBloc, StoreState>(
        listener: (context, state) {
          if (state is ShowMessageStoreState) {
            setState(() {
              _loading = false;
            });
            final snackBar = SnackBar(content: Text(state.message));
            Scaffold.of(context).showSnackBar(snackBar);
          }
          if (state is JwtExpiredStoreState) {
            Navigator.pushReplacementNamed(context, '/login');
          }
          if (state is AddedNewProductStoreState) {
            Navigator.of(context).pop();
          }
          if (state is EditedProductStoreState) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return _descriptionController != null
              ? SingleChildScrollView(
                  child: Card(
                    child: Container(
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            GridView.builder(
                              itemBuilder: (context, index) {
                                return (_imagesFiles.isNotEmpty &&
                                        _imagesFiles
                                            .containsKey('${index + 1}'))
                                    ? Stack(
                                        children: [
                                          Image.file(
                                            _imagesFiles['${index + 1}'],
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.fill,
                                          ),
                                          Positioned(
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  _deleteImage(index + 1),
                                            ),
                                            top: 0.0,
                                            right: 0.0,
                                          ),
                                        ],
                                      )
                                    : (_imagesUrls.isNotEmpty &&
                                            _imagesUrls
                                                .containsKey('${index + 1}'))
                                        ? Stack(
                                            children: [
                                              Image.network(
                                                _imagesUrls['${index + 1}'],
                                                height: 150,
                                                width: 150,
                                                fit: BoxFit.fill,
                                              ),
                                              Positioned(
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.cancel,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      _deleteImage(index + 1),
                                                ),
                                                top: 0.0,
                                                right: 0.0,
                                              ),
                                            ],
                                          )
                                        : InkWell(
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.add_photo_alternate,
                                                      color: Theme.of(context)
                                                          .disabledColor,
                                                    ),
                                                    onPressed: () =>
                                                        _showAlertDialog(
                                                            context),
                                                    padding:
                                                        EdgeInsets.all(0.0),
                                                  ),
                                                  Text(
                                                    'عکس شماره ${index + 1}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption,
                                                  ),
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                border: Border.all(width: 0.5),
                                              ),
                                            ),
                                            onTap: () =>
                                                _showAlertDialog(context),
                                          );
                              },
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 15.0,
                                crossAxisSpacing: 15.0,
                              ),
                              itemCount: 4,
                              shrinkWrap: true,
                              padding: EdgeInsets.all(
                                15.0,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            ProfileEditRow(
                              controller: _titleController,
                              prefixText: 'نام محصول:*',
                              keyboardType: TextInputType.text,
                              validator: (String value) {
                                return value.isEmpty
                                    ? 'فیلد نام  اجباری است'
                                    : null;
                              },
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            ProfileEditRow(
                              controller: _priceController,
                              prefixText: 'قیمت محصول(تومان):*',
                              keyboardType: TextInputType.number,
                              validator: (String value) {
                                return (value.isEmpty || value == '0')
                                    ? 'فیلد قیمت اجباری است'
                                    : null;
                              },
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            ProfileEditRow(
                              controller: _offPriceController,
                              prefixText: 'قیمت با تخفیف(تومان):',
                              keyboardType: TextInputType.number,
                              validator: (String value) {
                                if (value != '0' &&
                                    _priceController.text != '0') {
                                  return int.parse(value) >=
                                          int.parse(_priceController.text)
                                      ? 'قیمت با تخفیف باید از قیمت اصلی کمتر باشد'
                                      : null;
                                } else {
                                  return null;
                                }
                              },
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            (widget.type == TYPE.edit &&
                                    _productCategoryTitle != null)
                                ? Container(
                                    child: DropdownButton(
                                      items: _productCategoriesTitles
                                          .map((String _pc) {
                                        return DropdownMenuItem(
                                          child: Container(
                                            child: Text(_pc),
                                            alignment: Alignment.centerRight,
                                          ),
                                          key: Key(_pc),
                                          value: _pc,
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _productCategoryTitle = value;
                                          _allProductCategories
                                              .forEach((element) {
                                            if (element.title == value) {
                                              _productCategoryId = element.id;
                                            }
                                          });
                                        });
                                      },
                                      hint: Container(
                                        child: Text(
                                          'دسته بندی',
                                          textAlign: TextAlign.center,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                        ),
                                      ),
                                      isExpanded: true,
                                      value: _productCategoryTitle,
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                  )
                                : Container(),
                            SizedBox(
                              height: 5.0,
                            ),
                            Container(
                              child: DropdownButton(
                                items: _productsMeasurements
                                    .map((String _measurement) {
                                  return DropdownMenuItem(
                                    child: Container(
                                      child: Text(_measurement),
                                      alignment: Alignment.centerRight,
                                    ),
                                    key: Key(_measurement),
                                    value: _measurement,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _measurementValue = value;
                                  });
                                },
                                hint: Container(
                                  child: Text(
                                    'واحد اندازه گیری',
                                    textAlign: TextAlign.center,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                ),
                                isExpanded: true,
                                value: _measurementValue,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            ProfileEditRow(
                              controller: _measurementIndexController,
                              prefixText: 'مقدار واحد:*',
                              keyboardType: TextInputType.number,
                              validator: (String value) {
                                return value.isEmpty
                                    ? 'فیلد مقدار واحد اجباری است'
                                    : null;
                              },
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            ProfileEditRow(
                              controller: _descriptionController,
                              prefixText: 'توضیحات:',
                              keyboardType: TextInputType.multiline,
                              maxLines: 2,
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'نمایش محصول برای کاربران',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    onChanged: switchOnChanged,
                                    value: _available,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5.0),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            widget.type == TYPE.edit
                                ? Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'وضعیت تایید توسط ادمین',
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            _verified
                                                ? 'تاییدشده'
                                                : 'تاییدنشده',
                                            style: TextStyle(
                                              color: _verified
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 5.0),
                                  )
                                : Container(),
                            SizedBox(
                              height: 5.0,
                            ),
                            Container(
                              child: RaisedButton(
                                child: state is LoadingStoreState
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : _loading
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : Text(
                                            'ثبت تغییرات',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                onPressed: () => _saveChanges(context),
                              ),
                              width: 150,
                            ),
                          ],
                        ),
                        key: _formKey,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20.0,
                      ),
                    ),
                    margin:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    elevation: 1.0,
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
        cubit: _storeBloc,
      ),
    );
  }

  _saveChanges(BuildContext context) {
    if (_formKey.currentState.validate()) {
      if (_measurementValue == null || _measurementValue == '') {
        final snackBar = SnackBar(
          content: Text(
            'لطفا واحد اندازه گیری را مشخص کنید',
            textAlign: TextAlign.right,
          ),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      } else {
        setState(() {
          _loading = true;
        });
        _storeBloc.add(ShowLoadingStoreEvent());
        _storeBloc.title = _titleController.text;
        _storeBloc.available = _available;
        _storeBloc.measurement = _measurementValue;
        _storeBloc.measurementIndex =
            double.parse(_measurementIndexController.text ?? '0');
        _storeBloc.price = int.parse(_priceController.text ?? '0');
        _storeBloc.offPrice = int.parse(_offPriceController.text ?? '0');
        _storeBloc.description = _descriptionController.text ?? null;
//        _storeBloc.imageFile = _imageFile ?? null;
        _imagesFiles.forEach((key, value) {
          _storeBloc.imagesFiles.add(value);
        });
        if (widget.type == TYPE.edit) {
          _storeBloc.add(SubmitEditProductStoreEvent(
            product: widget.product,
            productCategoryId: _productCategoryId,
          ));
          if (_deletedImagesUrls.isNotEmpty) {
            _storeBloc.add(
              SubmitDeleteProductImage(
                  product: widget.product,
                  deletedImagesUrls: _deletedImagesUrls),
            );
          }
        } else {
          _storeBloc.add(SubmitAddProductStoreEvent(
            productCategoryId: widget.productCategory.id,
          ));
        }
      }
    }
  }

  switchOnChanged(bool value) {
    setState(() {
      _available = value;
    });
  }

  Future<void> _showAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text(
                    'گالری',
                  ),
                  onTap: () =>
                      _imageSourceSelected(context, ImageSource.gallery),
                ),
                SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  child: Text(
                    'دوربین',
                  ),
                  onTap: () =>
                      _imageSourceSelected(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _imageSourceSelected(BuildContext context, ImageSource _imageSource) async {
    _imagesCount++;
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: _imageSource);

    File _cropped = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 512,
      maxWidth: 512,
      compressQuality: 50,
      cropStyle: CropStyle.rectangle,
    );

    this.setState(() {
      _imagesFiles['$_imagesCount'] = _cropped;
    });
    Navigator.of(context).pop();
  }

  _getProductInfo() async {
    final res = await http.get(
      '$BASE_URI/shopper/product/${widget.product.id}',
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper responseWrapper =
          ResponseWrapper.fromJson(jsonDecode(res.body));
      if (responseWrapper.code == 200) {
        Map<String, dynamic> _data = responseWrapper.data;
        _titleController = TextEditingController(text: _data['title'] ?? ' ');
        _productCategoryId = _data['productKindId'];
        _descriptionController =
            TextEditingController(text: "${_data['description'] ?? ' '}");
        _priceController =
            TextEditingController(text: "${_data['price'] ?? 0}");
        _offPriceController =
            TextEditingController(text: "${_data['offPrice'] ?? 0}");
        _measurementValue = "${_data['measurement'] ?? ''}";
        _measurementIndexController =
            TextEditingController(text: "${_data['measurementIndex'] ?? 0}");
        _productsMeasurements.addAll(PRODUCT_MEASUREMENTS);
        _checkMeasurement(_measurementValue);
        _getProductCategories();
      }
    }
  }

  _getProductCategories() async {
    final res = await http.get(
      '$BASE_URI/shop/products/categories/${_storeBloc.currentStore.id}/1?limit=100',
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    if (res.statusCode == 200) {
      ResponseWrapper responseWrapper =
          ResponseWrapper.fromJson(jsonDecode(res.body));
      if (responseWrapper.code == 200) {
        (responseWrapper.data as List).forEach((element) {
          _allProductCategories.add(ProductCategory.fromJson(element));
          _productCategoriesTitles.add(element['title']);
        });

        /// find product title
        _allProductCategories.forEach((element) {
          if (element.id == _productCategoryId) {
            _productCategoryTitle = element.title;
          }
        });
        setState(() {});
      }
    }
  }

  _checkMeasurement(String _value) {
    int _index =
        _productsMeasurements.indexWhere((element) => element == _value);
    if (_index < 0) {
      _productsMeasurements.add(_value);
    }
  }

  _deleteImage(int index) {
    if (_imagesUrls.containsKey('$index')) {
      _deletedImagesUrls.add("${_imagesUrls['$index']}");
      _imagesUrls.removeWhere((key, value) => key == '$index');
    }
    _imagesFiles.removeWhere((key, value) => key == '$index');
    setState(() {});
  }

  _deleteProduct() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'حذف کردن محصول',
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.right,
          ),
          content: Text(
            'آیا از حذف این محصول مطمعن هستید؟ این عمل برگشت پذیر نمیباشد',
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.right,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'خیر',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Theme.of(context).accentColor,
                    ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'بله، حذف شود',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Colors.red,
                    ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                final res = await http.delete(
                  '$BASE_URI/shop/product/${widget.product.id}',
                  headers: {
                    'Authorization': "Bearer ${_storeBloc.user.authCode}",
                  },
                );
                ResponseWrapper _wrapper =
                    ResponseWrapper.fromJson(jsonDecode(res.body));
                if (_wrapper.code == 200) {
                  _storeBloc.add(SubmitDeleteProductEvent());
                  Navigator.pushReplacementNamed(context, '/store');
                } else {
                  Fluttertoast.showToast(
                    msg: getMessage(_wrapper.message),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 16.0,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
            ),
          ],
          contentPadding: EdgeInsets.all(10),
          actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _offPriceController.dispose();
    _measurementIndexController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
