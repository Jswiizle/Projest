import 'package:flutter/material.dart';
import 'package:projest/constants.dart';

class ProjectContentCoverPage extends StatefulWidget {
  ProjectContentCoverPage(
      {this.addImageContentCallback, this.addWebContentCallback});

  final Function addImageContentCallback;
  final Function addWebContentCallback;

  @override
  _ProjectContentCoverPageState createState() =>
      _ProjectContentCoverPageState();
}

class _ProjectContentCoverPageState extends State<ProjectContentCoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('Project Content'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: widget.addImageContentCallback,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: [
                        Text(
                          'Add Image Content',
                          style: TextStyle(
                              fontSize: 27.5, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Icon(
                          Icons.image,
                          size: 100,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: widget.addWebContentCallback,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: [
                        Text(
                          'Add Web Content',
                          style: TextStyle(
                              fontSize: 27.5, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Icon(
                          Icons.link,
                          size: 100,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
