import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

class MyWidget{

  //.style
  dotStyle(BuildContext context,{var color}){
    return Center(
      child: Container(
        // margin: EdgeInsets.only(top: 2),
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  noData(String title){
    return Column(
      children: [
        Container(
          child: Image.asset("assets/no_data.jpg"),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(title,style: TextStyle(fontSize: 18),textAlign: TextAlign.center),
        ),
      ],
    );
  }

  noInternetConnection(BuildContext context,{var action}){
    return Center(
      child: Container(
          margin: EdgeInsets.all(50),
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                child: Image.asset("assets/no_internet.png",color: Colors.grey.shade500,),
              ),
              Text("No Internet Connection!",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
              SizedBox(height: 10,),
              Text("The internet connection appears to be offline. Please check your internet connection and try again.",textAlign: TextAlign.center,style: TextStyle(fontSize: 16,height: 1.5,color: Colors.grey.shade700),),
              Container(
                margin: EdgeInsets.only(top: 20),
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(5)

                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: action,
                  child: Text("Retry",style: TextStyle(fontSize: 16,color: Colors.white),),
                ),
              ),
            ],
          )),
    );
  }

  showAlertNotification(Icon icon, String message, {int duration = 5}) {
    BotToast.showNotification(
      leading: (cancel) => SizedBox.fromSize(
        size: const Size(40, 40),
        child: IconButton(icon: icon, onPressed: cancel,),
      ),
      title: (_) => Text(message),
      animationDuration: Duration(milliseconds: 100),
      animationReverseDuration: Duration(milliseconds: 100),
      duration: Duration(seconds: duration),
    );

    Future.delayed(Duration(milliseconds: 300), (){
      BotToast.closeAllLoading();
    });
  }


  showAlert({required String? title, bool showConfirm = false, String? content, bool isCatch = false}) {

    BotToast.showAnimationWidget(
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.1),
      allowClick: false,
      toastBuilder: (cancelFunc) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isCatch?2:5)),
        title: new Text(
          title.toString(),
          style: TextStyle(height: 1, fontSize: 18),
          strutStyle: StrutStyle(height: 1.5),
        ),
        content: content != null ? Text(content, style: TextStyle(height: 1,),strutStyle: StrutStyle(height: 1.5),):null,
        contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        actionsPadding: EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 0),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              cancelFunc();
            },
            child: Text("Close", style: TextStyle(fontSize: 16)),
          ),
          Visibility(
            visible: showConfirm,
            child: TextButton(
              onPressed: () {
                cancelFunc();
              },
              child: Text("Confirm", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
      animationDuration: Duration(milliseconds: 300),
    );

    Future.delayed(Duration(milliseconds: 300), (){
      BotToast.closeAllLoading();
    });
  }
}
