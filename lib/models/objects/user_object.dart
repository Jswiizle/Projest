import 'package:cloud_firestore/cloud_firestore.dart';

class UserObject {
  UserObject(
      {this.email,
      this.uid,
      this.password,
      this.interestArray,
      this.points,
      this.credits,
      this.username,
      this.earlyAdopter,
      this.bio,
      this.blockedByUid,
      this.blockedUsersUid,
      this.facebookUrl,
      this.fcmToken,
      this.feedbackGivenArray,
      this.feedbackScoreArray,
      this.instagramUrl,
      this.joinDate,
      this.preferences,
      this.profileImageLink,
      this.twitterUrl,
      this.youtubeUrl,
      this.projectComplaintIdArray});

  String email;
  double points;
  double credits;
  String username;
  String profileImageLink;
  String uid;
  String password;
  List preferences;
  List<Map<String, dynamic>> interestArray;
  String bio;
  List<double> feedbackScoreArray;
  Timestamp joinDate;
  bool earlyAdopter;
  List<List> feedbackGivenArray;
  String fcmToken;
  List<String> blockedByUid;
  List<String> blockedUsersUid;
  List<String> projectComplaintIdArray;
  String youtubeUrl;
  String facebookUrl;
  String instagramUrl;
  String twitterUrl;

  Map<String, dynamic> toJson() => {
        'email': email,
        'points': points,
        'username': username,
        'profileImageLink': profileImageLink,
        'uid': uid,
        'password': password,
        'preferences': preferences,
        'interestArray': interestArray,
        'bio': bio,
        'feedbackScoreArray': feedbackScoreArray,
        'joinDate': joinDate,
        'earlyAdopter': earlyAdopter,
        'feedbackGivenArray': feedbackGivenArray,
        'fcmToken': fcmToken,
        'blockedByUid': blockedByUid,
        'blockedUsersUid': blockedUsersUid,
        'youtubeUrl': youtubeUrl,
        'facebookUrl': facebookUrl,
        'instagramUrl': instagramUrl,
        'twitterUrl': twitterUrl,
        'credits': credits,
        'projectComplaintIdArray': projectComplaintIdArray
      };

  factory UserObject.fromJson(Map<String, dynamic> parsedJson) {
    var jsonInterestArray = parsedJson['interestArray'];

    List<Map<String, dynamic>> array =
        new List<Map<String, dynamic>>.from(jsonInterestArray);

    double credits;
    double points;

    List<String> blockedUsersUid = [];
    List<String> blockedByUid = [];
    List<String> projectComplaintIdArray = [];

    if (parsedJson['blockedUsersUid'] != null) {
      blockedUsersUid = new List<String>.from(parsedJson['blockedUsersUid']);
    }

    if (parsedJson['blockedByUid'] != null) {
      blockedByUid = new List<String>.from(parsedJson['blockedByUid']);
    }

    if (parsedJson['projectComplaintIdArray'] != null) {
      projectComplaintIdArray =
          new List<String>.from(parsedJson['projectComplaintIdArray']);
    }

    if (parsedJson['credits'] is String) {
      credits = double.parse(parsedJson['credits']);
    } else if (parsedJson['credits'] is int) {
      credits = (parsedJson['credits'] as int).toDouble();
    } else {
      credits = parsedJson['credits'];
    }

    if (parsedJson['points'] is String) {
      points = double.parse(parsedJson['points']);
    } else if (parsedJson['points'] is int) {
      points = (parsedJson['points'] as int).toDouble();
    } else {
      points = parsedJson['points'];
    }

    return UserObject(
      profileImageLink: parsedJson['profileImageLink'],
      email: parsedJson['email'],
      uid: parsedJson['uid'],
      interestArray: array,
      joinDate: parsedJson['joinDate'],
      youtubeUrl: parsedJson['youtubeUrl'],
      points: points,
      credits: credits,
      username: parsedJson['username'],
      password: parsedJson['password'],
      bio: parsedJson['bio'],
      feedbackScoreArray: parsedJson['feedbackScoreArray'],
      earlyAdopter: parsedJson['earlyAdopter'],
      feedbackGivenArray: parsedJson['feedbackGivenArray'],
      fcmToken: parsedJson['fcmToken'],
      blockedByUid: blockedByUid,
      blockedUsersUid: blockedUsersUid,
      projectComplaintIdArray: projectComplaintIdArray,
      facebookUrl: parsedJson['facebookUrl'],
      instagramUrl: parsedJson['instagramUrl'],
      twitterUrl: parsedJson['twitterUrl'],
    );
  }

  double pointsToGive() {
    double p;

    if (points < 5) {
      p = 1;
    } else if (points < 10) {
      p = 1.5;
    } else if (points < 20) {
      p = 2;
    } else if (points < 50) {
      p = 3;
    } else if (points < 100) {
      p = 4;
    } else {
      p = 5;
    }

    return p;
  }

  int getLevel() {
    int level;

    if (points < 5) {
      level = 1;
    } else if (points < 10) {
      level = 2;
    } else if (points < 20) {
      level = 3;
    } else if (points < 50) {
      level = 4;
    } else if (points < 100) {
      level = 5;
    } else {
      level = 6;
    }

    return level;
  }
}
