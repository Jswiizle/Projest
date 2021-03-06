import 'package:flutter/material.dart';
import 'package:projest/constants.dart';
import 'package:projest/models/objects/category_object.dart';

class CategoryTile extends StatelessWidget {
  final CategoryObject category;
  final Function checkboxCallback;

  CategoryTile({
    this.category,
    this.checkboxCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.category),
      trailing: Checkbox(
        value: category.isSelected,
        onChanged: checkboxCallback,
        activeColor: kPrimaryColor,
      ),
    );
  }
}
