import 'package:dstoreloan/helper/calc.dart';
import 'package:dstoreloan/config/config.dart';
import 'package:dstoreloan/main.dart';
import 'package:flutter/material.dart';
import 'package:dstoreloan/screen/loanForm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoanResult extends StatefulWidget {

  @override
  _LoanResultState createState() => _LoanResultState();
}

class _LoanResultState extends State<LoanResult> with AutomaticKeepAliveClientMixin {

  Config config = Config();

  double _loanAmt = 0.00;
  double _deposit = 0.00;
  double _deposit1 = 0.00;
  double _interestRate = 0.00;
  double _currentPayment = 0.00;
  double _income = 0.00;


  double percentResult40 = 0.0;
  double percentResult50 = 0.0;
  double percentResult60 = 0.0;

  double moneyResult40 = 0.0;
  double moneyResult50 = 0.0;
  double moneyResult60 = 0.0;

  double valuePercent = 0;

  List<Calc> listCalc = [
    Calc(term: 3,),
    Calc(term: 6,),
    Calc(term: 9,),
    Calc(term: 12,),
    Calc(term: 18,),
    Calc(term: 24,),
    Calc(term: 30,),
    Calc(term: 36,),
    Calc(term: 48,),
  ];

  List<Calc> aeon = [];
  List<Calc> dstore = [];

  List loanDet= [];

  void _calculate() {

    _loanAmt = loanController.text != "" ? double.parse(loanController.text.replaceAll(",", ".")) : 0.0;
    _deposit = depositController.text != "" ? double.parse(depositController.text.replaceAll(",", ".")) : 0.0;
    _deposit1 = depositController.text != "" ? double.parse(depositController.text.replaceAll(",", ".")) : 0.0;
    _interestRate = interestController.text != "" ? double.parse(interestController.text.replaceAll(",", ".")) : 0.0;
    _currentPayment = currentPaymentController.text != "" ? double.parse(currentPaymentController.text.replaceAll(",", ".")) : 0.0;
    _income = incomeController.text != "" ? double.parse(incomeController.text.replaceAll(",", ".")) : 0.0;

    if(_interestRate>0) loanDet.add({"title" : "Interest", "detail" : "%"+_interestRate.toString()});
    if(_loanAmt>0) loanDet.add({"title" : "Loan Amount", "detail" : "\$"+_loanAmt.toString()});
    if(_deposit>0) loanDet.add({"title" : "Deposit", "detail" : "\$"+_deposit.toString()});
    if(_currentPayment>0) loanDet.add({"title" : "Current Payment", "detail" : "\$"+_currentPayment.toString()});
    if(_income>0) loanDet.add({"title" : "Income", "detail" : "\$"+_income.toString()});

    double loanAmount = _loanAmt-_deposit;
    double rate = _interestRate/100;

    for(Calc calc in listCalc) {
      calc.calculate(loanAmount: loanAmount, deposit: _deposit, interestRate: rate, currentPayment: _currentPayment, income: _income);
      if([6,12,18,24,30,36,48].contains(calc.term)) aeon.add(calc);
      if([3,6,9,12].contains(calc.term)) dstore.add(calc);
    }
    saveInterest(interestController.text.toString());
  }

  void saveInterest(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('interest', val);
  }

