import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../Helper/Responsive.dart';
import '../Data/searchResults.dart';
import '../Widgets/list_all.dart';
import '../Widgets/search_bar.dart';

class Search extends StatefulWidget {
  final String? queryHomePage;
  const Search({super.key, this.queryHomePage});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  final PagingController<int, dynamic> _searchPagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 3);

  String _currentQuery = '';
  bool _isSearched = false;

  @override
  void initState() {
    super.initState();
    _searchPagingController.addPageRequestListener((pageKey) {
      _loadTrackData(pageKey, _currentQuery);
    });
    if(widget.queryHomePage!=null) search(widget.queryHomePage!);
  }

  void _loadTrackData(int pageKey, String query) async {
    try {
      List<dynamic> trackData = await FetchSearchTracks(
        path: 'search',
        Query: query,
        controller: _searchPagingController,
        pageKey: pageKey,
      );
      final isLastPage = trackData.isEmpty;
      if (isLastPage) {
        _searchPagingController.appendLastPage(trackData);
      } else {
        _searchPagingController.appendPage(trackData, pageKey + 1);
      }

    } catch (error) {
      _searchPagingController.error = error;
    }
  }

  void search(String query) {
    setState(() {
      _currentQuery = query;
      _isSearched = true;
    });
    _searchPagingController.refresh();
  }

  @override
  void dispose() {
    _searchPagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:Responsive.isSmallScreen(context) ?AppBar(backgroundColor: Colors.black87,toolbarHeight: 5,):null,
      backgroundColor: Colors.black,
      body: Column(
        children: [
            Row(
              children: [
                Expanded(flex: 6,
                    child: searchBar(onSubmit: (val){search(val);},height: 45,isMarginReq: true,width: double.infinity,)),
                if(Responsive.isLargeScreen(context))
                Expanded(
                  flex: 1,
                    child: TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("CANCEL", style: TextStyle(color: Colors.white),)))
              ],
            ),

          if (_isSearched)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                child: PagedListView<int, dynamic>(
                    pagingController: _searchPagingController,
                    scrollDirection: Axis.vertical,
                    builderDelegate: PagedChildBuilderDelegate<dynamic>(
                        noItemsFoundIndicatorBuilder: (context)=>const Center(child: Text("No Items Found", style: TextStyle(color: Colors.red),),),
                        itemBuilder: (context, item, index) {
                          return ListAllWidget(
                              items: _searchPagingController.itemList,
                              index: index);
                        })),
              ),
            ),
        ],
      ),
    );
  }
}
