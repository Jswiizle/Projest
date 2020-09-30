import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projest/alert_helper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/constants.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/firebase_helper.dart';
import 'package:projest/models/objects/user_object.dart';
import 'package:projest/screens/main_tab_controller.dart';
import 'package:projest/models/objects/category_object.dart';
import 'package:projest/components/listviews/category_listview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
final _authHelper = FirebaseAuthHelper();

List<Map<String, dynamic>> _convertInterestsToJson(
    List<CategoryObject> categories) {
  List<Map<String, dynamic>> map = [];

  for (CategoryObject cat in categories) {
    map.add(cat.toJson());
  }
  return map;
}

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool showSpinner = false;
  String email;
  String password;

  List<CategoryObject> categories;

  Future<void> _gatherUserInterests() async {
    CategoryListview listview = CategoryListview(
      onCategoriesChanged: (newCategories) {
        categories = newCategories;
      },
    );

    await showDialog<CategoryObject>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text(
            'Select Your Interests',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w900,
            ),
          ),
          children: [
            Container(
              width: 200,
              height: 400,
              child: listview,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 2.5),
              child: RoundedButton(
                title: 'Done',
                color: kPrimaryColor,
                onPressed: () {
                  // TODO: Filter the password to ensure it meets standards

                  Navigator.pop(context);

                  for (CategoryObject c in categories) {
                    print('${c.category} toggle status is ${c.isSelected}');
                  }

                  _createAccount();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  _toggleSpinner() {
    setState(() {
      showSpinner = !showSpinner;
    });
  }

  _createAccount() async {
    final status =
        await _authHelper.createAccount(email: email, pass: password);
    if (status == AuthResultStatus.successful) {
      UserObject newUserObject = UserObject(
        uid: _authHelper.auth.currentUser.uid,
        interestArray: _convertInterestsToJson(categories),
        password: password,
        email: email,
        points: 0,
        earlyAdopter: false,
        joinDate: DateTime.now(),
      );

      // TODO: Await auth sign up / create user in database

      await _firestore
          .collection('Users')
          .doc(_authHelper.auth.currentUser.uid)
          .set(newUserObject.toJson());

      _toggleSpinner();

      Navigator.pushReplacementNamed(
        context,
        MainTabController.id,
      );
    } else {
      _toggleSpinner();

      final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);
      AlertHelper aHelper = AlertHelper(
          title: 'Error', body: errorMsg, choice1: 'Ok', choice2: 'Cancel');
      aHelper.generateAlert(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
        backgroundColor: kPrimaryColor,
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 225.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email')),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter a password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: kDarkBlueCompliment,
                title: 'Register',
                onPressed: () async {
                  _toggleSpinner();
                  _gatherUserInterests();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
