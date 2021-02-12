class CriteriaObject {
  CriteriaObject({this.criteria, this.isSelected});

  final String criteria;
  bool isSelected;

  void selectCriteria() {
    if (criteria != 'General') {
      isSelected = !isSelected;
    }
  }

  Map<String, dynamic> toJson() => {
        'criteria': criteria,
      };

  factory CriteriaObject.fromJson(Map<String, dynamic> parsedJson) {
    return CriteriaObject(
      criteria: parsedJson['criteria'],
    );
  }
}
