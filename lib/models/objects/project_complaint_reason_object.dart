class ProjectComplaintReasonObject {
  ProjectComplaintReasonObject({this.reason, this.isSelected});

  final String reason;
  bool isSelected;

  void selectReason() {
    isSelected = !isSelected;
  }

  Map<String, dynamic> toJson() => {
        'reason': reason,
      };

  factory ProjectComplaintReasonObject.fromJson(
      Map<String, dynamic> parsedJson) {
    return ProjectComplaintReasonObject(
      reason: parsedJson['reason'],
    );
  }
}
