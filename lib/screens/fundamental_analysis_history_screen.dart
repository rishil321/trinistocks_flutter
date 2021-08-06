import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trinistocks_flutter/apis/fundamental_analysis_api.dart';
import 'package:trinistocks_flutter/apis/listed_stocks_api.dart';
import 'package:trinistocks_flutter/apis/stock_price_api.dart';
import 'package:trinistocks_flutter/widgets/fundamentals_line_chart.dart';
import 'package:trinistocks_flutter/widgets/loading_widget.dart';
import 'package:trinistocks_flutter/widgets/main_drawer.dart';
import 'package:provider/provider.dart';
import 'package:trinistocks_flutter/widgets/stock_price_candlestick_chart.dart';
import 'package:loading_overlay/loading_overlay.dart';

class FundamentalAnalysisHistoryPage extends StatefulWidget {
  FundamentalAnalysisHistoryPage({Key? key}) : super(key: key);

  @override
  _FundamentalAnalysisHistoryPageState createState() =>
      _FundamentalAnalysisHistoryPageState();
}

class _FundamentalAnalysisHistoryPageState
    extends State<FundamentalAnalysisHistoryPage> {
  List<Color> generatedColors = <Color>[];
  String selectedSymbol = 'AGL';
  String selectedRatio = "priceToEarningsRatio";
  String dateRange = FundamentalDateRange.tenYears;
  double buttonBarLabelSize = 16;
  bool symbolDropdownButtonBuilt = false;
  List<DropdownMenuItem<String>> listedSymbols = [];
  bool _loading = true;
  Widget fundamentalAnnualHistoryChart = Text("");
  Widget fundamentalQuarterlyHistoryChart = Text("");

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
      updateFundamentalCharts(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fundamental History'),
        centerTitle: true,
      ),
      //add a drawer for navigation
      endDrawer: MainDrawer(),
      //setup futurebuilders to wait on the API data
      body: LoadingOverlay(
        child: ListView(
          children: [
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
                              color: Theme.of(context).cardColor,
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
                              color: Theme.of(context).cardColor,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Ratio",
                          style: TextStyle(
                            fontSize: buttonBarLabelSize,
                            color: Theme.of(context).cardColor,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 5, bottom: 5, left: 5, right: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Container(
                            height: 30,
                            margin: EdgeInsets.only(left: 5, right: 5),
                            child: buildFundamentalRatioChoiceDropdownButton(
                                context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            fundamentalAnnualHistoryChart,
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: fundamentalQuarterlyHistoryChart),
          ],
        ),
        isLoading: _loading,
      ),
    );
  }

  void updateFundamentalCharts(BuildContext context) {
    FundamentalAnalysisAPI.fetchAuditedFundamentalAnalysisData(
            selectedSymbol, dateRange)
        .then((List stockData) {
      fundamentalAnnualHistoryChart = FundamentalsLineChart(
        stockData,
        selectedRatio,
        "Annual Ratios",
        animate: false,
      );
      setState(() {});
    });
    FundamentalAnalysisAPI.fetchQuarterlyFundamentalAnalysisData(
            selectedSymbol, dateRange)
        .then((List stockData) {
      fundamentalQuarterlyHistoryChart = FundamentalsLineChart(
        stockData,
        selectedRatio,
        "Quarterly Ratios",
        animate: false,
      );
      setState(() {
        _loading = false;
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
          updateFundamentalCharts(context);
        });
      },
    );
  }

  Widget buildFundamentalRatioChoiceDropdownButton(BuildContext context) {
    return DropdownButton<String>(
      value: this.selectedRatio,
      icon: FaIcon(
        FontAwesomeIcons.chevronDown,
      ),
      items: [
        new DropdownMenuItem<String>(
          value: "earningsPerShare",
          child: Text(
            "EPS",
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: "returnOnInvestedCapital",
          child: Text(
            "RoIC",
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: "currentRatio",
          child: Text(
            "Current Ratio",
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: "priceToEarningsRatio",
          child: Text(
            "P/E",
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: "dividendYield",
          child: Text(
            "Dividend Yield",
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: "priceToBookRatio",
          child: Text(
            "P/B",
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: "dividendPayoutRatio",
          child: Text(
            "Dividend Payout",
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: "cashPerShare",
          child: Text(
            "Cash Per Share",
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
      ],
      underline: Text(""),
      onChanged: (String? newValue) {
        setState(() {
          _loading = true;
          selectedRatio = newValue!;
          updateFundamentalCharts(context);
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
          value: FundamentalDateRange.threeYears,
          child: Text(
            FundamentalDateRange.threeYears,
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: FundamentalDateRange.fiveYears,
          child: Text(
            FundamentalDateRange.fiveYears,
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
        new DropdownMenuItem<String>(
          value: FundamentalDateRange.tenYears,
          child: Text(
            FundamentalDateRange.tenYears,
            style: TextStyle(fontSize: buttonBarLabelSize),
          ),
        ),
      ],
      underline: Text(""),
      onChanged: (String? newValue) {
        setState(() {
          _loading = true;
          dateRange = newValue!;
          updateFundamentalCharts(context);
        });
      },
    );
  }
}
