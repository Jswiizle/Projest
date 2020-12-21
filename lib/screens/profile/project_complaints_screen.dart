import 'package:flutter/material.dart';
import 'package:projest/constants.dart';
import 'package:projest/helpers/firebase_helper.dart';
import 'package:projest/helpers/alert_helper.dart';
import 'package:projest/models/objects/project_complaint_object.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:projest/components/tiles/project_complaint_tile.dart';

class ProjectComplaintsScreen extends StatefulWidget {
  ProjectComplaintsScreen({this.complaints});

  final List<ProjectComplaintObject> complaints;

  @override
  _ProjectComplaintsScreenState createState() =>
      _ProjectComplaintsScreenState();
}

class _ProjectComplaintsScreenState extends State<ProjectComplaintsScreen> {
  List<ProjectComplaintTile> tiles;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    tiles = generateListTiles();

    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text('Project Complaints'),
        ),
        body: ListView(
          children: tiles,
        ),
      ),
    );
  }

  List<ProjectComplaintTile> generateListTiles() {
    List<ProjectComplaintTile> c = [];

    for (ProjectComplaintObject complaint in widget.complaints) {
      c.add(
        ProjectComplaintTile(
          complaint: complaint,
          onDeletePressed: () {
            presentRemoveComplaintPopup(complaint);
          },
        ),
      );
    }

    return c;
  }

  void presentRemoveComplaintPopup(ProjectComplaintObject c) {
    AlertHelper helper = AlertHelper(
      title: 'Are You Sure?',
      body: 'Are you sure you want to remove this complaint?',
      choice1: 'Yes',
      choice2: 'No',
      c1: () async {
        Navigator.pop(context);
        FirestoreHelper helper = FirestoreHelper();
        toggleSpinner();
        await helper.deleteComplaint(c);
        widget.complaints.remove(c);
        toggleSpinner();
      },
      c2: () {
        Navigator.pop(context);
      },
    );

    helper.generateChoiceAlert(context);
  }

  void toggleSpinner() {
    setState(() {
      loading = !loading;
    });
  }
}
