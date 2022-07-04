import 'package:flutter/material.dart';
import 'package:idehshop/models/store.dart';
import 'package:idehshop/routes/home_page/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

//financial/aggregation/report بیشتر از دوتا فروشگاه

/// urls
//const String BASE_URI = 'http://89.43.7.42:8090';
//const String BASE_URI = 'http://10.2.68.26:9292';
//const String BASE_URI = 'http://10.2.68.57:8090';
// const String BASE_URI = 'https://212.33.195.178:9090';
const String BASE_URI = 'http://my.idehshops.ir:8090';
const String MY_IDEHSHOP_URI = 'http://my.idehshops.ir';
const String PRIVACY_URI = 'http://idehshops.ir/privacyPolicy/privacy';
const String IDEHSHOP_URI = 'http://idehshops.ir/';
const String CONTACT_US_URI =
    'http://idehshops.ir/contact/%D8%AA%D9%85%D8%A7%D8%B3-%D8%A8%D8%A7-%D9%85%D8%A7';
const String VISITORS_URI =
    'http://idehshops.ir/resaller/%D9%86%D9%85%D8%A7%DB%8C%D9%86%D8%AF%DA%AF%DB%8C';

/// roles
const String PROVIDER_ROLE = 'provider';
const String CUSTOMER_ROLE = 'customer';
const String MARKETER_ROLE = 'marketer';
enum Role { provider, customer, marketer }

/// shared preferences keys
const String PREF_AUTH_CODE = 'authCode';
const String PREF_USER_NAME = 'userName';
const String PREF_PASSWORD = 'password';
const String PREF_MOBILE = 'mobile';
const String PREF_SELECTED_ADDRESS_ID = 'selectedAddressId';
const String PREF_MARKET = 'market';
const String PREF_OS = 'os';
const String PREF_LAST_VERSION_Code = 'lastVersionCode';

/// zooms
const MAP_NORMAL_ZOOM = 15.0;
const MAP_MORE_ZOOM = 18.0;

/// enums
enum REQUEST_TYPE { firstRequest, loadRequest }
enum ERROR { jwtExpired }
enum TYPE { create, edit }
enum PAY_WAY { home, idehShopPort, wallet }
enum SEARCH_TYPE { productInStore, productInNearStores }
enum SEARCH_ITEM { product, shop }
// enum SEARCH_ORDER { location, score }

///others
const String PRODUCT_ID = 'id';
const String PRODUCT_DESCRIPTION = 'description';
const DEFAULT_MARKETER_ID = 1;
const REPORTING_MODES_FA = [
  'روزانه',
  'ماهانه',
  'سالیانه',
];
const REPORTING_MODES_EN = [
  'daily',
  'monthly',
  'yearly',
];
const String WHERE_NEAR = 'near';
const String WHERE_CITY = 'city';
const String WHERE_STATE = 'state';
const String WHERE_COUNTRY = 'country';
const String WHERE_VIP = 'vip';
const String INFO_VERSION_CODE = 'version-code';
const String INFO_VERSION_NAME = 'version-name';
const String INFO_VERSION_FEATURES = 'features';
const String INFO_VERSION_FORCE_UPDATE = 'force-update';
const List<String> SHOP_ORDER_FROM = [
  'محله',
  'شهر',
  'استان',
  'کشور',
];
const List<String> PRODUCT_MEASUREMENTS = [
  'عدد',
  'بسته',
  'متر',
  'متر مربع',
  'سانتی متر',
  'جعبه',
  'کیلوگرم',
  'گرم',
  'کارتن',
  'قطعه',
  'حلقه',
  'جفت',
  'شاخه',
  'پکیج',
  'دستگاه',
  'سیستم',
  'تخته',
  'جلد',
  'ماشین',
  'سرویس',
  'لیتر',
  'میلی لیتر',
  'متر مکعب',
  'رول',
  'پاکت',
  'دست',
  'جین',
  'اشتراک',
  'سری',
  'تن',
  'مگابایت',
  'کیلوبایت',
];

/// remote config keys
const MINIMUM_BUILD_NUMBER = 'minimum_build_number';

