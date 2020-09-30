import 'package:flutter/material.dart';
import 'package:projest/constants.dart';
import 'package:projest/models/objects/category_object.dart';

class CategoryTile extends StatelessWidget {
  final CategoryObject category;
  final Function checkboxCallback;
  final bool isChecked;

  CategoryTile({
    this.category,
    this.checkboxCallback,
    this.isChecked,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.category),
      trailing: Checkbox(
        value: isChecked,
        onChanged: checkboxCallback,
        activeColor: kPrimaryColor,
      ),
    );
  }
}
