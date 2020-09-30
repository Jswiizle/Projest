import 'package:projest/models/objects/feedback_object.dart';

class ProjectObject {
  ProjectObject({
    this.title,
    this.projectOwnerUsername,
    this.category,
    this.description,
    this.thumbnailLink,
    this.feedbackArray,
    this.uid,
    this.date,
    this.profileImageLink,
    this.blipArray,
    this.projectOwnerAverageResponseTime,
    this.id,
    this.contributorsUid,
    this.featured,
    this.flaggedByUid,
    this.onWaitingList,
    this.ownerToken,
    this.ratedByUID,
    this.selectedCriteria,
    this.sponsoredEndTime,
    this.sponsoredStartTime,
    this.userScore,
  });

  String projectOwnerUsername;
  String title;
  String category;
  String description;
  String thumbnailLink;
  String uid;
  String id;
  List selectedCriteria;
  List ratedByUID;
  List<dynamic> feedbackArray;
  List<Map<String, dynamic>> blipArray;
  double userScore;
  String profileImageLink;
  bool featured;
  List contributorsUid;
  double projectOwnerAverageResponseTime;
  DateTime sponsoredStartTime;
  DateTime sponsoredEndTime;
  bool onWaitingList;
  String ownerToken;
  List flaggedByUid;
  DateTime date;

  bool checkForUnratedFeedback() {
    bool _hasUnratedFeedback = false;
    for (var feedback in feedbackArray) {
      if (feedback['rated'] == false) {
        _hasUnratedFeedback = true;
      }
    }
    return _hasUnratedFeedback;
  }

  List<FeedbackObject> getFeedbackObjectList() {
    List<FeedbackObject> list = [];

    for (var feedback in feedbackArray) {
      print(feedback);

      List<dynamic> feed = feedback['feedback'];

      FeedbackObject f = FeedbackObject(
        feedback: feed,
        senderUsername: feedback['senderUsername'],
        senderProfileImageUrl: feedback['senderProfileImageUrl'],
        rated: feedback['rated'],
        timeStamp: feedback['timeStamp'],
      );

      list.add(f);
    }

    return list;
  }
}

//TODO: Convert timestamp string into timestamp
