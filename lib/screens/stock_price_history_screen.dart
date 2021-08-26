import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trinistocks_flutter/apis/listed_stocks_api.dart';
import 'package:trinistocks_flutter/apis/stock_price_api.dart';
import 'package:trinistocks_flutter/widgets/loading_widget.dart';
import 'package:trinistocks_flutter/widgets/main_drawer.dart';
import 'package:provider/provider.dart';
import 'package:trinistocks_flutter/widgets/stock_price_candlestick_chart.dart';
import 'package:loading_overlay/loading_overlay.dart';

class StockPriceHistoryPage extends StatefulWidget {
  StockPriceHistoryPage({Key? key}) : super(key: key);

  @override
  _StockPriceHistoryPageState createState() => _StockPriceHistoryPageState();
}

class _StockPriceHistoryPageState extends State<StockPriceHistoryPage> {
  List<Color> generatedColors = <Color>[];
  String selectedSymbol = 'AGL';
  String dateRange = StockPriceDateRange.oneYear;
  double buttonBarLabelSize = 16;
  bool symbolDropdownButtonBuilt = false;
  List<DropdownMenuItem<String>> listedSymbols = [];
  bool _loading = true;
  late StockPriceCandlestickChart stockPriceCandlestickChart;
  bool stockPriceChartBuilt = false;

  @override
  void initState() {
    ListedStocksAPI.fetchListedStockSymbols().then((List<String> symbols) {
      for (String symbol in symbols) {
        listedSymbols.add(
          new DropdownMenuItem<String>(
            value: symbol,
            child: Text(
              symbol,
              style: TextStyle(fontSize: buttonBarLabelSize),
            ),
          ),
        );
      }
      updateStockPriceChart(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Price History'),
        centerTitle: true,
      ),
      //add a drawer for navigation
      endDrawer: MainDrawer(),
      //setup futurebuilders to wait on the API data
      body: LoadingOverlay(
        child: ListView(
          padding: const EdgeInsets.all(0.0),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        children: [
                          Text(
                            "Symbol",
                            style: TextStyle(
                              fontSize: buttonBarLabelSize,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 5, bottom: 5, left: 5, right: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Container(
                              height: 30,
                              margin: EdgeInsets.only(left: 5, right: 5),
                              child: buildSymbolDropdownButton(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        children: [
                          Text(
                            "Range",
                            style: TextStyle(
                              fontSize: buttonBarLabelSize,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 5, bottom: 5, left: 5, right: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Container(
                              height: 30,
                              margin: EdgeInsets.only(left: 5, right: 5),
                              child: startDateDropdownButton(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            stockPriceChartBuilt ? stockPriceCandlestickChart : Text(""),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).buttonColor),
                    ),
                    onPressed: resetZoom,
                    child: Row(children: [
                      FaIcon(FontAwesomeIcons.searchMinus),
                      Text(" Reset Zoom")
                    ]))
              ],
            )
          ],
        ),
        isLoading: _loading,
      ),
    );
  }

  void resetZoom() {
    stockPriceCandlestickChart.resetZoom();
  }

  void updateStockPriceChart(BuildContext context) {
    StockPriceAPI.fetchStockPriceData(selectedSymbol, dateRange)
        .then((List<Map> stockData) {
      stockPriceCandlestickChart = StockPriceCandlestickChart(
        stockData,
        animate: false,
      );
      setState(() {
        _loading = false;
        stockPriceChartBuilt = true;
      });
    });
  }

  Widget buildSymbolDropdownButton(BuildContext context) {
    return DropdownButton<String>(
      value: this.selectedSymbol,
      icon: FaIcon(
        FontAwesomeIcons.chevronDown,
      ),
      items: listedSymbols,
      underline: Text(""),
      onChanged: (String? newValue) {
        setState(() {
          _loading = true;
          selectedSymbol = newValue!;
          updateStockPriceChart(context);
        });
      },
    );
  }

  Widget startDateDropdownButton(BuildContext context) {
    return DropdownButton<String>(
      value: dateRange,
      icon: FaIcon(
        FontAwesomeIcons.chevronDown,
      ),
      items: [
        new DropdownMenuItem<String>(
          value: StockPriceDateRange.oneMonth,
          child: Text(
            StockPriceDateRange.oneMonth,
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: StockPriceDateRange.oneYear,
          child: Text(
            StockPriceDateRange.oneYear,
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: StockPriceDateRange.fiveYears,
          child: Text(
            StockPriceDateRange.fiveYears,
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: StockPriceDateRange.tenYears,
          child: Text(
            StockPriceDateRange.tenYears,
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
      ],
      underline: Text(""),
      onChanged: (String? newValue) {
        setState(() {
          _loading = true;
          dateRange = newValue!;
          updateStockPriceChart(context);
        });
      },
    );
  }
}
