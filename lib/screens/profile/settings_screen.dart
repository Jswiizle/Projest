import 'package:flutter/material.dart';
import 'package:projest/constants.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/models/objects/user_object.dart';
import 'package:projest/screens/profile/blocked_users_screen.dart';
import 'package:projest/models/objects/project_complaint_object.dart';
import 'package:projest/screens/profile/project_complaints_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: kPrimaryColor,
      ),
      body: ListView(
        children: [
          Card(
            elevation: 2.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: ListTile(
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  List<UserObject> users = await getUsers();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlockedUsersScreen(users: users),
                    ),
                  );
                },
                title: Text(
                  'Blocked Users',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
          ),
          Card(
            elevation: 2.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: ListTile(
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  List<ProjectComplaintObject> complaints =
                      await getComplaints();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProjectComplaintsScreen(complaints: complaints),
                    ),
                  );
                },
                title: Text(
                  'Project Complaints',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<List<UserObject>> getUsers() async {
    List<UserObject> users = [];

    for (String uid in FirebaseAuthHelper.loggedInUser.blockedUsersUid) {
      FirestoreHelper helper = FirestoreHelper();

      UserObject user = await helper.getUser(uid);
      users.add(user);
    }

    return users;
  }

  Future<List<ProjectComplaintObject>> getComplaints() async {
    List<ProjectComplaintObject> complaints = [];

    for (String id in FirebaseAuthHelper.loggedInUser.projectComplaintIdArray) {
      FirestoreHelper helper = FirestoreHelper();
      ProjectComplaintObject complaint = await helper.getComplaint(id);
      complaints.add(complaint);
    }

    return complaints;
  }
}
