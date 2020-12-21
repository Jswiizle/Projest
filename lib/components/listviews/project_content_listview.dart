import 'package:flutter/material.dart';
import 'package:projest/components/tiles/project_content_tile.dart';
import 'package:projest/components/tiles/add_project_content_tile.dart';

class ProjectContentListView extends StatelessWidget {
  ProjectContentListView(
      {@required this.listViewContent,
      @required this.onAddImagePressed,
      @required this.onAddLinkPressed});

  final List<ProjectContentTile> listViewContent;
  final Function onAddImagePressed;
  final Function onAddLinkPressed;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index != listViewContent.length) {
          return listViewContent[index];
        } else {
          return AddProjectContentTile(
            onAddImagePressed: onAddImagePressed,
            onAddUrlPressed: onAddLinkPressed,
          );
        }
      },
      itemCount: listViewContent.length + 1,
    );
  }
}
