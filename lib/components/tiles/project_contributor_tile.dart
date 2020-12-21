import 'package:flutter/material.dart';
import 'package:projest/constants.dart';
import 'package:projest/models/objects/project_object.dart';

class ProjectContributorTile extends StatelessWidget {
  ProjectContributorTile({@required this.project, @required this.onTap});
  final ProjectObject project;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: kDarkBlueCompliment,
                  radius: 26,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: project.profileImageLink != null &&
                            project.profileImageLink != ""
                        ? NetworkImage(project.profileImageLink)
                        : AssetImage('images/profile.png'),
                  ),
                ),
                SizedBox(
                  height: 7.5,
                ),
                Text(
                  project.projectOwnerUsername != null
                      ? project.projectOwnerUsername
                      : "",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
