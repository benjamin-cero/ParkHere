import 'package:parkhere_desktop/model/country.dart';
import 'package:parkhere_desktop/providers/base_provider.dart';

class CountryProvider extends BaseProvider<Country> {
  CountryProvider() : super('Country');

  @override
  Country fromJson(dynamic json) {
    return Country.fromJson(json);
  }
}
