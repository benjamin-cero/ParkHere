import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final int festivalId;
  final String festivalTitle;
  final int userId;
  final String username;
  final String userFullName;
  final String? festivalLogo;

  const Review({
    this.id = 0,
    this.rating = 0,
    this.comment,
    required this.createdAt,
    this.festivalId = 0,
    this.festivalTitle = '',
    this.userId = 0,
    this.username = '',
    this.userFullName = '',
    this.festivalLogo,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
