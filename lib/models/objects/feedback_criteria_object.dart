class FeedbackCriteriaObject {
  FeedbackCriteriaObject({this.criteria, this.rating, this.text, this.index});
  final String criteria;
  String text;
  double rating;
  final int index;

  Map<String, dynamic> toJson() => {
        'criteria': criteria,
        'text': text,
        'rating': rating,
      };

  factory FeedbackCriteriaObject.fromJson(Map<String, dynamic> parsedJson) {
    double rating;

    if (parsedJson['rating'] is int) {
      rating = (parsedJson['rating'] as int).toDouble();
    } else {
      rating = parsedJson['rating'];
    }

    return FeedbackCriteriaObject(
      criteria: parsedJson['criteria'],
      text: parsedJson['text'],
      rating: rating,
    );
  }
}
