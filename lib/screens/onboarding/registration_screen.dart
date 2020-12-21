import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/constants.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/models/objects/user_object.dart';
import 'package:projest/screens/misc/main_tab_controller.dart';
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
  String name;

  List<CategoryObject> categories;

  Future<void> _gatherUserInterests() async {
    CategoryListView listview = CategoryListView(
      state: CategoryListViewState.multiple,
      onCategoriesChanged: (newCategories) {
        List<CategoryObject> selectedCategories = [];

        for (CategoryObject c in newCategories) {
          if (c.isSelected) {
            selectedCategories.add(c);
          }
        }

        categories = selectedCategories;
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
                  Navigator.pop(context);
                  _createAccount();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  bool passwordIsSufficient() {
    if (password.length < 6) {
      AlertHelper helper = AlertHelper(
          choice1: 'Ok',
          title: 'Insufficent Password',
          body: 'Please ensure your password is at least 6 characters');
      helper.generateAlert(context);
      return false;
    } else {
      return true;
    }
  }

  bool emailIsSufficient() {
    bool sufficient;

    if (email.contains('@') && email.length > 1) {
      sufficient = true;
    } else {
      sufficient = false;
      AlertHelper helper = AlertHelper(
          choice1: 'Ok',
          title: 'Insufficient Email',
          body: 'Please ensure your email address is valid');
      helper.generateAlert(context);
    }

    return sufficient;
  }

  bool nameIsSufficient() {
    bool _sufficient;

    if (name.length > 1) {
      _sufficient = true;
    } else {
      AlertHelper helper = AlertHelper(
          choice1: 'Ok',
          title: 'Insufficient Name',
          body: 'Please ensure your name is at least 1 character');
      helper.generateAlert(context);
    }

    return _sufficient;
  }

  _toggleSpinner() {
    setState(() {
      showSpinner = !showSpinner;
    });
  }

  _createAccount() async {
    _toggleSpinner();

    final status =
        await FirebaseAuthHelper().createAccount(email: email, pass: password);
    if (status == AuthResultStatus.successful) {
      UserObject newUserObject = UserObject(
        uid: _authHelper.auth.currentUser.uid,
        interestArray: _convertInterestsToJson(categories),
        password: password,
        email: email,
        credits: 0,
        points: 0,
        earlyAdopter: false,
        joinDate: Timestamp.now(),
        username: name,
        blockedByUid: [],
        blockedUsersUid: [],
      );

      await _firestore
          .collection('Users')
          .doc(_authHelper.auth.currentUser.uid)
          .set(newUserObject.toJson());

      FirebaseAuthHelper.loggedInUser = newUserObject;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 100.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  name = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your name'),
              ),
              SizedBox(
                height: 10.0,
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
                height: 10.0,
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
                  if (passwordIsSufficient() &&
                      emailIsSufficient() &&
                      nameIsSufficient()) {
                    _gatherUserInterests();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
