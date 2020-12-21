import 'package:flutter/material.dart';
import 'package:projest/models/objects/feedback_object.dart';
import 'package:projest/components/tiles/feedback_tile.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/screens/myprojects/view_received_feedback_screen.dart';

class FeedbackListView extends StatelessWidget {
  FeedbackListView({@required this.project, @required this.refreshCallback});

  final ProjectObject project;
  final Function refreshCallback;

  @override
  Widget build(BuildContext context) {
    List<FeedbackObject> feedbacks = project.getFeedbackObjectList();
    List<FeedbackTile> tiles = [];

    for (FeedbackObject f in feedbacks) {
      tiles.add(FeedbackTile(
        feedback: f,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewReceivedFeedbackScreen(
                      state: f.rated == true
                          ? ViewReceivedFeedbackScreenState.rated
                          : ViewReceivedFeedbackScreenState.unrated,
                      f: f,
                    ),
                fullscreenDialog: true),
          ).then((value) {
            refreshCallback();
          });
        },
      ));
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 20.0),
      shrinkWrap: true,
      children: tiles,
    );
  }
}
