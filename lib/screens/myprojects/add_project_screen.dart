import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:projest/constants.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/models/objects/blip_object.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/models/objects/category_object.dart';
import 'package:projest/components/tiles/project_content_tile.dart';
import 'package:projest/screens/projectcontent/webcontent.dart';
import 'package:projest/screens/projectcontent/imagecontent.dart';
import 'package:projest/components/listviews/project_content_listview.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/components/listviews/criteria_listview.dart';

class AddProjectScreen extends StatefulWidget {
  static const String id = 'add_project_screen';

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  List<BlipObject> _blips = [];
  List<ProjectContentTile> listviewContent = [];

  List<CategoryObject> categories = [
    CategoryObject(
        category: 'Music', isSelected: false, criteria: kMusicCriteria),
    CategoryObject(category: 'Art', isSelected: false, criteria: kArtCriteria),
    CategoryObject(
        category: 'Coding', isSelected: false, criteria: kCodingCriteria),
    CategoryObject(
        category: 'Marketing', isSelected: false, criteria: kMarketingCriteria),
    CategoryObject(
        category: 'Podcasting',
        isSelected: false,
        criteria: kPodcastingCriteria),
    CategoryObject(
        category: 'Design', isSelected: false, criteria: kUiDesignCriteria),
    CategoryObject(
        category: 'Video', isSelected: false, criteria: kVideoCriteria),
    CategoryObject(
        category: 'Writing', isSelected: false, criteria: kWritingCriteria),
  ];

  final _firestore = FirebaseFirestore.instance;

  CategoryObject projectCategory;
  static List<String> selectedCriteria = [];

  String projectDescription;
  String projectTitle;
  bool settingThumbnail = false;
  bool showSpinner = false;
  Image defaultImage = Image.asset(
    'images/default.png',
    fit: BoxFit.fill,
  );

  File customThumbnail;

