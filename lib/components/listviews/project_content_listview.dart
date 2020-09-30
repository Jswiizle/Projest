import 'package:flutter/material.dart';
import 'package:projest/components/tiles/category_tile.dart';
import 'package:projest/models/objects/category_object.dart';

class ProjectContentListview extends StatefulWidget {
  @override
  _ProjectContentListviewState createState() => _ProjectContentListviewState();

  final ValueChanged<List<CategoryObject>> onCategoriesChanged;
  ProjectContentListview({this.onCategoriesChanged});
}

class _ProjectContentListviewState extends State<ProjectContentListview> {
  List<CategoryObject> interests = [
    CategoryObject(category: 'Music', isSelected: false),
    CategoryObject(category: 'Art', isSelected: false),
    CategoryObject(category: 'Coding', isSelected: false),
    CategoryObject(category: 'Marketing', isSelected: false),
    CategoryObject(category: 'Podcasting', isSelected: false),
    CategoryObject(category: 'Design', isSelected: false),
    CategoryObject(category: 'Video', isSelected: false),
    CategoryObject(category: 'Writing', isSelected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CategoryTile(
          isChecked: interests[index].isSelected,
          category: interests[index],
          checkboxCallback: (bool checkBoxState) {
            setState(() {
              interests[index].selectCategory();
              widget.onCategoriesChanged(interests);
            });
          },
        );
      },
      itemCount: interests.length,
    );
  }
}
