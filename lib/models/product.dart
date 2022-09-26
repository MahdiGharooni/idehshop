class Product {
  String id;
  String title;
  dynamic price;
  dynamic offPrice;
  String measurement;
  String measurementIndex;
  bool verified;
  bool available;
  List<dynamic> imageAddresses;
  String description;

  Product(
      {this.id,
      this.title,
      this.price,
      this.offPrice,
      this.verified,
      this.description,
      this.available,
      this.measurementIndex,
      this.measurement,
      this.imageAddresses});

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        price = json['price'],
        offPrice = json['offPrice'],
        verified = json['verified'],
        available = json['available'],
        measurement = json['measurement'],
        measurementIndex = '${json['measurementIndex'] ?? json['unit'] ?? 0}',
        description = json['description'] ?? '',
        imageAddresses = json['imageAddresses'] ?? [];
}
