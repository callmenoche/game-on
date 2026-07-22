import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_on/l10n/app_localizations.dart';
import 'package:game_on/models/group.dart';
import 'package:game_on/models/match.dart';
import 'package:game_on/widgets/profile_highlights.dart';

Match _match(SportType sport, DateTime when) => Match(
      id: 'm-${sport.name}-${when.millisecondsSinceEpoch}',
      creatorId: 'creator',
      sportType: sport,
      locationName: 'Le Terrain, quelque part avec un nom assez long',
      dateTime: when,
      createdAt: DateTime(2026, 1, 1),
    );

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SizedBox(width: 400, child: child)),
    );

void main() {
  testWidgets('ActivityStrip renders match cards without overflow',
      (tester) async {
    await tester.pumpWidget(_wrap(ActivityStrip(
      matches: [
        _match(SportType.padel, DateTime(2026, 7, 20)),
        _match(SportType.football, DateTime(2026, 7, 21)),
        _match(SportType.running, DateTime(2026, 7, 22)),
      ],
      emptyLabel: 'Nothing yet',
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(Card), findsNothing); // sanity: uses plain Containers
  });

  testWidgets('ActivityStrip renders empty state without overflow',
      (tester) async {
    await tester.pumpWidget(
        _wrap(const ActivityStrip(matches: [], emptyLabel: 'Nothing yet')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Nothing yet'), findsOneWidget);
  });

  testWidgets('TopSportsBars renders a ranked bar per sport, longest first',
      (tester) async {
    await tester.pumpWidget(_wrap(const TopSportsBars(counts: {
      SportType.padel: 7,
      SportType.football: 3,
      SportType.tennis: 1,
    })));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('TopSportsBars empty state renders without overflow',
      (tester) async {
    await tester.pumpWidget(_wrap(const TopSportsBars(counts: {})));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileGroupsStrip renders group chips, only members tappable',
      (tester) async {
    final groups = [
      Group(
        id: 'g1',
        name: 'Padel du dimanche',
        inviteCode: 'ABCD1234',
        creatorId: 'x',
        createdAt: DateTime(2026, 1, 1),
        memberCount: 12,
      ),
    ];
    await tester.pumpWidget(_wrap(ProfileGroupsStrip(
      groups: groups,
      isMember: (_) => false,
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Padel du dimanche'), findsOneWidget);
  });

  testWidgets('TopCoPlayersStrip renders avatars with count badges',
      (tester) async {
    await tester.pumpWidget(_wrap(const TopCoPlayersStrip(players: [
      (userId: 'u1', username: 'Zidane10', avatarUrl: null, count: 9),
      (userId: 'u2', username: 'a-very-long-username-here', avatarUrl: null, count: 2),
    ])));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
