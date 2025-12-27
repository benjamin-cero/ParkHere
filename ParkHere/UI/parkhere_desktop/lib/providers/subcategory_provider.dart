import 'package:parkhere_desktop/model/subcategory.dart';
import 'package:parkhere_desktop/providers/base_provider.dart';

class SubcategoryProvider extends BaseProvider<Subcategory> {
  SubcategoryProvider() : super('Subcategory');

  @override
  Subcategory fromJson(dynamic json) {
    return Subcategory.fromJson(json as Map<String, dynamic>);
  }
}
