import 'package:flutter/material.dart';
import 'package:projest/components/tiles/project_complaint_reason_tile.dart';
import 'package:projest/models/objects/project_complaint_reason_object.dart';

class SubmitProjectComplaintListView extends StatefulWidget {
  @override
  _SubmitProjectComplaintListViewState createState() =>
      _SubmitProjectComplaintListViewState();

  final ValueChanged<List<ProjectComplaintReasonObject>>
      onProjectComplaintReasonsChange;
  SubmitProjectComplaintListView({this.onProjectComplaintReasonsChange});
}

class _SubmitProjectComplaintListViewState
    extends State<SubmitProjectComplaintListView> {
  List<ProjectComplaintReasonObject> reasons = [
    ProjectComplaintReasonObject(reason: 'Violent Content', isSelected: false),
    ProjectComplaintReasonObject(
        reason: 'Inappropriate Content', isSelected: false),
    ProjectComplaintReasonObject(reason: 'Stolen Content', isSelected: false),
    ProjectComplaintReasonObject(reason: 'Other', isSelected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ProjectComplaintReasonTile(
          reason: reasons[index],
          checkboxCallback: (bool checkBoxState) {
            setState(() {
              reasons[index].selectReason();
              widget.onProjectComplaintReasonsChange(reasons);
            });
          },
        );
      },
      itemCount: reasons.length,
    );
  }
}
