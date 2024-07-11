import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class Helper{
  String getFormatDate(String? val) {
    if(val != null && val != "") {
      try {
        var postDate = DateTime.parse(val);
        final date2 = DateTime.now();
        final nMinute = date2.difference(postDate).inMinutes;
        final nHour = date2.difference(postDate).inHours;
        final nDay = date2.difference(postDate).inDays;
        var newDate = "";
        if(nDay < 1) {
          if(nMinute <= 1) {
            newDate = "Just Now";
          }
          else {
            if(nMinute<60) {
              newDate = nMinute.toString()+"m";
            } else {
              newDate = nHour.toString()+"h";
            }
          }
        }
        else if(nDay <= 7) {
          newDate = nDay.toString()+"d";
        }
        else {
          var formatter = DateFormat(postDate.year==date2.year ? 'MMM dd' : 'MMM dd, yyyy');
          newDate = formatter.format(postDate).toString();
        }
        return newDate;
      } catch(e) {
        print("Error getFormatDateV2: "+e.toString());
      }
    }
    return "";
  }

  Future<bool> checkPhotosPermission(BuildContext context) async {
    late PermissionStatus status;

    if(Platform.isIOS) {
      status = await Permission.photos.request();
    }
    else {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final permission = deviceInfo.version.sdkInt > 32 ? Permission.photos:Permission.storage;
      status = await permission.request();
    }

    if (status.isGranted == false) {
      if (status.isPermanentlyDenied) {
        permissionPopUp(content:"Error photo permission", context: context);
      }
      // ios only
      // else if(status == PermissionStatus.limited){
      //   permissionPopUp(content:"Error photo permission", context: context);
      //   return false;
      // }
    }

    return status == PermissionStatus.granted || status == PermissionStatus.limited;
  }

  void permissionPopUp({String? content, required BuildContext context}){
    FocusScope.of(context).unfocus();
    BotToast.cleanAll();

    BotToast.showAnimationWidget(
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.1),
      allowClick: false,
      toastBuilder: (cancelFunc) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: new Text("Permission Request", style: TextStyle(height: 1.2),),
        content: content != null ? new Text(content, style: TextStyle(height: 1.2,),):null,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(12),
            ),
            onPressed: () {
              cancelFunc();
              openAppSettings();
            },
            child: Text("Setting", style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(12),
            ),
            onPressed: () {
              cancelFunc();
            },
            child: Text("Close", style: TextStyle(fontSize: 16, color: Colors.grey,)),
          ),
        ],
      ),
      animationDuration: Duration(milliseconds: 300),
    );
  }
}