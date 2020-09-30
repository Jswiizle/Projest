import 'package:flutter/material.dart';
import 'package:projest/components/buttons/add_content_button.dart';

class AddProjectContentTile extends StatelessWidget {
  AddProjectContentTile({this.onAddImagePressed, this.onAddUrlPressed});

  final Function onAddImagePressed;
  final Function onAddUrlPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
          child: Text(
            "Add Project Content",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AddContentButton(
              onPressed: onAddImagePressed,
              icon: Icon(
                Icons.image,
              ),
            ),
            AddContentButton(
              onPressed: onAddUrlPressed,
              icon: Icon(
                Icons.link,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
