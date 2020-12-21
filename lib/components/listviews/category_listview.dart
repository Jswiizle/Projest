import 'package:flutter/material.dart';
import 'package:projest/components/tiles/category_tile.dart';
import 'package:projest/models/objects/category_object.dart';

class CategoryListView extends StatefulWidget {
  @override
  _CategoryListViewState createState() => _CategoryListViewState();

  final ValueChanged<List<CategoryObject>> onCategoriesChanged;
  final CategoryListViewState state;
  CategoryListView({this.onCategoriesChanged, this.state});
}

class _CategoryListViewState extends State<CategoryListView> {
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
          category: interests[index],
          checkboxCallback: (bool checkBoxState) {
            setState(() {
              if (widget.state == CategoryListViewState.single) {
                for (var i in interests) {
                  i.isSelected = false;
                }
              }

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

enum CategoryListViewState { single, multiple }
