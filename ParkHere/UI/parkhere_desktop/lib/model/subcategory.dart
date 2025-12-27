import 'package:json_annotation/json_annotation.dart';

part 'subcategory.g.dart';

@JsonSerializable()
class Subcategory {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final int categoryId;
  final String categoryName;

  const Subcategory({
    this.id = 0,
    this.name = '',
    this.description,
    this.isActive = true,
    this.categoryId = 0,
    this.categoryName = '',
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) =>
      _$SubcategoryFromJson(json);
  Map<String, dynamic> toJson() => _$SubcategoryToJson(this);
}
