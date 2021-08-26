import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:trinistocks_flutter/apis/listed_stocks_api.dart';
import 'package:trinistocks_flutter/apis/stock_monitoring_api.dart';
import 'package:trinistocks_flutter/widgets/listed_stocks_datatable.dart';
import 'package:trinistocks_flutter/widgets/loading_widget.dart';
import 'package:trinistocks_flutter/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

class StockNotificationsPage extends StatefulWidget {
  StockNotificationsPage({Key? key}) : super(key: key);

  @override
  _StockNotificationsPageState createState() => _StockNotificationsPageState();
}

class _StockNotificationsPageState extends State<StockNotificationsPage> {
  List<DropdownMenuItem<String>> listedSymbols = [];
  bool _loading = true;
  String selectedSymbol = 'AGL';
  List<TableRow> monitoredStocks = [];
  late FToast fToast;

  @override
  void initState() {
    ListedStocksAPI.fetchListedStockSymbols().then(
      (List<String> symbols) {
        for (String symbol in symbols) {
          listedSymbols.add(
            new DropdownMenuItem<String>(
              value: symbol,
              child: Text(
                symbol,
                style: TextStyle(fontSize: 14),
              ),
            ),
          );
        }
        setState(() {
          _loading = false;
        });
      },
    );
    StockMonitoringAPI.fetchMonitoredStocks().then(
      (List<String> returnSymbols) {
        if (returnSymbols.isNotEmpty) {
          monitoredStocks.add(
            TableRow(
              children: <Widget>[
                Center(
                  child: Text(
                    "Symbol",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Center(
                  child: Text(
                    "Stop Monitoring",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          );
          for (String symbol in returnSymbols) {
            monitoredStocks.add(
              TableRow(
                children: <Widget>[
                  Center(
                    child: Text(symbol,
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                  Center(
                    child: IconButton(
                      color: Colors.red,
                      onPressed: () {
                        setState(
                          () {
                            _loading = true;
                          },
                        );
                        StockMonitoringAPI.removeMonitoredSymbol(symbol).then(
                          (Map returnValue) {
                            if (returnValue['message'] == null) {
                              fToast.showToast(
                                child: returnToast(
                                    "Symbol removed successfully.", true),
                                toastDuration: Duration(seconds: 5),
                                gravity: ToastGravity.BOTTOM,
                              );
                              setState(() {
                                _loading = false;
                                Navigator.pushReplacementNamed(
                                    context, '/stock_notifications');
                              });
                            } else {
                              fToast.showToast(
                                child:
                                    returnToast(returnValue['message'], false),
                                toastDuration: Duration(seconds: 5),
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          },
                        );
                      },
                      icon: FaIcon(FontAwesomeIcons.timesCircle),
                    ),
                  ),
                ],
              ),
            );
          }
        }
        setState(() {
          _loading = false;
        });
      },
    );
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Notifications'),
        centerTitle: true,
      ),
      //add a drawer for navigation
      endDrawer: MainDrawer(),
      //setup futurebuilders to wait on the API data
      body: LoadingOverlay(
        isLoading: _loading,
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: [
            Card(
              child: Text(
                "Add stocks here to monitor them for daily price updates!",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin:
                        EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
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
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(
                        () {
                          _loading = true;
                        },
                      );
                      StockMonitoringAPI.addSymbolMonitored(selectedSymbol)
                          .then(
                        (Map returnValue) {
                          if (returnValue['message'] == null) {
                            fToast.showToast(
                              child: returnToast(
                                  "Symbol added successfully.", true),
                              toastDuration: Duration(seconds: 5),
                              gravity: ToastGravity.BOTTOM,
                            );
                            setState(
                              () {
                                _loading = false;
                                Navigator.pushReplacementNamed(
                                    context, '/stock_notifications');
                              },
                            );
                          } else {
                            fToast.showToast(
                              child: returnToast(returnValue['message'], false),
                              toastDuration: Duration(seconds: 5),
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        },
                      );
                    },
                    icon: FaIcon(FontAwesomeIcons.bell),
                    label: Text("Monitor Stock"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.orange),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                  )
                ],
              ),
            ),
            monitoredStocks.isEmpty
                ? Text("")
                : Card(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Table(
                        border: TableBorder.all(
                            color: Theme.of(context).shadowColor),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FlexColumnWidth(),
                          1: FixedColumnWidth(200),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: monitoredStocks,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
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
        setState(
          () {
            selectedSymbol = newValue!;
          },
        );
      },
    );
  }

  Widget returnToast(String text, bool success) {
    Widget toast = Text("");
    if (success) {
      toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.green,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.check),
            SizedBox(
              width: 12.0,
            ),
            Expanded(
              child: Text(text),
            ),
          ],
        ),
      );
    } else {
      toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.red,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.exclamation),
            SizedBox(
              width: 12.0,
            ),
            Expanded(
              child: Text(text),
            ),
          ],
        ),
      );
    }
    return toast;
  }
}
