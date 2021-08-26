// @dart=2.9
import 'dart:io';

import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trinistocks_flutter/apis/daily_trades_api.dart';
import 'package:trinistocks_flutter/apis/listed_stocks_api.dart';
import 'package:trinistocks_flutter/apis/stock_monitoring_api.dart';
import 'package:trinistocks_flutter/screens/dividend_history_screen.dart';
import 'package:trinistocks_flutter/screens/portfolio_summary_screen.dart';
import 'package:trinistocks_flutter/screens/portfolio_transactions_screen.dart';
import 'package:trinistocks_flutter/screens/simulator_create_game_screen.dart';
import 'package:trinistocks_flutter/screens/simulator_game_rankings_screen.dart';
import 'package:trinistocks_flutter/screens/simulator_games_summary_screen.dart';
import 'package:trinistocks_flutter/screens/simulator_join_game_screen.dart';
import 'package:trinistocks_flutter/screens/simulator_portfolio_summary_screen.dart';
import 'package:trinistocks_flutter/screens/simulator_transactions_screen.dart';
import 'package:trinistocks_flutter/screens/stock_notifications.dart';
import 'screens/fundamental_analysis_history_screen.dart';
import 'screens/fundamental_analysis_screen.dart';
import 'screens/listed_stocks_screen.dart';
import 'screens/login_screen.dart';
import 'screens/market_index_history_screen.dart';
import 'screens/outstanding_trade_history_screen.dart';
import 'screens/stock_news_history_screen.dart';
import 'screens/technical_analysis_screen.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'screens/stock_price_history_screen.dart';
import 'screens/user_profile_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  // final cron = Cron();
  // FlutterLocalNotificationsPlugin flip = new FlutterLocalNotificationsPlugin();
  // cron.schedule(
  //   //set up a cronjob to trigger the daily notifications every day
  //   Schedule.parse('* * * * *'),
  //   () async {
  //     _showNotificationWithDefaultSound(flip);
  //   },
  // );
  runApp(
    TriniStocks(),
  );
}

Future _showNotificationWithDefaultSound(flip) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'trinistocks', 'stocks', 'Stock data on trini tickers',
      fullScreenIntent: true,
      importance: Importance.max,
      priority: Priority.high);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  // initialise channel platform for both Android and iOS device.
  var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  //use the API to fetch the stocks that the user is monitoring
  StockMonitoringAPI.fetchMonitoredStocks().then(
    (List<String> allMonitoredSymbols) async {
      //if we have some stocks that are monitored, fetch the latest data on each symbol
      if (allMonitoredSymbols.isNotEmpty) {
        List<Map> monitoredSymbolData = [];
        FetchDailyTradesAPI.fetchLatestTrades().then(
          (Map latestTradedStockData) async {
            ListedStocksAPI.fetchListedStockSymbolsAndLatestPrices().then(
              (List<Map> latestStockPrices) async {
                for (String monitoredSymbol in allMonitoredSymbols) {
                  bool monitoredSymbolTradedToday = false;
                  for (Map symbolData in latestTradedStockData['tableData']) {
                    if (symbolData['symbol'] == monitoredSymbol) {
                      monitoredSymbolTradedToday = true;
                      Map stockData = symbolData;
                      stockData['tradedToday'] = true;
                      monitoredSymbolData.add(stockData);
                    }
                  }
                  if (!monitoredSymbolTradedToday) {
                    //find the latest price for this monitored symbol
                    for (Map symbolData in latestStockPrices) {
                      if (symbolData['symbol'] == monitoredSymbol) {
                        Map stockData = symbolData;
                        stockData['tradedToday'] = false;
                        monitoredSymbolData.add(stockData);
                      }
                    }
                  }
                }

                await flip.show(
                  //notification id
                  0,
                  //title
                  'Daily Monitored Stock Updates',
                  //body
                  monitoredSymbolData.toString(),
                  platformChannelSpecifics,
                  payload:
                      //payload to pass back to app
                      'Default_Sound',
                );
              },
            );
          },
        );
      }
    },
  );
}

class TriniStocks extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'trinistocks',
      theme: FlexColorScheme.light(scheme: FlexScheme.green).toTheme,
      darkTheme: FlexColorScheme.dark(scheme: FlexScheme.green).toTheme,
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/user_profile': (context) => UserProfilePage(),
        '/listed_stocks': (context) => ListedStocksPage(),
        '/technical_analysis': (context) => TechnicalAnalysisPage(),
        '/fundamental_analysis': (context) => FundamentalAnalysisPage(),
        '/stock_price_history': (context) => StockPriceHistoryPage(),
        '/dividend_history': (context) => DividendHistoryPage(),
        '/market_index_history': (context) => MarketIndexHistoryPage(),
        '/outstanding_trade_history': (context) =>
            OutstandingTradesHistoryPage(),
        '/stock_news_history': (context) => StockNewsHistoryPage(),
        '/fundamental_analysis_history': (context) =>
            FundamentalAnalysisHistoryPage(),
        '/portfolio_summary': (context) => PortfolioSummaryPage(),
        '/portfolio_transactions': (context) => PortfolioTransactionsPage(),
        '/simulator_games': (context) => SimulatorGamesPage(),
        '/simulator_game_create': (context) => SimulatorGameCreatePage(),
        '/simulator_game_join': (context) => SimulatorJoinGamePage(),
        '/simulator_portfolio_summary': (context) =>
            SimulatorPortfolioSummaryPage(),
        '/simulator_transactions': (context) => SimulatorTransactionsPage(),
        '/simulator_games_rankings': (context) => SimulatorGamesRankingsPage(),
        '/stock_notifications': (context) => StockNotificationsPage(),
      },
    );
  }
}
