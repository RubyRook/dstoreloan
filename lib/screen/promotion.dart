import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dstoreloan/detail/post_detail.dart';
import 'package:dstoreloan/main.dart';
import 'package:dstoreloan/widget/my_widget.dart';
import 'package:dstoreloan/widget/shimer_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dstoreloan/helper/helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:dstoreloan/config/config.dart';

class Promotion extends StatefulWidget {

  @override
  _PromotionState createState() => _PromotionState();
}

class _PromotionState extends State<Promotion> with AutomaticKeepAliveClientMixin{

  MyWidget myWidget = MyWidget();
  Config config = Config();
  ShimmerWidget shimmerWidget = ShimmerWidget();
  Helper helper = Helper();

  List promotion = [];
  bool isError = false;
  bool isLoading = false;

  reloadPage(){setState(() {});}

  int offset = 0;
  int limit = 10;
  bool enableLoadMore = true;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() {
    _refreshController.refreshCompleted();
    reloadPromotion();
  }
  void _onLoading() {
    if(mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    promotion.add({"type":"loading"});
    getPromotion();

  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: InkWell(
          child: Container(
            height: 20,
            padding: EdgeInsets.only(left: 20,right: 20),
            child: Image.asset(
              "assets/dstore_logo.png",
            ),
          ),
          onTap: (){
            promotionScrollCon.animateTo(0, curve: Curves.easeOut, duration: Duration(milliseconds: 300));
          },
        ),
        centerTitle: false,
      ),
      body: NotificationListener(
        onNotification: (scrollNotification){
          if (scrollNotification is ScrollUpdateNotification) {
            if(scrollNotification.metrics.maxScrollExtent-scrollNotification.metrics.pixels < 200 && enableLoadMore == true){
              getPromotion();
            }
          }
          return true;
        },
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          header: WaterDropHeader(),
          child: ListView.separated(
            separatorBuilder: (context, index)=> Divider(height: 0,thickness: 0.9, indent: 10, endIndent: 10),
            itemCount: promotion.length,
            controller: promotionScrollCon,
            itemBuilder: (context, index){

              var data = promotion[index];

              if(data != null && data.length > 0){
                if(data["type"] != null && data["type"].toString() == "loading") {

                  if(enableLoadMore == false && isLoading == false) {

                    // error
                    if(isError){

                      return Card(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          shadowColor: Colors.black45,
                          child: myWidget.noInternetConnection(context,action: (){ reloadPromotion(); })
                      );
                    }

                    return Container(
                      padding: EdgeInsets.all(30),
                      child: Text(promotion.length == 1 ? "No Result" : "No More Result!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                    );
                  }

                  // loading
                  if(isLoading) return Container(
                    child: Center(
                      child: shimmerWidget.subListingShimmer(),
                    ),
                  );

                  return Container();
                }
              }

              return InkWell(
                child: Container(
                  padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                  color: Colors.white,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // image
                        Expanded(
                          flex: 0,
                          child: Container(
                            width: 120,
                            height: 105,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: data["image"] != "" ? CachedNetworkImage(
                              imageUrl: data["image"],
                              imageBuilder: (context, imageProvider) => Container(
                                height: 105,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: config.colorAliceBlue
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.image_outlined, color: Colors.grey, size: 60),
                            ) : Icon(Icons.image_outlined, color: Colors.grey, size: 60),
                          ),
                        ),

                        // postDate, title, desc, like, comment
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // title
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12,right: 12,top: 5),
                                  child: Text(data["title"],style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.w600),maxLines: 3,overflow: overflowStyle,),
                                ),
                              ),

                              // post date, share, bookmark
                              Expanded(
                                flex: 0,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Text(helper.getFormatDate(data["post_date"]),style: TextStyle(fontSize: 12,color: Colors.black,fontFamily: 'roboto')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> PostDetail(detail: data,type: "promotion",analytics: MyApp.analytics)));
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> getPromotion() async{

    try{

      if(isLoading == true || enableLoadMore == false) {
        return;
      }
      isError = false;
      isLoading = true;
      reloadPage();

      var url = Uri.parse(config.baseURL+"post?content=true&category=86&limit=10&offset=$offset");
      final http.Response response = await http.get(url, headers: {"Authorization": config.accessToken});

      if (response.statusCode == 200) {

        var jsonResponse = jsonDecode(response.body);

        if(jsonResponse != null) {

          if(jsonResponse["data"] != null && jsonResponse["data"] is List && jsonResponse["data"].length > 0) {

            if(jsonResponse["limit"] != null && int.parse(jsonResponse["limit"].toString()) > 0) limit = int.parse(jsonResponse["limit"].toString());

            offset += limit;

            promotion.insertAll(promotion.length - 1, jsonResponse["data"]);

            if(jsonResponse["data"].length < limit) enableLoadMore = false;

            reloadPage();
          }
          else {
            enableLoadMore = false;
            reloadPage();
          }
        } else {
          enableLoadMore = false;
          isError = true;
          reloadPage();
        }
        isLoading = false;

      }

      // not 200
      else {
        isError = true;
        isLoading = false;
        enableLoadMore = false;
        reloadPage();
      }

    } on SocketException{
      isLoading = false;
      isError = true;
      enableLoadMore = false;
      reloadPage();

    } catch(e){
      isLoading = false;
      isError = true;
      enableLoadMore = false;
      throw Exception("Error Get Data For You - $e");
    }
  }

  reloadPromotion() {
    isLoading = false;
    isError = false;
    enableLoadMore = true;

    promotion = [];
    promotion.add({"type": "loading"});
    offset = 0;
    limit = 10;
    reloadPage();

    getPromotion();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
