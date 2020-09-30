class CategoryObject {
  CategoryObject(
      {this.category, this.criteria, this.articleArray, this.isSelected});

  List<List> articleArray;
  final String category;
  final String criteria;
  bool isSelected;

  void selectCategory() {
    isSelected = !isSelected;
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'criteria': criteria,
        'articleArray': articleArray,
      };
}
