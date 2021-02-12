import 'package:flutter/material.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/screens/misc/main_tab_controller.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:projest/constants.dart';
import 'package:projest/main.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkIfAuth();
    });

    super.initState();
  }

  void checkIfAuth() {
    if (Projest.authenticated) {
      Navigator.pushNamed(context, MainTabController.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projest'),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 180,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'Projest',
                      style: TextStyle(
                        fontSize: 70.0,
                        fontFamily: 'LobsterTwo',
                        fontWeight: FontWeight.w700,
                        color: kDarkBlueCompliment,
                      ),
                    ),
                  ),
                  Hero(
                    tag: 'logo',
                    child: Image(
                      image: AssetImage('images/logo.png'),
                      height: 70,
                      width: 70,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              RoundedButton(
                color: kPrimaryColor,
                title: 'Login',
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ),
              RoundedButton(
                color: kDarkBlueCompliment,
                title: 'Register',
                onPressed: () {
                  Navigator.pushNamed(context, RegistrationScreen.id);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
