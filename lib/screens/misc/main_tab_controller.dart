import 'package:flutter/material.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/screens/myprojects/add_project_screen.dart';
import '../myprojects/my_projects_screen.dart';
import '../searchprojects/search_projects_screen.dart';
import '../profile/my_profile_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/screens/profile/settings_screen.dart';
import 'package:projest/constants.dart';

class MainTabController extends StatefulWidget {
  static const String id = 'tab_controller';

  @override
  _MainTabControllerState createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;
  bool _showSpinner = false;
  List<Widget> tabs = [];

  List<Widget> configureAppBarActions() {
    if (_currentIndex == 0) {
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
    } else {
      return null;
    }
  }

  Future<void> updateCurrentUser() async {
    FirestoreHelper helper = FirestoreHelper(updateFailed: () {
      AlertHelper alertHelper =
          AlertHelper(title: 'Update Failed', body: 'Update account failed');
      alertHelper.generateAlert(context);
    });
    _toggleSpinner();
    helper.updateCurrentUser().whenComplete(() => _toggleSpinner());
  }

  Widget configureAppBarLeading() {
    if (_currentIndex == 2) {
      return GestureDetector(
        onTap: () {
          FirebaseAuthHelper().logout();
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Icon(
            Icons.logout,
            color: Colors.white,
            size: 30,
          ),
        ),
      );
    } else {
      return null;
    }
  }

  final navigationBarItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.poll),
      label: 'My Projects',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search Projects',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    tabs = [
      MyProjectsScreen(),
      SearchProjectsScreen(),
      MyProfileScreen(),
    ];

    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      child: Scaffold(
        floatingActionButton: configureFloatingActionButton(),
        appBar: _currentIndex != 1
            ? AppBar(
                leading: configureAppBarLeading(),
                actions: configureAppBarActions(),
                automaticallyImplyLeading: false,
                title: Text(navigationBarItems[_currentIndex].label),
                backgroundColor: Colors.lightBlueAccent,
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: kPrimaryColor,
          currentIndex: _currentIndex,
          items: navigationBarItems,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        body: tabs[_currentIndex],
      ),
    );
  }

  FloatingActionButton configureFloatingActionButton() {
    FloatingActionButton button;

    if (_currentIndex == 2) {
      button = FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, SettingsScreen.id);
        },
        child: Icon(Icons.settings),
        backgroundColor: kPrimaryColor,
        elevation: 4,
      );
    }

    return button;
  }

  void _toggleSpinner() {
    setState(() {
      _showSpinner = !_showSpinner;
    });
  }
}
