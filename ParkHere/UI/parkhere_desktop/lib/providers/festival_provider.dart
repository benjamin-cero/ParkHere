import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parkhere_desktop/model/festival.dart';
import 'package:parkhere_desktop/model/search_result.dart';
import 'package:parkhere_desktop/providers/base_provider.dart';

class FestivalProvider extends BaseProvider<Festival> {
  FestivalProvider() : super('Festival');

  @override
  Festival fromJson(dynamic json) {
    return Festival.fromJson(json as Map<String, dynamic>);
  }

  Future<SearchResult<Festival>> getWithoutAssets({dynamic filter}) async {
    var url = "${BaseProvider.baseUrl}$endpoint/without-assets";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<Festival>();
      result.totalCount = data['totalCount'];
      result.items = List<Festival>.from(data["items"].map((e) => fromJson(e)));
      return result;
    } else {
      throw Exception("Unknown error");
    }
  }
}
