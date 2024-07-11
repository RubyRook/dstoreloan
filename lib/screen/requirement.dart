import 'dart:convert';
import 'dart:io';
import 'package:dstoreloan/detail/post_detail.dart';
import 'package:dstoreloan/main.dart';
import 'package:dstoreloan/widget/my_widget.dart';
import 'package:dstoreloan/widget/shimer_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:dstoreloan/config/config.dart';
import 'package:dstoreloan/helper/helper.dart';

class Requirement extends StatefulWidget {

  @override
  _RequirementState createState() => _RequirementState();
}

class _RequirementState extends State<Requirement> with AutomaticKeepAliveClientMixin{

  MyWidget myWidget = MyWidget();
  Config config = Config();
  ShimmerWidget shimmerWidget = ShimmerWidget();
  Helper helper = Helper();

  List requirement = [];
  bool isError = false;
  bool isLoading = false;

  reloadPage(){setState(() {});}

  int offset = 0;
  int limit = 10;
  bool enableLoadMore = true;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() {
    _refreshController.refreshCompleted();
    reloadRequirement();
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
    requirement.add({"type":"loading"});
    getRequirement();

  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: config.bgColor,
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
            requirementScrollCon.animateTo(0, curve: Curves.easeOut, duration: Duration(milliseconds: 300));
          },
        ),
        centerTitle: false,
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation){

          double height = MediaQuery.of(context).size.height / 6;

          if(orientation == Orientation.landscape){
            height = MediaQuery.of(context).size.width/2;
          }

          return NotificationListener(
            onNotification: (scrollNotification){
              if (scrollNotification is ScrollUpdateNotification) {
                if(scrollNotification.metrics.maxScrollExtent-scrollNotification.metrics.pixels < 200 && enableLoadMore == true){
                  getRequirement();
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
              child: CustomScrollView(
                controller: requirementScrollCon,
                slivers: [

                  // sub listing
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        var data = requirement[index];

                        if(data != null && data.length > 0){
                          if(data["type"] != null && data["type"].toString() == "loading") {

                            if(enableLoadMore == false && isLoading == false) {

                              // error
                              if(isError){

                                return Card(
                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    shadowColor: Colors.black45,
                                    child: myWidget.noInternetConnection(context,action: (){ reloadRequirement(); })
                                );
                              }

                              return Container(
                                padding: EdgeInsets.all(30),
                                child: Text(requirement.length == 1 ? "No Result" : "No More Result!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                              );
                            }

                            // loading
                            if(isLoading) return Container(
                              child: Center(
                                child: shimmerWidget.rectangleShimmer(),
                              ),
                            );

                            return Container();
                          }
                        }

                        return Column(
                          children: [

                            InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetail(detail: data, type: "requirement",analytics: MyApp.analytics,)));
                              },
                              child: Card(
                                margin: EdgeInsets.only(top: 10,left: 5,right: 5,),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                  ),
                                  height: height,
                                  child: Row(
                                    children: [

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: Text(data["title"],style:TextStyle(fontSize: 14, fontWeight: FontWeight.w600),maxLines: 3,overflow: overflowStyle,)),
                                            Text(helper.getFormatDate(data["post_date"]),style: TextStyle(color: Colors.grey,fontSize: 12,height: 1.3),),
                                          ],
                                        ),
                                      ),
                                      Divider(endIndent: 5),
                                      Expanded(
                                        flex: 0,
                                        child: Icon(Icons.arrow_forward_ios,color: Colors.grey.shade300,size: 20,),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: requirement.length,
                    ),
                  ),
                ],
              ),
            ),
          );

        },
      ),
    );
  }

  Future<void> getRequirement() async{

    try{

      if(isLoading == true || enableLoadMore == false) {
        return;
      }
      isError = false;
      isLoading = true;
      reloadPage();


      var url = Uri.parse(config.baseURL+"post?content=true&category=1&limit=10&offset=$offset");

      final http.Response response = await http.get(url, headers: {"Authorization": config.accessToken});

      if (response.statusCode == 200) {



        var jsonResponse = jsonDecode(response.body);

        if(jsonResponse != null) {

          if(jsonResponse["data"] != null && jsonResponse["data"] is List && jsonResponse["data"].length > 0) {

            if(jsonResponse["limit"] != null && int.parse(jsonResponse["limit"].toString()) > 0) limit = int.parse(jsonResponse["limit"].toString());

            offset += limit;

            requirement.insertAll(requirement.length - 1, jsonResponse["data"]);

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

  reloadRequirement() {
    isLoading = false;
    isError = false;
    enableLoadMore = true;

    requirement = [];
    requirement.add({"type": "loading"});
    offset = 0;
    limit = 10;
    reloadPage();

    getRequirement();
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}

