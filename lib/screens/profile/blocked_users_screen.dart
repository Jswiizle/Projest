import 'package:flutter/material.dart';
import 'package:projest/constants.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/models/objects/user_object.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/helpers/alert_helper.dart';

class BlockedUsersScreen extends StatefulWidget {
  BlockedUsersScreen({this.users});

  final List<UserObject> users;

  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<Card> cards;

  @override
  Widget build(BuildContext context) {
    print('Users length is ${widget.users.length}');

    cards = generateListTiles();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('Blocked Users'),
      ),
      body: ListView(
        children: cards,
      ),
    );
  }

  List<Card> generateListTiles() {
    List<Card> c = [];

    for (UserObject user in widget.users) {
      c.add(
        Card(
          elevation: 2.5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: user.profileImageLink != null
                    ? NetworkImage(user.profileImageLink)
                    : AssetImage('images/profile.png'),
              ),
              title: Text(
                user.username,
                style: TextStyle(fontSize: 18
                ),
              ),
              trailing: RoundedButton(
                color: kPrimaryColor,
                title: 'Unblock',
                onPressed: () {
                  presentUnblockUserPopup(user);
                },
              ),
            ),
          ),
        ),
      );
    }

    return c;
  }

  void presentUnblockUserPopup(UserObject u) {
    AlertHelper helper = AlertHelper(
      title: 'Are You Sure?',
      body: 'Are you sure you want to unblock ${u.username}?',
      choice1: 'Yes',
      choice2: 'No',
      c1: () async {
        Navigator.pop(context);
        FirebaseAuthHelper.loggedInUser.blockedUsersUid.remove(u.uid);
        FirestoreHelper helper = FirestoreHelper();
        await helper.updateCurrentUser();

        setState(() {
          widget.users.remove(u);
        });
      },
      c2: () {
        Navigator.pop(context);
      },
    );

    helper.generateChoiceAlert(context);
  }
}
