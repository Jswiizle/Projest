import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:projest/screens/myprojects/view_my_project_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/constants.dart';
import 'package:projest/models/objects/blip_object.dart';
import 'package:uuid/uuid.dart';
import 'package:projest/helpers/firebase_helper.dart';

class WebContent extends StatefulWidget {
  static const String id = 'web_content';

  final WebContentState state;
  final BlipObject blip;
  final Function deleteContentCallback;

  WebContent({@required this.state, this.blip, this.deleteContentCallback});

  @override
  _WebContentState createState() => _WebContentState();
}

class _WebContentState extends State<WebContent> {
  String webViewUrl;
  WebViewController _webViewController;
  BlipObject _newBlip;
  bool loading = false;
  List<GestureDetector> appBarActions;

  @override
  void initState() {
    configureMisc();
    setScreenTitle();
    appBarActions = createAppBarActions();
    super.initState();
  }

  //TODO: Add config logic for viewing temporary web content - use image content as example

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
        body: WebView(
          initialUrl: webViewUrl,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
          },
        ),
        floatingActionButton: configureFloatingActionButton(),
      ),
    );
  }

  void configureMisc() {
    switch (widget.state) {
      case WebContentState.addingContentToNew:
      case WebContentState.addingContentToExisting:
        WidgetsBinding.instance.addPostFrameCallback((_) => _showUrlDialogue());
        break;
      case WebContentState.viewingMyContent:
      case WebContentState.viewingTemporaryWebContent:
      case WebContentState.viewingUserContent:
        webViewUrl = widget.blip.url;
        break;
      default:
        break;
    }
  }

  List<GestureDetector> createAppBarActions() {
    List<GestureDetector> actions = [];

    switch (widget.state) {
      case WebContentState.viewingMyContent:
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
      case WebContentState.addingContentToNew:
      case WebContentState.addingContentToExisting:
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
              _showUrlDialogue();
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

  Text setScreenTitle() {
    Text title;

    switch (widget.state) {
      case WebContentState.addingContentToNew:
      case WebContentState.addingContentToExisting:
        title = Text('Add Web Content');
        break;
      default:
        title = Text('Web Content');
        break;
    }

    return title;
  }

  Future<void> _showUrlDialogue() async {
    TextField _textField = TextField(
      onChanged: (value) {
        webViewUrl = value;
      },
      decoration: kTextFieldDecoration.copyWith(hintText: 'ex: www.google.com'),
    );

    await showDialog(
      context: context,
      builder: (BuildContext cText) {
        return SimpleDialog(
          title: Text(
            setUrlDialogueTitle(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Container(
              width: 200,
              height: 75,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _textField,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 2.5,
              ),
              child: RoundedButton(
                title: setUrlDialogueButtonTitle(),
                color: kPrimaryColor,
                onPressed: () {
                  Navigator.pop(context);
                  handleRetrievedUrl(webViewUrl.cleanUrl());
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String setUrlDialogueTitle() {
    String title;

    if (widget.state == WebContentState.viewingMyContent) {
      title = 'Enter a New Url';
    } else {
      title = 'Enter a Url';
    }

    return title;
  }

  String setUrlDialogueButtonTitle() {
    String title;

    if (widget.state == WebContentState.viewingMyContent) {
      title = 'Save';
    } else {
      title = 'Preview';
    }

    return title;
  }

  void presentDetailsAlert() {
    setState(() {
      AlertHelper alert = AlertHelper(
        choice1: 'Ok',
        title: 'Content Details',
        body: '\n Description: ' +
            widget.blip.description +
            '\n \n Title: ' +
            widget.blip.title +
            '\n \n URL: ' +
            widget.blip.url,
      );

      alert.generateAlert(context);
    });
  }

  Future<void> _showEditDetailsDialogue() async {
    if (_newBlip == null) {
      _newBlip = widget.blip;
    }

    TextEditingController titleController =
        TextEditingController(text: _newBlip.title);
    TextEditingController descriptionController =
        TextEditingController(text: _newBlip.description);

    TextField _titleTextField = TextField(
      onChanged: (value) {
        _newBlip.title = value;
      },
      controller: titleController,
      decoration:
          kTextFieldDecoration.copyWith(hintText: 'Enter content title'),
    );

    TextField _descriptionTextField = TextField(
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
                    child: _titleTextField,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                    child: _descriptionTextField,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20
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

  Future<void> updateUrl(String url) async {
    toggleSpinner();

    webViewUrl = url;
    widget.blip.url = webViewUrl;
    _webViewController.loadUrl(webViewUrl);

    List<BlipObject> array = createBlipArray();

    for (BlipObject b in array) {
      if (b.id == widget.blip.id) {
        b.url = url;
      }
    }

    List<Map<String, dynamic>> list = [];

    for (BlipObject b in array) {
      list.add(b.toJson());
    }

    ViewMyProjectScreen.p.blipArray = list;
    FirestoreHelper helper = FirestoreHelper();

    await helper.updateProject(ViewMyProjectScreen.p);

    toggleSpinner();
  }

  void handleRetrievedUrl(String url) async {
    switch (widget.state) {
      case WebContentState.viewingMyContent:
        await updateUrl(url);
        break;
      case WebContentState.addingContentToNew:
      case WebContentState.addingContentToExisting:
        setState(() {
          webViewUrl = url;
          _webViewController.loadUrl(webViewUrl);
        });
        break;
      default:
        break;
    }
  }

  FloatingActionButton configureFloatingActionButton() {
    FloatingActionButton button;

    switch (widget.state) {
      case WebContentState.viewingMyContent:
        button = FloatingActionButton.extended(
          onPressed: () {
            _showUrlDialogue();
          },
          label: Text(
            'Change URL',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: Icon(Icons.link),
          backgroundColor: kPrimaryColor,
          elevation: 8.0,
        );
        break;
      case WebContentState.addingContentToNew:
      case WebContentState.addingContentToExisting:
        if (webViewUrl != null) {
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

  void toggleSpinner() {
    setState(() {
      loading = !loading;
    });
  }

  List<BlipObject> createBlipArray() {
    List<BlipObject> array = [];

    for (var dict in ViewMyProjectScreen.p.blipArray) {
      array.add(BlipObject.fromJson(dict));
    }

    return array;
  }

  Future<void> _showCompletionDialogue() async {
    String _title;
    String _description;

    TextField _titleTextField = TextField(
      onChanged: (value) {
        _title = value;
      },
      decoration:
          kTextFieldDecoration.copyWith(hintText: 'Enter content title'),
    );

    TextField _descriptionTextField = TextField(
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
                    child: _titleTextField,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                    child: _descriptionTextField,
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
                        setState(() {
                          createBlipAndPassData(_title, _description);
                        });
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

  void createBlipAndPassData(String title, String description) {
    BlipObject blip;

    blip = BlipObject(
      title: title,
      description: description,
      url: webViewUrl.cleanUrl(),
      id: Uuid().v4(),
    );

    Navigator.pop(context);
    Navigator.pop(context, blip);
  }
}

enum WebContentState {
  addingContentToNew,
  addingContentToExisting,
  viewingTemporaryWebContent,
  viewingMyContent,
  viewingUserContent,
  viewingArticle,
  addingArticle,
}
