import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';

class PortfolioTransactionsDataTable extends StatefulWidget {
  //constructor to ask for tabledata
  PortfolioTransactionsDataTable(
      {required this.tableData,
      required this.headerColor,
      required this.leftHandColor});

  List<Map> tableData;
  final Color headerColor;
  final Color leftHandColor;

  @override
  _PortfolioTransactionsDataTableState createState() =>
      _PortfolioTransactionsDataTableState();
}

class _PortfolioTransactionsDataTableState
    extends State<PortfolioTransactionsDataTable> {
  int symbolSort = 0;
  int valueTradedSort = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    transactions.initData(widget.tableData);
    return Container(
      child: HorizontalDataTable(
        leftHandSideColumnWidth: 80,
        rightHandSideColumnWidth: 460,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: _generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: widget.tableData.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black54,
          height: 1.0,
          thickness: 1.0,
        ),
        leftHandSideColBackgroundColor: widget.leftHandColor,
        rightHandSideColBackgroundColor: Theme.of(context).backgroundColor,
        enablePullToRefresh: false,
        elevation: 0.0,
      ),
      height: 53.0 * (widget.tableData.length + 1),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget("Date", 80),
      _getTitleItemWidget("Symbol", 80),
      _getTitleItemWidget("Bought/Sold", 100),
      _getTitleItemWidget("Num Shares", 60),
      _getTitleItemWidget("Share Price", 80),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        textAlign: TextAlign.start,
      ),
      width: width,
      height: 50,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
      color: widget.headerColor,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      child: Text(
        DateFormat.yMMMd()
            .format(transactions.portfolioTransactionData[index].date),
        style: TextStyle(color: Colors.black),
      ),
      width: 80,
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    var compactFormat =
        NumberFormat.compactCurrency(locale: 'en_US', symbol: "\$");
    return Row(
      children: <Widget>[
        Container(
          child: Row(
            children: <Widget>[
              Text(
                transactions.portfolioTransactionData[index].symbol,
              )
            ],
          ),
          width: 80,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
            transactions.portfolioTransactionData[index].boughtOrSold,
          ),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
            transactions.portfolioTransactionData[index].numShares.toString(),
          ),
          width: 60,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(
            compactFormat.format(
                transactions.portfolioTransactionData[index].sharePrice),
          ),
          width: 60,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
      ],
    );
  }
}

PortfolioTransactions transactions = PortfolioTransactions();

class PortfolioTransactions {
  List<TransactionData> portfolioTransactionData = [];

  void initData(List<Map> tableData) {
    portfolioTransactionData = [];
    for (int i = 0; i < tableData.length; i++) {
      portfolioTransactionData.add(
        TransactionData(
          tableData[i]['symbol'],
          tableData[i]['date'],
          tableData[i]['boughtOrSold'],
          tableData[i]['numShares'],
          tableData[i]['sharePrice'],
        ),
      );
    }
  }
}

class TransactionData {
  String symbol;
  DateTime date;
  String boughtOrSold;
  int numShares;
  double sharePrice;

  TransactionData(this.symbol, this.date, this.boughtOrSold, this.numShares,
      this.sharePrice);
}
