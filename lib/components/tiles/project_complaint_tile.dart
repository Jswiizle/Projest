import 'package:flutter/material.dart';
import 'package:projest/models/objects/project_complaint_object.dart';
import 'package:projest/constants.dart';
import 'package:projest/components/buttons/rounded_button.dart';

class ProjectComplaintTile extends StatelessWidget {
  ProjectComplaintTile({this.complaint, this.onDeletePressed});
  final ProjectComplaintObject complaint;
  final Function onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      child: ListTile(
        contentPadding: EdgeInsets.only(right: 6),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 5),
          child: RoundedButton(
            title: 'Delete',
            onPressed: onDeletePressed,
            color: kPrimaryColor,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(
                image: complaint.projectThumbnailUrl != null &&
                        complaint.projectThumbnailUrl != "" &&
                        complaint.projectThumbnailUrl != " "
                    ? NetworkImage(complaint.projectThumbnailUrl)
                    : AssetImage('images/default.png'),
              ),
            ),
          ),
        ),
        title: Text(
          complaint.projectTitle,
          maxLines: 1,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          'Complaint: ${complaint.text}',
          // overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }
}
