import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parkhere_desktop/model/business_report.dart';
import 'package:parkhere_desktop/providers/auth_provider.dart';

class BusinessReportProvider with ChangeNotifier {
  static String? baseUrl;
  BusinessReportResponse? _businessReport;
  bool _isLoading = false;
  String? _error;

  BusinessReportProvider() {
    baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5130/",
    );
  }

  BusinessReportResponse? get businessReport => _businessReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<BusinessReportResponse?> getBusinessReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Remove trailing slash from baseUrl if it exists
      String cleanBaseUrl = baseUrl!.endsWith('/')
          ? baseUrl!.substring(0, baseUrl!.length - 1)
          : baseUrl!;
      var url = "$cleanBaseUrl/BusinessReport";
      var uri = Uri.parse(url);
      var headers = _createHeaders();

      print("Calling BusinessReport endpoint: $url");
      print("Headers: $headers");
      print("Username: ${AuthProvider.username}");
      print("Password: ${AuthProvider.password}");

      var response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception("Request timeout - backend might not be running");
            },
          );

      print("Response status: ${response.statusCode}");
      print("Response headers: ${response.headers}");
      print("Response body: ${response.body}");

      if (_isValidResponse(response)) {
        var data = jsonDecode(response.body);
        print("Parsed JSON data: $data");
        _businessReport = BusinessReportResponse.fromJson(data);
        _error = null;
      } else {
        _error = "Failed to fetch business report";
      }
    } catch (e) {
      print("Error in getBusinessReport: $e");
      if (e.toString().contains("SocketException")) {
        _error =
            "Cannot connect to backend. Please check if the backend is running.";
      } else if (e.toString().contains("timeout")) {
        _error = "Request timeout. Backend might not be responding.";
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _businessReport;
  }

  bool _isValidResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Please check your credentials and try again.");
    } else if (response.statusCode == 404) {
      throw Exception(
        "Business report endpoint not found. Status: ${response.statusCode}",
      );
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  }

  Map<String, String> _createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    return headers;
  }
}
