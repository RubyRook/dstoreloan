import 'package:dstoreloan/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dstoreloan/screen/loanResult.dart';

TextEditingController interestController = TextEditingController();
TextEditingController loanController = TextEditingController();
TextEditingController depositController = TextEditingController();
TextEditingController currentPaymentController = TextEditingController();
TextEditingController incomeController = TextEditingController();


var focusNodeInterest = FocusNode();
var focusNodeLoan = FocusNode();
var focusNodeDeposit = FocusNode();
var focusNodeCurrentPay = FocusNode();
var focusNodeIncome = FocusNode();


setDefaultInterest(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String val = prefs.getString('interest') ?? "";
  interestController.text = val;
}

var regNumeric = r'^\d+(\.?\d{0,2}|\,?\d{0,2})?';
class LoanForm extends StatefulWidget {
  @override
  _LoanFormState createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> with AutomaticKeepAliveClientMixin {

  final _formKey = GlobalKey<FormState>();
  Config config = Config();
  String? field;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: KeyboardDismissOnTap(
        child: Form(
          key: _formKey,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Container(
                height: 20,
                padding: EdgeInsets.only(left: 20,right: 20),
                child: Image.asset(
                  "assets/dstore_logo.png",
                ),
              ),
              centerTitle: false,
              actions: [
                TextButton(
                  child: Text("Clear",style: TextStyle(color: config.primaryColor, fontSize: 16, fontWeight: FontWeight.w600)),
                  onPressed: (){
                    loanController.clear();
                    depositController.clear();
                    currentPaymentController.clear();
                    incomeController.clear();
                  },
                ),
                KeyboardVisibilityBuilder(builder: (context, visible) {
                  return visible ? IconButton(
                    color: config.primaryColor,
                    icon: Icon(Icons.keyboard_hide),
                    onPressed: (){
                      FocusScope.of(context).unfocus();
                    },
                  ) : Container();
                }),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 100),
              physics: BouncingScrollPhysics(),
              child: Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [

                    inputForm(context, "Interest Rate %", hintText: '0.0', controller: interestController,focusNode: focusNodeInterest, nextFocus: focusNodeLoan, textInputType:  TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.next,
                        onTap: (){
                          focusNodeInterest.requestFocus();
                        }
                    ),
                    Divider(height: 0),
                    inputForm(context, "Loan Amount", hintText: '0', controller: loanController,focusNode: focusNodeLoan, nextFocus: focusNodeDeposit, textInputType: TextInputType.number, textInputAction: TextInputAction.next,validate: true,
                        onTap: (){
                          focusNodeLoan.requestFocus();
                        }
                    ),
                    Divider(height: 0),
                    inputForm(context, "Deposit", hintText: '0', controller: depositController,focusNode: focusNodeDeposit, nextFocus: focusNodeCurrentPay, textInputType: TextInputType.number, textInputAction: TextInputAction.next, validateDep: true,
                        onTap: (){
                          focusNodeDeposit.requestFocus();
                        }
                    ),
                    Divider(height: 0),
                    inputForm(context, "Current Pay", hintText: '0', controller: currentPaymentController,focusNode: focusNodeCurrentPay, nextFocus: focusNodeIncome, textInputType: TextInputType.number, textInputAction: TextInputAction.next,
                        onTap: (){
                          focusNodeCurrentPay.requestFocus();
                        }
                    ),
                    Divider(height: 0),
                    inputForm(context, "Income", hintText: '0', controller: incomeController, focusNode: focusNodeIncome, textInputType: TextInputType.number, textInputAction: TextInputAction.done,onFiledIncome: true,
                        onTap: (){
                          focusNodeIncome.requestFocus();
                        }
                    ),
                  ],
                ),
              ),
            ),

