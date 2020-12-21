import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projest/components/listviews/projects_listview_stream.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/constants.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class MyProjectsScreen extends StatefulWidget {
  static const String id = 'my_projects_screen';

  @override
  _MyProjectsScreenState createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  final messageTextController = TextEditingController();
  String messageText;

  int sponsoredDays = 1;
  String sponsoredText = "Day";
  int creditsToSponsor = 5;
  bool isSponsorButtonEnabled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: ProjectStream(
          state: ProjectStreamState.myProjects,
          context: context,
          onLongPress: (ProjectObject project) async {
            if (project.boostedEndTime != null &&
                project.boostedEndTime.compareTo(Timestamp.now()) > 0) {
              DateTime endDate = project.boostedEndTime.toDate();
              Duration hoursLeft = endDate.difference(DateTime.now());

              AlertHelper helper = AlertHelper(
                  title: 'Sponsored', body: createAlertString(hoursLeft));

              helper.generateAlert(context);
            } else {
              presentSponsorPopup(project);
            }
          },
        ),
      ),
    );
  }

  String createAlertString(Duration duration) {
    String string;

    if (duration.inHours > 23) {
      if (duration.inHours > 47) {
        string =
            'This project is sponsored for another ${duration.inDays} days';
      } else {
        string = 'This project is sponsored for ${duration.inDays} day';
      }
    } else {
      if (duration.inHours >= 1) {
        if (duration.inHours != 1) {
          string =
              'This project is sponsored for another ${duration.inHours} hours';
        } else {
          string = 'This project is sponsored for one more hour';
        }
      } else {
        string =
            'This project is sponsored for another ${duration.inMinutes} minutes';
      }
    }

    return string;
  }

  Future<void> presentSponsorPopup(ProjectObject project) async {
    project.checkIfProjectIsBoosted();

    isSponsorButtonEnabled =
        FirebaseAuthHelper.loggedInUser.credits >= creditsToSponsor
            ? true
            : false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: Text(
                'Boost "${project.title}"',
                style: TextStyle(
                  fontSize: 22.5,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                ),
              ),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: project.thumbnailLink != null
                              ? Image.network(project.thumbnailLink)
                              : Image.asset('images/default.png'),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 50,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: sponsoredDays,
                            items: createDropdownItems(),
                            onChanged: (days) {
                              setState(() {
                                creditsToSponsor = days * 5;
                                isSponsorButtonEnabled =
                                    FirebaseAuthHelper.loggedInUser.credits >=
                                            creditsToSponsor
                                        ? true
                                        : false;
                                sponsoredDays = days;
                                if (days > 1) {
                                  sponsoredText = "Days";
                                } else {
                                  sponsoredText = "Day";
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Text(
                      sponsoredText,
                      style: TextStyle(
                          fontSize: 22.5, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      '   =   $creditsToSponsor Credits',
                      style: TextStyle(
                          fontSize: 22.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: RoundedButton(
                    title: 'Boost',
                    color: isSponsorButtonEnabled ? kPrimaryColor : Colors.grey,
                    onPressed: isSponsorButtonEnabled
                        ? () async {
                            Navigator.pop(context);
                            await _boostProject(project);
                          }
                        : null,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _boostProject(ProjectObject project) async {
    toggleSpinner();

    project.boostedStartTime = Timestamp.fromDate(DateTime.now());
    project.boostedEndTime =
        Timestamp.fromDate(DateTime.now().add(Duration(days: sponsoredDays)));

    FirestoreHelper helper = FirestoreHelper();

    await helper.updateProject(project).then(
      (value) async {
        FirebaseAuthHelper.loggedInUser.credits =
            FirebaseAuthHelper.loggedInUser.credits - creditsToSponsor;
        FirestoreHelper helper = FirestoreHelper();
        await helper.updateCurrentUser();
      },
    );

    toggleSpinner();
  }

  void toggleSpinner() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  List<DropdownMenuItem> createDropdownItems() {
    List<DropdownMenuItem> items = [];
    List<int> times = [1, 2, 3, 4, 5];

    for (int time in times) {
      items.add(
        DropdownMenuItem(
          child: Text(
            time.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 18,
            ),
          ),
          value: time,
        ),
      );
    }

    return items;
  }
}
