import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:projest/constants.dart';
import 'package:projest/components/buttons/rounded_button.dart';
import 'package:projest/models/objects/blip_object.dart';
import 'package:projest/components/tiles/add_project_content_tile.dart';

class AddProjectScreen extends StatefulWidget {
  static const String id = 'add_project_screen';

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  List<BlipObject> blips = [];

  @override
  Widget build(BuildContext context) {
    List<Widget> listviewContent = [
      AddProjectContentTile(
        onAddImagePressed: () {},
        onAddUrlPressed: () {
          _showUrlDialogue();
        },
      )
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('Add Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter a project title'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter a project description',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: listviewContent,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: RoundedButton(
                title: 'Add Project',
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUrlDialogue() async {
    String text = "";

    TextField _textField = TextField(
      onChanged: (value) {
        text = value;
      },
      decoration: kTextFieldDecoration.copyWith(hintText: 'ex: www.google.com'),
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text(
            'Enter a Url',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Container(
              width: 200,
              height: 75,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _textField,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 2.5),
              child: RoundedButton(
                title: 'Preview',
                color: kPrimaryColor,
                onPressed: () {
                  // TODO: Segue with data from textfield to view url page
                  print(text);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

//TODO: Add Listview with sections - last cell has buttons for types of content
