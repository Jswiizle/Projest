import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';
import 'package:projest/models/objects/blip_object.dart';
import 'package:projest/constants.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projest/screens/myprojects/view_my_project_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:projest/helpers/firebase_helper.dart';


class ImageContent extends StatefulWidget {
  static const String id = 'image_content';

  final ImageContentState state;
  final BlipObject blip;
  final Function deleteContentCallback;

  ImageContent({@required this.state, this.blip, this.deleteContentCallback});

  @override
  _ImageContentState createState() => _ImageContentState();
}

class _ImageContentState extends State<ImageContent> {
  BlipObject _newBlip;
  bool loading = false;
  File imageFile;
  List<GestureDetector> appBarActions;
  ImageProvider networkImgProvider;

  @override
  void initState() {
    super.initState();

    configureMisc();
    setScreenTitle();
    appBarActions = createAppBarActions();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        appBar: AppBar(
          actions: appBarActions,
          title: setScreenTitle(),
          backgroundColor: kPrimaryColor,
        ),
        body: Center(
          child: Container(
            color: Colors.grey,
            child: configureImage(),
          ),
        ),
        floatingActionButton: configureFloatingActionButton(),
        resizeToAvoidBottomInset: false,
       ),
    );
  }

  //region Data Handling

  void handleCroppedImage(File img) async {
    switch (widget.state) {
      case ImageContentState.viewingMyContent:
        networkImgProvider.evict();
        toggleSpinner();
        StorageReference thumbnailRef = FirebaseStorage().ref().child(
            "${FirebaseAuthHelper.loggedInUser.uid}/${ViewMyProjectScreen.p.id}/content/${widget.blip.id}");
        StorageUploadTask thumbTask = thumbnailRef.putFile(img);
        await thumbTask.onComplete;
        toggleSpinner();
        break;
      case ImageContentState.addingContentToNew:
      case ImageContentState.addingContentToExisting:
        setState(() {});
        break;
      default:
        break;
    }
  }

  List<BlipObject> createBlipArray() {
    List<BlipObject> array = [];

    for (var dict in ViewMyProjectScreen.p.blipArray) {
      array.add(BlipObject.fromJson(dict));
    }

    return array;
  }

  void createBlipAndPassData(String title, String description) {
    BlipObject blip;

    blip = BlipObject(
      title: title,
      description: description,
      temporaryImage: imageFile,
      id: Uuid().v4(),
    );

    Navigator.pop(context);
    Navigator.pop(context, blip);
  }

  //endregion

  //region Image Cropping

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
      iosUiSettings: IOSUiSettings(),
      androidUiSettings: AndroidUiSettings(),
    );
    if (croppedImage != null) {
      imageFile = croppedImage;
      handleCroppedImage(croppedImage);
    }
  }

  //endregion

  //region View Configuration

  void toggleSpinner() {
    setState(() {
      loading = !loading;
    });
  }

  List<GestureDetector> createAppBarActions() {
    List<GestureDetector> actions = [];

    switch (widget.state) {
      case ImageContentState.viewingMyContent:
        actions.add(
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.edit,
                size: 30,
              ),
            ),
            onTap: () {
              _showEditDetailsDialogue();
            },
          ),
        );

        actions.add(
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.delete_forever,
                size: 30,
              ),
            ),
            onTap: () {
              AlertHelper helper = AlertHelper(
                  title: 'Are you sure?',
                  body:
                      'Are you sure you want to permanently delete this content?',
                  choice1: 'Delete',
                  choice2: 'Cancel',
                  c1: () {
                    Navigator.pop(context);
                    widget.deleteContentCallback(widget.blip);
                  },
                  c2: () {
                    Navigator.pop(context);
                  });

              helper.generateChoiceAlert(context);
            },
          ),
        );
        break;
      case ImageContentState.addingContentToNew:
      case ImageContentState.addingContentToExisting:
        actions.add(
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.refresh,
                size: 30,
              ),
            ),
            onTap: () {
              _getFromGallery();
            },
          ),
        );
        break;

      default:
        actions.add(
          GestureDetector(
            onTap: presentDetailsAlert,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.description,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        );
        break;
    }

    return actions;
  }

  FloatingActionButton configureFloatingActionButton() {
    FloatingActionButton button;

    switch (widget.state) {
      case ImageContentState.viewingMyContent:
        button = FloatingActionButton.extended(
          onPressed: () {
            _getFromGallery();
          },
          label: Text(
            'Change Image',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: Icon(Icons.image),
          backgroundColor: kPrimaryColor,
          elevation: 8.0,
        );
        break;
      case ImageContentState.addingContentToNew:
      case ImageContentState.addingContentToExisting:
        if (imageFile != null) {
          button = FloatingActionButton.extended(
            onPressed: () {
              _showCompletionDialogue();
            },
            label: Text(
              'Done',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: Icon(Icons.thumb_up_alt_rounded),
            backgroundColor: kPrimaryColor,
            elevation: 8.0,
          );
        }
        break;
      default:
        break;
    }

    return button;
  }

  void configureMisc() {
    switch (widget.state) {
      case ImageContentState.addingContentToNew:
      case ImageContentState.addingContentToExisting:
        WidgetsBinding.instance.addPostFrameCallback((_) => _getFromGallery());
        break;
      default:
        break;
    }
  }

  Text setScreenTitle() {
    Text title;

    switch (widget.state) {
      case ImageContentState.addingContentToNew:
      case ImageContentState.addingContentToExisting:
        title = Text('Add Image Content');
        break;
      default:
        title = Text('Image Content');
        break;
    }

    return title;
  }

  Image configureImage() {
    Image img;

    switch (widget.state) {
      case ImageContentState.addingContentToNew:
      case ImageContentState.addingContentToExisting:
        if (imageFile == null) {
          img = null;
        } else {
          img = Image(
            image: FileImage(imageFile),
            key: UniqueKey(),
            fit: BoxFit.fill,
          );
        }
        break;
      case ImageContentState.viewingTemporaryImageContent:
        img = Image(
          image: FileImage(widget.blip.temporaryImage),
          key: UniqueKey(),
          fit: BoxFit.fill,
        );
        break;
      case ImageContentState.viewingMyContent:
        if (imageFile == null) {

          //TODO: Test new caching logic on iOS - works on Android


          networkImgProvider = NetworkImage(widget.blip.imageUrl);

          img = Image(
            image: networkImgProvider,
            key: UniqueKey(),
            fit: BoxFit.fill,
          );
        } else {

          img = Image(
            image: FileImage(imageFile),
            key: UniqueKey(),
            fit: BoxFit.fill,
          );
        }
        break;
      case ImageContentState.viewingUserContent:
        img = Image(
          image: NetworkImage(widget.blip.imageUrl),
          key: UniqueKey(),
          fit: BoxFit.fill,
        );
        break;
    }

    return img;
  }

  //endregion

  //region Dialogues

  void presentDetailsAlert() {
    setState(() {
      AlertHelper alert = AlertHelper(
        choice1: 'Ok',
        title: 'Content Details',
        body: '\n Title: ' +
            widget.blip.title +
            '\n \n Description: ' +
            widget.blip.description,
      );

      alert.generateAlert(context);
    });
  }

  Future<void> _showCompletionDialogue() async {
    String _title;
    String _description;

    TextField _titleTextfield = TextField(
      onChanged: (value) {
        _title = value;
      },
      decoration:
          kTextFieldDecoration.copyWith(hintText: 'Enter content title'),
    );

    TextField _descriptionTextfield = TextField(
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      decoration: kTextFieldDecoration.copyWith(
        hintText: 'Enter content description',
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
      onChanged: (value) {
        _description = value;
      },
    );

    await showDialog(
      context: context,
      builder: (BuildContext cText) {
        return SimpleDialog(
          title: const Text(
            'Add A Title/Description',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Container(
              width: 250,
              height: 187.5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    child: _titleTextfield,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                    child: _descriptionTextfield,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: RoundedButton(
                      title: 'Done',
                      color: kPrimaryColor,
                      onPressed: () {
                        createBlipAndPassData(_title, _description);
                      },
                    ),
                  ),
                  FlatButton(
                    color: Colors.white,
                    textColor: kPrimaryColor,
                    child: Text('Skip'),
                    onPressed: () {
                      createBlipAndPassData("", "");
                    },
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDetailsDialogue() async {
    if (_newBlip == null) {
      _newBlip = widget.blip;
    }

    TextEditingController titleController =
        TextEditingController(text: _newBlip.title);
    TextEditingController descriptionController =
        TextEditingController(text: _newBlip.description);

    TextField _titleTextfield = TextField(
      onChanged: (value) {
        _newBlip.title = value;
      },
      controller: titleController,
      decoration:
          kTextFieldDecoration.copyWith(hintText: 'Enter content title'),
    );

    TextField _descriptionTextfield = TextField(
      controller: descriptionController,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      decoration: kTextFieldDecoration.copyWith(
        hintText: 'Enter content description',
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
      onChanged: (value) {
        _newBlip.description = value;
      },
    );

    await showDialog(
      context: context,
      builder: (BuildContext cText) {
        return SimpleDialog(
          title: const Text(
            'Edit Content Details',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Container(
              width: 250,
              height: 175,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    child: _titleTextfield,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                    child: _descriptionTextfield,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: RoundedButton(
                      title: 'Save',
                      color: kPrimaryColor,
                      onPressed: () async {
                        List<BlipObject> array = createBlipArray();

                        int index = 0;

                        for (var b in array) {
                          if (b.id == _newBlip.id) {
                            array[index] = _newBlip;
                          }
                          index += 1;
                        }

                        List<Map<String, dynamic>> newPArray = [];

                        for (BlipObject b in array) {
                          newPArray.add(b.toJson());
                        }
                        Navigator.pop(context);

                        ViewMyProjectScreen.p.blipArray = newPArray;
                        toggleSpinner();
                        FirestoreHelper helper = FirestoreHelper();
                        await helper.updateProject(ViewMyProjectScreen.p);
                        toggleSpinner();
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

  //endregion
}

enum ImageContentState {
  addingContentToNew,
  addingContentToExisting,
  viewingTemporaryImageContent,
  viewingUserContent,
  viewingMyContent,
}
