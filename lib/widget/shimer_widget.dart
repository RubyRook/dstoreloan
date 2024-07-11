import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget{

  subListingShimmer(){
    return Container(
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: Colors.white,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index)=> Divider(thickness: 1,color: Colors.white),
                itemCount: 3,
                itemBuilder: (context, index){
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 0,
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            height: 100,
                            width: 120,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 12,
                                color: Colors.white,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                height: 12,
                                color: Colors.white,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                height: 8,
                                color: Colors.white,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                height: 8,
                                color: Colors.white,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(top: 22),
                                height: 8,
                                width: 30,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
            ),
          ),
        ),
      ),
    );
  }

  rectangleShimmer(){
    return Container(
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: Colors.white,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, index)=> Divider(thickness: 1,color: Colors.white),
              itemCount: 3,
              itemBuilder: (context, index){
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 12,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 12,
                        color: Colors.white,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 25),
                        height: 8,
                        width: 30,
                        color: Colors.white,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}