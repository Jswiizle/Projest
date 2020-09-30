class UserObject {
  UserObject({
    this.email,
    this.uid,
    this.password,
    this.interestArray,
    this.points,
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
  });

  String email;
  double points;
  String username;
  String profileImageLink;
  String uid;
  String password;
  List preferences;
  List<Map<String, dynamic>> interestArray;
  String bio;
  List<double> feedbackScoreArray;
  DateTime joinDate;
  bool earlyAdopter;
  List<List> feedbackGivenArray;
  String fcmToken;
  List<String> blockedByUid;
  List<String> blockedUsersUid;
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
      };
}

//TODO: Convert join date string to timestamp
