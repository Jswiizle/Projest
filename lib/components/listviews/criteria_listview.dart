import 'package:flutter/material.dart';
import 'package:projest/components/tiles/criteria_tile.dart';
import 'package:projest/models/objects/category_object.dart';
import 'package:projest/models/objects/criteria_object.dart';

class CriteriaListView extends StatefulWidget {
  @override
  _CriteriaListViewState createState() => _CriteriaListViewState();

  final ValueChanged<List<String>> onCriteriaChanged;
  final CategoryObject category;
  List<String> selectedCriteria;
  CriteriaListView(
      {this.onCriteriaChanged, this.category, this.selectedCriteria});
}

class _CriteriaListViewState extends State<CriteriaListView> {
  List<CriteriaObject> criteria = [];

  @override
  void initState() {
    buildCriteriaObjects();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CriteriaTile(
          criteria: criteria[index],
          checkboxCallback: (bool checkBoxState) {
            setState(() {
              criteria[index].selectCriteria();
              widget.onCriteriaChanged(buildCriteriaStringArray());
            });
          },
        );
      },
      itemCount: criteria.length,
    );
  }

  void buildCriteriaObjects() {
    criteria.add(CriteriaObject(
      criteria: 'General',
      isSelected: true,
    ));

    widget.selectedCriteria.add('General');

    for (String c in widget.category.criteria) {
      criteria.add(CriteriaObject(
          criteria: c,
          isSelected: widget.selectedCriteria.contains(c) ? true : false));
    }
  }

  List<String> buildCriteriaStringArray() {
    List<String> stringArray = [];

    for (CriteriaObject c in criteria) {
      if (c.isSelected == true) {
        stringArray.add(c.criteria);
      }
    }

    return stringArray;
  }
}
