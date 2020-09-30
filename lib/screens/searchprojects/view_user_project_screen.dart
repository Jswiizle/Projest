import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:projest/models/objects/project_object.dart';
import 'package:projest/constants.dart';
import 'package:projest/components/buttons/rounded_button.dart';

class ViewUserProjectScreen extends StatefulWidget {
  ViewUserProjectScreen();

  static const String id = 'view_user_project_screen';

  @override
  _ViewUserProjectScreenState createState() => _ViewUserProjectScreenState();
}

class _ViewUserProjectScreenState extends State<ViewUserProjectScreen> {
  @override
  Widget build(BuildContext context) {
    final ProjectObject p = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(p.title),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Card(
                  elevation: 8,
                  child: Image(
                    image: NetworkImage(p.thumbnailLink),
                    width: 320,
                    height: 180,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
              child: Text(
                'Description',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    p.description,
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
              child: Text(
                'Project Contributors',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(child: ProjectCreatorList(project: p)),
            Expanded(child: SizedBox()),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: RoundedButton(
                title: 'Review Project',
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectCreatorList extends StatelessWidget {
  ProjectCreatorList({@required this.project});

  final ProjectObject project;

  @override
  Widget build(BuildContext context) {
    // TODO: (VX) Allow users to add multiple project contributors

    List<ProjectCreatorTile> tiles = [];

    tiles.add(ProjectCreatorTile(project: project));

    return ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 20.0),
      shrinkWrap: true,
      children: tiles,
    );
  }
}

class ProjectCreatorTile extends StatelessWidget {
  ProjectCreatorTile({this.project});
  final ProjectObject project;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 150,
        width: 150,
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(project.profileImageLink),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  project.projectOwnerUsername,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
