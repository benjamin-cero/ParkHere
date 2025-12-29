// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessReportResponse _$BusinessReportResponseFromJson(
        Map<String, dynamic> json) =>
    BusinessReportResponse(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalReservations: (json['totalReservations'] as num).toInt(),
      totalUsers: (json['totalUsers'] as num).toInt(),
      monthlyRevenueTrends: (json['monthlyRevenueTrends'] as List<dynamic>)
          .map((e) => MonthlyRevenue.fromJson(e as Map<String, dynamic>))
          .toList(),
      mostPopularSpot: json['mostPopularSpot'] == null
          ? null
          : PopularItem.fromJson(
              json['mostPopularSpot'] as Map<String, dynamic>),
      mostPopularType: json['mostPopularType'] == null
          ? null
          : PopularItem.fromJson(
              json['mostPopularType'] as Map<String, dynamic>),
      mostPopularWing: json['mostPopularWing'] == null
          ? null
          : PopularItem.fromJson(
              json['mostPopularWing'] as Map<String, dynamic>),
      mostPopularSector: json['mostPopularSector'] == null
          ? null
          : PopularItem.fromJson(
              json['mostPopularSector'] as Map<String, dynamic>),
      spotTypeDistribution: (json['spotTypeDistribution'] as List<dynamic>)
          .map((e) => PopularItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      sectorDistribution: (json['sectorDistribution'] as List<dynamic>)
          .map((e) => PopularItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      genderDistribution: json['genderDistribution'] == null
          ? []
          : (json['genderDistribution'] as List<dynamic>)
              .map((e) => PopularItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$BusinessReportResponseToJson(
        BusinessReportResponse instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'totalReservations': instance.totalReservations,
      'totalUsers': instance.totalUsers,
      'monthlyRevenueTrends': instance.monthlyRevenueTrends,
      'mostPopularSpot': instance.mostPopularSpot,
      'mostPopularType': instance.mostPopularType,
      'mostPopularWing': instance.mostPopularWing,
      'mostPopularSector': instance.mostPopularSector,
      'spotTypeDistribution': instance.spotTypeDistribution,
      'sectorDistribution': instance.sectorDistribution,
      'genderDistribution': instance.genderDistribution,
    };

MonthlyRevenue _$MonthlyRevenueFromJson(Map<String, dynamic> json) =>
    MonthlyRevenue(
      month: json['month'] as String,
      revenue: (json['revenue'] as num).toDouble(),
    );

Map<String, dynamic> _$MonthlyRevenueToJson(MonthlyRevenue instance) =>
    <String, dynamic>{
      'month': instance.month,
      'revenue': instance.revenue,
    };

PopularItem _$PopularItemFromJson(Map<String, dynamic> json) => PopularItem(
      name: json['name'] as String,
      count: (json['count'] as num).toInt(),
      revenue: (json['revenue'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PopularItemToJson(PopularItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'count': instance.count,
      'revenue': instance.revenue,
    };
