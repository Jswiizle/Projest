import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/constants.dart';
import 'package:projest/screens/misc/main_tab_controller.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/helpers/alert_helper.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  String email = '';
  String password = '';

  _login() async {
    final status =
        await FirebaseAuthHelper().login(email: email, pass: password);
    if (status == AuthResultStatus.successful) {
      toggleSpinner();
      Navigator.pushReplacementNamed(
        context,
        MainTabController.id,
      );
    } else {
      toggleSpinner();
      final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);

      AlertHelper aHelper = AlertHelper(
          title: 'Error', body: errorMsg, choice1: 'Ok', choice2: 'Cancel');

      aHelper.generateAlert(context);
    }
  }

  void toggleSpinner() {
    setState(() {
      showSpinner = !showSpinner;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: kPrimaryColor,
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Hero(
                tag: 'logo',
                child: Container(
                  height: 100.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter Your Email'),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter Password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: kPrimaryColor,
                title: 'Login',
                onPressed: () async {
                  if (canLogin() == true) {
                    toggleSpinner();
                    _login();
                  } else {
                    AlertHelper helper = AlertHelper(
                        title: 'Invalid Credentials',
                        body: 'Please enter valid credentials');
                    helper.generateAlert(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool canLogin() {
    if (password.characters.length >= 6 &&
        email.contains('@') &&
        email.contains('.')) {
      return true;
    } else {
      return false;
    }
  }
}
