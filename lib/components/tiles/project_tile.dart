import 'package:flutter/material.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/constants.dart';

class ProjectTile extends StatelessWidget {
  ProjectTile({this.project, this.onTap, this.onLongPress, this.state});
  final ProjectObject project;
  final Function onTap;
  final Function onLongPress;
  final ProjectTileState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.only(right: 6),
        onTap: onTap,
        onLongPress: onLongPress,
        trailing: Padding(
          padding: const EdgeInsets.only(right: 5),
          child: configureTrailingIcon(),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(
                image: project.thumbnailLink != null &&
                        project.thumbnailLink != "" &&
                        project.thumbnailLink != " "
                    ? NetworkImage(project.thumbnailLink)
                    : AssetImage('images/default.png'),
              ),
            ),
          ),
        ),
        title: Text(
          project.title,
          maxLines: 1,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          project.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }

  Widget configureTrailingIcon() {
    Widget trailing;

    switch (state) {
      case ProjectTileState.viewingMyProject:
        trailing = Icon(
          project.checkForUnratedFeedback()
              ? Icons.notifications
              : Icons.notifications_none,
          size: 32.5,
          color: project.checkForUnratedFeedback()
              ? kLightOrangeCompliment
              : Colors.grey.withOpacity(0.25),
        );
        break;
      case ProjectTileState.viewingUserProject:
        trailing = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              project.checkIfUserHasSubmittedFeedback()
                  ? Icons.rate_review
                  : Icons.rate_review_outlined,
              size: 17,
              color: Colors.black26,
            ),
            SizedBox(height: 1),
            generateCategoryIcon(),
            SizedBox(height: 1),
            Text(
              createPointsToGiveString(),
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black26),
            ),
          ],
        );
        break;
      default: break;

    }

    return trailing;
  }

  String createPointsToGiveString() {
    String string;

    if (project.checkIfProjectIsBoosted()) {
      string = (project.userPointsToGive * 2).truncate().toString();
    } else {
      string = project.userPointsToGive.truncate().toString();
    }
    return string;
  }

  Icon generateCategoryIcon() {
    Icon icon;

    if (project.category == 'Music') {
      icon = Icon(
        Icons.music_note,
        size: 17,
        color: Colors.black26,
      );
    } else if (project.category == 'Art') {
      icon = Icon(
        Icons.palette,
        size: 17,
        color: Colors.black26,
      );
    } else if (project.category == 'Design') {
      icon = Icon(
        Icons.architecture,
        size: 17,
        color: Colors.black26,
      );
    } else if (project.category == 'Podcasting') {
      icon = Icon(
        Icons.mic,
        size: 17,
        color: Colors.black26,
      );
    } else if (project.category == 'Video') {
      icon = Icon(
        Icons.video_collection,
        size: 17,
        color: Colors.black26,
      );
    } else if (project.category == 'Coding') {
      icon = Icon(
        Icons.code,
        size: 17,
        color: Colors.black26,
      );
    } else if (project.category == 'Marketing') {
      icon = Icon(
        Icons.business,
        size: 17,
        color: Colors.black26,
      );
    } else if (project.category == 'Writing') {
      icon = Icon(
        Icons.book,
        size: 17,
        color: Colors.black26,
      );
    } else {
      return null;
    }

    return icon;
  }
}

enum ProjectTileState { viewingMyProject, viewingUserProject, viewingProjectsOnUserProfile }
