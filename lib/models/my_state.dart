class MyState {
  final String id;
  final String name;

  MyState({this.id, this.name});

  MyState.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
