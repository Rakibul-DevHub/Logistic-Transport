// import 'package:tag/feature/bill_of_loading/model/add_load_data.dart';
//
// class LoadDetailsResponse {
//   final int? code;
//   final String? message;
//   final AddLoadData? data;
//
//   const LoadDetailsResponse({
//     this.code,
//     this.message,
//     this.data,
//   });
//
//   factory LoadDetailsResponse.fromJson(Map<String, dynamic> json) {
//     return LoadDetailsResponse(
//       code: json['code'] is int
//           ? json['code'] as int
//           : int.tryParse('${json['code']}'),
//       message: json['message']?.toString(),
//       data: json['data'] is Map<String, dynamic>
//           ? AddLoadData.fromJson(json['data'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }






import 'package:tag/feature/bill_of_loading/model/add_load_data.dart';

class LoadDetailsResponse {
  final int? code;
  final String? message;
  final AddLoadData? data;

  const LoadDetailsResponse({
    this.code,
    this.message,
    this.data,
  });

  factory LoadDetailsResponse.fromJson(Map<String, dynamic> json) {
    return LoadDetailsResponse(
      code: json['code'] is int
          ? json['code'] as int
          : int.tryParse('${json['code']}'),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? AddLoadData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}