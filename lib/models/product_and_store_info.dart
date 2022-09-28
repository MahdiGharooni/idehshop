import 'dart:core';

class ProductAndStoreInfo {
  String id;
  String title;
  String price;
  String offPrice;
  List<dynamic> imageAddresses;
  String shopKind;
  String shopTitle;
  String measurement;
  String measurementIndex;
  dynamic shopScore;
  double shopLong;
  double shopLat;
  dynamic openAt;

  dynamic closeAt;

  dynamic hasPreOrder;

  ProductAndStoreInfo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        price = '${json['price']}',
        offPrice = '${json['offPrice']}',
        imageAddresses = json['imageAddresses'],
        shopKind = json['shopKind'],
        shopTitle = json['shopTitle'],
        shopScore = json['shopScore'],
        shopLong = json['shopLong'],
        measurement = json['measurement'],
        openAt = json['openAt'] ?? Map(),
        closeAt = json['closeAt'] ?? Map(),
        hasPreOrder = json['hasPreOrder'] ?? false,
        measurementIndex = '${json['measurementIndex'] ?? 0}',
        shopLat = json['shopLat'];
}
