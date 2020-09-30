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
    this.sponsored,
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
  String timeStamp;
  String ratedTimestamp;
  int timeSpentReviewing;
  bool sponsored;
  bool earlyAdopter;
  String projectTitle;
  String projectImageUrl;
  bool ratedHelpful;
}

//TODO: Change timestamp string to firebase timestamp
//TODO: Refactor so I can serialize from a map
