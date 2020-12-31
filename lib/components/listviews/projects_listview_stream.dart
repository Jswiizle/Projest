import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/components/tiles/project_tile.dart';
import 'package:projest/screens/myprojects/view_my_project_screen.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/screens/searchprojects/view_user_project_screen.dart';

class ProjectStream extends StatelessWidget {
  ProjectStream(
      {this.state,
      this.viewUserProfileUid,
      this.onLongPress,
      this.context,
      this.projectObject});

  final Function onLongPress;
  final String viewUserProfileUid;
  final ProjectStreamState state;
  final _firestore = FirebaseFirestore.instance;
  final BuildContext context;
  final ProjectObject projectObject;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: state == ProjectStreamState.myProjects
          ? _firestore
              .collection('Projects')
              .where('uid', isEqualTo: FirebaseAuthHelper.loggedInUser.uid)
              .snapshots()
          : _firestore
              .collection('Projects')
              .where('uid', isEqualTo: viewUserProfileUid)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData == true) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final projects = snapshot.data.docs.reversed;
        List<ProjectTile> projectList = [];
        for (var project in projects) {
          final pObject = ProjectObject.fromJson(project.data());

          final p = ProjectTile(
            project: pObject,
            state: state == ProjectStreamState.viewUserProfileProjects ? ProjectTileState.viewingProjectsOnUserProfile : ProjectTileState.viewingMyProject,
            onTap: () {
              switch (state) {
                case ProjectStreamState.myProjects:
                  ViewMyProjectScreen.p = pObject;
                  Navigator.pushNamed(context, ViewMyProjectScreen.id);
                  break;
                case ProjectStreamState.viewUserProjects:
                case ProjectStreamState.viewUserProfileProjects:
                  if (projectObject.id == pObject.id) {
                    ViewUserProjectScreen.p = pObject;
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ViewUserProjectScreen.p = pObject;
                    Navigator.pushNamed(context, ViewUserProjectScreen.id);
                  }
              }
            },

            onLongPress: () async {
              onLongPress(pObject);
            },
          );
          projectList.add(p);
        }
        return ListView(
          padding: EdgeInsets.all(7.5),
          children: projectList,
          itemExtent: 80,
        );
      },
    );
  }
}

enum ProjectStreamState {
  myProjects,
  viewUserProjects,
  viewUserProfileProjects
}

//NOTES:

// Check for timestamp when submitting feedback, etc? Add function to check if project is sponsored?
