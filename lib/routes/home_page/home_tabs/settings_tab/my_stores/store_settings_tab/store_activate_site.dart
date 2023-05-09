import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:idehshop/blocs/bloc.dart';
import 'package:idehshop/cards/error_description_row.dart';
import 'package:idehshop/cards/profile_edit_row.dart';
import 'package:idehshop/cards/profile_row.dart';
import 'package:idehshop/models/response_wrapper.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/routes/home_page/home_tabs/settings_tab/my_stores/store_page.dart';
import 'package:idehshop/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreActivateSite extends StatefulWidget {
  @override
  _StoreActivateSiteState createState() => _StoreActivateSiteState();
}

class _StoreActivateSiteState extends State<StoreActivateSite> {
  StoreBloc _storeBloc;
  bool _loading = true;
  bool _activeLoading = false;
  Store _store;
  String _cost = '0';
  String _ipAddress = '';
  final _formKey = GlobalKey<FormState>();
  TextEditingController _editingController =
      TextEditingController(text: 'example.com');
  File _bannerFile;
  List<String> _bannerUrls = List();
  List<String> _deletedImagesUrls = List();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeBloc = BlocProvider.of<StoreBloc>(context);
      setState(() {
        _store = _storeBloc.currentStore;
        if (_store.siteInfo != null) {
          _editingController =
              TextEditingController(text: _store.siteInfo['domain']);
          (_store.siteInfo['banners'] ?? []).forEach(
            (element) {
              _bannerUrls.add("http://$element");
            },
          );
        }
      });

