import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/models/objects/feedback_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.flaggedByUid,
    this.ownerToken,
    this.ratedByUID,
    this.selectedCriteria,
    this.boostedEndTime,
    this.boostedStartTime,
    this.userPointsToGive,
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
  List<Map<String, dynamic>> feedbackArray;
  List<Map<String, dynamic>> blipArray;
  double userPointsToGive;
  String profileImageLink;
  List contributorsUid;
  double projectOwnerAverageResponseTime;
  Timestamp boostedStartTime;
  Timestamp boostedEndTime;
  String ownerToken;
  List<String> flaggedByUid;
  Timestamp date;

  Map<String, dynamic> toJson() => {
        'title': title,
        'projectOwnerUsername': projectOwnerUsername,
        'category': category,
        'profileImageLink': profileImageLink,
        'uid': uid,
        'description': description,
        'thumbnailLink': thumbnailLink,
        'id': id,
        'selectedCriteria': selectedCriteria,
        'ratedByUID': ratedByUID,
        'feedbackArray': feedbackArray,
        'blipArray': blipArray,
        'userPointsToGive': userPointsToGive,
        'contributorsUid': contributorsUid,
        'projectOwnerAverageResponseTime': projectOwnerAverageResponseTime,
        'boostedStartTime': boostedStartTime,
        'boostedEndTime': boostedEndTime,
        'ownerToken': ownerToken,
        'flaggedByUid': flaggedByUid,
        'date': date,
      };

  factory ProjectObject.fromJson(Map<String, dynamic> parsedJson) {
    var jsonBArray = parsedJson['blipArray'];
    var jsonFArray = parsedJson['feedbackArray'];
    var jsonFlaggedByUid = parsedJson['flaggedByUid'];

    List<Map<String, dynamic>> bArray =
        new List<Map<String, dynamic>>.from(jsonBArray);

    List<Map<String, dynamic>> fArray;

    if (jsonFArray != null) {
      fArray = List<Map<String, dynamic>>.from(jsonFArray);
    }

    List<String> flaggedArray;

    if (jsonFlaggedByUid == null) {
      flaggedArray = [];
    } else {
      flaggedArray = List<String>.from(jsonFlaggedByUid);
    }

    double pointsToGive;

    if (parsedJson['userPointsToGive'] is int) {
      pointsToGive = (parsedJson['userPointsToGive'] as int).toDouble();
    } else {
      pointsToGive = parsedJson['userPointsToGive'];
    }

    return ProjectObject(
      profileImageLink: parsedJson['profileImageLink'],
      title: parsedJson['title'],
      uid: parsedJson['uid'],
      projectOwnerUsername: parsedJson['projectOwnerUsername'],
      category: parsedJson['category'],
      id: parsedJson['id'],
      selectedCriteria: parsedJson['selectedCriteria'],
      ratedByUID: parsedJson['ratedByUID'],
      feedbackArray: fArray != null ? fArray : null,
      blipArray: bArray,
      userPointsToGive: pointsToGive,
      contributorsUid: parsedJson['contributorsUid'],
      projectOwnerAverageResponseTime:
          parsedJson['projectOwnerAverageResponseTime'],
      boostedStartTime: parsedJson['boostedStartTime'],
      boostedEndTime: parsedJson['boostedEndTime'],
      ownerToken: parsedJson['ownerToken'],
      date: parsedJson['date'],
      description: parsedJson['description'],
      thumbnailLink: parsedJson['thumbnailLink'],
      flaggedByUid: flaggedArray,
    );
  }

  double calculatePointsToGive() {
    double pointsToGive;

    if (this.boostedEndTime != null &&
        this.boostedEndTime.compareTo(Timestamp.now()) > 0) {
      pointsToGive = userPointsToGive * 2;
    } else {
      pointsToGive = userPointsToGive;
    }

    return pointsToGive;
  }

  bool checkForUnratedFeedback() {
    bool _hasUnratedFeedback = false;

    if (feedbackArray != null) {
      for (var feedback in feedbackArray) {
        if (feedback['rated'] == false) {
          _hasUnratedFeedback = true;
        }
      }
    }

    return _hasUnratedFeedback;
  }

  List<FeedbackObject> getFeedbackObjectList() {
    List<FeedbackObject> list = [];

    if (feedbackArray != null) {
      for (var feedback in feedbackArray) {
        FeedbackObject f = FeedbackObject.fromJson(feedback);
        list.add(f);
      }
    }

    return list;
  }

  bool checkIfUserHasSubmittedFeedback() {
    bool submitted = false;

    if (feedbackArray != null && feedbackArray.length > 0) {
      for (var feedback in feedbackArray) {
        if (feedback['senderId'] == FirebaseAuthHelper.loggedInUser.uid) {
          submitted = true;
        }
      }
    }

    return submitted;
  }

  bool checkIfProjectIsBoosted() {
    bool boosted;

    if (boostedEndTime != null &&
        boostedEndTime.compareTo(Timestamp.now()) > 0) {
      boosted = true;
    } else {
      boosted = false;
    }

    return boosted;
  }
}
