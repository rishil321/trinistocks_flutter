import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trinistocks_flutter/apis/profile_management_api.dart';

class StockMonitoringAPI {
  StockMonitoringAPI() {}

  static Future<List<String>> fetchMonitoredStocks() async {
    //ensure that the user is signed in
    return ProfileManagementAPI.checkUserLoggedIn().then((Map userInfo) async {
      //set up a list to store all the portfolio data
      List<String> symbols = [];
      if (userInfo['isLoggedIn'] = true) {
        String url = 'https://trinistocks.com/api/stockmonitoring';
        final apiToken = userInfo['token'];
        var response =
            await http.get(url, headers: {"Authorization": "Token $apiToken"});
        List apiResponse = [];
        if (response.statusCode == 200) {
          apiResponse = json.decode(response.body);
        } else {
          throw Exception("Could not fetch API data from $url");
        }
        for (Map response in apiResponse) {
          symbols.add(response['symbol']);
        }
      }
      return symbols;
    });
  }

  static Future<Map> addSymbolMonitored(String symbol) async {
    //ensure that the user is signed in
    return ProfileManagementAPI.checkUserLoggedIn().then(
      (Map userInfo) async {
        Map response = Map();
        if (userInfo['isLoggedIn'] = true) {
          String url = 'https://trinistocks.com/api/stockmonitoring';
          final apiToken = userInfo['token'];
          var apiResponse = await http.post(
            url,
            headers: {"Authorization": "Token $apiToken"},
            body: {'symbol': symbol, 'operation': 'add_monitor'},
          );
          if (apiResponse.statusCode == 202) {
            response['message'] = null;
          } else {
            response['message'] = apiResponse.body;
          }
        } else {
          response['message'] = "No user logged in";
        }
        return response;
      },
    );
  }

  static Future<Map> removeMonitoredSymbol(String symbol) async {
    //ensure that the user is signed in
    return ProfileManagementAPI.checkUserLoggedIn().then(
      (Map userInfo) async {
        Map response = Map();
        if (userInfo['isLoggedIn'] = true) {
          String url = 'https://trinistocks.com/api/stockmonitoring';
          final apiToken = userInfo['token'];
          var apiResponse = await http.post(
            url,
            headers: {"Authorization": "Token $apiToken"},
            body: {'symbol': symbol, 'operation': 'remove_monitor'},
          );
          if (apiResponse.statusCode == 202) {
            response['message'] = null;
          } else {
            response['message'] = apiResponse.body;
          }
        } else {
          response['message'] = "No user logged in";
        }
        return response;
      },
    );
  }
}
