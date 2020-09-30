import 'package:flutter/material.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/models/objects/feedback_object.dart';
import 'package:projest/constants.dart';
import 'package:projest/screens/myprojects/incoming_feedback_screen.dart';

class ViewMyProjectScreen extends StatefulWidget {
  ViewMyProjectScreen();

  static const String id = 'view_my_project_screen';

  @override
  _ViewMyProjectScreenState createState() => _ViewMyProjectScreenState();
}

class _ViewMyProjectScreenState extends State<ViewMyProjectScreen> {
  @override
  Widget build(BuildContext context) {
    final ProjectObject p = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(p.title),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Card(
                  elevation: 8,
                  child: Image(
                    image: NetworkImage(p.thumbnailLink),
                    width: 320,
                    height: 180,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
              child: Text(
                'Description',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    p.description,
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
              child: Text(
                'Incoming Feedback',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
            FeedbackList(project: p),
          ],
        ),
      ),
    );
  }
}

class FeedbackList extends StatelessWidget {
  FeedbackList({@required this.project});

  final ProjectObject project;

  @override
  Widget build(BuildContext context) {
    List<FeedbackObject> feedbacks = project.getFeedbackObjectList();
    List<FeedbackTile> tiles = [];

    for (FeedbackObject f in feedbacks) {
      print(f);
      tiles.add(FeedbackTile(
        feedback: f,
      ));
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 20.0),
      shrinkWrap: true,
      children: tiles,
    );
  }
}

class FeedbackTile extends StatelessWidget {
  FeedbackTile({this.feedback});
  final FeedbackObject feedback;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, IncomingFeedbackScreen.id,
                arguments: feedback);
          },
          trailing: feedback.rated
              ? null
              : Icon(Icons.feedback, color: kLightOrangeCompliment),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(feedback.senderProfileImageUrl),
          ),
          title: Text(
            feedback.senderUsername,
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            feedback.timeStamp,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
      ),
    );
  }
}
