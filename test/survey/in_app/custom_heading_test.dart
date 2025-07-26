import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbricks_flutter/src/survey/in_app/components/custom_heading.dart';
//import 'package:formbricks_flutter/src/survey/in_app/components/formbricks_video_player.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:formbricks_flutter/formbricks_flutter.dart';

void main() {
  group('CustomHeading Widget', () {
    late Question questionWithTextImageVideo;

    setUp(() {
      questionWithTextImageVideo = Question(
        id: '1',
        type: QuestionType.freeText,
        headline: {"default": "Rate this aura farmer"},
        subheader: {"default": "Read before answering"},
        imageUrl:
            "https://app.formbricks.com/storage/cmcm0ihkk5ell0801mo8gh38i/public/Farmer's%2520Details--fid--0a1fdc3c-db23-40cb-be86-880394633ac9.png",
        videoUrl: "https://www.youtube.com/embed/A30ni82gX6Q",
        required: false,
        logic: [],
      );
    });

    testWidgets('renders headline, subheader, and optional text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: CustomHeading(
              question: questionWithTextImageVideo,
              required: false,
            ),
          ),
        ),
      );

      expect(find.text('Rate this aura farmer'), findsOneWidget);
      expect(find.text('Read before answering'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
    });

    testWidgets('renders image when imageUrl is provided', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomHeading(
                question: questionWithTextImageVideo,
                required: true,
              ),
            ),
          ),
        );
        expect(find.byType(CachedNetworkImage), findsOneWidget);
      });
    });

    // testWidgets('renders video when videoUrl is provided', (
    //   WidgetTester tester,
    // ) async {
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Scaffold(
    //         body: CustomHeading(
    //           question: questionWithTextImageVideo,
    //           required: true,
    //         ),
    //       ),
    //     ),
    //   );
    //
    //   expect(find.byType(FormbricksVideoPlayer), findsOneWidget);
    // });
  });
}
