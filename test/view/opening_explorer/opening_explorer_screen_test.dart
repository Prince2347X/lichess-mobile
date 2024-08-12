import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:lichess_mobile/src/model/analysis/analysis_controller.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/common/http.dart';
import 'package:lichess_mobile/src/model/opening_explorer/opening_explorer_preferences.dart';
import 'package:lichess_mobile/src/view/opening_explorer/opening_explorer_screen.dart';

import '../../test_app.dart';
import '../../test_utils.dart';

MockClient client(OpeningDatabase db) => MockClient((request) {
      return request.url.host == 'explorer.lichess.ovh'
          ? switch (db) {
              OpeningDatabase.master =>
                mockResponse(mastersOpeningExplorerResponse, 200),
              OpeningDatabase.lichess =>
                mockResponse(lichessOpeningExplorerResponse, 200),
              OpeningDatabase.player =>
                mockResponse(playerOpeningExplorerResponse, 200),
            }
          : request.url.host == 'en.wikibooks.org'
              ? mockResponse('', 200)
              : mockResponse('', 404);
    });

void main() {
  const options = AnalysisOptions(
    id: standaloneAnalysisId,
    isLocalEvaluationAllowed: false,
    orientation: Side.white,
    variant: Variant.standard,
  );

  group('OpeningExplorerScreen', () {
    testWidgets(
      'meets accessibility guidelines',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        final app = await buildTestApp(
          tester,
          home: const OpeningExplorerScreen(
            pgn: '',
            options: options,
          ),
          overrides: [
            defaultClientProvider
                .overrideWithValue(client(OpeningDatabase.master)),
          ],
        );

        await tester.pumpWidget(app);

        // wait for opening explorer data to load
        await tester.pump(const Duration(milliseconds: 50));

        await meetsTapTargetGuideline(tester);

        await tester.pump(const Duration(milliseconds: 50));

        handle.dispose();
      },
      variant: kPlatformVariant,
    );

    testWidgets(
      'master opening explorer loads',
      (WidgetTester tester) async {
        final app = await buildTestApp(
          tester,
          home: const OpeningExplorerScreen(
            pgn: '',
            options: options,
          ),
          overrides: [
            defaultClientProvider
                .overrideWithValue(client(OpeningDatabase.master)),
          ],
        );
        await tester.pumpWidget(app);

        // wait for opening explorer data to load
        await tester.pump(const Duration(milliseconds: 50));

        final moves = [
          'e4',
          'd4',
        ];
        expect(find.byKey(const Key('moves-table')), findsOneWidget);
        for (final move in moves) {
          expect(find.widgetWithText(TableRowInkWell, move), findsOneWidget);
        }

        expect(find.widgetWithText(Container, 'Top games'), findsOneWidget);
        expect(find.widgetWithText(Container, 'Recent games'), findsNothing);
        expect(
          find.byKey(const Key('game-list')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('game-tile')),
          findsNWidgets(2),
        );

        await tester.pump(const Duration(milliseconds: 50));
      },
      variant: kPlatformVariant,
    );

    testWidgets(
      'lichess opening explorer loads',
      (WidgetTester tester) async {
        final app = await buildTestApp(
          tester,
          home: const OpeningExplorerScreen(
            pgn: '',
            options: options,
          ),
          overrides: [
            defaultClientProvider
                .overrideWithValue(client(OpeningDatabase.lichess)),
          ],
        );
        await tester.pumpWidget(app);

        // wait for opening explorer data to load
        await tester.pump(const Duration(milliseconds: 50));

        final moves = [
          'd4',
        ];
        expect(find.byKey(const Key('moves-table')), findsOneWidget);
        for (final move in moves) {
          expect(find.widgetWithText(TableRowInkWell, move), findsOneWidget);
        }

        expect(find.widgetWithText(Container, 'Top games'), findsNothing);
        expect(find.widgetWithText(Container, 'Recent games'), findsOneWidget);
        expect(
          find.byKey(const Key('game-list')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('game-tile')),
          findsOneWidget,
        );

        await tester.pump(const Duration(milliseconds: 50));
      },
      variant: kPlatformVariant,
    );

    testWidgets(
      'player opening explorer loads',
      (WidgetTester tester) async {
        final app = await buildTestApp(
          tester,
          home: const OpeningExplorerScreen(
            pgn: '',
            options: options,
          ),
          overrides: [
            defaultClientProvider
                .overrideWithValue(client(OpeningDatabase.player)),
          ],
        );
        await tester.pumpWidget(app);

        // wait for opening explorer data to load
        await tester.pump(const Duration(milliseconds: 50));

        final moves = [
          'c4',
        ];
        expect(find.byKey(const Key('moves-table')), findsOneWidget);
        for (final move in moves) {
          expect(find.widgetWithText(TableRowInkWell, move), findsOneWidget);
        }

        expect(find.widgetWithText(Container, 'Top games'), findsNothing);
        expect(find.widgetWithText(Container, 'Recent games'), findsOneWidget);
        expect(
          find.byKey(const Key('game-list')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('game-tile')),
          findsOneWidget,
        );

        await tester.pump(const Duration(milliseconds: 50));
      },
      variant: kPlatformVariant,
    );
  });
}

