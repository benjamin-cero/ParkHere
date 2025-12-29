import 'package:parkhere_desktop/model/user.dart';
import 'package:parkhere_desktop/model/parking_reservation.dart';

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

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      userId: json['userId'] as int? ?? 0,
      reservationId: json['reservationId'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      user: json['user'] != null 
          ? User.fromJson(json['user'] as Map<String, dynamic>) 
          : null,
      parkingReservation: json['parkingReservation'] != null 
          ? ParkingReservation.fromJson(json['parkingReservation'] as Map<String, dynamic>) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'userId': userId,
      'reservationId': reservationId,
      'createdAt': createdAt.toIso8601String(),
      'user': user?.toJson(),
      'parkingReservation': parkingReservation?.toJson(),
    };
  }
}
