import 'package:json_annotation/json_annotation.dart';
import 'parking_reservation.dart';
import 'user.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final int userId;
  final int reservationId;
  final ParkingReservation? parkingReservation;
  final User? user;

  const Review({
    this.id = 0,
    this.rating = 0,
    this.comment,
    required this.createdAt,
    this.userId = 0,
    this.reservationId = 0,
    this.parkingReservation,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
