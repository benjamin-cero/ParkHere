import 'package:json_annotation/json_annotation.dart';
import 'package:parkhere_desktop/model/user.dart';
import 'package:parkhere_desktop/model/parking_reservation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  final int rating;
  final String? comment;
  final int userId;
  final int reservationId;
  final DateTime createdAt;
  final User? user;
  final ParkingReservation? parkingReservation;

  const Review({
    this.id = 0,
    this.rating = 0,
    this.comment,
    this.userId = 0,
    this.reservationId = 0,
    required this.createdAt,
    this.user,
    this.parkingReservation,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
