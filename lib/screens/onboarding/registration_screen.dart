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

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool showSpinner = false;
  String email;
  String password;
  String username;

  List<CategoryObject> categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                height: 17.5,
              ),
              Hero(
                tag: 'logo',
                child: Container(
                  height: 82.5,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              SizedBox(
                height: 17.5,
              ),
              TextField(
                keyboardType: TextInputType.visiblePassword,
                enableSuggestions: false,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Email Address'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                enableSuggestions: false,
                maxLength: 14,
                keyboardType: TextInputType.visiblePassword,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  username = value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Username'),
              ),
              SizedBox(
                height: 8,
              ),
              TextField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Password'),
              ),
              SizedBox(
                height: 8,
              ),
              RoundedButton(
                color: kDarkBlueCompliment,
                title: 'Register',
                onPressed: () async {
                  FocusScope.of(context).unfocus();

                  if (passwordIsSufficient() &&
                      emailIsSufficient() &&
                      usernameIsSufficient() &&
                      await usernameAndEmailAreAvailable()) {
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

  Future<void> _gatherUserInterests() async {
    CategoryListView listView = CategoryListView(
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
              fontWeight: FontWeight.w900,
            ),
          ),
          children: [
            Container(
              width: 200,
              height: 400,
              child: listView,
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

  bool usernameIsSufficient() {
    bool _sufficient;

    if (username.length > 1) {
      _sufficient = true;
    } else {
      AlertHelper helper = AlertHelper(
          choice1: 'Ok',
          title: 'Insufficient Username',
          body: 'Please ensure your username is at least 1 character');
      helper.generateAlert(context);
    }

    return _sufficient;
  }

  Future<bool> usernameAndEmailAreAvailable() async {
    bool usernameIsAvailable;
    bool emailIsAvailable;
    bool bothAreAvailable = true;

    FirestoreHelper helper = FirestoreHelper();

    usernameIsAvailable =
        await helper.usernameIsAvailable(username.toLowerCase());
    emailIsAvailable = await helper.emailIsAvailable(email.toLowerCase());

    if (usernameIsAvailable == false) {
      AlertHelper helper = AlertHelper(
          title: 'Username Unavailable',
          body: 'Please enter a different username');
      helper.generateAlert(context);
      bothAreAvailable = false;
    }

    if (emailIsAvailable == false) {
      AlertHelper helper = AlertHelper(
          title: 'Email Unavailable',
          body: 'There is already an account registered to this email address');
      helper.generateAlert(context);
      bothAreAvailable = false;
    }

    return bothAreAvailable;
  }

  _toggleSpinner() {
    setState(() {
      showSpinner = !showSpinner;
    });
  }

  List<Map<String, dynamic>> _convertInterestsToJson(
      List<CategoryObject> categories) {
    List<Map<String, dynamic>> map = [];

    for (CategoryObject cat in categories) {
      map.add(cat.toJson());
    }
    return map;
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
        username: username.toLowerCase(),
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
}
