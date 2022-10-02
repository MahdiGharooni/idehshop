class ProductReportModel {
  String date;

  int unit;
  int price;
  int cost;
  int transportPrice;

  ProductReportModel({
    this.unit,
    this.price,
    this.date,
    this.cost,
    this.transportPrice,
  });

  ProductReportModel.fromMap(String key, Map<String, dynamic> value) {
    date = key;
    unit = value['unit'] ?? 0;
    cost = value['cost'] ?? 0;
    transportPrice = value['transportPrice'] ?? 0;
    price = value['price'] ?? 0;
  }
}
