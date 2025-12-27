import 'package:json_annotation/json_annotation.dart';

part 'asset.g.dart';

@JsonSerializable()
class Asset {
  final int id;
  final String fileName;
  final String contentType;
  final String base64Content;
  final int festivalId;
  final String? festivalTitle;

  Asset({
    required this.id,
    required this.fileName,
    required this.contentType,
    required this.base64Content,
    required this.festivalId,
    this.festivalTitle,
  });

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
  Map<String, dynamic> toJson() => _$AssetToJson(this);

  // Helper method to get file extension
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Helper method to check if it's an image
  bool get isImage {
    return contentType.startsWith('image/');
  }

  // Helper method to get display name
  String get displayName {
    if (fileName.length > 20) {
      return '${fileName.substring(0, 17)}...';
    }
    return fileName;
  }
}
