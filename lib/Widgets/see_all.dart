import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:runo_music/Widgets/list_all.dart';
import 'package:runo_music/Widgets/track_album_widget.dart';

import '../Helper/Responsive.dart';

class SeeAll extends StatefulWidget {
  final Type type;
  final PagingController<int, dynamic> pagingController;

  const SeeAll({super.key, required this.type, required this.pagingController});
  @override
  State<SeeAll> createState() => _SeeAllState();
}

class _SeeAllState extends State<SeeAll> {
  @override
  Widget build(BuildContext context) {
    String title = "Tracks for You";
    if(widget.type==Type.album) title = "Albums for You";
    else if(widget.type==Type.artist) title = "Artists for You";
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        leading:
        IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon:const Icon(Icons.keyboard_arrow_left, color: Colors.white,size: 40,)
        ),
        backgroundColor: Colors.black.withOpacity(0.88),
        title:
        Padding(
          padding: const EdgeInsets.only(top:5.0),
          child: Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        ),
      ),
      body:Container(
        padding:  EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                end: Alignment.topCenter,
                begin: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.99),
                  Colors.black.withOpacity(0.92),
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.88)
                ])),
        child: widget.type==Type.track ? PagedGridView<int, dynamic>(
            pagingController: widget.pagingController,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(mainAxisExtent: 80,
                maxCrossAxisExtent: Responsive.isSmallScreen(context) ? 600 :(Responsive.isMediumScreen(context)? 800 : 1000)
            ),
            // scrollDirection: Axis.vertical,
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
              noItemsFoundIndicatorBuilder: (context)=>Center(child: Text("No Items Found", style: TextStyle(color: Colors.red),),),
                itemBuilder: (context, item, index) {
              return
              ListAllWidget(
                  items : widget.pagingController.itemList,
                  index:index) ;
            })) :
         PagedGridView<int, dynamic>(
             pagingController: widget.pagingController,
             gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250),
             builderDelegate: PagedChildBuilderDelegate<dynamic>(
                 itemBuilder: (context, item, index){
                   return TrackAlbumWidget(index: index, type: widget.type,items:widget.pagingController.itemList!,);
                 }
             )
         ),

      ),
    );
  }
}

