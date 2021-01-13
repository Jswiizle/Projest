import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projest/screens/profile/settings_screen.dart';
import 'screens/myprojects/add_project_screen.dart';
import 'screens/searchprojects/view_user_project_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/login_screen.dart';
import 'screens/onboarding/registration_screen.dart';
import 'screens/myprojects/my_projects_screen.dart';
import 'screens/myprojects/view_my_project_screen.dart';
import 'screens/misc/main_tab_controller.dart';
import 'screens/myprojects/view_received_feedback_screen.dart';
import 'screens/projectcontent/webcontent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Projest());
}

class Projest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        MyProjectsScreen.id: (context) => MyProjectsScreen(),
        ViewMyProjectScreen.id: (context) => ViewMyProjectScreen(),
        ViewReceivedFeedbackScreen.id: (context) =>
            ViewReceivedFeedbackScreen(),
        AddProjectScreen.id: (context) => AddProjectScreen(),
        ViewUserProjectScreen.id: (context) => ViewUserProjectScreen(),
        SettingsScreen.id: (context) => SettingsScreen(),
        MainTabController.id: (context) => MainTabController(),
        WebContent.id: (context) => WebContent(),
      },
    );
  }
}

//IMMEDIATE BUG FIXES

//MASTER TO_DO

//TODO: - Import the old firebase database
//TODO: - Bogus To-do

//TODO: - (V-1.1) - Add support for tablets
//TODO: - (V-1.1) - Display version in the settings screen
//TODO: - (V-1.1) - Add youtube content support using plugin

//TODO: - (V2) Set up Pinterest style layout - dynamic cell height
//TODO: - (V2) Create custom alert for displaying content info
//TODO: - (V2) Add social media buttons to profile
//TODO: - (V2) Add edit interests capability
//TODO: - (V2) Implement push notifications
//TODO: - (V2) Add a progress indicator for level
//TODO: - (V2) Sign in with Google

//TODO: - (VX) Allow users to add multiple project contributors
//TODO: - (VX) Filter search results on project stream instead of locally - once there are a lot of projects

//FUNCTION TESTING TO_DO

//TODO: - Uploading a web project
//TODO: - Uploading an image project
//TODO: - Uploading a web+image project
//TODO: - Uploading WITH a thumbnail
//TODO: - Uploading WITHOUT a thumbnail
//TODO: - Creating a new account
//TODO: - Edit project title
//TODO: - Edit project description
//TODO: - Edit web content
//TODO: - Edit web content description
//TODO: - Edit image content
//TODO: - Edit image content description
//TODO: - Searching projects
//TODO: - Signing in - try with invalid fields
//TODO: - Changing profile image
//TODO: - Deleting a project
//TODO: - Add project thumbnail to project with default
//TODO: - Editing project thumbnail
//TODO: - Changing profile email
//TODO: - Adding image content to existing
//TODO: - Adding web content to existing
//TODO: - Reviewing a image project
//TODO: - Reviewing a web project
//TODO: - Reviewing a web+image project
//TODO: - Submitting feedback
//TODO: - Submitting feedback on a sponsored project
//TODO: - Rating feedback
//TODO: - Test leveling up points to give - make sure it loops through projects
//TODO: - Submit a project complaint
//TODO: - Delete a project complaint
//TODO: - Block a user
//TODO: - Unblock a user

//SCREEN SIZE TESTING TO_DO

// TODO: - Login screen
// TODO: - Register screen
// TODO: - Welcome screen
// TODO: - View project content screen
// TODO: - My projects screen
// TODO: - Add projects screen
// TODO: - Project content cover page
// TODO: - View my project screen
// TODO: - View received feedback screen
// TODO: - My profile screen
// TODO: - Image content screen
// TODO: - Web content screen
// TODO: - Search projects screen
// TODO: - Submit feedback screen
// TODO: - View profile screen
// TODO: - View user project screen