/// markets
const CAFE_BAZZAR = 'cafe_bazzar';
const MAYKET = 'mayket';
const GOOGLE_PLAY = 'google_play';

/// os
const OS_ANDROID = 'android';
const OS_IOS = 'ios';

SnackBar getSnackBar(BuildContext context, String data, int seconds) {
  return SnackBar(
    backgroundColor: Theme.of(context).accentColor,
    content: Text(
      data,
      style:
          Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white),
      textAlign: TextAlign.right,
    ),
    duration: Duration(seconds: seconds),
  );
}

setDataInSharedPreferences(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

getDataFromSharedPreferences(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString(key) != null) {
    return prefs.getString(key);
  } else {
    return null;
  }
}

String getMessage(String _msg) {
  String _newMsg = _msg;
  if (_msg.contains('at least an order registered by this location')) {
    _newMsg = 'حداقل یک سفارش با این آدرس ثبت شده است.';
  } else if (_msg.contains('at least an order exist for this shop product')) {
    _newMsg = 'حداقل یک سفارش با این محصول ثبت شده است.';
  } else if (_msg.contains('at least an order exist for this shop')) {
    _newMsg = 'حداقل یک سفارش با این فروشگاه ثبت شده است.';
  } else if (_msg.contains('at least a product exist for this category')) {
    _newMsg = 'حداقل یک محصول برای این دسته بندی ثبت شده است.';
  }
  return _newMsg;
}

String getDateDayName(int _weekDay) {
  switch (_weekDay) {
    case 1:
      return 'شنبه';
      break;
    case 2:
      return 'یکشنبه';
      break;
    case 3:
      return 'دوشنبه';
      break;
    case 4:
      return 'سه شنبه';
      break;
    case 5:
      return 'چهارشنبه';
      break;
    case 6:
      return 'پنج شنبه';
      break;
    case 7:
      return 'جمعه';
      break;
    default:
      return '';
      break;
  }
}

String getTimeInCorrectFormat(String _number) {
  if (_number.length == 1) {
    return '0$_number';
  } else {
    return _number;
  }
}

showCustomDialog(BuildContext context, String title, String description) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.right,
            ),
          ),
          actions: [
            FlatButton(
              child: Text(
                'باشه',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Theme.of(context).accentColor,
                    ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
        );
      });
}

bool isStoreOpen(Store _store) {
  if (_store.openAt == null || _store.closeAt == null) {
    return true;
  }
  if ((_store.openAt is Map) && (_store.openAt as Map).isEmpty) {
    return true;
  }
  DateTime _now = DateTime.now();
  int _hour = _now.hour;
  int _minute = _now.minute;
  int _storeOpenHour = int.parse('${_store.openAt['hour']}');
  int _storeOpenMin = int.parse('${_store.openAt['min']}');
  int _storeCloseHour = int.parse('${_store.closeAt['hour']}');
  int _storeCloseMin = int.parse('${_store.closeAt['min']}');
  if (_storeOpenHour < _hour && _hour < _storeCloseHour) {
    return true;
  } else if (_hour == _storeOpenHour && _minute > _storeOpenMin) {
    return true;
  } else if (_hour == _storeCloseHour && _minute < _storeCloseMin) {
    return true;
  }

  /// 23:00 - 6:00
  if (_storeOpenHour > _storeCloseHour &&
      (_hour < _storeCloseHour || _hour > _storeOpenHour)) {
    return true;
  }
  if (_storeOpenHour > _storeCloseHour &&
      ((_hour <= _storeCloseHour && _minute <= _storeCloseMin) ||
          (_hour >= _storeOpenHour && _minute >= _storeOpenMin))) {
    return true;
  }
  return false;
}

String getFormattedPrice(num number) {
  if (number == null) {
    number = 0;
  }
  String _result = '';
  String _stringNum = (number.round()).toString();
  int _stringNumSize = _stringNum.length;
  for (int i = 0; i < _stringNumSize; i++) {
    if ((_stringNumSize - i) % 3 == 0 && i != 0) {
      _result = "$_result,";
    }
    _result = "$_result${_stringNum[i]}";
  }
  return _result;
}

goToHomePage(BuildContext context, int _index) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) {
      return HomePage(
        index: _index,
      );
    }),
  );
}
