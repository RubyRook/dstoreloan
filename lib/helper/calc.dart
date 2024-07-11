class Calc {
  final int term;
  Calc({required this.term});

  double firstPay = 0.00;
  int nextPay = 0;
  int roundPay = 0;
  double totalPay = 0;
  double interest = 0;
  int dstoreTotalPay = 0;
  int dstoreInterest = 0;

  double percent = 0;

  void calculate({
    required double loanAmount,
    required double deposit,
    required double interestRate,

    required double currentPayment,
    required double income,
  }){
    double monthlyInterest = 0.0;

    interest = loanAmount*interestRate*term;
    totalPay = interest+loanAmount;
    monthlyInterest = totalPay/term;
    roundPay = monthlyInterest.ceil();
    if(monthlyInterest is int) {
      firstPay = monthlyInterest;
      nextPay = monthlyInterest.toInt();

    }
    else {
      nextPay = monthlyInterest.floor();
      firstPay = (interest+loanAmount)-(nextPay*(term-1));
    }

    interest = formatValue(interest);
    totalPay = formatValue(totalPay);
    firstPay = formatValue(firstPay);
    dstoreTotalPay = roundPay*term;
    dstoreInterest = dstoreTotalPay-loanAmount.toInt();


    percent = ((currentPayment + nextPay)/income)*100;
    percent = formatValue(percent);

    // print(term);


  }

  double formatValue(double val) {
    return double.parse(val.toStringAsFixed(2));
  }

  void clear(){
    firstPay = 0.00;
    nextPay = 0;
    roundPay = 0;
    totalPay = 0;
    interest = 0;
    dstoreTotalPay = 0;
    dstoreInterest = 0;
  }
}