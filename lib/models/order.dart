import 'package:idehshop/models/product.dart';

class Order {
  String id;
  dynamic long;
  dynamic lat;
  String address;
  String postalCode;
  String customerFirstName;
  String customerLastName;
  List<dynamic> customerNumbers;
  String customerNationalCode;
  List<Product> products = List();
  dynamic transportPrice;
  dynamic totalPrice;
  dynamic score;
  dynamic offPrice;
  bool accepted;
  dynamic arrivingTime;
  String status;
  List<dynamic> titles = List();
  dynamic orderedAt;
  String authorFirstName;
  String authorLastName;
  int dislike;
  String locationId;
  String shopId;
  bool payed;

  Order(
      {id,
      long,
      lat,
      address,
      postalCode,
      customerFirstName,
      customerLastName,
      customerNumbers,
      customerNationalCode,
      products,
      transportPrice,
      totalPrice,
      score,
      accepted,
      arrivingTime,
      status,
      titles,
      orderedAt,
      authorFirstName,
      authorLastName,
      dislike,
      locationId,
      offPrice,
      shopId,
      payed}) {
    this.id = id;
    this.long = long;
    this.lat = lat;
    this.address = address;
    this.postalCode = postalCode;
    this.customerFirstName = customerFirstName;
    this.customerLastName = customerLastName;
    this.customerNumbers = customerNumbers;
    this.customerNationalCode = customerNationalCode;
    this.transportPrice = transportPrice;
    this.totalPrice = totalPrice;
    this.score = score;
    this.accepted = accepted;
    this.arrivingTime = arrivingTime;
    this.status = status;
    this.orderedAt = orderedAt;
    this.dislike = dislike;
    this.authorFirstName = authorFirstName;
    this.authorLastName = authorLastName;
    this.locationId = locationId;
    this.shopId = shopId;
    this.offPrice = offPrice ?? 0;
    this.payed = payed ?? false;
    this.arrivingTime = arrivingTime;
    (products ?? []).forEach((element) {
      this.products.add(Product.fromJson(element));
    });
    (titles ?? []).forEach((element) {
      this.titles.add(element);
    });
  }

  Order.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.long = json['long'];
    this.lat = json['lat'];
    this.address = json['address'];
    this.postalCode = json['postalCode'];
    this.customerFirstName = json['customerFirstName'];
    this.customerLastName = json['customerLastName'];
    this.customerNumbers = json['customerNumbers'];
    this.customerNationalCode = json['customerNationalCode'];
    this.transportPrice = json['transportPrice'];
    this.totalPrice =
        json['totalPrice'] ?? json['price'] ?? json['purePrice'] ?? 0;
    this.score = json['score'];
    this.accepted = json['accepted'];
    this.arrivingTime = json['arrivingTime'];
    this.status = json['status'];
    this.orderedAt = json['orderedAt'];
    this.dislike = json['dislike'];
    this.authorFirstName = json['authorFirstName'];
    this.authorLastName = json['authorLastName'];
    this.locationId = json['locationId'];
    this.shopId = json['shopId'];
    this.offPrice = json['offPrice'] ?? 0;
    this.payed = json['payed'] ?? false;
    this.arrivingTime = json['arrivingTime'];
    (json['products'] ?? []).forEach((product) {
      this.products.add(Product.fromJson(product));
    });
    (json['titles'] ?? []).forEach((title) {
      this.titles.add(title);
    });
  }
}
