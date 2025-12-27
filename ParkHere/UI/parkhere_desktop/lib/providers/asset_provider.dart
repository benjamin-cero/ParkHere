import 'package:parkhere_desktop/model/asset.dart';
import 'package:parkhere_desktop/providers/base_provider.dart';

class AssetProvider extends BaseProvider<Asset> {
  AssetProvider() : super('Asset');

  @override
  Asset fromJson(dynamic json) {
    return Asset.fromJson(json as Map<String, dynamic>);
  }
}