      _getShopSiteInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سایت اختصاصی',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: (_loading && _store == null)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: ListView(
                children: [
                  // SizedBox(
                  //   height: 20,
                  // ),
                  _store.siteInfo != null
                      ? Container()
                      : ErrorDescriptionRow(
                          description:
                              'در این قسمت میتوانید سایت اختصاصی فروشگاه خود را بسازید و محصولات خود را برای فروش اراعه دهید.',
                        ),
                  _store.siteInfo != null
                      ? SizedBox(
                          height: 10,
                        )
                      : Container(),
                  _store.siteInfo != null
                      ? Card(
                          child: Container(
                            child: Row(
                              children: [
                                Icon(Icons.web),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'کانفیگ سایت',
                                  style: Theme.of(context).textTheme.subtitle2,
                                )
                              ],
                            ),
                            padding: EdgeInsets.all(10),
                          ),
                        )
                      : Container(),
                  _store.siteInfo != null
                      ? Card(
                          child: ProfileRow(
                            icon: null,
                            label: 'Ip Address',
                            value: _ipAddress,
                          ),
                        )
                      : Container(),
                  _store.siteInfo == null
                      ? SizedBox(
                          height: 20,
                        )
                      : Container(),
                  _store.siteInfo != null
                      ? Card(
                          child: Container(
                            child: Column(
                              children: [
                                Form(
                                  child: ProfileEditRow(
                                    controller: _editingController,
                                    prefixText: 'دامنه',
                                    keyboardType: TextInputType.url,
                                    hintText: 'example.com',
                                    maxLines: 1,
                                    validator: (value) {
                                      return value.isEmpty
                                          ? 'فیلد دامنه اجباری است'
                                          : value.length < 6
                                              ? 'فرمت دامنه صحیح نمیباشد'
                                              : null;
                                    },
                                  ),
                                  key: _formKey,
                                ),
                                Container(
                                  child: Text(
                                    'لطفا نام دامنه را بدون .www وارد کنید.',
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(vertical: 5),
                          ),
                        )
                      : ErrorDescriptionRow(
                          description:
                              'بعد از فعالسازی سایت میتوانید نام دامنه و تنظیمات مربوط به آنرا از همین قسمت انجام دهید.',
                        ),
                  _store.siteInfo != null
                      ? Container()
                      : SizedBox(
                          height: 10,
                        ),
                  _store.siteInfo != null
                      ? Container()
                      : ErrorDescriptionRow(
                          description:
                              'هزینه فعالسازی سایت ${getFormattedPrice(int.parse(_cost))} ریال میباشد و میتوانید بمدت نامحدود از آن استفاده کنید.',
                        ),
                  _store.siteInfo == null
                      ? Container()
                      : SizedBox(
                          height: 20,
                        ),
                  _store.siteInfo == null
                      ? Container()
                      : Card(
                          child: Container(
                            child: Row(
                              children: [
                                Icon(Icons.image),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'بنرهای سایت',
                                  style: Theme.of(context).textTheme.subtitle2,
                                )
                              ],
                            ),
                            padding: EdgeInsets.all(10),
                          ),
                        ),
                  _store.siteInfo == null
                      ? Container()
                      : Card(
                          child: GridView.builder(
                            itemBuilder: (context, index) {
                              return index < _bannerUrls.length
                                  ? Stack(
                                      children: [
                                        Image.network(
                                          _bannerUrls[index],
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
                                            onPressed: () => _deleteImage(
                                                _bannerUrls[index]),
                                          ),
                                          top: 0.0,
                                          right: 0.0,
                                        ),
                                      ],
                                    )
                                  : _bannerFile != null
                                      ? Stack(
                                          children: [
                                            Image.file(
                                              _bannerFile,
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
                                                  onPressed: () {
                                                    setState(() {
                                                      _bannerFile = null;
                                                    });
                                                  }),
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
                                                      _showAlertDialog(context),
                                                  padding: EdgeInsets.all(0.0),
                                                ),
                                                Text(
                                                  'بنر جدید',
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
                                            height: 150,
                                            width: 150,
                                          ),
                                          onTap: () =>
                                              _showAlertDialog(context),
                                        );
                            },
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 15.0,
                              crossAxisSpacing: 15.0,
                            ),
                            itemCount: (_bannerUrls.length + 1),
                            shrinkWrap: true,
                            padding: EdgeInsets.all(
                              15.0,
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  _store.siteInfo != null
                      ? Center(
                          child: Container(
                            child: RaisedButton(
                              onPressed: () => _submitChanges(),
                              child: _activeLoading
                                  ? CircularProgressIndicator(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    )
                                  : Text(
                                      'ثبت تغییرات',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .button
                                            .color,
                                      ),
                                    ),
                            ),
                            width: 200,
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 40,
                  ),
                  _store.siteInfo != null
                      ? Container()
                      : Center(
                          child: Container(
                            child: RaisedButton(
                              onPressed: () => _active(),
                              child: _activeLoading
                                  ? CircularProgressIndicator(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    )
                                  : Text(
                                      'درخواست فعالسازی سایت',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .button
                                            .color,
                                      ),
                                    ),
                            ),
                            width: 200,
                          ),
                        )
                ],
                padding: EdgeInsets.all(0),
              ),
            ),
    );
  }

  _active() async {
    setState(() {
      _activeLoading = true;
    });
    final response = await http.get(
      '$BASE_URI/active/shop/private/site/${_storeBloc.currentStore.id}',
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    ResponseWrapper _wrapper =
        ResponseWrapper.fromJson(jsonDecode(response.body));
    if (response.statusCode == 200 && _wrapper.code == 200) {
      var _content = _wrapper.data['content'];
      if (await canLaunch(_content)) {
        setState(() {
          _activeLoading = false;
        });
        await launch(_content);
      } else {
        throw 'Could not launch $_content';
      }
    }
  }

  _getShopSiteInfo() async {
    final response = await http.get(
      '$BASE_URI/sites/configs/info',
      headers: {
        'Authorization': "Bearer ${_storeBloc.user.authCode}",
      },
    );
    ResponseWrapper _wrapper =
        ResponseWrapper.fromJson(jsonDecode(response.body));
    if (response.statusCode == 200 && _wrapper.code == 200) {
      setState(() {
        _cost = '${(_wrapper.data)['cost']}';
        _ipAddress = (_wrapper.data)['ipAddress'];
        _loading = false;
      });
    }
  }

  _submitChanges() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _activeLoading = true;
      });

      FormData formData = FormData.fromMap({
        'domain': _editingController.text,
        'file': _bannerFile != null
            ? await MultipartFile.fromFile(
                _bannerFile.path,
                filename: _bannerFile.path.split('/').last,
                contentType: MediaType.parse('image/jpeg'),
              )
            : null,
      });

      Dio dio = Dio();
      final response = await dio.post(
        '$BASE_URI/shop/private/site/info/${_storeBloc.currentStore.id}',
        options: Options(
          headers: {
            'Authorization': "Bearer ${_storeBloc.user.authCode}",
            'contentType': 'multipart/form-data',
          },
        ),
        data: formData,
      );

      ResponseWrapper _wrapper = ResponseWrapper.fromJson(response.data);
      if (response.statusCode == 200 && _wrapper.code == 200) {
        /// get store details again
        _storeBloc.add(SubmitChangedStoreSiteDomainStoreEvent());

        if (_deletedImagesUrls.isNotEmpty) {
          _storeBloc.add(
              SubmitDeleteBannersStoreEvent(bannerUrls: _deletedImagesUrls));
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return StorePage(
                key: Key('${_storeBloc.currentStore.id}'),
              );
            },
          ),
        );

        setState(() {
          _activeLoading = false;
        });
      }
    }
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

    setState(() {
      _bannerFile = File(pickedFile.path);
    });
    Navigator.of(context).pop();
  }

  _deleteImage(String _deleteUrl) {
    _bannerUrls.removeWhere((element) => element.contains(_deleteUrl));
    _deletedImagesUrls.add(_deleteUrl);
    setState(() {});
  }
}
