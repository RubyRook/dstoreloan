import 'package:bot_toast/bot_toast.dart';
import 'package:dstoreloan/screen/promotion.dart';
import 'package:dstoreloan/screen/requirement.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dstoreloan/screen/loanForm.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'config/config.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    setDefaultInterest(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: BotToastInit(),
      navigatorObservers: [
        BotToastNavigatorObserver(),
        FirebaseAnalyticsObserver(analytics: MyApp.analytics),
      ],
      theme: ThemeData(
        fontFamily: 'Battambang',
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Colors.white,
        ),
      ),
      home: NavScreen(analytics: MyApp.analytics),
    );
  }
}

class NavScreen extends StatefulWidget {
  final FirebaseAnalytics analytics;
  NavScreen({Key? key,required this.analytics}) : super(key: key);

  @override
  _NavScreenState createState() => _NavScreenState();
}
class _NavScreenState extends State<NavScreen>{

  int _currentIndex = 0;
  Config config = Config();
  final List<Widget> _screens = [
    LoanForm(),
    Requirement(),
    Promotion(),
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.analytics.setCurrentScreen(screenName: "Navigate Screen");
  }
  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: WillPopScope(
        onWillPop: _onBackPress,
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            unselectedFontSize: 12,
            iconSize: 22,
            selectedFontSize: 12,
            selectedLabelStyle: TextStyle(fontFamily: 'roboto'),
            unselectedLabelStyle: TextStyle(fontFamily: 'roboto'),
            unselectedItemColor: Color.fromARGB(255, 112, 112, 112),
            showUnselectedLabels: true,
            showSelectedLabels: true,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: SizedBox(height: 25,child: Icon(Ionicons.calculator)),
                label: 'Loan',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(height: 25,child: Icon(Ionicons.document)),
                label: 'Requirement',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(height: 25,child: Icon(FontAwesomeIcons.percent)),
                label: 'Promotion',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: config.primaryColor,
            onTap: (index){
              setState(() {
                _selectedIndex = index;
                FocusScope.of(context).unfocus();
                _sendCurrentTabToAnalytics();

                if(index == _currentIndex){
                  _currentIndex = _selectedIndex;
                  if(_selectedIndex == 1) requirementScrollCon.animateTo(0, curve: Curves.easeOut, duration: Duration(milliseconds: 300));
                  if(_selectedIndex == 2) promotionScrollCon.animateTo(0, curve: Curves.easeOut, duration: Duration(milliseconds: 300));
                } else {
                  _currentIndex = _selectedIndex;
                }

              });
            },
          ),
        ),
      ),
    );
  }

  void _sendCurrentTabToAnalytics() {
    String? tabName;
    if(_selectedIndex == 0) tabName = "LoanFormScreen";
    if(_selectedIndex == 1) tabName = "RequirementScreen";
    if(_selectedIndex == 2) tabName = "PromotionScreen";

    widget.analytics.setCurrentScreen(screenName: tabName);
  }

  Future<bool> _onBackPress() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text("Do you want to exit an App"),
        contentPadding: EdgeInsets.symmetric(horizontal: 25),
        actionsPadding: EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 15),
        actions: [
          Container(
            height: 36,
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200,),
                      child: Text("Cancel", style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(backgroundColor: config.primaryColor,),
                      child: Text("Exit", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    )) ?? false;
  }
}
