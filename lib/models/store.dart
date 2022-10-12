import 'package:idehshop/models/product_and_store_info.dart';
import 'package:idehshop/models/shop_bank_account.dart';

class Store {
  final String id;
  dynamic long;
  dynamic lat;
  final String kind;
  final String title;
  String imageAddress;
  dynamic score;
  String address;
  String postalCode;
  dynamic lastUsage;
  String stateId;
  String cityId;
  List<dynamic> accessNumbers;
  bool payed;
  bool verified;
  bool vip;
  bool isCommon;
  bool hasPreOrder;
  bool hasDefaultPaymentGateWay;
  dynamic commission;
  String description;
  List<dynamic> documents;
  dynamic limitDistance;
  dynamic transportPriceNear;
  dynamic transportPriceFar;
  dynamic openAt;
  dynamic closeAt;
  dynamic siteInfo;
  BankAccount bankAccount;
  bool orderFromCity;

  bool orderFromState;

  bool orderFromCountry;

  Store({
    this.id,
    this.long,
    this.lat,
    this.kind,
    this.title,
    this.imageAddress,
    this.score = '',
    this.address,
    this.postalCode,
    this.cityId,
    this.lastUsage,
    this.stateId,
    this.accessNumbers,
    this.payed,
    this.verified,
    this.vip,
    this.isCommon,
    this.description,
    this.documents,
    this.limitDistance,
    this.transportPriceNear,
    this.transportPriceFar,
    this.openAt,
    this.closeAt,
    this.hasPreOrder,
    this.hasDefaultPaymentGateWay,
    this.siteInfo,
    this.bankAccount,
    this.commission,
    this.orderFromCity,
    this.orderFromState,
    this.orderFromCountry,
  });

  Store.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        long = json['long'],
        lat = json['lat'],
        kind = json['kind'],
        title = json['title'],
        score = json['score'] ?? '',
        imageAddress = json['imageAddress'],
        address = json['address'],
        postalCode = json['postalCode'],
        lastUsage = json['lastUsage'],
        stateId = json['stateId'],
        cityId = json['cityId'],
        accessNumbers = json['accessNumbers'],
        payed = json['payed'] ?? false,
        verified = json['verified'],
        vip = json['vip'],
        isCommon = json['isCommon'],
        description = json['description'],
        documents = json['documents'],
        limitDistance = json['limitDistance'],
        siteInfo = json['siteInfo'],
        orderFromCity =
            json.containsKey('orderFrom') ? json['orderFrom']['city'] : false,
        orderFromState =
            json.containsKey('orderFrom') ? json['orderFrom']['state'] : false,
        orderFromCountry = json.containsKey('orderFrom')
            ? json['orderFrom']['country']
            : false,
        commission = json['commission'] ?? 0,
        hasPreOrder = json['hasPreOrder'] ?? false,
        hasDefaultPaymentGateWay = json['hasDefaultPaymentGateWay'] ?? false,
        openAt = json['openAt'] ?? Map(),
        closeAt = json['closeAt'] ?? Map(),
        bankAccount = BankAccount.fromJson(json['bankAccountInfo'] ?? Map()),
        transportPriceNear = json['nearDistancePrice'],
        transportPriceFar = json['farDistancePrice'];

  Store.fromProductStoreInfo(ProductAndStoreInfo productAndStoreInfo)
      : id = productAndStoreInfo.id,
        kind = productAndStoreInfo.shopKind,
        title = productAndStoreInfo.shopTitle,
        score = productAndStoreInfo.shopScore,
        lat = productAndStoreInfo.shopLat,
        long = productAndStoreInfo.shopLong,
        hasPreOrder = productAndStoreInfo.hasPreOrder,
        openAt = productAndStoreInfo.openAt,
        closeAt = productAndStoreInfo.closeAt;
}
