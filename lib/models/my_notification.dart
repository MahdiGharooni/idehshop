class MyNotification {
  String id;
  String enMessage;
  String faMessage;
  String status;

  int createAt;

  MyNotification(
      {this.id, this.enMessage, this.faMessage, this.status, this.createAt});

  MyNotification.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        enMessage = json['en_message'],
        faMessage = json['fa_message'],
        createAt = json['createAt'],
        status = json['status'];
}
