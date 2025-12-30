import 'package:json_annotation/json_annotation.dart';

part 'business_report.g.dart';

@JsonSerializable()
class BusinessReportResponse {
  @JsonKey(name: 'top3SoldProducts')
  final List<TopProductResponse> top3SoldProducts;

  @JsonKey(name: 'top3ServicesUsed')
  final List<TopServiceResponse> top3ServicesUsed;

  @JsonKey(name: 'moneyGeneratedFromProducts')
  final double moneyGeneratedFromProducts;

  @JsonKey(name: 'moneyGeneratedFromServices')
  final double moneyGeneratedFromServices;

  @JsonKey(name: 'bestReviewedService')
  final BestReviewedServiceResponse? bestReviewedService;

  @JsonKey(name: 'userWithMostServices')
  final UserWithMostServicesResponse? userWithMostServices;

  BusinessReportResponse({
    required this.top3SoldProducts,
    required this.top3ServicesUsed,
    required this.moneyGeneratedFromProducts,
    required this.moneyGeneratedFromServices,
    this.bestReviewedService,
    this.userWithMostServices,
  });

  factory BusinessReportResponse.fromJson(Map<String, dynamic> json) =>
      _$BusinessReportResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessReportResponseToJson(this);
}

@JsonSerializable()
class TopProductResponse {
  @JsonKey(name: 'productId')
  final int productId;

  @JsonKey(name: 'productName')
  final String productName;

  @JsonKey(name: 'productImage')
  final String? productImage;

  @JsonKey(name: 'totalQuantitySold')
  final int totalQuantitySold;

  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;

  TopProductResponse({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });

  factory TopProductResponse.fromJson(Map<String, dynamic> json) =>
      _$TopProductResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TopProductResponseToJson(this);
}

@JsonSerializable()
class TopServiceResponse {
  @JsonKey(name: 'serviceId')
  final int serviceId;

  @JsonKey(name: 'serviceName')
  final String serviceName;

  @JsonKey(name: 'serviceImage')
  final String? serviceImage;

  @JsonKey(name: 'totalAppointments')
  final int totalAppointments;

  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;

  TopServiceResponse({
    required this.serviceId,
    required this.serviceName,
    this.serviceImage,
    required this.totalAppointments,
    required this.totalRevenue,
  });

  factory TopServiceResponse.fromJson(Map<String, dynamic> json) =>
      _$TopServiceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TopServiceResponseToJson(this);
}

@JsonSerializable()
class BestReviewedServiceResponse {
  @JsonKey(name: 'serviceId')
  final int serviceId;

  @JsonKey(name: 'serviceName')
  final String serviceName;

  @JsonKey(name: 'serviceImage')
  final String? serviceImage;

  @JsonKey(name: 'averageRating')
  final double averageRating;

  @JsonKey(name: 'reviewCount')
  final int reviewCount;

  BestReviewedServiceResponse({
    required this.serviceId,
    required this.serviceName,
    this.serviceImage,
    required this.averageRating,
    required this.reviewCount,
  });

  factory BestReviewedServiceResponse.fromJson(Map<String, dynamic> json) =>
      _$BestReviewedServiceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BestReviewedServiceResponseToJson(this);
}

@JsonSerializable()
class UserWithMostServicesResponse {
  @JsonKey(name: 'userId')
  final int userId;

  @JsonKey(name: 'userFullName')
  final String userFullName;

  @JsonKey(name: 'userImage')
  final String? userImage;

  @JsonKey(name: 'totalServicesCount')
  final int totalServicesCount;

  UserWithMostServicesResponse({
    required this.userId,
    required this.userFullName,
    this.userImage,
    required this.totalServicesCount,
  });

  factory UserWithMostServicesResponse.fromJson(Map<String, dynamic> json) =>
      _$UserWithMostServicesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserWithMostServicesResponseToJson(this);
}
