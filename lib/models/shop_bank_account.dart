class BankAccount {
  String number;

  String shaba;

  BankAccount({this.number, this.shaba});

  BankAccount.fromJson(Map<String, dynamic> json)
      : number = '${json['number'] ?? ''}',
        shaba = "${json['shaba'] ?? ''}";
}
