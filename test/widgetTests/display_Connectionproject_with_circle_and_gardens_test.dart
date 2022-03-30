
import 'package:biodiversity/screens/map_page/maps_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../environment/mock_provider_environment.dart';

void main() {
  testWidgets('Check if circles are present', (tester) async {
    await setUpBiodiversityEnvironment(tester: tester, widget: MaterialApp(
      home:MapsPage()
    ));
    await tester.tap(find.byType(Marker));
    await tester.pumpAndSettle();

    expect(find.byType(MapsPage), findsNothing,
        reason: 'No Connectionprojects');

    expect((tester.firstWidget(find.byType(Marker)) as Marker).icon,'connectionProject');

    var circle = Circle;
    expect(circle, findsOneWidget, reason: 'No circle found');
  });

  testWidgets('Check if garden markes are green', (tester) async {
    await setUpBiodiversityEnvironment(tester: tester, widget: MapsPage());
    await tester.tap(find.byType(Marker));
    await tester.pumpAndSettle();

    expect(find.byType(MapsPage), findsNothing,
        reason: 'No Connectionprojects');

    expect((tester.firstWidget(find.byType(Marker)) as Marker).icon,'joinableGarden');

  });
}
