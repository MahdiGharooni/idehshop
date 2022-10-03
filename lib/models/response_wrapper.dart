class ResponseWrapper {
  final int code;
  final bool success;
  final String message;
  final dynamic data;
  final String role;

  ResponseWrapper(
      {this.code, this.success, this.message, this.data, this.role});

  ResponseWrapper.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        success = json['success'],
        message = json['message'],
        data = json['data'],
        role = json['role'];
}
