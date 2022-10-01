class ProductCategory {
  String id;
  String title;
  bool verified;
  String imageAddress;

  ProductCategory({
    this.id,
    this.title,
    this.verified,
    this.imageAddress,
  });
  ProductCategory.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        title = json['title'] ?? '',
        verified = json['verified'] ?? false,
        imageAddress = json['imageAddress'] ?? '';
}