  @override
  void initState() {
    super.initState();

    projectCategory = categories[0];
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text('Add Project'),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter a project title'),
                  onChanged: (title) {
                    projectTitle = title;
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter a project description',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  onChanged: (description) {
                    projectDescription = description;
                  },
                ),
                SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 40, left: 20),
                        child: Text(
                          'Select A Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 17.5,
                          ),
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: projectCategory,
                          items: createDropdownItems(),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                          },
                          onChanged: (selectedCategory) {
                            setState(() {
                              projectCategory = selectedCategory;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: ProjectContentListView(
                    listViewContent: listviewContent,
                    onAddImagePressed: _presentImageContentScreenAndWaitForData,
                    onAddLinkPressed: _presentWebContentScreenAndWaitForData,
                  ),
                ),
                RoundedButton(
                  title: 'Add Project',
                  color: kPrimaryColor,
                  onPressed: () {
                    if (_blips.length > 0) {
                      if (projectIsReady() == true) {
                        _showProjectCriteriaAndThumbnailPopup();
                      } else {
                        AlertHelper aHelper = AlertHelper(
                          title: 'Missing Fields',
                          body:
                              'Please ensure you have entered a project title and description',
                          choice1: 'Ok',
                          choice2: 'Cancel',
                        );
                        aHelper.generateAlert(context);
                      }
                    } else {
                      AlertHelper aHelper = AlertHelper(
                        title: 'No Project Content',
                        body: "Please add project content",
                        choice1: 'Ok',
                        choice2: 'Cancel',
                      );

                      aHelper.generateAlert(context);
                    }
                  },
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem> createDropdownItems() {
    List<DropdownMenuItem> items = [];

    for (CategoryObject c in categories) {
      items.add(
        DropdownMenuItem(
          child: Text(
            c.category,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
            ),
          ),
          value: c,
        ),
      );
    }

    return items;
  }

  void _presentWebContentScreenAndWaitForData() async {
    FocusScope.of(context).unfocus();

    BlipObject _blip = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebContent(
          state: WebContentState.addingContentToNew,
        ),
      ),
    );

    if (_blip.url != "" && _blip.url != null) {
      setState(() {
        listviewContent.insert(
          0,
          ProjectContentTile(
            blipObject: _blip,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebContent(
                    state: WebContentState.viewingTemporaryWebContent,
                    blip: _blip,
                  ),
                ),
              );
            },
          ),
        );

        _blips.add(_blip);
      });
    }
  }

  void _presentImageContentScreenAndWaitForData() async {
    FocusScope.of(context).unfocus();

    BlipObject _blip = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageContent(
          state: ImageContentState.addingContentToNew,
        ),
      ),
    );

    if (_blip != null && _blip.temporaryImage != null) {
      setState(() {
        listviewContent.insert(
          0,
          ProjectContentTile(
            blipObject: _blip,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageContent(
                    state: ImageContentState.viewingTemporaryImageContent,
                    blip: _blip,
                  ),
                ),
              );
            },
          ),
        );

        _blips.add(_blip);
      });
    }
  }

  Future<void> _showProjectCriteriaAndThumbnailPopup() async {
    await showDialog(
      context: context,
      builder: (BuildContext cText) {
        return SimpleDialog(
          title: const Text(
            'Feedback Criteria',
            style: TextStyle(
              fontSize: 22.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Container(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 170,
                    child: CriteriaListview(
                      selectedCriteria: selectedCriteria,
                      category: projectCategory,
                      onCriteriaChanged: (criteriaSelected) {
                        selectedCriteria = criteriaSelected;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 25, 20, 5),
                    child: Text('Project Thumbnail',
                        style: TextStyle(
                          fontSize: 22.5,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 6),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        child: ClipRRect(
                          child: customThumbnail == null
                              ? defaultImage
                              : Image.file(
                                  customThumbnail,
                                  fit: BoxFit.fill,
                                ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: RoundedButton(
                      title: 'Done',
                      color: kPrimaryColor,
                      onPressed: () {
                        _uploadProject();
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 0),
                    child: FlatButton(
                      height: 40,
                      color: Colors.white,
                      textColor: kPrimaryColor,
                      child: Text(customThumbnail == null
                          ? 'Add Custom Thumbnail'
                          : 'Change Thumbnail'),
                      onPressed: () {
                        settingThumbnail = true;
                        // Navigator.pop(context);
                        _getFromGallery();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _getFromGallery() async {
    await Permission.photos.request();

    if (await Permission.photos.isGranted) {
      PickedFile pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        _cropImage(pickedFile.path);
      }
    }
  }

  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
        androidUiSettings: AndroidUiSettings(
          lockAspectRatio: true,
        ),
        iosUiSettings: IOSUiSettings(aspectRatioLockEnabled: true));

    setState(() {
      if (settingThumbnail == true) {
        customThumbnail = croppedImage;
      }

      _showProjectCriteriaAndThumbnailPopup();
    });
  }

  bool projectIsReady() {
    if (projectTitle != null &&
        projectDescription != null &&
        projectTitle != "" &&
        projectDescription != "") {
      return true;
    } else {
      return false;
    }
  }

  Future _uploadProject() async {
    String uuid = Uuid().v4();
    FirebaseAuthHelper auth = FirebaseAuthHelper();
    String thumbnailUrl;

    Navigator.pop(context);
    _toggleSpinner();

    // Step 1: Upload Thumbnail

    if (customThumbnail != null) {
      StorageReference thumbnailRef = FirebaseStorage()
          .ref()
          .child("${auth.auth.currentUser.uid}/$uuid/thumbnail");
      StorageUploadTask thumbTask = thumbnailRef.putFile(customThumbnail);

      Navigator.pop(context);

      await thumbTask.onComplete;
      thumbnailUrl = await thumbnailRef.getDownloadURL();
    }

    //Step 2: Upload project content, gather image URL's

    for (var b in _blips) {
      if (b.temporaryImage != null) {
        StorageReference ref = FirebaseStorage()
            .ref()
            .child("${auth.auth.currentUser.uid}/$uuid/content/${b.id}");

        StorageUploadTask task = ref.putFile(b.temporaryImage);
        await task.onComplete;

        b.imageUrl = await ref.getDownloadURL();
      }
    }

    //Step 3: Create a new project object and upload object

    List<Map<String, dynamic>> blipArray = [];

    for (BlipObject b in _blips) {
      blipArray.add(b.toJson());
    }

    ProjectObject p = ProjectObject(
      flaggedByUid: [],
      blipArray: blipArray,
      title: projectTitle,
      description: projectDescription,
      thumbnailLink: thumbnailUrl != null ? thumbnailUrl : null,
      date: Timestamp.now(),
      profileImageLink: FirebaseAuthHelper.loggedInUser.profileImageLink != null
          ? FirebaseAuthHelper.loggedInUser.profileImageLink
          : "",
      uid: FirebaseAuthHelper.loggedInUser.uid,
      id: uuid,
      selectedCriteria: selectedCriteria,
      projectOwnerUsername: FirebaseAuthHelper.loggedInUser.username,
      category: projectCategory.category,
      userPointsToGive: FirebaseAuthHelper.loggedInUser.pointsToGive(),
    );

    selectedCriteria = [];
    await _firestore.collection('Projects').doc(p.id).set(p.toJson());
    _toggleSpinner();
    Navigator.pop(context);
  }

  _toggleSpinner() {
    setState(() {
      showSpinner = !showSpinner;
    });
  }
}
