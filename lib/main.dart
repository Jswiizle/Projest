import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projest/models/objects/feedback_object.dart';
import 'package:projest/screens/searchprojects/search_projects_screen.dart';
import 'models/objects/project_object.dart';
import 'screens/myprojects/add_project_screen.dart';
import 'screens/searchprojects/view_user_project_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/login_screen.dart';
import 'screens/onboarding/registration_screen.dart';
import 'screens/myprojects/my_projects_screen.dart';
import 'screens/myprojects/view_my_project_screen.dart';
import 'screens/main_tab_controller.dart';
import 'screens/myprojects/incoming_feedback_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Projest());
}

class Projest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        MyProjectsScreen.id: (context) => MyProjectsScreen(),
        ViewMyProjectScreen.id: (context) => ViewMyProjectScreen(),
        IncomingFeedbackScreen.id: (context) => IncomingFeedbackScreen(),
        AddProjectScreen.id: (context) => AddProjectScreen(),
        ViewUserProjectScreen.id: (context) => ViewUserProjectScreen(),
        MainTabController.id: (context) => MainTabController(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ViewMyProjectScreen.id) {
          final ProjectObject project = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return ViewMyProjectScreen();
            },
          );
        } else if (settings.name == IncomingFeedbackScreen.id) {
          final FeedbackObject feedbackObject = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return IncomingFeedbackScreen();
            },
          );
        } else {
          return MaterialPageRoute();
        }
      },
    );
  }
}

//MASTER TO_DO

//TODO: Re-add security rules for firebase
//TODO: Import the old firebase database
