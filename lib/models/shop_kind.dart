class ShopKind {
  final String id;
  final String kind;
  final String imageAddress;

  ShopKind({this.id, this.kind, this.imageAddress});

  ShopKind.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        kind = json['kind'],
        imageAddress = json['imageAddress'];
}
