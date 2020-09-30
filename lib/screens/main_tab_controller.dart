import 'package:flutter/material.dart';
import 'package:projest/firebase_helper.dart';
import 'package:projest/screens/myprojects/add_project_screen.dart';
import 'myprojects/my_projects_screen.dart';
import 'searchprojects/search_projects_screen.dart';
import 'profile/my_profile_screen.dart';

class MainTabController extends StatefulWidget {
  static const String id = 'tab_controller';

  @override
  _MainTabControllerState createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  List<Widget> configureAppBarButtons() {
    if (_currentIndex == 2) {
      return [
        GestureDetector(
          onTap: () {
            FirebaseAuthHelper().logout();
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.cancel,
              color: Colors.white,
              size: 30,
            ),
          ),
        )
      ];
    } else if (_currentIndex == 0) {
      return [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AddProjectScreen.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        )
      ];
    }
  }

  final tabs = [
    MyProjectsScreen(),
    SearchProjectsScreen(),
    MyProfileScreen(),
  ];

  final navigationBarItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.poll),
      title: Text('My Projects'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      title: Text('Search Projects'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      title: Text('Profile'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: configureAppBarButtons(),
        automaticallyImplyLeading: false,
        title: navigationBarItems[_currentIndex].title,
        backgroundColor: Colors.lightBlueAccent,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: navigationBarItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: tabs[_currentIndex],
    );
  }
}
