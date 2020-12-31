import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/constants.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/components/listviews/project_contributor_listview.dart';
import 'package:projest/screens/misc/view_project_content_screen.dart';
import 'package:projest/components/listviews/submit_project_complaint_listview.dart';
import 'package:projest/models/objects/project_complaint_reason_object.dart';
import 'package:projest/models/objects/project_complaint_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ViewUserProjectScreen extends StatefulWidget {
  static ProjectObject p;

  static const String id = 'view_user_project_screen';

  @override
  _ViewUserProjectScreenState createState() => _ViewUserProjectScreenState();
}



class _ViewUserProjectScreenState extends State<ViewUserProjectScreen> {
  ImageProvider provider;
  List<ProjectComplaintReasonObject> reasons = [];
  String complaintText;
  TextEditingController descriptionController = TextEditingController(text: ViewUserProjectScreen.p.description);


  @override
  Widget build(BuildContext context) {
    provider = ViewUserProjectScreen.p.thumbnailLink != null &&
            ViewUserProjectScreen.p.thumbnailLink != ""
        ? NetworkImage(ViewUserProjectScreen.p.thumbnailLink)
        : AssetImage('images/default.png');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () async {
                await _presentFlagProjectAlert();
              },
              child: Icon(
                Icons.flag_rounded,
                size: 35,
              ),
            ),
          ),
        ],
        backgroundColor: kPrimaryColor,
        title: Text(ViewUserProjectScreen.p.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.5)),
                elevation: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(
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
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 2.5),
            child: Text(
              'Description',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: Container(
              height: 65,
              child: SingleChildScrollView(
                child: TextField(
                  controller: descriptionController,
                  enabled: false,
                  maxLines: null,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5),
            child: Text(
              'Project Contributors',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            height: 110,
            child: ProjectContributorList(
              project: ViewUserProjectScreen.p,
            ),
          ),
          Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
            child: RoundedButton(
              title: ViewUserProjectScreen.p.checkIfUserHasSubmittedFeedback()
                  ? 'View Content'
                  : 'Review Content',
              color: kPrimaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProjectContentScreen(
                        submittedFeedbackCallback: () {
                          setState(() {});
                        },
                        p: ViewUserProjectScreen.p,
                        state: ViewUserProjectScreen.p
                                    .checkIfUserHasSubmittedFeedback() ==
                                true
                            ? ViewProjectContentScreenState
                                .viewingUserProjectContentRated
                            : ViewProjectContentScreenState
                                .viewingUserProjectContentUnrated),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _presentFlagProjectAlert() async {
    SubmitProjectComplaintListView listView = SubmitProjectComplaintListView(
      onProjectComplaintReasonsChange: (newReasons) {
        List<ProjectComplaintReasonObject> selectedReasons = [];

        for (ProjectComplaintReasonObject reason in newReasons) {
          if (reason.isSelected) {
            selectedReasons.add(reason);
          }
        }

        reasons = selectedReasons;
      },
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text(
            'Submit Project Complaint',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w900,
            ),
          ),
          children: [
            Container(
              width: 200,
              height: 100,
              child: listView,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter additional information',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
                onChanged: (c) {
                  complaintText = c;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 5, 20, 0),
              child: RoundedButton(
                title: 'Submit',
                color: kPrimaryColor,
                onPressed: () async {
                  await submitProjectComplaint();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitProjectComplaint() async {
    if (ViewUserProjectScreen.p.flaggedByUid == null) {
      ViewUserProjectScreen.p.flaggedByUid = [];
    }

    ProjectComplaintObject object = ProjectComplaintObject(
      id: Uuid().v4(),
      timestamp: Timestamp.now(),
      text: complaintText,
      reasons: reasons,
      complaineeUid: ViewUserProjectScreen.p.uid,
      complainerUid: FirebaseAuthHelper.loggedInUser.uid,
      projectId: ViewUserProjectScreen.p.id,
      projectThumbnailUrl: ViewUserProjectScreen.p.thumbnailLink,
      projectTitle: ViewUserProjectScreen.p.title,
      projectDescription: ViewUserProjectScreen.p.description,
    );

    ViewUserProjectScreen.p.flaggedByUid
        .add(FirebaseAuthHelper.loggedInUser.uid);
    FirebaseAuthHelper.loggedInUser.projectComplaintIdArray.add(object.id);

    FirestoreHelper helper = FirestoreHelper();

    await helper.submitProjectComplaint(object);
    await helper.updateProject(ViewUserProjectScreen.p);
    await helper.updateCurrentUser();
  }
}
