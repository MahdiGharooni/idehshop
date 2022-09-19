class MyLocation {
  final dynamic lng;
  final dynamic lat;
  String id;
  String address;
  String stateId;
  String cityId;

  final String postalCode;

  MyLocation({
    this.lng,
    this.lat,
    this.postalCode,
    this.id,
    this.address,
  });

  MyLocation.fromJson(Map<String, dynamic> json)
      : lat = json['lat'] ?? json['location']['lat'] ?? '',
        lng = json['long'] ?? json['location']['long'] ?? '',
        id = json['id'] ?? json['location']['id'] ?? '',
        address = json['address'] ?? json['location']['address'] ?? '',
        stateId = json['stateId'] ?? '',
        cityId = json['cityId'] ?? '',
        postalCode = json['postalCode'] ?? '';
}
