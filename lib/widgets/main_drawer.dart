import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trinistocks_flutter/apis/profile_management_api.dart';

class MainDrawer extends StatefulWidget {
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  double drawerMainHeaderSize = 18;
  double dropDownHeaderSize = 18;
  double itemHeaderSize = 16;
  double iconSize = 34;
  bool userLoggedIn = false;
  String username = "";

  @override
  void initState() {
    super.initState();
    //check if user is logged in
    ProfileManagementAPI.checkUserLoggedIn().then((Map userInfo) {
      setState(() {
        userLoggedIn = userInfo['isLoggedIn'];
        username = userInfo['username'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 120,
            child: DrawerHeader(
              child: buildUserProfile(),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.house,
              size: iconSize,
            ),
            title: Text(
              'Home',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: itemHeaderSize,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ExpansionTile(
            leading: Icon(
              Icons.table_chart,
              size: iconSize,
            ),
            title: Text(
              "Summarized",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: dropDownHeaderSize,
              ),
            ),
            children: [
              ListTile(
                leading: Icon(
                  Icons.list_alt_rounded,
                  size: iconSize,
                ),
                title: Text(
                  'Listed Stocks',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: itemHeaderSize,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/listed_stocks');
                },
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.chartLine,
                  size: iconSize,
                ),
                title: Text(
                  'Technical Analysis',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: itemHeaderSize,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/technical_analysis');
                },
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.bookReader,
                  size: iconSize,
                ),
                title: Text(
                  'Fundamental Analysis',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: itemHeaderSize,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/fundamental_analysis');
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(
              Icons.stacked_line_chart_rounded,
              size: iconSize,
            ),
            title: Text(
              "Historical",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: dropDownHeaderSize,
              ),
            ),
            children: [
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.chartBar,
                  size: iconSize,
                ),
                title: Text(
                  'Stock Prices',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: itemHeaderSize,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/stock_price_history');
                },
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.handHoldingUsd,
                  size: iconSize,
                ),
                title: Text(
                  'Dividends',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: itemHeaderSize,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/dividend_history');
                },
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.landmark,
                  size: iconSize,
                ),
                title: Text(
                  'Market Indices',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: itemHeaderSize,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/market_index_history');
                },
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.balanceScale,
                  size: iconSize,
                ),
                title: Text(
                  'Outstanding Trades',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: itemHeaderSize,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/outstanding_trade_history');
                },
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.newspaper,
                  size: iconSize,
                ),
                title: Text(
                  'Stock News History',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: itemHeaderSize,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/stock_news_history');
                },
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.bookReader,
                  size: iconSize,
                ),
                title: Text(
                  'Fundamental History',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: itemHeaderSize,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/fundamental_analysis_history');
                },
              ),
            ],
          ),
          buildPortfolioExpansion(),
          buildSimulatorExpansion(),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.solidBell,
              size: iconSize,
            ),
            title: Text(
              'Stock Notifications',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: itemHeaderSize,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/stock_notifications');
            },
          ),
        ],
      ),
    );
  }

  Widget buildPortfolioExpansion() {
    if (userLoggedIn) {
      return ExpansionTile(
        leading: FaIcon(
          FontAwesomeIcons.piggyBank,
          size: iconSize,
        ),
        title: Text(
          "Portfolio",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: dropDownHeaderSize,
          ),
        ),
        children: [
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.chartPie,
              size: iconSize,
            ),
            title: Text(
              'Summary',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: itemHeaderSize,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/portfolio_summary');
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.cashRegister,
              size: iconSize,
            ),
            title: Text(
              'Transactions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: itemHeaderSize,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/portfolio_transactions');
            },
          ),
        ],
      );
    } else {
      return Text("");
    }
  }

  Widget buildUserProfile() {
    if (userLoggedIn) {
      return ElevatedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FaIcon(
              FontAwesomeIcons.userCheck,
              size: iconSize,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: drawerMainHeaderSize,
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/user_profile');
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              Theme.of(context).toggleableActiveColor),
        ),
      );
    } else
      return ElevatedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FaIcon(
              FontAwesomeIcons.userNinja,
              size: iconSize,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Guest',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: drawerMainHeaderSize,
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              Theme.of(context).toggleableActiveColor),
        ),
      );
  }

  Widget buildSimulatorExpansion() {
    if (userLoggedIn) {
      return ListTile(
        leading: FaIcon(
          FontAwesomeIcons.gamepad,
          size: iconSize,
        ),
        title: Text(
          'Simulator',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: itemHeaderSize,
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/simulator_games');
        },
      );
    } else
      return Text("");
  }
}
