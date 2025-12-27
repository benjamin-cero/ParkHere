import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'business_report.g.dart';

@JsonSerializable()
class BusinessReportResponse {
  @JsonKey(name: 'topGrossingFestivals')
  final List<FestivalRevenueResponse> topGrossingFestivals;

  @JsonKey(name: 'totalRevenueThisYear')
  final double totalRevenueThisYear;

  @JsonKey(name: 'totalTicketsSoldThisYear')
  final int totalTicketsSoldThisYear;

  @JsonKey(name: 'userWithMostTickets')
  final User? userWithMostTickets;

  @JsonKey(name: 'userWithMostTicketsCount')
  final int? userWithMostTicketsCount;

  @JsonKey(name: 'topFestivalsByAverageRating')
  final List<FestivalRatingResponse> topFestivalsByAverageRating;

  BusinessReportResponse({
    required this.topGrossingFestivals,
    required this.totalRevenueThisYear,
    required this.totalTicketsSoldThisYear,
    this.userWithMostTickets,
    this.userWithMostTicketsCount,
    required this.topFestivalsByAverageRating,
  });

  factory BusinessReportResponse.fromJson(Map<String, dynamic> json) =>
      _$BusinessReportResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessReportResponseToJson(this);
}

@JsonSerializable()
class FestivalRevenueResponse {
  @JsonKey(name: 'festivalId')
  final int festivalId;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;

  FestivalRevenueResponse({
    required this.festivalId,
    required this.title,
    required this.totalRevenue,
  });

  factory FestivalRevenueResponse.fromJson(Map<String, dynamic> json) =>
      _$FestivalRevenueResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FestivalRevenueResponseToJson(this);
}

@JsonSerializable()
class FestivalRatingResponse {
  @JsonKey(name: 'festivalId')
  final int festivalId;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'averageRating')
  final double averageRating;

  FestivalRatingResponse({
    required this.festivalId,
    required this.title,
    required this.averageRating,
  });

  factory FestivalRatingResponse.fromJson(Map<String, dynamic> json) =>
      _$FestivalRatingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FestivalRatingResponseToJson(this);
}
