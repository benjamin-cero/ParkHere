import 'package:json_annotation/json_annotation.dart';

part 'business_report.g.dart';

@JsonSerializable()
class BusinessReportResponse {
  final double totalRevenue;
  final int totalReservations;
  final int totalUsers;
  final List<MonthlyRevenue> monthlyRevenueTrends;
  final PopularItem? mostPopularSpot;
  final PopularItem? mostPopularType;
  final PopularItem? mostPopularWing;
  final PopularItem? mostPopularSector;
  final List<PopularItem> spotTypeDistribution;
  final List<PopularItem> sectorDistribution;
  final List<PopularItem> genderDistribution;

  BusinessReportResponse({
    required this.totalRevenue,
    required this.totalReservations,
    required this.totalUsers,
    required this.monthlyRevenueTrends,
    this.mostPopularSpot,
    this.mostPopularType,
    this.mostPopularWing,
    this.mostPopularSector,
    required this.spotTypeDistribution,
    required this.sectorDistribution,
    required this.genderDistribution,
  });

  factory BusinessReportResponse.fromJson(Map<String, dynamic> json) =>
      _$BusinessReportResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessReportResponseToJson(this);
}

@JsonSerializable()
class MonthlyRevenue {
  final String month;
  final double revenue;

  MonthlyRevenue({required this.month, required this.revenue});

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) =>
      _$MonthlyRevenueFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyRevenueToJson(this);
}

@JsonSerializable()
class PopularItem {
  final String name;
  final int count;
  final double? revenue;

  PopularItem({required this.name, required this.count, this.revenue});

  factory PopularItem.fromJson(Map<String, dynamic> json) =>
      _$PopularItemFromJson(json);

  Map<String, dynamic> toJson() => _$PopularItemToJson(this);
}
