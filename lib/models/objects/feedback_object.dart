import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackObject {
  FeedbackObject({
    this.feedback,
    this.senderId,
    this.uid,
    this.rated,
    this.id,
    this.senderUsername,
    this.senderProfileImageUrl,
    this.senderTokens,
    this.timeStamp,
    this.ratedTimestamp,
    this.timeSpentReviewing,
    this.boosted,
    this.earlyAdopter,
    this.projectTitle,
    this.projectImageUrl,
    this.ratedHelpful,
  });

  List<dynamic> feedback;
  String uid;
  bool rated;
  String id;
  String senderUsername;
  List<String> senderTokens;
  String senderId;
  String senderProfileImageUrl;
  Timestamp timeStamp;
  Timestamp ratedTimestamp;
  int timeSpentReviewing;
  bool boosted;
  bool earlyAdopter;
  String projectTitle;
  String projectImageUrl;
  bool ratedHelpful;

  Map<String, dynamic> toJson() => {
        'feedback': feedback,
        'senderId': senderId,
        'uid': uid,
        'rated': rated,
        'id': id,
        'senderUsername': senderUsername,
        'senderProfileImageUrl': senderProfileImageUrl,
        'senderTokens': senderTokens,
        'timeStamp': timeStamp,
        'ratedTimestamp': ratedTimestamp,
        'timeSpentReviewing': timeSpentReviewing,
        'boosted': boosted,
        'earlyAdopter': earlyAdopter,
        'projectTitle': projectTitle,
        'projectImageUrl': projectImageUrl,
        'ratedHelpful': ratedHelpful,
      };

  factory FeedbackObject.fromJson(Map<String, dynamic> parsedJson) {
    List<dynamic> jsonFArray = parsedJson['feedback'];
    List<String> tokens;

    if (parsedJson['ownerTokens'] == null) {
      tokens = [];
    } else {
      tokens = List<String>.from(parsedJson['ownerTokens']);
    }

    return FeedbackObject(
      feedback: jsonFArray,
      senderId: parsedJson['senderId'],
      uid: parsedJson['uid'],
      rated: parsedJson['rated'],
      senderUsername: parsedJson['senderUsername'],
      id: parsedJson['id'],
      senderProfileImageUrl: parsedJson['senderProfileImageUrl'],
      senderTokens: tokens,
      timeStamp: parsedJson['timeStamp'],
      ratedTimestamp: parsedJson['ratedTimestamp'],
      timeSpentReviewing: parsedJson['timeSpentReviewing'],
      boosted: parsedJson['boosted'],
      earlyAdopter: parsedJson['earlyAdopter'],
      projectTitle: parsedJson['projectTitle'],
      projectImageUrl: parsedJson['projectImageUrl'],
      ratedHelpful: parsedJson['ratedHelpful'],
    );
  }
}
