// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessReportResponse _$BusinessReportResponseFromJson(
        Map<String, dynamic> json) =>
    BusinessReportResponse(
      top3SoldProducts: (json['top3SoldProducts'] as List<dynamic>?)
              ?.map((e) => TopProductResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      top3ServicesUsed: (json['top3ServicesUsed'] as List<dynamic>?)
              ?.map((e) => TopServiceResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      moneyGeneratedFromProducts:
          (json['moneyGeneratedFromProducts'] as num?)?.toDouble() ?? 0.0,
      moneyGeneratedFromServices:
          (json['moneyGeneratedFromServices'] as num?)?.toDouble() ?? 0.0,
      bestReviewedService: json['bestReviewedService'] == null
          ? null
          : BestReviewedServiceResponse.fromJson(
              json['bestReviewedService'] as Map<String, dynamic>),
      userWithMostServices: json['userWithMostServices'] == null
          ? null
          : UserWithMostServicesResponse.fromJson(
              json['userWithMostServices'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BusinessReportResponseToJson(
        BusinessReportResponse instance) =>
    <String, dynamic>{
      'top3SoldProducts': instance.top3SoldProducts.map((e) => e.toJson()).toList(),
      'top3ServicesUsed': instance.top3ServicesUsed.map((e) => e.toJson()).toList(),
      'moneyGeneratedFromProducts': instance.moneyGeneratedFromProducts,
      'moneyGeneratedFromServices': instance.moneyGeneratedFromServices,
      'bestReviewedService': instance.bestReviewedService?.toJson(),
      'userWithMostServices': instance.userWithMostServices?.toJson(),
    };

TopProductResponse _$TopProductResponseFromJson(Map<String, dynamic> json) =>
    TopProductResponse(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: json['productName'] as String? ?? '',
      productImage: json['productImage'] as String?,
      totalQuantitySold: (json['totalQuantitySold'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$TopProductResponseToJson(TopProductResponse instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'productImage': instance.productImage,
      'totalQuantitySold': instance.totalQuantitySold,
      'totalRevenue': instance.totalRevenue,
    };

TopServiceResponse _$TopServiceResponseFromJson(Map<String, dynamic> json) =>
    TopServiceResponse(
      serviceId: (json['serviceId'] as num?)?.toInt() ?? 0,
      serviceName: json['serviceName'] as String? ?? '',
      serviceImage: json['serviceImage'] as String?,
      totalAppointments: (json['totalAppointments'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$TopServiceResponseToJson(TopServiceResponse instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceImage': instance.serviceImage,
      'totalAppointments': instance.totalAppointments,
      'totalRevenue': instance.totalRevenue,
    };

BestReviewedServiceResponse _$BestReviewedServiceResponseFromJson(
        Map<String, dynamic> json) =>
    BestReviewedServiceResponse(
      serviceId: (json['serviceId'] as num?)?.toInt() ?? 0,
      serviceName: json['serviceName'] as String? ?? '',
      serviceImage: json['serviceImage'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BestReviewedServiceResponseToJson(
        BestReviewedServiceResponse instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceImage': instance.serviceImage,
      'averageRating': instance.averageRating,
      'reviewCount': instance.reviewCount,
    };

UserWithMostServicesResponse _$UserWithMostServicesResponseFromJson(
        Map<String, dynamic> json) =>
    UserWithMostServicesResponse(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userFullName: json['userFullName'] as String? ?? '',
      userImage: json['userImage'] as String?,
      totalServicesCount: (json['totalServicesCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserWithMostServicesResponseToJson(
        UserWithMostServicesResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userFullName': instance.userFullName,
      'userImage': instance.userImage,
      'totalServicesCount': instance.totalServicesCount,
    };
