import 'package:flutter/material.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/components/tiles/project_contributor_tile.dart';
import 'package:projest/models/objects/user_object.dart';
import 'package:projest/screens/searchprojects/view_profile_screen.dart';
import 'package:projest/helpers/firebase_helper.dart';

class ProjectContributorList extends StatelessWidget {
  ProjectContributorList({@required this.project});

  final ProjectObject project;

  @override
  Widget build(BuildContext context) {
    List<ProjectContributorTile> tiles = [];

    tiles.add(
      ProjectContributorTile(
        project: project,
        onTap: () async {
          UserObject user;
          FirestoreHelper helper = FirestoreHelper();

          user = await helper.getUser(project.uid);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProfileScreen(
                user: user,
              ),
            ),
          );
        },
      ),
    );

    return ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(5),
      shrinkWrap: true,
      children: tiles,
    );
  }
}