const mastersOpeningExplorerResponse = '''
{
  "white": 834333,
  "draws": 1085272,
  "black": 600303,
  "moves": [
    {
      "uci": "e2e4",
      "san": "e4",
      "averageRating": 2399,
      "white": 372266,
      "draws": 486092,
      "black": 280238,
      "game": null
    },
    {
      "uci": "d2d4",
      "san": "d4",
      "averageRating": 2414,
      "white": 302160,
      "draws": 397224,
      "black": 209077,
      "game": null
    }
  ],
  "topGames": [
    {
      "uci": "d2d4",
      "id": "QR5UbqUY",
      "winner": null,
      "black": {
        "name": "Caruana, F.",
        "rating": 2818
      },
      "white": {
        "name": "Carlsen, M.",
        "rating": 2882
      },
      "year": 2019,
      "month": "2019-08"
    },
    {
      "uci": "e2e4",
      "id": "Sxov6E94",
      "winner": "white",
      "black": {
        "name": "Carlsen, M.",
        "rating": 2882
      },
      "white": {
        "name": "Caruana, F.",
        "rating": 2818
      },
      "year": 2019,
      "month": "2019-08"
    }
  ],
  "opening": null
}
''';

const lichessOpeningExplorerResponse = '''
{
  "white": 2848672002,
  "draws": 225287646,
  "black": 2649860106,
  "moves": [
    {
      "uci": "d2d4",
      "san": "d4",
      "averageRating": 1604,
      "white": 1661457614,
      "draws": 129433754,
      "black": 1565161663,
      "game": null
    }
  ],
  "recentGames": [
    {
      "uci": "e2e4",
      "id": "RVb19S9O",
      "winner": "white",
      "speed": "rapid",
      "mode": "rated",
      "black": {
        "name": "Jcats1",
        "rating": 1548
      },
      "white": {
        "name": "carlosrivero32",
        "rating": 1690
      },
      "year": 2024,
      "month": "2024-06"
    }
  ],
  "topGames": [],
  "opening": null
}
''';

const playerOpeningExplorerResponse = '''
{
  "white": 1713,
  "draws": 119,
  "black": 1459,
  "moves": [
    {
      "uci": "c2c4",
      "san": "c4",
      "averageOpponentRating": 1767,
      "performance": 1796,
      "white": 1691,
      "draws": 116,
      "black": 1432,
      "game": null
    }
  ],
  "recentGames": [
    {
      "uci": "e2e4",
      "id": "abc",
      "winner": "white",
      "speed": "bullet",
      "mode": "rated",
      "black": {
        "name": "foo",
        "rating": 1869
      },
      "white": {
        "name": "baz",
        "rating": 1912
      },
      "year": 2023,
      "month": "2023-08"
    }
  ],
  "opening": null,
  "queuePosition": 0
}
''';
