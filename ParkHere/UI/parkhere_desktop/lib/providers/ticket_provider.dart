import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parkhere_desktop/model/ticket.dart';
import 'package:parkhere_desktop/providers/base_provider.dart';

class TicketProvider extends BaseProvider<Ticket> {
  TicketProvider() : super('Ticket');

  @override
  Ticket fromJson(dynamic json) {
    return Ticket.fromJson(json as Map<String, dynamic>);
  }

  Future<Ticket> redeemTicket(String qrCodeData) async {
    var url = "${BaseProvider.baseUrl}$endpoint/redeem";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(qrCodeData),
    );

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to redeem ticket");
    }
  }
}
