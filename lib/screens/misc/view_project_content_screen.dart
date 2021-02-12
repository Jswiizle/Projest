import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/models/objects/blip_object.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:projest/screens/projectcontent/imagecontent.dart';
import 'package:projest/screens/projectcontent/webcontent.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:projest/screens/myprojects/project_content_cover_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:projest/screens/searchprojects/submit_feedback_screen.dart';
import 'dart:async';

class ViewProjectContentScreen extends StatefulWidget {
  ViewProjectContentScreen(
      {this.p, this.state, this.submittedFeedbackCallback});

  final ProjectObject p;
  final ViewProjectContentScreenState state;
  final Function submittedFeedbackCallback;

  @override
  _ViewProjectContentScreenState createState() =>
      _ViewProjectContentScreenState();
}

class _ViewProjectContentScreenState extends State<ViewProjectContentScreen> {
  PageController _controller = PageController(
    initialPage: 0,
  );

  BlipObject currentBlip;
  List<BlipObject> blips = [];
  List<Widget> pages = [];
  double currentIndex = 0;
  ProjectObject project;
  bool loading = false;
  Timer _timer;
  bool timerIsStopped = false;

  @override
  void initState() {
    configureScreen();
    super.initState();
  }

  void configureScreen() {
    if (project == null) {
      project = widget.p;
    }

    if (pages.length == 0) {
      pages = createContentScreenArray(project);
    }

    if (widget.state ==
            ViewProjectContentScreenState.viewingUserProjectContentUnrated &&
        _timer == null) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        SubmitFeedbackScreen.secondsViewed += 1;
        print(
            'Timer called, new time is ${SubmitFeedbackScreen.secondsViewed}');
      });
    }
  }

  @override
  void dispose() {
    SubmitFeedbackScreen.secondsViewed = 0;
    SubmitFeedbackScreen.criteria = null;

    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              children: pages,
              onPageChanged: (index) {
                currentIndex = index.toDouble();

                setState(() {
                  if (widget.state ==
                      ViewProjectContentScreenState.viewingMyProjectContent) {
                    if (index != 0) {
                      currentBlip = blips[index - 1];
                    }
                  } else if (widget.state ==
                          ViewProjectContentScreenState
                              .viewingUserProjectContentUnrated &&
                      currentIndex == pages.length - 1) {
                    timerIsStopped = true;
                    _timer.cancel();
                    _timer = null;
                  } else {
                    if (widget.state ==
                        ViewProjectContentScreenState
                            .viewingUserProjectContentUnrated) {
                      if (timerIsStopped == true) {
                        timerIsStopped = false;

                        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                          SubmitFeedbackScreen.secondsViewed += 1;
                          print(
                              'Timer called, new time is ${SubmitFeedbackScreen.secondsViewed}');
                        });
                      }
                    }
                    currentBlip = blips[index];
                  }
                });
              },
            ),
          ),
          Container(
            height: 55,
            child: DotsIndicator(
              dotsCount: pages.length,
              position: currentIndex,
              axis: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> createContentScreenArray(ProjectObject p) {
    List<Widget> list = [];

    if (widget.state == ViewProjectContentScreenState.viewingMyProjectContent) {
      list.add(
        ProjectContentCoverPage(
          addImageContentCallback: () async {
            BlipObject newBlip = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageContent(
                  state: ImageContentState.addingContentToExisting,
                ),
              ),
            );

            if (newBlip != null) {
              toggleSpinner();

              await updateProject(newBlip);

              setState(() {
                loading = !loading;
                pages = createContentScreenArray(project);
              });
            }
          },
          addWebContentCallback: () async {
            BlipObject newBlip = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebContent(
                  state: WebContentState.addingContentToExisting,
                ),
              ),
            );

            if (newBlip != null) {
              toggleSpinner();

              await updateProject(newBlip);

              setState(() {
                loading = !loading;
                pages = createContentScreenArray(project);
              });
            }
          },
        ),
      );
    }

    blips = [];

    for (var dict in p.blipArray) {
      blips.add(BlipObject.fromJson(dict));
    }

    for (var b in blips) {
      if (b.imageUrl != null && b.imageUrl != "") {
        list.add(ImageContent(
          deleteContentCallback: (BlipObject blipToDelete) {
            deleteContent(blipToDelete);
          },
          blip: b,
          state: determineImageContentState(),
        ));
      } else if (b.url != null && b.url != "") {
        list.add(WebContent(
          deleteContentCallback: (BlipObject blipToDelete) {
            deleteContent(blipToDelete);
          },
          blip: b,
          state: determineWebContentState(),
        ));
        //Blip
      } else {
        print('neither, bad data');
      }
    }

    if (widget.state ==
        ViewProjectContentScreenState.viewingUserProjectContentUnrated) {
      list.add(SubmitFeedbackScreen(
        submittedFeedbackCallback: widget.submittedFeedbackCallback,
        p: p,
      ));
    }

    return list;
  }

  Future<void> deleteContent(BlipObject b) async {
    toggleSpinner();

    if (b.imageUrl != null && b.imageUrl != "") {
      StorageReference ref = FirebaseStorage().ref().child(
          "${FirebaseAuthHelper.loggedInUser.uid}/${project.id}/content/${b.id}");

      await ref.delete();
    }

    blips.remove(b);
    List<Map<String, dynamic>> dictArray = [];

    for (BlipObject b in blips) {
      dictArray.add(b.toJson());
    }

    project.blipArray = dictArray;
    FirestoreHelper helper = FirestoreHelper();
    await helper.updateProject(project);

    setState(() {
      if (currentIndex == (blips.length + 1)) {
        currentIndex = currentIndex - 1;
      }

      loading = !loading;
      pages = createContentScreenArray(project);
    });
  }

  Future<void> updateProject(BlipObject b) async {
    if (b.temporaryImage != null) {
      StorageReference ref = FirebaseStorage().ref().child(
          "${FirebaseAuthHelper.loggedInUser.uid}/${project.id}/content/${b.id}");

      StorageUploadTask task = ref.putFile(b.temporaryImage);
      await task.onComplete;
      b.imageUrl = await ref.getDownloadURL();
    }
    blips.add(b);

    List<Map<String, dynamic>> dictArray = [];

    for (BlipObject blip in blips) {
      dictArray.add(blip.toJson());
    }

    project.blipArray = dictArray;
    FirestoreHelper helper = FirestoreHelper();
    await helper.updateProject(project);
    _controller.jumpToPage(pages.length + 1);
  }

  ImageContentState determineImageContentState() {
    ImageContentState state;

    if (widget.state == ViewProjectContentScreenState.viewingMyProjectContent) {
      state = ImageContentState.viewingMyContent;
    } else {
      state = ImageContentState.viewingUserContent;
    }

    return state;
  }

  WebContentState determineWebContentState() {
    WebContentState state;

    if (widget.state == ViewProjectContentScreenState.viewingMyProjectContent) {
      state = WebContentState.viewingMyContent;
    } else {
      state = WebContentState.viewingUserContent;
    }

    return state;
  }

  void presentDetailsAlert() {
    setState(() {
      AlertHelper alert = AlertHelper(
        choice1: 'Ok',
        title: 'Content Details',
        body: '\n Title: ' +
            currentBlip.title +
            '\n \n Description: ' +
            currentBlip.description,
      );

      alert.generateAlert(context);
    });
  }

  void toggleSpinner() {
    setState(() {
      loading = !loading;
    });
  }
}

enum ViewProjectContentScreenState {
  viewingMyProjectContent,
  viewingUserProjectContentUnrated,
  viewingUserProjectContentRated
}
