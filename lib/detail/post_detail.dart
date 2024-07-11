import 'package:dstoreloan/config/config.dart';
import 'package:dstoreloan/helper/helper.dart';
import 'package:dstoreloan/widget/my_widget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'image_viewer.dart';

class PostDetail extends StatefulWidget implements PreferredSizeWidget {
  final Map? detail;
  final String? type;
  final FirebaseAnalytics analytics;
  PostDetail({Key? key, this.detail, this.type, required this.analytics}) : preferredSize = Size.fromHeight(kToolbarHeight),super(key: key);

  @override
  final Size preferredSize;
  _PostDetailState createState() => _PostDetailState();

}

class _PostDetailState extends State<PostDetail> {

  Config config = Config();
  MyWidget myWidget = MyWidget();
  Helper helper = Helper();

  Color titleClr = Colors.transparent;
  Color iconClr = Colors.white;
  bool allowChangClr = false;

  reloadPage(){ setState(() {}); }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.analytics.setCurrentScreen(screenName: "${widget.type}/${widget.detail?["id"]}");
  }
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double totalBarHeight = statusBarHeight+widget.preferredSize.height;
    double screenHeight = MediaQuery.of(context).size.height;
    var condition = widget.type == "promotion" && widget.detail?["image"] == "" || widget.detail?["image"] == null;
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.type == "requirement" || condition ? AppBar(
          iconTheme: IconThemeData(
            color: Colors.grey,
          ),
          title: Text(widget.detail?["title"], style: TextStyle(color: Colors.black,fontSize: 17)),
        ) : null,
        body: Container(
          height: screenHeight,
          color: config.bgColor,
          child: CustomScrollView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            slivers: [
              if(widget.detail?["image"] != "" && widget.type == "promotion") SliverAppBar(
                expandedHeight: 330,
                floating: false,
                primary: true,
                pinned: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                iconTheme: IconThemeData(
                  color: iconClr,
                ),
                title: Text(widget.detail?["title"], style: TextStyle(color: titleClr, fontSize: 17, fontWeight: FontWeight.w600)),
                backgroundColor: Colors.white,

                flexibleSpace: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                  if( constraints.biggest.height <= totalBarHeight + 15 && allowChangClr == true ){
                    allowChangClr = false;
                    titleClr = Colors.black;
                    iconClr = Colors.grey;

                    Future.delayed(Duration(milliseconds: 30), () => reloadPage());
                  }

                  if(constraints.biggest.height >= totalBarHeight + 15 && allowChangClr == false) {
                    allowChangClr = true;
                    titleClr = Colors.transparent;
                    iconClr = Colors.white;

                    Future.delayed(Duration(milliseconds: 30), () => reloadPage());
                  }

                  return Stack(
                    children: [
                      FlexibleSpaceBar(
                          collapseMode: CollapseMode.none,
                          background: InkWell(
                            child: Stack(
                              children: [
                                // image
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  right: 0,
                                  left: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(widget.detail?["image"]),
                                        )
                                    ),
                                  ),
                                ),

                                // Liner gradient
                                Positioned(
                                  top: 250,
                                  bottom: 0,
                                  right: 0,
                                  left: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0),
                                          Colors.black,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // categories, title
                                Positioned(
                                  top: 0,
                                  bottom: 10,
                                  right: 10,
                                  left: 10,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(widget.detail?["title"], style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: overflowStyle),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> ImageViewer(image: widget.detail?["image"])));
                            },
                          )
                      ),

                      if(allowChangClr == true) Positioned(
                        top: 0, left: 0, right: 0,
                        child: Container(
                          height: widget.preferredSize.height+MediaQuery.of(context).padding.top,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.5, 1],
                              colors: [
                                Color.fromRGBO(0, 0, 0, 0.5),
                                Color.fromRGBO(0, 0, 0, 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },),
              ),

              // Post Detail
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Post Date, Content_writer
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/calendar.svg",
                                colorFilter: ColorFilter.mode(config.primaryColor, BlendMode.srcIn),
                                height: 12,
                                width: 12,
                              ),
                              Divider(endIndent: 5),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(helper.getFormatDate(widget.detail?["post_date"]), style: TextStyle(fontSize: 12,color: config.primaryColor)),
                              ),
                            ],
                          ),
                          Container(
                            width: 20,
                            child: Divider(thickness: 1, color: config.primaryColor),
                          ),
                        ],
                      ),
                    ),

                    // Post Content
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(left: 10,right: 10,bottom: 20),
                      child: HtmlWidget(
                        widget.detail?["post_content"],
                        textStyle: TextStyle(fontSize: 15,height: 1.6,color: Colors.black),
                        // webViewDebuggingEnabled: true,
                        // webViewMediaPlaybackAlwaysAllow: true,
                        onTapImage: (image){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> ImageViewer(image: image.sources.first.url)));
                        },
                        onTapUrl: (url) async {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            throw 'Could not launch $url';
                          }

                          return true;
                        },
                      ),
                    ),

                    // Copyright
                    Divider(indent: 10,endIndent: 10,height: 0,thickness: 0.8),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      padding: EdgeInsets.all(10),
                      child: Text("Copyright ©2021 D-Store",style: TextStyle(color: Colors.grey,fontSize: 12, fontFamily: 'roboto')),
                    ),
                  ],
                ),
              ),

              SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
        ),
      ),
    );
  }
}
