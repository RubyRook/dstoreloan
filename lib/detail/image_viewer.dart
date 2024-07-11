import 'dart:typed_data';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:dstoreloan/helper/helper.dart';
import 'package:dstoreloan/widget/my_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  final image;
  ImageViewer({super.key, this.image});

  final helper = Helper();
  final myWidget = MyWidget();

  @override
  Widget build(BuildContext context) {


    return Dismissible(
      key: Key(""),
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: PhotoView(
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  loadingBuilder: (context, event) {
                    return CircularProgressIndicator();
                  },
                  imageProvider: NetworkImage(image),
                )
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(
                top: false,
                child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.black.withOpacity(0.1),
                  iconTheme: IconThemeData(
                    color: Colors.white,
                  ),
                  actions: [
                    TextButton.icon(
                      icon: Icon(Icons.cloud_download, color: Colors.white,),
                      label: Text("Save", style: TextStyle(color: Colors.white),),
                      onPressed: () => streamImageDownload(context),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => Navigator.of(context).pop(),
      direction: DismissDirection.vertical,
    );
  }

  void streamImageDownload(BuildContext context) async {
    final status = await helper.checkPhotosPermission(context);
    if(status == false) return;

    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 35)),);

    try {
      BotToast.showLoading(crossPage: false);
      final result = await dio.get<List<int>>(image, options: Options(responseType: ResponseType.bytes),);

      if(result.statusCode == 200 && result.data is Uint8List){
        var data = await ImageGallerySaver.saveImage(result.data as Uint8List, name: DateFormat("yMd_hms").format(DateTime.now(),),);

        if(data is Map && data["isSuccess"] == true) {
          myWidget.showAlertNotification(const Icon(Icons.check_circle, color: Colors.green,), "Photo saved to device", duration: 3);
        }
        else {
          myWidget.showAlert(title:"Oops! something went wrong",);
        }
      }
      else {
        throw const FormatException("");
      }
    }
    catch(e){
      final dioConnection = [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
      ];

      if(e is DioException && dioConnection.contains(e.type)){
        myWidget.showAlert(
          title:"Connection Error",
          content:"The internet connection appears to be offline. Please check your internet connection and try again.",
        );
      }
      else {
        myWidget.showAlert(title:"Oops! something went wrong", isCatch: true);
      }
    }

    try {
      dio.close();
    }
    catch (e) {
      print("");
    }

    BotToast.closeAllLoading();
  }
}
