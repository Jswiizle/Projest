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
  String senderId;
  String uid;
  bool rated;
  String id;
  String senderUsername;
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

    return FeedbackObject(
      feedback: jsonFArray,
      senderId: parsedJson['senderId'],
      uid: parsedJson['uid'],
      rated: parsedJson['rated'],
      senderUsername: parsedJson['senderUsername'],
      id: parsedJson['id'],
      senderProfileImageUrl: parsedJson['senderProfileImageUrl'],
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
