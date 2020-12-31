import 'package:flutter/material.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/constants.dart';
import 'package:projest/components/listviews/feedback_listview.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:projest/screens/misc/view_project_content_screen.dart';

class ViewMyProjectScreen extends StatefulWidget {
  ViewMyProjectScreen();

  static const String id = 'view_my_project_screen';
  static ProjectObject p;

  @override
  _ViewMyProjectScreenState createState() => _ViewMyProjectScreenState();
}

class _ViewMyProjectScreenState extends State<ViewMyProjectScreen> {
  bool showSpinner = false;

  ImageProvider provider;

  TextEditingController descriptionController = TextEditingController(text: ViewMyProjectScreen.p.description);

  @override
  Widget build(BuildContext context) {
    provider = ViewMyProjectScreen.p.thumbnailLink != null
        ? NetworkImage(ViewMyProjectScreen.p.thumbnailLink)
        : AssetImage('images/default.png');

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text(ViewMyProjectScreen.p.title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: GestureDetector(
                child: Icon(
                  Icons.edit,
                  size: 30,
                ),
                onTap: () {
                  _presentEditAlert(EditTextAlertState.editingTitle);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: GestureDetector(
                child: Icon(
                  Icons.perm_media_rounded,
                  size: 30,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewProjectContentScreen(
                              p: ViewMyProjectScreen.p,
                              state: ViewProjectContentScreenState
                                  .viewingMyProjectContent,
                            ),
                        fullscreenDialog: true),
                  );
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 25),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.5)),
                    elevation: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        key: UniqueKey(),
                        image: provider,
                        width: 320,
                        height: 180,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 2.5),
                child: Row(
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        _presentEditAlert(
                            EditTextAlertState.editingDescription);
                      },
                      child: Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0.0, 20, 25.0),
                child: TextField(
                  controller: descriptionController,
                  enabled: false,
                  maxLines: null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 7.5),
                child: Text(
                  'Project Feedback',
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                  height: 175,
                  child: FeedbackListView(
                project: ViewMyProjectScreen.p,
                refreshCallback: () {
                  setState(() {});
                },
              )),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                child: RoundedButton(
                  color: kPrimaryColor,
                  title: 'Change Project Thumbnail',
                  onPressed: () {
                    _getFromGallery(ViewMyProjectScreen.p);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                child: FlatButton(
                  child: Text(
                    'Delete Project',
                    style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),
                  ),
                  onPressed: () {
                    print('Pressed');
                    AlertHelper helper = AlertHelper(
                      choice1: 'Delete Project',
                      choice2: 'Cancel',
                      title: 'Are you sure?',
                      body:
                          'Are you sure you want to permanently delete this project?',
                      c1: () async {
                        Navigator.pop(context);

                        FirestoreHelper helper = FirestoreHelper();

                        _toggleSpinner();
                        await helper.deleteProject(ViewMyProjectScreen.p);
                        _toggleSpinner();
                        Navigator.pop(context);
                      },
                      c2: () {
                        Navigator.pop(context);
                      },
                    );

                    helper.generateChoiceAlert(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _presentEditAlert(EditTextAlertState state) async {
    switch (state) {
      case EditTextAlertState.editingDescription:

        TextEditingController controller = TextEditingController(text: ViewMyProjectScreen.p.description);

        String newDescription;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text(
                'Edit Project Description',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                ),
              ),
              children: [
                Container(
                  width: 200,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.multiline,
                          maxLines: 6,
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: 'Enter a new description',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 20.0),
                          ),
                          onChanged: (description) {
                            newDescription = description;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 2.5),
                  child: RoundedButton(
                    title: 'Save',
                    color: kPrimaryColor,
                    onPressed: () async {

                      if (newDescription != null) {

                        setState(() {
                          descriptionController.text = newDescription;
                          ViewMyProjectScreen.p.description = newDescription;
                        });

                        FirestoreHelper helper = FirestoreHelper();
                        await helper.updateProject(ViewMyProjectScreen.p);
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            );
          },
        );
        break;
      case EditTextAlertState.editingTitle:

        TextEditingController controller = TextEditingController(text: ViewMyProjectScreen.p.title);

        String newTitle;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text(
                'Edit Project Title',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                ),
              ),
              children: [
                Container(
                  width: 200,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: controller,
                          decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Enter a new title'),
                          onChanged: (title) {
                            newTitle = title;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 2.5),
                  child: RoundedButton(
                    title: 'Save',
                    color: kPrimaryColor,
                    onPressed: () async {

                      if (newTitle != null) {

                        setState(() {
                          ViewMyProjectScreen.p.title = newTitle;
                        });

                        FirestoreHelper helper = FirestoreHelper();
                        await helper.updateProject(ViewMyProjectScreen.p);
                      }

                      Navigator.pop(context);
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

  _getFromGallery(ProjectObject project) async {
    await Permission.photos.request();

    if (await Permission.photos.isGranted) {
      PickedFile pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
      );
      _cropImage(pickedFile.path, project);
    }
  }

  _cropImage(filePath, ProjectObject p) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
        androidUiSettings: AndroidUiSettings(
          lockAspectRatio: true,
        ),
        iosUiSettings: IOSUiSettings(aspectRatioLockEnabled: true));

    if (croppedImage != null) {
      _toggleSpinner();

      StorageReference thumbnailRef = FirebaseStorage()
          .ref()
          .child("${FirebaseAuthHelper.loggedInUser.uid}/${p.id}/thumbnail");
      StorageUploadTask thumbTask = thumbnailRef.putFile(croppedImage);

      await thumbTask.onComplete;

      if (p.thumbnailLink == null || p.thumbnailLink == "") {
        p.thumbnailLink = await thumbnailRef.getDownloadURL();
        FirestoreHelper helper = FirestoreHelper();
        await helper.updateProject(p);
      }

      provider.evict();
      _toggleSpinner();
    }
  }

  _toggleSpinner() {
    setState(() {
      showSpinner = !showSpinner;
    });
  }
}

enum EditTextAlertState { editingTitle, editingDescription }
