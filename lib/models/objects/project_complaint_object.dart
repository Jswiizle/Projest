import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projest/models/objects/project_complaint_reason_object.dart';

class ProjectComplaintObject {
  ProjectComplaintObject({
    this.reasons,
    this.text,
    this.timestamp,
    this.projectId,
    this.complaineeUid,
    this.complainerUid,
    this.id,
    this.projectTitle,
    this.projectDescription,
    this.projectThumbnailUrl,
  });

  final List<ProjectComplaintReasonObject> reasons;
  final String text;
  final Timestamp timestamp;
  final String projectId;
  final String complainerUid;
  final String complaineeUid;
  final String id;
  final String projectTitle;
  final String projectDescription;
  final String projectThumbnailUrl;

  Map<String, dynamic> toJson() => {
        'reasons': getReasonStrings(),
        'timestamp': timestamp,
        'projectId': projectId,
        'complainerUid': complainerUid,
        'complaineeUid': complaineeUid,
        'id': id,
        'text': text,
        'projectTitle': projectTitle,
        'projectDescription': projectDescription,
        'projectThumbnailUrl': projectThumbnailUrl,
      };

  factory ProjectComplaintObject.fromJson(Map<String, dynamic> parsedJson) {
    List<ProjectComplaintReasonObject> reasons = [];
    List<String> reasonStrings = new List<String>.from(parsedJson['reasons']);

    for (String r in reasonStrings) {
      reasons.add(ProjectComplaintReasonObject(
        reason: r,
        isSelected: false,
      ));
    }

    return ProjectComplaintObject(
      reasons: reasons,
      timestamp: parsedJson['timestamp'],
      projectId: parsedJson['projectId'],
      complainerUid: parsedJson['complainerUid'],
      complaineeUid: parsedJson['complaineeUid'],
      id: parsedJson['id'],
      text: parsedJson['text'],
      projectThumbnailUrl: parsedJson['projectThumbnailUrl'],
      projectDescription: parsedJson['projectDescription'],
      projectTitle: parsedJson['projectTitle'],
    );
  }

  List<String> getReasonStrings() {
    List<String> strings = [];

    for (ProjectComplaintReasonObject r in reasons) {
      strings.add(r.reason);
    }

    return strings;
  }
}
