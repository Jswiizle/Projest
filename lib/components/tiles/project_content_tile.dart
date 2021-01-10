import 'package:flutter/material.dart';
import 'package:projest/models/objects/blip_object.dart';

class ProjectContentTile extends StatelessWidget {
  final BlipObject blipObject;
  final Function onTap;

  ProjectContentTile({this.blipObject, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blipObject.title ?? "",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  blipObject.description ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w200,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          trailing: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              blipObject.url != null && blipObject.url != ""
                  ? Icons.link_rounded
                  : Icons.image,
              color: Colors.black,
              size: 45,
            ),
          ),
        ),
      ),
    );
  }
}
