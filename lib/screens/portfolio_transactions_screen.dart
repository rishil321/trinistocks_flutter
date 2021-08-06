import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:trinistocks_flutter/apis/listed_stocks_api.dart';
import 'package:trinistocks_flutter/apis/portfolio_api.dart';
import 'package:trinistocks_flutter/apis/profile_management_api.dart';
import 'package:trinistocks_flutter/widgets/main_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trinistocks_flutter/widgets/portfolio_transactions_datatable.dart';
import 'package:after_layout/after_layout.dart';

class PortfolioTransactionsPage extends StatefulWidget {
  PortfolioTransactionsPage({Key? key}) : super(key: key);

  @override
  _PortfolioTransactionsPageState createState() =>
      _PortfolioTransactionsPageState();
}

class _PortfolioTransactionsPageState extends State<PortfolioTransactionsPage>
    with AfterLayoutMixin<PortfolioTransactionsPage> {
  bool isLoading = true;
  TextEditingController numSharesController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();
  late FToast fToast;
  String cardView = "Initial";
  late Card addTransactionCardView;
  List<DropdownMenuItem<String>> listedSymbols = [];
  String selectedSymbol = 'AGL';
  String boughtOrSold = 'Bought';
  double buttonBarLabelSize = 16;
  double spacing = 20.0;
  Widget pastPortfolioTransactions = Text("");

  @override
  void initState() {
    ListedStocksAPI.fetchListedStockSymbols().then((List<String> symbols) {
      for (String symbol in symbols) {
        listedSymbols.add(
          new DropdownMenuItem<String>(
            value: symbol,
            child: Text(
              symbol,
              style: TextStyle(),
            ),
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    addTransactionCardView = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Theme.of(context).accentColor),
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Table(
              border: TableBorder(),
              columnWidths: {0: FixedColumnWidth(130)},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    Text(
                      "Symbol",
                      style: TextStyle(fontSize: buttonBarLabelSize),
                    ),
                    buildSymbolDropdownButton(context),
                  ],
                ),
                TableRow(
                  children: [
                    SizedBox(
                      height: spacing,
                    ),
                    SizedBox(
                      height: spacing,
                    ),
                  ],
                ),
                TableRow(children: [
                  Text(
                    "Shares traded",
                    style: TextStyle(fontSize: buttonBarLabelSize),
                  ),
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: TextFormField(
                      controller: numSharesController,
                      decoration: const InputDecoration(
                        labelText: 'Number of shares',
                        hintText: "100",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ]),
                TableRow(
                  children: [
                    SizedBox(
                      height: spacing,
                    ),
                    SizedBox(
                      height: spacing,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      "Bought or Sold?",
                      style: TextStyle(fontSize: buttonBarLabelSize),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: this.boughtOrSold,
                      icon: FaIcon(
                        FontAwesomeIcons.arrowAltCircleDown,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      items: <DropdownMenuItem<String>>[
                        DropdownMenuItem(
                          value: "Bought",
                          child: Text("Bought "),
                        ),
                        DropdownMenuItem(
                          value: "Sold",
                          child: Text("Sold "),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSymbol = newValue!;
                        });
                      },
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    SizedBox(
                      height: spacing,
                    ),
                    SizedBox(
                      height: spacing,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      "Price per share",
                      style: TextStyle(fontSize: buttonBarLabelSize),
                    ),
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Share Price(\$)',
                          hintText: "20.00",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    SizedBox(
                      height: spacing,
                    ),
                    SizedBox(
                      height: spacing,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      "Date executed",
                      style: TextStyle(fontSize: buttonBarLabelSize),
                    ),
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: TextFormField(
                        readOnly: true,
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Click to pick date',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2150));
                          dateController.text =
                              date.toString().substring(0, 10);
                        },
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    SizedBox(
                      height: spacing,
                    ),
                    SizedBox(
                      height: spacing,
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              child: Text(
                "Add Transaction",
                style: TextStyle(color: Theme.of(context).backgroundColor),
              ),
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).primaryColor)),
              onPressed: () {
                isLoading = true;
                //first ensure that correct values have been put in the numshares and price fields
                try {
                  if (numSharesController.text == '') {
                    throw FormatException(
                        "Please enter the number of shares traded.");
                  }
                  int numShares = int.parse(numSharesController.text);
                  if (priceController.text == '') {
                    throw FormatException(
                        "Please enter the price for the shares traded.");
                  }
                  double sharePrice = double.parse(priceController.text);
                  addPortfolioTransaction(selectedSymbol, dateController.text,
                          boughtOrSold, numShares, sharePrice)
                      .then(
                    (Map returnValue) {
                      String? returnMessage = returnValue['message'];
                      isLoading = false;
                      if (returnMessage != null) {
                        fToast.showToast(
                          child: returnToast(returnMessage, false),
                          toastDuration: Duration(seconds: 5),
                          gravity: ToastGravity.BOTTOM,
                        );
                      } else {
                        fToast.showToast(
                          child: returnToast(
                              "Transaction added successfully!", true),
                          gravity: ToastGravity.BOTTOM,
                          toastDuration: Duration(seconds: 2),
                        );
                        Navigator.pushNamed(context, '/portfolio_summary');
                      }
                    },
                  );
                } catch (e) {
                  fToast.showToast(
                    child: returnToast(e.toString(), false),
                    toastDuration: Duration(seconds: 5),
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Portfolio Transactions'),
        centerTitle: true,
      ),
      //add a drawer for navigation
      endDrawer: MainDrawer(),
      //setup futurebuilders to wait on the API data
      body: LoadingOverlay(
        child: ListView(
          children: [
            addTransactionCardView,
            pastPortfolioTransactions,
          ],
        ),
        isLoading: isLoading,
      ),
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

  Widget buildSymbolDropdownButton(BuildContext context) {
    return DropdownButton<String>(
      value: this.selectedSymbol,
      isExpanded: true,
      icon: FaIcon(
        FontAwesomeIcons.arrowAltCircleDown,
        color: Theme.of(context).secondaryHeaderColor,
      ),
      items: listedSymbols,
      onChanged: (String? newValue) {
        setState(() {
          selectedSymbol = newValue!;
        });
      },
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    PortfolioAPI.getPortfolioTransactions().then((List<Map> returnValue) {
      if (returnValue.isNotEmpty) {
        setState(
          () {
            pastPortfolioTransactions = Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(color: Theme.of(context).accentColor),
              ),
              child: PortfolioTransactionsDataTable(
                  tableData: returnValue,
                  headerColor: Theme.of(context).primaryColor,
                  leftHandColor: Theme.of(context).highlightColor),
            );
          },
        );
      } else {
        fToast.showToast(
          child: returnToast(
              "Could not fetch past portfolio transactions.", false),
          toastDuration: Duration(seconds: 5),
          gravity: ToastGravity.BOTTOM,
        );
      }
    });
  }

  Future<Map> addPortfolioTransaction(String symbol, String date,
      String boughtOrSold, int numShares, double sharePrice) {
    Map putData = {
      'symbol': symbol,
      'date': date,
      'bought_or_sold': boughtOrSold,
      'num_shares': numShares.toString(),
      'share_price': sharePrice.toString()
    };
    return PortfolioAPI.addPortfolioTransaction(putData);
  }
}
