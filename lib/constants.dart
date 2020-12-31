import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF00B6F0);
const kDarkBlueCompliment = Color(0xFF0B2933);
const kLightOrangeCompliment = Color(0xFFFFA244);

const kTextFieldDecoration = InputDecoration(
  hintText: '',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);



const kMusicCriteria = [
  'General',
  'Production',
  'Cultural Relevance',
  'Artistic Purpose',
  'Melody',
  'Listening Experience',
  'Musical Color',
  'Rhythm',
  'Harmony',
  'Stage Presence',
  'Vocal Range',
  'Originality',
  'Story Telling',
  'Catchiness',
  'Commercial Appeal',
  'Composition',
];

const kArtCriteria = [
  'General',
  'Creativity',
  'Color',
  'Lighting',
  'Composition',
  'Commercial Appeal',
  'Exposure',
  'Focus',
  'Clarity of Expression',
  'Overall Impression',
  'Social Impact',
  'Originality',
  'Entertainment',
  'Story Telling',
  'Theme Adherence',
  'Artistic Value',
];

const kCodingCriteria = [
  'General',
  'Readability',
  'Maintainability',
  'Efficiency',
  'Simplicity',
  'Layering',
  'Fatal Errors',
  'Performance',
  'Stability',
  'Design',
  'Modernity',
  'Documentation',
  'Bugs',
  'Modularity',
];

const kMarketingCriteria = [
  'General',
  'Trustworthiness',
  'Targeting',
  'Aesthetic Design',
  'Call to Action',
  'Theme Consistency',
  'Brand Relevance',
  'Efficiency',
  'Attention Grabbing',
  'Effectiveness',
  'Consumer Response',
  'Originality',
  'Story Telling',
];

const kPodcastingCriteria = [
  'General',
  'Production Quality',
  'Subject Matter',
  'Consistent Scheduling',
  'Theme Adherence',
  'Show Structure',
  'Commercial Appeal',
  'Guest Quality',
  'Informativeness',
  'Entertainment Value',
  'Quality of Host',
  'Audience Response',
  'Audience Interaction',
  'Originality',
  'Visual Appeal',
  'Audio Quality',
  'Conversation Flow',
];

const kUiDesignCriteria = [
  'General',
  'One Task Per Screen',
  'Hierarchical Organization',
  'Use of Color',
  'Consistency',
  'Alignment',
  'Aspect Ratios',
  'Contrast',
  'Navigability',
];

const kVideoCriteria = [
  'General',
  'Content',
  'Entertainment Value',
  'Clarity of Purpose',
  'Informative Value',
  'Appropriate Duration',
  'Audio Quality',
  'Originality',
  'Attention Grabbing',
  'Editing',
  'Audience Response',
  'Content Consistency',
  'Video Quality',
];

const kWritingCriteria = [
  'General',
  'Organization',
  'Sentence Fluency',
  'Word Choice',
  'Focus',
  'Entertainment Value',
  'Informative Value',
  'Emotional Appeal',
  'Logical Appeal',
  'Tone',
  'Spelling',
  'Originality',
  'Story Telling',
  'Coherence',
  'Grammar',
];

extension UrlString on String {
  String cleanUrl() {
    if (this.contains("https")) {
      return this;
    } else if (this.contains("www")) {
      return "https://" + this;
    } else if (this.contains(".com")) {
      return "https://www." + this;
    }
  }
}