  aeonResultWithPercent(Calc calc, bool even){

    Color color1 = Colors.red;
    Color color2 = Colors.red;
    Color color3 = Colors.red;

    valuePercent = calc.percent;
    percentResult40 =  40 - valuePercent;
    percentResult50 =  50 - valuePercent;
    percentResult60 =  60 - valuePercent;

    moneyResult40 = (percentResult40*_income)/100;
    moneyResult50 = (percentResult50*_income)/100;
    moneyResult60 = (percentResult60*_income)/100;

    var deposit40 = (moneyResult40 /(1+(_interestRate/100)*calc.term)*calc.term);
    var deposit50 = (moneyResult50 /(1+(_interestRate/100)*calc.term)*calc.term);
    var deposit60 = (moneyResult60 /(1+(_interestRate/100)*calc.term)*calc.term);

    if(valuePercent <= 40){
      color1 = config.primaryColor;
    }
    if(valuePercent <= 50){
      color2 = config.primaryColor;
    }
     if(valuePercent <= 60){
      color3 = config.primaryColor;
    }

    return TableRow(
        decoration: BoxDecoration(
          color: even ? null : Colors.black.withOpacity(.07),
        ),
        children: [
          Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(calc.term.toString(),
              style: TextStyle(fontSize: 16,),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              '\$${calc.interest}',
              style: TextStyle(fontSize: 16,),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              '\$${calc.totalPay}',
              style: TextStyle(fontSize: 16,),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              '\$${calc.firstPay}',
              style: TextStyle(
                  fontSize: 16
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              '\$${calc.nextPay}',
              style: TextStyle(
                  fontSize: 16
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${moneyResult40<0?"-":""}\$${moneyResult40.abs().toStringAsFixed(2).replaceAll(".00", "")} ",style: TextStyle(fontSize: 15,color: color1)),
                    Text("(${percentResult40.toStringAsFixed(2).replaceAll(".00", "")}%) ",style: TextStyle(fontSize: 12,color: color1)),
                  ],
                ),

                if(percentResult40 < 0) Text("${'dep: ' +  '\$'+(deposit40.round().abs()+_deposit1).toStringAsFixed(0).replaceAll(".00", "")}",style: TextStyle(fontSize: 14,color: color1, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${moneyResult50<0?"-":""}\$${moneyResult50.abs().toStringAsFixed(2).replaceAll(".00", "")} ",style: TextStyle(fontSize: 15,color: color2)),
                    Text("(${percentResult50.toStringAsFixed(2).replaceAll(".00", "")}%) ",style: TextStyle(fontSize: 12,color: color2)),
                  ],
                ),
                if(percentResult50 < 0) Text("${'dep: ' +  '\$'+(deposit50.round().abs()+_deposit1).toStringAsFixed(0).replaceAll(".00", "")}",style: TextStyle(fontSize: 14,color: color2, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${moneyResult60<0?"-":""}\$${moneyResult60.abs().toStringAsFixed(2).replaceAll(".00", "")} ",style: TextStyle(fontSize: 15,color: color3)),
                    Text("(${percentResult60.toStringAsFixed(2).replaceAll(".00", "")}%) ",style: TextStyle(fontSize: 12,color: color3)),
                  ],
                ),
                if(percentResult60 < 0) Text("${'dep: ' +  '\$'+(deposit60.round().abs()+_deposit1).toStringAsFixed(0)}",style: TextStyle(fontSize: 14,color: color3, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ]
    );
  }

  Widget aeonResultNoPercent(Calc calc, bool even){
    return Container(
      color: even ? null:Colors.black.withOpacity(.07),
      padding: EdgeInsets.all(6.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text(calc.term.toString(), style: TextStyle(fontSize: 18,),),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${calc.interest}',
                      style: TextStyle(fontSize: 16,),
                    ),
                  ),

                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${calc.totalPay}',
                      style: TextStyle(fontSize: 16,),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${calc.firstPay}',
                      style: TextStyle(
                          fontSize: 16
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${calc.nextPay}',
                      style: TextStyle(
                          fontSize: 16
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dstoreResult(Calc calc, bool even){
    return Container(
      color: even ? null:Colors.black.withOpacity(.07),
      padding: EdgeInsets.all(6.00),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text(calc.term.toString(), style: TextStyle(fontSize: 18),),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${calc.dstoreInterest}',
                      style: TextStyle(fontSize: 16,),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${calc.dstoreTotalPay}',
                      style: TextStyle(fontSize: 16,),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${calc.roundPay}',
                      style: TextStyle(fontSize: 16,),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget loanDetail(String title, String detail, bool even){
    return Container(
      color: even ? null:Colors.black.withOpacity(.07),
      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title+":  ", style: TextStyle(fontSize: 15)),
          Flexible(child: Text(detail.replaceAll(".0", ""), style: TextStyle(fontSize: 18), overflow: overflowStyle,maxLines: 1)),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calculate();

    MyApp.analytics.logScreenView(screenName: "LoanResult");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: config.primaryColor,
        title: Text('D Store Loan'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: (){
              Navigator.pop(context, "close");
              clearAll();
            }),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            // header title and loan detail
            Container(
              margin: EdgeInsets.only(top: 10.00),
              padding: EdgeInsets.all(12.00),
              color: config.primaryColor,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Loan Detail',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for(int i = 0; i < loanDet.length; i++) loanDetail(loanDet[i]["title"],loanDet[i]["detail"].toString(), (i % 2) == 0),


            // Aeon Bank Loan
            Container(
              margin: EdgeInsets.only(top: 40),
              padding: EdgeInsets.all(12.00),
              color: Color.fromRGBO(179, 31, 141, 1),
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Aeon specialized Bank',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Aeon title no percent and Aeon result no percent
            if(_income<=0) Container(
              padding: EdgeInsets.all(6.00),
              color: Color.fromRGBO(179, 31, 141, 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Term',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Interest',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Total Pay',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'First Month',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Next Month',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(_income<=0) for(int i = 0; i < aeon.length; i++) aeonResultNoPercent(aeon[i], (i % 2) == 0),


            // Aeon Loan Result with percent(40%,50%,60%)
            if(_income>0) LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewportConstraints){
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: viewportConstraints.maxWidth,
                      ),
                      child: Table(
                        border: TableBorder.all(width: 0,color: Colors.transparent),
                        defaultColumnWidth: IntrinsicColumnWidth(),

                        // columnWidths: {
                        //   0: FixedColumnWidth(55),
                        //   1: FixedColumnWidth(120),
                        //   2: FixedColumnWidth(120),
                        //   3: FixedColumnWidth(120),
                        //   4: FixedColumnWidth(120),
                        //   5: FixedColumnWidth(120),
                        //   6: FixedColumnWidth(120),
                        // },

                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: <TableRow>[

                          // Aeon Bank Header
                          TableRow(
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(179, 31, 141, 1),
                            ),
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                child: Text(
                                  'Term',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Interest',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                child: Text(
                                  'Total Pay',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                child: Text(
                                  'First Month',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                child: Text(
                                  'Next Month',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),textAlign: TextAlign.center,
                                ),
                              ),

                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  '40%',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                  ),textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  '50%',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  '60%',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                  ),textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),

                          // Aeon Bank Result
                          for(int i = 0; i < aeon.length; i++) aeonResultWithPercent(aeon[i], (i % 2) == 0),

                        ],
                      ),
                    ),
                  );
                }
            ),


            // D Store Loan
            Container(
              margin: EdgeInsets.only(top: 20.00),
              padding: EdgeInsets.all(12.00),
              color: config.primaryColor,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Loan by D Store',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(6.00),
              color: config.primaryColor,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: <Widget>[
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Term',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: <Widget>[
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Interest',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: <Widget>[
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Total Pay',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: <Widget>[
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Monthly Pay',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // D Store Loan result
            for(int i = 0; i < dstore.length; i++) dstoreResult(dstore[i], (i % 2) == 0),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: config.primaryColor,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.edit),
      ),
    );
  }

  void clearAll() {
    setState(() {
      loanController.text = "";
      depositController.text = "";
      currentPaymentController.text = "";
      incomeController.text = "";
    });

  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

