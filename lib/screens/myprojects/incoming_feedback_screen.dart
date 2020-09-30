import 'package:flutter/material.dart';
import 'package:projest/models/objects/feedback_object.dart';
import 'package:projest/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:projest/components/buttons/rounded_button.dart';

class IncomingFeedbackScreen extends StatefulWidget {
  static const String id = 'incoming_feedback_screen';

  @override
  _IncomingFeedbackScreenState createState() => _IncomingFeedbackScreenState();
}

class _IncomingFeedbackScreenState extends State<IncomingFeedbackScreen> {
  List<FeedbackCriteria> getFeedbackCriteria() {
    List<FeedbackCriteria> c = [];

    final FeedbackObject _f = ModalRoute.of(context).settings.arguments;

    for (var criteria in _f.feedback) {
      String category = criteria['criteria'];
      String text = criteria['text'];

      int rating = criteria['rating'];

      c.add(FeedbackCriteria(
          criteria: category, text: text, rating: rating.toDouble()));
    }

    return c;
  }

  List<Widget> _buildExpandableContent(FeedbackCriteria criteriaItem) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 15, left: 15, bottom: 15),
        child: Text(
          criteriaItem.text,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<FeedbackCriteria> _criteria = getFeedbackCriteria();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('View Feedback'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: _criteria.length,
              itemBuilder: (context, i) {
                return Card(
                  elevation: 10.0,
                  child: ExpansionTile(
                    title: Row(
                      children: <Widget>[
                        Text(
                          _criteria[i].criteria,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: 12.5,
                        ),
                        RatingBar(
                          itemCount: 5,
                          itemSize: 20,
                          ignoreGestures: true,
                          allowHalfRating: false,
                          initialRating: _criteria[i].rating,
                          ratingWidget: RatingWidget(
                            full: Icon(
                              Icons.star,
                              color: Colors.orange,
                            ),
                            empty: Icon(Icons.star_border,
                                color: kLightOrangeCompliment),
                          ),
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                    children: <Widget>[
                      new Column(
                        children: _buildExpandableContent(_criteria[i]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Text(
            'Was This Feedback Helpful?',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 40.0, right: 40.0, bottom: 40.0, top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: RoundedButton(
                    onPressed: () {
                      // TODO: Change feedback dictionary to reflect, also chsae
                    },
                    title: 'Yes',
                    color: kPrimaryColor,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: RoundedButton(
                    title: 'No',
                    color: kLightOrangeCompliment,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FeedbackCriteria {
  FeedbackCriteria({this.criteria, this.rating, this.text});
  final String criteria;
  final String text;
  final double rating;
}
