import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/models/objects/feedback_object.dart';
import 'package:projest/models/objects/feedback_criteria_object.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:projest/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:projest/screens/searchprojects/view_user_project_screen.dart';

class SubmitFeedbackScreen extends StatefulWidget {
  SubmitFeedbackScreen({this.p, this.submittedFeedbackCallback});

  final ProjectObject p;
  final Function submittedFeedbackCallback;

  static int secondsViewed = 0;
  static List<FeedbackCriteriaObject> criteria;

  @override
  _SubmitFeedbackScreenState createState() => _SubmitFeedbackScreenState();
}

class _SubmitFeedbackScreenState extends State<SubmitFeedbackScreen> {
  @override
  void initState() {
    if (SubmitFeedbackScreen.criteria == null) {
      SubmitFeedbackScreen.criteria = getFeedbackCriteria();
    }
    super.initState();
  }

  List<Text> createTimeDisplay() {
    List<Text> textDisplay = [];

    if (SubmitFeedbackScreen.secondsViewed < 60) {
      textDisplay.add(Text(
        SubmitFeedbackScreen.secondsViewed.toString(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ));
      textDisplay.add(Text(
        SubmitFeedbackScreen.secondsViewed != 1 ? 'Seconds' : 'Second',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ));
    } else {
      textDisplay.add(Text(
        (SubmitFeedbackScreen.secondsViewed / 60).truncate().toString(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ));
      textDisplay.add(Text(
        SubmitFeedbackScreen.secondsViewed < 120 ? 'Minute' : 'Minutes',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ));
    }

    return textDisplay;
  }

  @override
  Widget build(BuildContext context) {
    final double b = MediaQuery.of(context).viewInsets.bottom;

    print('Bottom inset is $b)');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: createTimeDisplay(),
            ),
          ),
        ],
        backgroundColor: kPrimaryColor,
        title: Text('Submit Feedback'),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            bottom: b != 0 ? MediaQuery.of(context).viewInsets.bottom - 60 : 0),
        child: SingleChildScrollView(
          reverse: true,
          child: Container(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(10),
              itemCount: SubmitFeedbackScreen.criteria.length + 1,
              itemBuilder: (context, i) {
                if (i != SubmitFeedbackScreen.criteria.length) {
                  return Card(
                    elevation: 2.0,
                    child: ExpansionTile(
                      title: Row(
                        children: <Widget>[
                          Text(
                            SubmitFeedbackScreen.criteria[i].criteria,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 12.5),
                        ],
                      ),
                      children: <Widget>[
                        new Column(
                          children: _buildExpandableContent(
                              SubmitFeedbackScreen.criteria[i]),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: RoundedButton(
                      title: 'Submit',
                      color: kPrimaryColor,
                      onPressed: () async {
                        widget.p.feedbackArray = [];
                        widget.p.feedbackArray
                            .add(createFeedbackObject().toJson());

                        if (widget.p.ratedByUids == null) {
                          widget.p.ratedByUids = [];
                        }

                        widget.p.ratedByUids
                            .add(FirebaseAuthHelper.loggedInUser.uid);
                        ViewUserProjectScreen.p = widget.p;
                        FirestoreHelper helper = FirestoreHelper();
                        await helper.updateProject(widget.p);
                        Navigator.pop(context);
                        widget.submittedFeedbackCallback();
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  FeedbackObject createFeedbackObject() {
    List<Map<String, dynamic>> criteriaArray = [];

    for (FeedbackCriteriaObject f in SubmitFeedbackScreen.criteria) {
      criteriaArray.add(f.toJson());
    }

    return FeedbackObject(
      senderTokens: FirebaseAuthHelper.loggedInUser.fcmTokens,
      projectImageUrl: widget.p.profileImageLink,
      projectTitle: widget.p.title,
      senderProfileImageUrl: FirebaseAuthHelper.loggedInUser.profileImageLink,
      senderId: FirebaseAuthHelper.loggedInUser.uid,
      senderUsername: FirebaseAuthHelper.loggedInUser.username,
      boosted: widget.p.checkIfProjectIsBoosted(),
      feedback: criteriaArray,
      ratedHelpful: false,
      id: Uuid().v4(),
      rated: false,
      timeStamp: Timestamp.now(),
      uid: widget.p.uid,
      timeSpentReviewing: SubmitFeedbackScreen.secondsViewed,
    );
  }

  List<FeedbackCriteriaObject> getFeedbackCriteria() {
    List<FeedbackCriteriaObject> c = [];

    int index = 0;

    for (String criteria in widget.p.selectedCriteria) {
      c.add(FeedbackCriteriaObject(
          criteria: criteria, text: "", rating: 0, index: index));

      index = index + 1;
    }

    return c;
  }

  List<Widget> _buildExpandableContent(FeedbackCriteriaObject criteriaItem) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 15, left: 15, bottom: 15),
        child: Column(
          children: [
            TextField(
              maxLines: 6,
              textInputAction: TextInputAction.done,
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: criteriaItem.text,
                  selection: TextSelection.fromPosition(TextPosition(
                    offset: criteriaItem.text.length,
                  )),
                ),
              ),
              decoration: kTextFieldDecoration,
              onChanged: (value) {
                SubmitFeedbackScreen.criteria[criteriaItem.index].text = value;
              },
            ),
            SizedBox(height: 15),
            RatingBar(
              itemCount: 5,
              itemSize: 50,
              allowHalfRating: false,
              initialRating:
                  SubmitFeedbackScreen.criteria[criteriaItem.index].rating,
              ratingWidget: RatingWidget(
                full: Icon(
                  Icons.star,
                  color: Colors.orange,
                ),
                empty: Icon(Icons.star_border, color: kLightOrangeCompliment),
              ),
              direction: Axis.horizontal,
              onRatingUpdate: (value) {
                FocusScope.of(context).unfocus();

                setState(() {
                  SubmitFeedbackScreen.criteria[criteriaItem.index].rating =
                      value;
                });
              },
            )
          ],
        ),
      ),
    ];
  }
}
