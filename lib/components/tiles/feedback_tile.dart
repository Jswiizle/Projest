import 'package:flutter/material.dart';
import 'package:projest/models/objects/feedback_object.dart';
import 'package:projest/constants.dart';
import 'package:intl/intl.dart';

class FeedbackTile extends StatelessWidget {
  FeedbackTile({this.feedback, this.onTap});
  final FeedbackObject feedback;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        trailing: feedback.rated
            ? null
            : Icon(Icons.feedback, color: kLightOrangeCompliment),
        leading: CircleAvatar(
          backgroundImage: feedback.senderProfileImageUrl != null
              ? NetworkImage(feedback.senderProfileImageUrl)
              : AssetImage('images/profile.png'),
        ),
        title: Text(
          feedback.senderUsername,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          createDateString(),
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w100,
          ),
        ),
      ),
    );
  }

  String createDateString() {
    int hoursBetween =
        feedback.timeStamp.toDate().difference(DateTime.now()).inHours;

    if (hoursBetween > 23) {
      return DateFormat().add_yMMMd().format(feedback.timeStamp.toDate());
    } else {
      return DateFormat.jm().format(feedback.timeStamp.toDate());
    }
  }
}
