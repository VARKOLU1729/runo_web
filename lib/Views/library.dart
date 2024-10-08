import 'dart:core';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:runo_music/Helper/loadingIndicator.dart';
import 'package:runo_music/Views/same_view.dart';
import 'package:runo_music/Widgets/create_playlist_dialog.dart';
import 'package:runo_music/Widgets/track_album_widget.dart';

import '../Helper/Responsive.dart';
import '../Services/Providers/provider.dart';
import '../Widgets/mobile_app_bar2.dart';
import '../models/play_list_model.dart';


class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {

  String playlistImage = "assets/images/favouritesImage.webp";

  @override
  void initState()
  {
    PlayListProvider playListProvider = Provider.of<PlayListProvider>(context, listen: false);
    playListProvider.loadPlayLists();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<FavouriteItemsProvider, AudioProvider, PlayListProvider>(builder: (context, favProvider,audioProvider,playListProvider, child)=>
        Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              appBar:Responsive.isMobile() ? MobileAppBar2(context):null,
              backgroundColor: Colors.black87,
              body: Padding(
                padding: MediaQuery.of(context).padding,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors:
                        [
                          Theme.of(context).colorScheme.secondary,
                          Colors.black
                        ]
                    )
                  ),
                  child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                  SizedBox(height: Responsive.isMobile()? 70 : 20,),

                  if(Responsive.isMobile())
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:  InkWell(
                      mouseCursor: MouseCursor.uncontrolled,
                      onTap: (){context.push('/profile-view');},
                      child: Container(
                        height: 50,
                        width: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            child: Icon(Icons.person, size: 50,color: Colors.white.withOpacity(0.5),),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                  Colors.orange.withOpacity(0.9), Colors.red.withOpacity(0.9)
                                ])
                            ),
                          ),
                        ),

                      ),
                      // child: ClipOval(
                      //     child: Image.asset(
                      //       'assets/images/profile_image.png',
                      //       width: 30,
                      //       height: 30,
                      //       fit: BoxFit.cover,
                      //     ),
                      //   ),
                    ),
                    title: Text("My Library", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 22),),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Header(title: "Playlists"),
                            FilledButton(
                              style: ButtonStyle(
                                visualDensity: VisualDensity(vertical: -3),
                                backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.tertiary),
                                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 0, horizontal: 15)),
                              ),
                                onPressed: (){
                                showCreatePlaylistDialog(context: context,
                                    playListProvider: playListProvider,
                                    // onSave: (playListName)
                                    // {
                                    //   playListProvider.createNewPlayList(name: playListName, imageUrl: playlistImage);
                                    // }
                                );

                                },
                                child: Text("+ NEW PLAYLIST", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold,fontSize: 12),),
                            )
                          ],
                        ),

                        SizedBox(height: 15,),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Item(Url: "assets/images/favouritesImage.webp", Title: "My Favourites", pageType: PageType.Favourites, provider: favProvider),
                              if(!playListProvider.isNamesLoading)
                              for(int i=0; i<playListProvider.playLists.length; i++)
                              playListProvider.playLists.values.map((playlist)=>Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Item(Title: playlist.name, Url: playlist.imageUrl, pageType: PageType.PlayList, playListName: playlist.name, provider: playListProvider),
                              )).toList()[i],
                              if(playListProvider.isNamesLoading) Padding(
                                padding: const EdgeInsets.only(left: 60.0),
                                child: loadingIndicator(),
                              )
                            ],
                          ),
                        ),

                        SizedBox(height: 30,),

                        Header(title: "Made for you"),

                        SizedBox(height: 20,),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [


                              Item(Url: "assets/images/favouritesImage.webp", Title: "My Favourites", pageType: PageType.Favourites, provider: favProvider),

                              SizedBox(width: 20,),

                              Item(Url: "assets/images/recentsImage.webp", Title: "My Recent Plays", pageType: PageType.RecentlyPlayed, provider: playListProvider),


                            ],
                          ),
                        ),

                      ],
                    ),
                  )
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ));
  }
  
  Widget Header({required String title})
  {
    return Text("$title", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),);
  }

  Widget Item({required String Url, required String Title, required PageType pageType, String playListName='null', required provider})
  {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 8,
              child: InkWell(
                onTap: (){
                  if(pageType==PageType.PlayList) provider.setCurrentName(playListName);
                  context.push('/same-view', extra: {'pageType':pageType}); },
                child: SizedBox(
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                    Image.asset(
                      Url,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          ),
          Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: 160,
                  child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: "PLAYLIST ", style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.tertiary)),
                          if(pageType==PageType.PlayList && !provider.checkIfPublic(name:Title)) TextSpan(text: "\u2022", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold, color: Colors.red)),
                          TextSpan(text: "\n$Title" ,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400, color: Colors.white))
                        ]
                      )
                  ),
                ),
              )
          )
        ],
      ),
    );
  }

}
