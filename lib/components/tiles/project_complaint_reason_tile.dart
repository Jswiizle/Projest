import 'package:flutter/material.dart';
import 'package:projest/constants.dart';
import 'package:projest/models/objects/project_complaint_reason_object.dart';

class ProjectComplaintReasonTile extends StatelessWidget {
  final ProjectComplaintReasonObject reason;
  final Function checkboxCallback;

  ProjectComplaintReasonTile({
    this.reason,
    this.checkboxCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(reason.reason),
      trailing: Checkbox(
        value: reason.isSelected,
        onChanged: checkboxCallback,
        activeColor: kPrimaryColor,
      ),
    );
  }
}
