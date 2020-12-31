import 'package:flutter/material.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/models/objects/feedback_object.dart';
import 'package:projest/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/models/objects/feedback_criteria_object.dart';
import 'package:projest/models/objects/user_object.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/screens/myprojects/view_my_project_screen.dart';
import 'package:projest/helpers/alert_helper.dart';

class ViewReceivedFeedbackScreen extends StatefulWidget {
  ViewReceivedFeedbackScreen({this.f, this.state});

  static const String id = 'incoming_feedback_screen';

  final FeedbackObject f;
  final ViewReceivedFeedbackScreenState state;

  @override
  _ViewReceivedFeedbackScreenState createState() =>
      _ViewReceivedFeedbackScreenState();
}

class _ViewReceivedFeedbackScreenState
    extends State<ViewReceivedFeedbackScreen> {
  bool loading = false;
  String digitString;
  String unitsString;
  List<FeedbackCriteriaObject> _criteria;

  @override
  Widget build(BuildContext context) {
    _criteria = getFeedbackCriteria();

    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 15, 5),
              child: GestureDetector(
                onTap: () {
                  AlertHelper helper = AlertHelper(
                      title: 'Time Spent Reviewing',
                      body:
                          '${widget.f.senderUsername} reviewed your project for $digitString $unitsString');
                  helper.generateAlert(context);
                },
                child: Column(
                  children: createTimeDisplay(),
                ),
              ),
            ),
          ],
          backgroundColor: kPrimaryColor,
          title: Text('View Feedback'),
        ),
        body: Column(children: createWidgetList()),
      ),
    );
  }

  List<Widget> createWidgetList() {
    List<Widget> list = [];

    switch (widget.state) {
      case ViewReceivedFeedbackScreenState.unrated:
        list.add(
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _criteria.length,
              itemBuilder: (context, i) {
                return Card(
                  elevation: 10.0,
                  child: ExpansionTile(
                    title: Row(
                      children: <Widget>[
                        Text(
                          _criteria[i].criteria,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        RatingBar(
                          itemCount: 5,
                          itemSize: 20,
                          ignoreGestures: true,
                          allowHalfRating: false,
                          initialRating: _criteria[i].rating,
                          ratingWidget: RatingWidget(
                            full: Icon(
                              Icons.star,
                              color: Colors.orange,
                            ),
                            empty: Icon(Icons.star_border,
                                color: kLightOrangeCompliment),
                          ),
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _buildExpandableContent(_criteria[i]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        list.add(
          SizedBox(height: 20)
        );
        list.add(
          Text(
            'Was This Feedback Helpful?',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
        );
        list.add(
          Padding(
            padding: const EdgeInsets.only(
                left: 40.0, right: 40.0, bottom: 20.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: RoundedButton(
                    onPressed: () async {
                      FeedbackObject _mutableFeedback = widget.f;

                      _mutableFeedback.rated = true;
                      _mutableFeedback.ratedHelpful = true;

                      List<FeedbackObject> feedbacks =
                          ViewMyProjectScreen.p.getFeedbackObjectList();

                      FeedbackObject toRemove;

                      for (FeedbackObject f in feedbacks) {
                        if (f.id == _mutableFeedback.id) {
                          toRemove = f;
                        }
                      }

                      feedbacks.remove(toRemove);
                      feedbacks.add(_mutableFeedback);

                      ViewMyProjectScreen.p.feedbackArray =
                          convertFeedbackArray(feedbacks);

                      FirestoreHelper helper = FirestoreHelper();
                      toggleSpinner();
                      await helper.updateProject(ViewMyProjectScreen.p);

                      UserObject user =
                          await helper.getUser(_mutableFeedback.senderId);

                      double oldPointsToGive = user.pointsToGive();

                      if (_mutableFeedback.boosted == true) {
                        user.credits = user.credits +
                            (FirebaseAuthHelper.loggedInUser.pointsToGive() *
                                2);
                        user.points = user.points +
                            (FirebaseAuthHelper.loggedInUser.pointsToGive() *
                                2);
                      } else {
                        user.credits = user.credits +
                            FirebaseAuthHelper.loggedInUser.pointsToGive();
                        user.points = user.points +
                            FirebaseAuthHelper.loggedInUser.pointsToGive();
                      }

                      if (user.pointsToGive() > oldPointsToGive) {
                        print(
                            'Called: Old points is $oldPointsToGive new points is ${user.pointsToGive()}');

                        await helper.updateProjectsWithNewUserPointsToGive(
                            user.uid, user.pointsToGive());
                      }

                      await helper.updateUser(user);

                      toggleSpinner();
                      Navigator.pop(context);
                    },
                    title: 'Yes',
                    color: kPrimaryColor,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: RoundedButton(
                    title: 'No',
                    color: kLightOrangeCompliment,
                    onPressed: () async {
                      FeedbackObject _mutableFeedback = widget.f;

                      _mutableFeedback.rated = true;
                      _mutableFeedback.ratedHelpful = true;

                      List<FeedbackObject> feedbacks =
                          ViewMyProjectScreen.p.getFeedbackObjectList();

                      FeedbackObject toRemove;

                      for (FeedbackObject f in feedbacks) {
                        if (f.id == _mutableFeedback.id) {
                          toRemove = f;
                        }
                      }

                      feedbacks.remove(toRemove);

                      feedbacks.add(_mutableFeedback);
                      ViewMyProjectScreen.p.feedbackArray =
                          convertFeedbackArray(feedbacks);

                      FirestoreHelper helper = FirestoreHelper();
                      toggleSpinner();
                      await helper.updateProject(ViewMyProjectScreen.p);
                      toggleSpinner();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      case ViewReceivedFeedbackScreenState.rated:
        list.add(
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: _criteria.length,
              itemBuilder: (context, i) {
                return Card(
                  elevation: 2.0,
                  child: ExpansionTile(
                    title: Row(
                      children: <Widget>[
                        Text(
                          _criteria[i].criteria,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        RatingBar(
                          itemCount: 5,
                          itemSize: 16,
                          ignoreGestures: true,
                          allowHalfRating: false,
                          initialRating: _criteria[i].rating,
                          ratingWidget: RatingWidget(
                            full: Icon(
                              Icons.star,
                              color: Colors.orange,
                            ),
                            empty: Icon(Icons.star_border,
                                color: kLightOrangeCompliment),
                          ),
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _buildExpandableContent(_criteria[i]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        list.add(
          Text(
            'You rated this feedback',
            style: TextStyle(
              fontSize: 21.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
        );
        list.add(
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.f.ratedHelpful == true ? "Helpful" : "Unhelpful",
                  style: TextStyle(
                    fontSize: 21.5,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  widget.f.ratedHelpful == true
                      ? Icons.thumb_up
                      : Icons.thumb_down,
                  color:
                      widget.f.ratedHelpful == true ? Colors.green : Colors.red,
                )
              ],
            ),
          ),
        );
    }

    return list;
  }

  List<Text> createTimeDisplay() {
    List<Text> textDisplay = [];

    if (widget.f.timeSpentReviewing < 60) {
      digitString = widget.f.timeSpentReviewing.toString();
      unitsString = widget.f.timeSpentReviewing < 2 ? 'Second' : 'Seconds';

      textDisplay.add(Text(
        digitString,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ));
      textDisplay.add(Text(
        widget.f.timeSpentReviewing != 1 ? 'Seconds' : 'Second',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ));
    } else {
      digitString = (widget.f.timeSpentReviewing / 60).truncate().toString();
      unitsString = widget.f.timeSpentReviewing < 120 ? 'Minute' : 'Minutes';

      textDisplay.add(Text(
        digitString,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ));
      textDisplay.add(Text(
        unitsString,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ));
    }

    return textDisplay;
  }

  List<Map<String, dynamic>> convertFeedbackArray(
      List<FeedbackObject> objects) {
    List<Map<String, dynamic>> newList = [];

    for (FeedbackObject obj in objects) {
      newList.add(obj.toJson());
    }

    return newList;
  }

  List<FeedbackCriteriaObject> getFeedbackCriteria() {
    List<FeedbackCriteriaObject> c = [];

    for (var criteria in widget.f.feedback) {
      c.add(FeedbackCriteriaObject.fromJson(criteria));
    }

    return c;
  }

  List<Widget> _buildExpandableContent(FeedbackCriteriaObject criteriaItem) {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 17.5),
        child: Text(
          criteriaItem.text,
          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w400),
        ),
      ),
    ];
  }

  void toggleSpinner() {
    setState(() {
      loading = !loading;
    });
  }
}

enum ViewReceivedFeedbackScreenState {
  rated,
  unrated,
}
