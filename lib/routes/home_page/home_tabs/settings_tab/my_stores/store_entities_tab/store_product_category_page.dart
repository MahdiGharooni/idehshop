import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/profile_edit_row.dart';
import 'package:idehshop/models/product_category.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class StoreProductCategoryPage extends StatefulWidget {
  final TYPE type;
  final ProductCategory productCategory;

  StoreProductCategoryPage({
    @required this.type,
    this.productCategory,
    this.key,
  });

  final Key key;

  @override
  _StoreProductCategoryPageState createState() =>
      _StoreProductCategoryPageState();
}

class _StoreProductCategoryPageState extends State<StoreProductCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController;
  File _imageFile;
  String _imageUrl;
  bool _verified = false;
  bool _loading = false;
  StoreBloc _storeBloc;
  String id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      if (widget.type == TYPE.edit) {
        _getProductCategoryInfo();
      } else {
        _titleController = TextEditingController();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == TYPE.edit
              ? 'ویرایش دسته بندی'
              : 'اضافه کردن دسته بندی',
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
                  onPressed: _deleteProductCategory,
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
          if (state is AddedProductCategoryStoreState ||
              state is EditedProductCategoryStoreState) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return _titleController != null
              ? SingleChildScrollView(
                  child: Card(
                    child: Container(
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            _imageFile != null
                                ? Image.file(
                                    _imageFile,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.fill,
                                  )
                                : (_imageUrl != null &&
                                        !_imageUrl.contains('null'))
                                    ? Stack(
                                        children: [
                                          Image.network(
                                            _imageUrl,
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
                                              onPressed: () {
                                                setState(() {
                                                  _imageUrl = null;
                                                });
                                              },
                                            ),
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
                                                    _showAlertDialog(context),
                                                padding: EdgeInsets.all(0.0),
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
                                        onTap: () => _showAlertDialog(context),
                                      ),
                            SizedBox(
                              height: 5.0,
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            ProfileEditRow(
                              controller: _titleController,
                              prefixText: 'نام دسته بندی:*',
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
                            widget.type == TYPE.edit
                                ? Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'وضعیت دسته بندی',
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
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: _imageSource);

    File _cropped = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 375,
      maxWidth: 500,
      compressQuality: 50,
      cropStyle: CropStyle.rectangle,
    );

    this.setState(() {
      _imageFile = _cropped;
    });
    Navigator.of(context).pop();
  }

  _getProductCategoryInfo() async {
    final res = await http.get(
      '$BASE_URI/shop/products/category/${widget.productCategory.id}',
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
        _imageUrl = 'http://${_data['imageAddress']}';
        _verified = _data['verified'];
        id = _data['id'];
        setState(() {});
      }
    }
  }

  _deleteProductCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'حذف کردن دسته بندی',
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.right,
          ),
          content: Text(
            'آیا از حذف این دسته بندی مطمعن هستید؟ این عمل برگشت پذیر نمیباشد',
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
                  '$BASE_URI/shop/products/category/${widget.productCategory.id}',
                  headers: {
                    'Authorization': "Bearer ${_storeBloc.user.authCode}",
                  },
                );
                ResponseWrapper _wrapper =
                    ResponseWrapper.fromJson(jsonDecode(res.body));
                if (_wrapper.code == 200) {
                  _storeBloc.add(SubmitDeleteProductCategoryEvent());
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

  _saveChanges(BuildContext context) {
    if (_formKey.currentState.validate()) {
      setState(() {
        _loading = true;
      });
      if (widget.type == TYPE.edit) {
        _storeBloc.add(
          SubmitEditProductCategoryEvent(
            id: widget.productCategory.id,
            title: _titleController.text,
            imageFile: _imageFile,
          ),
        );
      } else {
        _storeBloc.add(SubmitCreateProductCategoryEvent(
          title: _titleController.text,
          imageFile: _imageFile ?? null,
        ));
      }
    }
  }
}
