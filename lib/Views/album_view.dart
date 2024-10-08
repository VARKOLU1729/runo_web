import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runo_music/Helper/Responsive.dart';
import 'package:runo_music/Helper/deviceParams.dart';
import 'package:runo_music/Helper/messenger.dart';
import 'package:runo_music/Helper/sort.dart';
import 'package:runo_music/Widgets/back_ground_blur.dart';
import 'package:runo_music/Services/Data/fetch_data.dart';
import 'package:runo_music/Widgets/mobile_app_bar.dart';
import 'package:runo_music/Widgets/play_round_button.dart';
import 'package:runo_music/Widgets/play_text_button.dart';
import 'package:runo_music/Widgets/pop_out.dart';
import 'package:runo_music/Widgets/list_all.dart';
import 'package:runo_music/Services/Providers/provider.dart';
import 'package:runo_music/models/track_model.dart';

import '../Widgets/albumContoller.dart';
import 'music_player_view.dart';
import '../Widgets/filter.dart' as customFilter;

class AlbumView extends StatefulWidget {
  final List<dynamic> items;
  final int index;

  const AlbumView(
      {super.key,required this.items, required this.index});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {

  List<TrackModel> albumTrackData = [];

  //paging option is not there , so directly fetched all the results
  void _loadData() async {
    List<TrackModel> albumTrackDat = [];
    var albumTracksJson =  await fetchData(path: '/albums/${widget.items[widget.index].id}/tracks');
    var noAlbumTracks = albumTracksJson['meta']['returnedCount'];
    for (int i = 0; i < noAlbumTracks; i++) {

      var track = await TrackModel.fromJson(albumTracksJson['tracks'][i]) ;
      albumTrackDat.add(track);
    }
    setState(() {
      albumTrackData = albumTrackDat;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {

    final String albumId = widget.items[widget.index].id;
    final String albumName = widget.items[widget.index].name;
    final String albumImageUrl = widget.items[widget.index].imageUrl;
    final String artistId = widget.items[widget.index].artistId;
    final String artistName = widget.items[widget.index].artistName;

    var audioProvider = Provider.of<AudioProvider>(context, listen: false);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: !Responsive.isMobile() ? null:
      MobileAppBar(context,
          disablePop: false,
          actionIcon: Icons.filter_alt,
          actionOnPressed: (){
            // customFilter.Filter(context: context);
            customFilter.Filter(context: context, onSubmit : (selectedVal){setState(() {
              sortTracks(albumTrackData, sortBy: selectedVal);
            });});
          }
      ),
        backgroundColor: const Color.fromARGB(200, 9, 3, 3),
        body: Stack(children: [

          Image.network(
            albumImageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          Container(
            margin: EdgeInsets.only(top: getHeight(context)/2),
            color: Colors.black.withOpacity(0.8),
          ),

          const BackGroundBlur(),



          NestedScrollView(
              headerSliverBuilder: (context, isScrolled)
              {
                return [
                  SliverToBoxAdapter(
                  child: Responsive.isMobile(context)||Responsive.isSmallScreen(context) ? Column(
                    children: [
                      SizedBox(
                        height: 120,
                      ),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:
                          Image.network(
                            albumImageUrl,
                            fit: BoxFit.cover,
                            scale: 0.7,
                          ),
                        ),
                      ),

                      SizedBox(height: 20,),

                      Responsive.isMobile(context) ?
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              albumName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text('${artistName}', style: TextStyle(color: Colors.white, fontSize: 15),),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text('${albumTrackData.length} SONGS . ${((albumTrackData.length*30)/60).truncate()} MINS AND ${(albumTrackData.length*30)%60} SECS',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 10
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                                title:Row(
                                  children: [
                                    iconButton(context:context, icon: Icons.shuffle, onPressed: ()async{
                                      var items = albumTrackData;
                                      // items.shuffle();
                                      // await audioProvider.loadAudio(trackList: items, index: 0);
                                      audioProvider.toggleShuffle(context:context, itemsToShuffle: items);
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MusicPlayerView()),);
                                    }),
                                    iconButton(context:context, icon: Icons.favorite_outline,onPressed: (){showMessage(context: context, content: "Functionality Not Exists");}),
                                    iconButton(context:context, icon: Icons.file_download, onPressed:(){showMessage(context: context, content: "Functionality Not Exists");}),
                                    iconButton(context:context, icon: Icons.share, onPressed:(){showMessage(context: context, content: "Functionality Not Exists");})
                                  ],
                                ),
                                trailing:PlayRoundButton(items: albumTrackData)
                              ),
                            ),
                          ],
                        ),
                      ):

                      SizedBox(
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              albumName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              artistName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text('${albumTrackData.length} SONGS . ${((albumTrackData.length*30)/60).truncate()} MINS AND ${(albumTrackData.length*30)%60} SECS',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 15
                              ),
                            ),
                            Row(
                              mainAxisAlignment : MainAxisAlignment.center,
                              children: [
                                PlayTextButton(trackList: albumTrackData),
                                iconButton(context:context, icon: Icons.shuffle, onPressed: ()async{
                                  var items = albumTrackData;
                                  // items.shuffle();
                                  // await audioProvider.loadAudio(trackList: items, index: 0);
                                  audioProvider.toggleShuffle(context:context, itemsToShuffle: items);
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MusicPlayerView()),);
                                }),
                              ],
                            )
                          ],
                        ),
                      ),


                    ],
                  ):
                      Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Row(
                          children: [
                            // Spacer(),
                            // ClipRRect(
                            //   borderRadius: BorderRadius.circular(10),
                            //   child:
                            //   Image.network(
                            //     albumImageUrl,
                            //     fit: BoxFit.cover,
                            //     scale: 0.6,
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(left: 60),
                              child: SizedBox(
                                width: getWidth(context)<700 ? 250 : 300,
                                height: getWidth(context)<700 ? 250 : 300,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 20, top: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(albumImageUrl, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(width: 40,),
                            
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 40),
                                child: SizedBox(
                                  height: getWidth(context)<700 ? 200 : 300,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        albumName,
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.white,
                                            fontSize: 50,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        artistName,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: Responsive.isLargeScreen(context)?20: 5,),
                                      Text('${albumTrackData.length} SONGS . ${((albumTrackData.length*30)/60).truncate()} MINS AND ${(albumTrackData.length*30)%60} SECS',
                                        style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 15
                                        ),
                                      ),
                                      SizedBox(height: Responsive.isLargeScreen(context)?20: 5,),
                                      Row(
                                        children: [
                                          PlayTextButton(trackList: albumTrackData),
                                          iconButton(context:context, icon: Icons.shuffle, onPressed: ()async{
                                            var items = albumTrackData;
                                            items.shuffle();
                                            await audioProvider.loadAudio(trackList: items, index: 0);
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MusicPlayerView()),);
                                          }),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                )];
              },
              body: ListView.builder(
                key: ValueKey(albumTrackData.length),
                padding: EdgeInsets.only(bottom: 125, top: 40),
                  itemCount: albumTrackData.length,
                  itemBuilder: (context, index) {
                    return ListAllWidget(key: ValueKey(albumTrackData[index].id), index: index,items: albumTrackData, decorationReq: true,);

                  }),
          ),
        ]
        )
    );
  }



}


