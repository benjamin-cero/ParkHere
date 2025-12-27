import 'package:json_annotation/json_annotation.dart';


part 'city.g.dart';
@JsonSerializable()
class City {
  final int id;
  final String name;
  final String countryName;
  final int countryId;

  City({
    this.id = 0,
    this.name = '',
    this.countryName = '',
    this.countryId = 0,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}