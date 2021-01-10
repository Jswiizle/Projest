import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/constants.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:projest/components/buttons/rounded_button.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  TextEditingController nameController;
  TextEditingController emailController;

  bool showSpinner = false;

  ImageProvider avatarProvider;

  @override
  void initState() {
    nameController =
        TextEditingController(text: FirebaseAuthHelper.loggedInUser.username);
    emailController =
        TextEditingController(text: FirebaseAuthHelper.loggedInUser.email);

    avatarProvider = FirebaseAuthHelper.loggedInUser.profileImageLink != null
        ? NetworkImage(FirebaseAuthHelper.loggedInUser.profileImageLink)
        : AssetImage('images/profile.png');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 17.5),
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: kDarkBlueCompliment,
                      radius: 101.5,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 100,
                        backgroundImage: avatarProvider,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: MaterialButton(
                        elevation: 5,
                        height: 60,
                        onPressed: _getFromGallery,
                        shape: CircleBorder(),
                        color: kPrimaryColor,
                        child: Icon(
                          Icons.edit,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12.5),
                GestureDetector(
                  onTap: () {
                    AlertHelper helper = AlertHelper(
                        title:
                            'Level ${FirebaseAuthHelper.loggedInUser.getLevel()}',
                        body:
                            'Earn levels by giving other users helpful feedback. As you level up, your projects will yield more points to other users that submit helpful feedback. The more feedback you give, the more you get!');
                    helper.generateAlert(context);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 75),
                      child: Text(
                        'Level ${FirebaseAuthHelper.loggedInUser.getLevel()}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.5),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 10, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: nameController,
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          _presentEditAlert(EditTextAlertState.editingUsername);
                        },
                        child: Icon(
                          Icons.edit,
                          color: kDarkBlueCompliment,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 10, 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: emailController,
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          _presentEditAlert(EditTextAlertState.editingEmail);
                        },
                        child: Icon(
                          Icons.edit,
                          color: kDarkBlueCompliment,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                  FirebaseAuthHelper.loggedInUser.credits.toDouble() != 1 ? 'You have ${removeDecimalZeroFormat(FirebaseAuthHelper.loggedInUser.credits.toDouble())} credits' : 'You have ${removeDecimalZeroFormat(FirebaseAuthHelper.loggedInUser.credits.toDouble())} credit'
                      ,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 12.5),
                    GestureDetector(
                      onTap: () {
                        AlertHelper alert = AlertHelper(
                            title: 'Credits',
                            body:
                                'You can earn credits by giving other users feedback on their projects. If your feedback is helpful, you will earn credits. Credits can be used to temporarily boost your projects in the algorithm.');
                        alert.generateAlert(context);
                      },
                      child: Icon(
                        Icons.details,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _presentEditAlert(EditTextAlertState state) async {
    switch (state) {
      case EditTextAlertState.editingEmail:
        String newEmail;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text(
                'Change Email Address',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              children: [
                Container(
                  width: 300,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: 'Enter your new email',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 20.0),
                          ),
                          onChanged: (e) {
                            newEmail = e;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  child: RoundedButton(
                    title: 'Save',
                    color: kPrimaryColor,
                    onPressed: () async {
                      Navigator.pop(context);
                      _toggleSpinner();
                      FirebaseAuthHelper.loggedInUser.email = newEmail;
                      FirestoreHelper helper = FirestoreHelper();
                      await helper.updateCurrentUser();
                      emailController.text = newEmail;
                      _toggleSpinner();
                    },
                  ),
                ),
              ],
            );
          },
        );
        break;
      case EditTextAlertState.editingUsername:
        String newUsername;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text(
                'Change Username',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              children: [
                Container(
                  width: 300,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Enter your new username'),
                          onChanged: (u) {
                            newUsername = u;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  child: RoundedButton(
                    title: 'Save',
                    color: kPrimaryColor,
                    onPressed: () async {
                      Navigator.pop(context);
                      _toggleSpinner();
                      FirebaseAuthHelper.loggedInUser.username = newUsername;
                      FirestoreHelper helper = FirestoreHelper();
                      await helper.updateCurrentUser();
                      nameController.text = newUsername;
                      _toggleSpinner();
                    },
                  ),
                ),
              ],
            );
          },
        );
        break;
    }
  }

  String removeDecimalZeroFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }

  _getFromGallery() async {
    await Permission.photos.request();

    if (await Permission.photos.isGranted) {

      print('Permission is granted');

      PickedFile pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
      );

      print('got it');

      if (pickedFile != null) {

        print('File exists');

        _cropImage(pickedFile.path);
      }
    }
  }

  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        androidUiSettings: AndroidUiSettings(
          lockAspectRatio: true,
        ),
        iosUiSettings: IOSUiSettings(aspectRatioLockEnabled: true));

    if (croppedImage != null) {
      _toggleSpinner();

      StorageReference thumbnailRef = FirebaseStorage()
          .ref()
          .child("${FirebaseAuthHelper.loggedInUser.uid}/profile");
      StorageUploadTask thumbTask = thumbnailRef.putFile(croppedImage);

      await thumbTask.onComplete;

      if (FirebaseAuthHelper.loggedInUser.profileImageLink == null) {
        FirebaseAuthHelper.loggedInUser.profileImageLink =
            await thumbnailRef.getDownloadURL();
        FirestoreHelper helper = FirestoreHelper();
        await helper.updateCurrentUser();
      }

      avatarProvider.evict();

      _toggleSpinner();

      setState(() {
        avatarProvider =
            NetworkImage(FirebaseAuthHelper.loggedInUser.profileImageLink);
      });
    }
  }

  _toggleSpinner() {
    setState(() {
      showSpinner = !showSpinner;
    });
  }
}

enum EditTextAlertState { editingUsername, editingEmail }

//NOTES

//Using a single child scrollview to get rid of renderflex error
