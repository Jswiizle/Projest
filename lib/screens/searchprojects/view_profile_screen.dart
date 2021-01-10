import 'package:flutter/material.dart';
import 'package:projest/constants.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/models/objects/user_object.dart';
import 'package:projest/components/listviews/projects_listview_stream.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/screens/searchprojects/view_user_project_screen.dart';
import 'package:projest/helpers/alert_helper.dart';

class ViewProfileScreen extends StatefulWidget {
  ViewProfileScreen({this.user, this.project});
  final UserObject user;
  final ProjectObject project;

  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  ImageProvider avatarProvider;

  @override
  void initState() {
    avatarProvider = widget.user.profileImageLink != null
        ? NetworkImage(widget.user.profileImageLink)
        : AssetImage('images/profile.png');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text("${capitalize(widget.user.username)}'s Profile",
            style: TextStyle(fontSize: 18)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 17.5),
            child: GestureDetector(
              onTap: () {
                print('Block pressed');
                AlertHelper helper = AlertHelper(
                  title: 'Are you sure?',
                  body:
                      'Are you sure you want to block ${widget.user.username}?',
                  choice1: 'Yes',
                  choice2: 'No',
                  c1: () async {
                    Navigator.pop(context);

                    FirebaseAuthHelper.loggedInUser.blockedUsersUid = [];
                    widget.user.blockedByUid = [];

                    FirebaseAuthHelper.loggedInUser.blockedUsersUid
                        .add(widget.user.uid);
                    widget.user.blockedByUid
                        .add(FirebaseAuthHelper.loggedInUser.uid);
                    FirestoreHelper helper = FirestoreHelper();
                    await helper.updateUser(FirebaseAuthHelper.loggedInUser);
                    await helper.updateUser(widget.user);

                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  c2: () {
                    Navigator.pop(context);
                  },
                );

                helper.generateChoiceAlert(context);
              },
              child: Icon(
                Icons.block,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              CircleAvatar(
                radius: 75.75,
                backgroundColor: kDarkBlueCompliment,
                child: CircleAvatar(
                  radius: 74.75,
                  backgroundImage: avatarProvider,
                ),
              ),
              SizedBox(height: 15),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  child: Text(
                    'Level ${widget.user.getLevel()}',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 60),
              Text(
                "${capitalize(widget.user.username)}'s Projects",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Expanded(
                child: ProjectStream(
                  projectObject: ViewUserProjectScreen.p,
                  state: ProjectStreamState.viewUserProfileProjects,
                  viewUserProfileUid: widget.user.uid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
