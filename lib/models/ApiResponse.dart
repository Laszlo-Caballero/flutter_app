class Apiresponse<T> {
  final T? data;
  final String message;
  final String status;

  Apiresponse({this.data, required this.message, required this.status});

  factory Apiresponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return Apiresponse(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