            floatingActionButton: FloatingActionButton(
              backgroundColor: config.primaryColor,
              onPressed: (){
                double dep, loan;
                String val = loanController.text.toString().replaceAll(',', '.');
                String val1 = depositController.text.toString().replaceAll(',', '.');
                loan = loanController.text != "" ? double.parse(val) : 0.0;
                dep = depositController.text != "" ? double.parse(val1) : 0.0;
                FocusScope.of(context).unfocus();
                if (_formKey.currentState!.validate()) {
                  navigate(context);
                }
                if(loanController.text.length <= 0) FocusScope.of(context).requestFocus(focusNodeLoan);
                if(dep > loan) FocusScope.of(context).requestFocus(focusNodeDeposit);
              },
              child: Icon(Icons.arrow_forward),
            ),
          ),
        ),
      ),
    );
  }

  void navigate(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => LoanResult()));
    if(result == "close")  FocusScope.of(context).requestFocus(focusNodeLoan);
  }

  inputForm(BuildContext context, String label, {
    var controller,
    var onTap,
    var focusNode,
    var nextFocus,
    TextInputType? textInputType,
    TextInputAction? textInputAction,
    bool validate = false,
    bool validateDep = false,
    bool onFiledIncome = false,
    required String hintText,
  }){
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [

            Expanded(flex: 1,child: Text(label,style: TextStyle(fontSize: 16, color: Colors.black),maxLines: 1,overflow: overflowStyle)),

            Expanded(
              flex: 2,
              child: Row(

                children: [
                  Text("|",style: TextStyle(fontSize: 16, color: Colors.grey.shade200)), Divider(endIndent: 10),

                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration.collapsed(
                        hintText: hintText,
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                      ),
                      controller: controller,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      focusNode: focusNode,
                      textInputAction: textInputAction,
                      keyboardType: textInputType,
                      onChanged: (value) {
                        if(value.length == 2 && value[0] == "0" && ![",","."].contains(value[1])) {
                          int? newVal = int.tryParse(value);

                          controller.text = (newVal ?? 0).toString();
                          controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                        }
                        else if(value.length == 0){
                          field = '';
                          controller.text = "";
                          controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                        }
                        else {
                          if (isValid(regNumeric, value)) {
                            field = value;

                          }
                          else {
                            TextEditingController txtCtrl = controller;
                            int oldIndex = txtCtrl.selection.baseOffset;
                            controller.text = double.tryParse(field.toString().replaceAll(",", ".")) != null ? field : "";

                            txtCtrl.selection = TextSelection.fromPosition(TextPosition(offset: oldIndex > 0 ? oldIndex-1:oldIndex));
                          }
                        }
                      },

                      onFieldSubmitted: (term){
                       if(onFiledIncome == false) _fieldFocusChange(context, focusNode, nextFocus);

                        if(onFiledIncome == true){
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            navigate(context);
                          }
                          if(loanController.text.length <= 0) FocusScope.of(context).requestFocus(focusNodeLoan);
                        }
                      },
                      validator: (value) {
                        double loan;
                        String val = loanController.text.toString().replaceAll(',', '.');
                        loan = loanController.text != "" ? double.parse(val) : 0.0;
                        if(validate == true){
                          if (value == null || value.isEmpty) {
                            return 'Please input $label';
                          }
                          else if(loan < 10){
                            return 'Loan Must be bigger or equal to 10\$';
                          }
                        }

                         if(validateDep == true){
                           double dep, loan;
                           String val = loanController.text.toString().replaceAll(',', '.');
                           String val1 = depositController.text.toString().replaceAll(',', '.');
                           loan = loanController.text != "" ? double.parse(val) : 0.0;
                           dep = depositController.text != "" ? double.parse(val1) : 0.0;

                           if(depositController.text.isNotEmpty){
                             if(dep >= loan){
                               return 'Deposit must be smaller than Loan';
                             }
                           }
                         }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  bool isValid(String regexSource, String value) {
    try {
      final regex = RegExp(regexSource);
      final matches = regex.allMatches(value);
      for (Match match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // Invalid regex
      assert(false, e.toString());
      return true;
    }
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}