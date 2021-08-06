import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trinistocks_flutter/apis/profile_management_api.dart';

class PortfolioAPI {
  PortfolioAPI() {}

  static Future<List> fetchPortfolioSummaryData() async {
    //ensure that the user is signed in
    return ProfileManagementAPI.checkUserLoggedIn().then((Map userInfo) async {
      //set up a list to store all the portfolio data
      List<Map> portfolioData = [];
      if (userInfo['isLoggedIn'] = true) {
        String url = 'https://trinistocks.com/api/portfoliosummary';
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
          Map parsedData = new Map();
          try {
            parsedData['symbol'] = response['symbol'];
          } catch (e) {
            parsedData['symbol'] = null;
          }
          try {
            parsedData['shares_remaining'] = response['shares_remaining'];
          } catch (e) {
            parsedData['shares_remaining'] = null;
          }
          try {
            parsedData['average_cost'] = double.parse(response['average_cost']);
          } catch (e) {
            parsedData['average_cost'] = null;
          }
          try {
            parsedData['book_cost'] = double.parse(response['book_cost']);
          } catch (e) {
            parsedData['book_cost'] = null;
          }
          try {
            parsedData['current_market_price'] =
                double.parse(response['current_market_price']);
          } catch (e) {
            parsedData['current_market_price'] = null;
          }
          try {
            parsedData['market_value'] = double.parse(response['market_value']);
          } catch (e) {
            parsedData['market_value'] = null;
          }
          try {
            parsedData['total_gain_loss'] =
                double.parse(response['total_gain_loss']);
          } catch (e) {
            parsedData['total_gain_loss'] = null;
          }
          try {
            parsedData['gain_loss_percent'] =
                double.parse(response['gain_loss_percent']);
          } catch (e) {
            parsedData['gain_loss_percent'] = null;
          }
          portfolioData.add(parsedData);
        }
        portfolioData
            .sort((a, b) => (b['market_value']).compareTo(a['market_value']));
      }
      return portfolioData;
    });
  }

  static Future<List> fetchPortfolioSectorData() async {
    //ensure that the user is signed in
    return ProfileManagementAPI.checkUserLoggedIn().then((Map userInfo) async {
      //set up a list to store all the portfolio data
      List<Map> portfolioData = [];
      if (userInfo['isLoggedIn'] = true) {
        String url = 'https://trinistocks.com/api/portfoliosectors';
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
          Map parsedData = new Map();
          try {
            parsedData['sector'] = response['sector'];
          } catch (e) {
            parsedData['sector'] = null;
          }
          try {
            parsedData['book_cost'] = double.parse(response['book_cost']);
          } catch (e) {
            parsedData['book_cost'] = null;
          }
          try {
            parsedData['market_value'] = double.parse(response['market_value']);
          } catch (e) {
            parsedData['market_value'] = null;
          }
          try {
            parsedData['total_gain_loss'] =
                double.parse(response['total_gain_loss']);
          } catch (e) {
            parsedData['total_gain_loss'] = null;
          }
          try {
            parsedData['gain_loss_percent'] =
                double.parse(response['gain_loss_percent']);
          } catch (e) {
            parsedData['gain_loss_percent'] = null;
          }
          portfolioData.add(parsedData);
        }
        portfolioData
            .sort((a, b) => (b['market_value']).compareTo(a['market_value']));
      }
      return portfolioData;
    });
  }

  static Future<List<Map>> getPortfolioTransactions() async {
    //ensure that the user is signed in
    return ProfileManagementAPI.checkUserLoggedIn().then(
      (Map userInfo) async {
        List<Map> portfolioData = [];
        if (userInfo['isLoggedIn'] = true) {
          String url = 'https://trinistocks.com/api/portfoliotransactions';
          final apiToken = userInfo['token'];
          var response = await http
              .get(url, headers: {"Authorization": "Token $apiToken"});
          List apiResponse = [];
          if (response.statusCode == 200) {
            apiResponse = json.decode(response.body);
            for (Map response in apiResponse) {
              Map parsedData = new Map();
              try {
                parsedData['date'] = DateTime.parse(response['date']);
              } catch (e) {
                parsedData['date'] = null;
              }
              try {
                parsedData['boughtOrSold'] = response['bought_or_sold'];
              } catch (e) {
                parsedData['boughtOrSold'] = null;
              }
              try {
                parsedData['sharePrice'] =
                    double.parse(response['share_price']);
              } catch (e) {
                parsedData['sharePrice'] = null;
              }
              try {
                parsedData['numShares'] = response['num_shares'];
              } catch (e) {
                parsedData['numShares'] = null;
              }
              try {
                parsedData['symbol'] = response['symbol'];
              } catch (e) {
                parsedData['symbol'] = null;
              }
              portfolioData.add(parsedData);
            }
            portfolioData.sort((a, b) => (b['date']).compareTo(a['date']));

            return portfolioData;
          } else {
            throw Exception("Could not fetch API data from $url");
          }
        } else {
          return [];
        }
      },
    );
  }

  static Future<Map> addPortfolioTransaction(Map transactionData) async {
    //ensure that the user is signed in
    return ProfileManagementAPI.checkUserLoggedIn().then((Map userInfo) async {
      Map response = Map();
      if (userInfo['isLoggedIn'] = true) {
        String url = 'https://trinistocks.com/api/portfoliotransaction';
        final apiToken = userInfo['token'];
        var apiResponse = await http.put(url,
            headers: {"Authorization": "Token $apiToken"},
            body: transactionData);
        if (apiResponse.statusCode == 201) {
          response['message'] = null;
        } else {
          response['message'] = apiResponse.body;
        }
      } else {
        response['message'] = "No user logged in";
      }
      return response;
    });
  }
}
