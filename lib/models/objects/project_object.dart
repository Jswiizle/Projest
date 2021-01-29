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
    this.ownerTokens,
    this.ratedByUids,
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
  List<String> ratedByUids;
  List<Map<String, dynamic>> feedbackArray;
  List<Map<String, dynamic>> blipArray;
  double userPointsToGive;
  String profileImageLink;
  List contributorsUid;
  double projectOwnerAverageResponseTime;
  Timestamp boostedStartTime;
  Timestamp boostedEndTime;
  List<String> ownerTokens;
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
        'ratedByUids': ratedByUids,
        'feedbackArray': feedbackArray,
        'blipArray': blipArray,
        'userPointsToGive': userPointsToGive,
        'contributorsUid': contributorsUid,
        'projectOwnerAverageResponseTime': projectOwnerAverageResponseTime,
        'boostedStartTime': boostedStartTime,
        'boostedEndTime': boostedEndTime,
        'ownerTokens': ownerTokens,
        'flaggedByUid': flaggedByUid,
        'date': date,
      };

  factory ProjectObject.fromJson(Map<String, dynamic> parsedJson) {
    List<Map<String, dynamic>> bArray =
        new List<Map<String, dynamic>>.from(parsedJson['blipArray']);

    List<Map<String, dynamic>> fArray;
    List<String> flaggedArray;
    List<String> ratedByUid;
    List<String> tokens;
    double pointsToGive;

    if (parsedJson['feedbackArray'] != null) {
      fArray = List<Map<String, dynamic>>.from(parsedJson['feedbackArray']);
    }

    if (parsedJson['flaggedByUid'] == null) {
      flaggedArray = [];
    } else {
      flaggedArray = List<String>.from(parsedJson['flaggedByUid']);
    }

    if (parsedJson['ratedByUids'] == null) {
      ratedByUid = [];
    } else {
      ratedByUid = List<String>.from(parsedJson['ratedByUids']);
    }

    if (parsedJson['userPointsToGive'] is int) {
      pointsToGive = (parsedJson['userPointsToGive'] as int).toDouble();
    } else {
      pointsToGive = parsedJson['userPointsToGive'];
    }

    if (parsedJson['ownerTokens'] == null) {
      tokens = [];
    } else {
      tokens = List<String>.from(parsedJson['ownerTokens']);
    }

    return ProjectObject(
      profileImageLink: parsedJson['profileImageLink'],
      title: parsedJson['title'],
      uid: parsedJson['uid'],
      projectOwnerUsername: parsedJson['projectOwnerUsername'],
      category: parsedJson['category'],
      id: parsedJson['id'],
      selectedCriteria: parsedJson['selectedCriteria'],
      ratedByUids: ratedByUid,
      feedbackArray: fArray != null ? fArray : null,
      blipArray: bArray,
      userPointsToGive: pointsToGive,
      contributorsUid: parsedJson['contributorsUid'],
      projectOwnerAverageResponseTime:
          parsedJson['projectOwnerAverageResponseTime'],
      boostedStartTime: parsedJson['boostedStartTime'],
      boostedEndTime: parsedJson['boostedEndTime'],
      ownerTokens: tokens,
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
