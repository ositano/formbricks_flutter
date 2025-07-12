/*
                    "id": "jrbzg6y3u047aakmqgiugeq3",
                    "type": "endScreen",
                    "headline": {
                        "default": "Thank you!"
                    },
                    "imageUrl": "https://app.formbricks.com/storage/cmcm0ihkk5ell0801mo8gh38i/public/timing--fid--aedcd7cd-6bda-4589-bc4c-5b051dc919e2.jpg",
                    "videoUrl": "",
                    "subheader": {
                        "default": "We appreciate your feedback."
                    }
 */

/// Defines the response model for survey submissions.
class Ending {
  final String id;
  final String type;
  final Map<String, String> headline;
  final Map<String, String>? subheader;
  final String? imageUrl;
  final String? videoUrl;

  Ending({
    required this.id,
    required this.type,
    required this.headline,
    this.imageUrl,
    this.videoUrl,
    this.subheader
  });

  factory Ending.fromJson(Map<String, dynamic> json) {
    return Ending(
      id: json['id'],
      type: json['type'],
      headline: Map<String, String>.from(json['headline'] ?? {'default': ''}),
      subheader: json['subheader'] != null ? Map<String, String>.from(
          json['subheader']) : null,
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
    );
  }
}