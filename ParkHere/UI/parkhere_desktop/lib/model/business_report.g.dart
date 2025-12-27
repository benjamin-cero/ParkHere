// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessReportResponse _$BusinessReportResponseFromJson(
  Map<String, dynamic> json,
) => BusinessReportResponse(
  topGrossingFestivals: (json['topGrossingFestivals'] as List<dynamic>)
      .map((e) => FestivalRevenueResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalRevenueThisYear: (json['totalRevenueThisYear'] as num).toDouble(),
  totalTicketsSoldThisYear: (json['totalTicketsSoldThisYear'] as num).toInt(),
  userWithMostTickets: json['userWithMostTickets'] == null
      ? null
      : User.fromJson(json['userWithMostTickets'] as Map<String, dynamic>),
  userWithMostTicketsCount: (json['userWithMostTicketsCount'] as num?)?.toInt(),
  topFestivalsByAverageRating:
      (json['topFestivalsByAverageRating'] as List<dynamic>)
          .map(
            (e) => FestivalRatingResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$BusinessReportResponseToJson(
  BusinessReportResponse instance,
) => <String, dynamic>{
  'topGrossingFestivals': instance.topGrossingFestivals,
  'totalRevenueThisYear': instance.totalRevenueThisYear,
  'totalTicketsSoldThisYear': instance.totalTicketsSoldThisYear,
  'userWithMostTickets': instance.userWithMostTickets,
  'userWithMostTicketsCount': instance.userWithMostTicketsCount,
  'topFestivalsByAverageRating': instance.topFestivalsByAverageRating,
};

FestivalRevenueResponse _$FestivalRevenueResponseFromJson(
  Map<String, dynamic> json,
) => FestivalRevenueResponse(
  festivalId: (json['festivalId'] as num).toInt(),
  title: json['title'] as String,
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
);

Map<String, dynamic> _$FestivalRevenueResponseToJson(
  FestivalRevenueResponse instance,
) => <String, dynamic>{
  'festivalId': instance.festivalId,
  'title': instance.title,
  'totalRevenue': instance.totalRevenue,
};

FestivalRatingResponse _$FestivalRatingResponseFromJson(
  Map<String, dynamic> json,
) => FestivalRatingResponse(
  festivalId: (json['festivalId'] as num).toInt(),
  title: json['title'] as String,
  averageRating: (json['averageRating'] as num).toDouble(),
);

Map<String, dynamic> _$FestivalRatingResponseToJson(
  FestivalRatingResponse instance,
) => <String, dynamic>{
  'festivalId': instance.festivalId,
  'title': instance.title,
  'averageRating': instance.averageRating,
};
