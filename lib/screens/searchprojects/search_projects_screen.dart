import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projest/constants.dart';
import 'package:projest/models/objects/category_object.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/components/tiles/project_tile.dart';
import 'package:projest/screens/searchprojects/view_user_project_screen.dart';

final _firestore = FirebaseFirestore.instance;

FirebaseAuthHelper authHelper;

class SearchProjectsScreen extends StatefulWidget {
  static const String id = 'search_projects_screen';

  @override
  _SearchProjectsScreenState createState() => _SearchProjectsScreenState();
}

class _SearchProjectsScreenState extends State<SearchProjectsScreen> {
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search Query";
  List<ProjectObject> projects = [];
  List<ProjectTile> listTiles = [];
  List<Text> tabs;

  @override
  void initState() {
    tabs = _buildTabs();

    super.initState();
    authHelper = FirebaseAuthHelper();
  }

  @override
  Widget build(BuildContext context) {
    tabs = _buildTabs();

    return DefaultTabController(
      length: FirebaseAuthHelper.loggedInUser.interestArray.length + 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: _isSearching ? const BackButton() : Container(),
          title: _isSearching ? _buildSearchField() : Text('Search Projects'),
          actions: _buildActions(),
          bottom: _buildTabBar(),
        ),
        body: TabBarView(
          children: buildTabViews(),
        ),
      ),
    );
  }

  TabBar _buildTabBar() {
    TabBar tBar = TabBar(
      labelPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 7.5),
      unselectedLabelColor: Colors.white70,
      labelColor: kPrimaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      isScrollable: true,
      tabs: tabs,
    );

    return tBar;
  }

  List<Text> _buildTabs() {
    List<Text> tabs = [];
    tabs.add(
      Text(
        'All',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    for (var c in FirebaseAuthHelper.loggedInUser.interestArray) {
      CategoryObject cat = CategoryObject.fromJson(c);
      tabs.add(
        Text(
          cat.category,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return tabs;
  }

  List<ProjectTile> filteredProjectTiles(String query) {
    List<ProjectTile> filtered = [];

    for (ProjectObject p in projects) {
      if (p.title.contains(query)) {
        filtered.add(ProjectTile(
          state: ProjectTileState.viewingUserProject,
          project: p,
          onTap: () {
            ViewUserProjectScreen.p = p;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewUserProjectScreen(),
              ),
            );
          },
        ));
      }
    }

    return filtered;
  }

  List<Widget> buildTabViews() {
    List<Widget> widgets = [];

    widgets.add(
      StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Projects').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData == true) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final snapshots = snapshot.data.docs.reversed;

          projects = [];
          listTiles = [];

          for (var snapshot in snapshots) {
            final pObject = ProjectObject.fromJson(snapshot.data());

            if (pObject.uid != authHelper.auth.currentUser.uid &&
                FirebaseAuthHelper.loggedInUser.blockedUsersUid
                        .contains(pObject.uid) ==
                    false &&
                pObject.flaggedByUid
                        .contains(FirebaseAuthHelper.loggedInUser.uid) ==
                    false) {
              projects.add(pObject);

              final p = ProjectTile(
                state: ProjectTileState.viewingUserProject,
                project: pObject,
                onTap: () async {
                  ViewUserProjectScreen.p = pObject;
                  await Navigator.pushNamed(context, ViewUserProjectScreen.id);
                  setState(() {});
                },
              );
              listTiles.add(p);
            }
          }
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 12.5),
            children: _isSearching == false
                ? listTiles
                : filteredProjectTiles(searchQuery),
            itemExtent: 80,
          );
        },
      ),
    );

    for (var c in FirebaseAuthHelper.loggedInUser.interestArray) {
      String cat = c['category'];

      widgets.add(StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Projects')
            .where('category', isEqualTo: cat)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData == true) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final snapshots = snapshot.data.docs.reversed;

          projects = [];
          listTiles = [];

          for (var snapshot in snapshots) {
            final pObject = ProjectObject.fromJson(snapshot.data());

            projects.add(pObject);

            if (pObject.uid != authHelper.auth.currentUser.uid &&
                FirebaseAuthHelper.loggedInUser.blockedUsersUid
                        .contains(pObject.uid) ==
                    false &&
                pObject.flaggedByUid
                        .contains(FirebaseAuthHelper.loggedInUser.uid) ==
                    false) {
              final p = ProjectTile(
                state: ProjectTileState.viewingUserProject,
                project: pObject,
                onTap: () async {
                  ViewUserProjectScreen.p = pObject;
                  await Navigator.pushNamed(context, ViewUserProjectScreen.id);
                  setState(() {});
                },
              );
              listTiles.add(p);
            }
          }
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 12.5),
            children: _isSearching == false
                ? listTiles
                : filteredProjectTiles(searchQuery),
            itemExtent: 80,
          );
        },
      ));
    }

    return widgets;
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      cursorColor: Colors.white24,
      decoration: InputDecoration(
        hintText: "Search Projects...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white.withOpacity(.9)),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    listTiles = [];

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }
}
