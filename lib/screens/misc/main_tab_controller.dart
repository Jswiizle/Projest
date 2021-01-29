import 'package:flutter/material.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/main.dart';
import 'package:projest/screens/myprojects/add_project_screen.dart';
import 'package:projest/screens/myprojects/view_my_project_screen.dart';
import '../myprojects/my_projects_screen.dart';
import '../searchprojects/search_projects_screen.dart';
import '../profile/my_profile_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/screens/profile/settings_screen.dart';
import 'package:projest/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:projest/models/objects/project_object.dart';

class MainTabController extends StatefulWidget {
  static const String id = 'tab_controller';

  @override
  _MainTabControllerState createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int _currentIndex = 0;
  bool _showSpinner = false;
  bool notificationsConfigured = false;
  List<Widget> tabs = [];

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
  void initState() {
    super.initState();
    tabs = [
      MyProjectsScreen(),
      SearchProjectsScreen(),
      MyProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (notificationsConfigured == false) {
      _initFirebaseMessaging();
    }
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
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
      ),
    );
  }

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
    } else if (_currentIndex == 2) {
      return [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, SettingsScreen.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.settings,
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
        onTap: () async {
          Navigator.of(context).popUntil((route) => route.isFirst);
          await FirebaseAuthHelper().logout();
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

  void _initFirebaseMessaging() {
    bool isAndroid = Theme.of(context).platform == TargetPlatform.android;

    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage : $message');
        return;
      },
      onBackgroundMessage: isAndroid ? myBackgroundMessageHandler : null,
      onResume: (Map<String, dynamic> message) async {
        print('onResume : $message');
        String projectId = isAndroid ? message['data']['pId'] : message['pId'];
        FirestoreHelper helper = FirestoreHelper();
        _toggleSpinner();
        ProjectObject project = await helper.getProject(projectId);
        ViewMyProjectScreen.p = project;
        _toggleSpinner();
        Navigator.pushNamed(context, ViewMyProjectScreen.id);

        print('Done, project ID is: $projectId');

        return;
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch : $message');
        return;
      },
    );

    _firebaseMessaging.getToken().then((t) async {
      print(t);

      if (FirebaseAuthHelper.loggedInUser.fcmTokens.contains(t) == false) {
        FirestoreHelper helper = FirestoreHelper();
        await helper.addFcmToken(t);
      }
    });

    notificationsConfigured = true;
  }

  void _toggleSpinner() {
    setState(() {
      _showSpinner = !_showSpinner;
    });
  }
}
