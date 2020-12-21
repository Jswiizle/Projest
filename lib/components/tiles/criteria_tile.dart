import 'package:flutter/material.dart';
import 'package:projest/constants.dart';
import 'package:projest/models/objects/criteria_object.dart';

class CriteriaTile extends StatelessWidget {
  final CriteriaObject criteria;
  final Function checkboxCallback;

  CriteriaTile({
    this.criteria,
    this.checkboxCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(criteria.criteria, overflow: TextOverflow.ellipsis),
      trailing: Checkbox(
        value: criteria.isSelected,
        onChanged: checkboxCallback,
        activeColor: kPrimaryColor,
      ),
    );
  }
}
