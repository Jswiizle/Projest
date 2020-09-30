//TODO: (V2) Set up pinterest style layout - dynamic cell height

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projest/constants.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/firebase_helper.dart';
import 'package:projest/screens/searchprojects/view_user_project_screen.dart';

final _firestore = FirebaseFirestore.instance;

FirebaseAuthHelper authHelper;

class SearchProjectsScreen extends StatefulWidget {
  static const String id = 'search_projects_screen';

  @override
  _SearchProjectsScreenState createState() => _SearchProjectsScreenState();
}

class _SearchProjectsScreenState extends State<SearchProjectsScreen> {
  final messageTextController = TextEditingController();
  String messageText;

  @override
  void initState() {
    super.initState();
    authHelper = FirebaseAuthHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProjectStream(),
    );
  }
}

class ProjectStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //TODO: Only show projects with Auth UID
      stream: _firestore.collection('Projects').snapshots(),
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
          final projectThumbnail = project.data()['thumbnailLink'];
          final projectTitle = project.data()['title'];
          final projectDescription = project.data()['description'];
          final projectFeedbackArray = project.data()['feedbackArray'];
          final projectCategory = project.data()['category'];
          final pUid = project.data()['uid'];
          final profileImageLink = project.data()['profileImageLink'];

          final pObject = ProjectObject(
            title: projectTitle,
            category: projectCategory,
            description: projectDescription,
            projectOwnerUsername: authHelper.auth.currentUser.email,
            thumbnailLink: projectThumbnail,
            feedbackArray: projectFeedbackArray,
            uid: pUid,
            profileImageLink: profileImageLink,
          );

          if (pObject.uid != authHelper.auth.currentUser.uid) {
            final p = ProjectTile(
              project: pObject,
            );
            projectList.add(p);
          }
        }
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 12.5),
          children: projectList,
          itemExtent: 83,
        );
      },
    );
  }
}

class ProjectTile extends StatelessWidget {
  ProjectTile({this.project});
  final ProjectObject project;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15,
      child: ListTile(
        onTap: () {
          //TODO: Change to view users project instead of view my project

          Navigator.pushNamed(context, ViewUserProjectScreen.id,
              arguments: project);
        },
        contentPadding: EdgeInsets.all(2),
        trailing: Icon(
          project.checkForUnratedFeedback()
              ? Icons.notifications
              : Icons.notifications_none,
          size: 45,
          color: project.checkForUnratedFeedback()
              ? kLightOrangeCompliment
              : Colors.grey.withOpacity(0.25),
        ),
        leading: Image(
          image: NetworkImage(project.thumbnailLink),
          height: 75,
          width: 120,
        ),
        title: Text(
          project.title,
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          project.description,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }
}
