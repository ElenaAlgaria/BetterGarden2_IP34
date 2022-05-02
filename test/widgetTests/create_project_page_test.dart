import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_provider_environment.dart';

// Todo: fix failing test
void main() {
  testWidgets('test if all fields are present', (tester) async {
     await setUpBiodiversityEnvironment(
        tester: tester, widget: CreateProjectPage());
    expect(find.widgetWithText(TextFormField, 'Projekttitel'), findsOneWidget,
      reason: 'Projekttitel field not present');
    expect(find.widgetWithText(TextFormField, 'Projektbeschreibung'), findsOneWidget,
      reason: 'Projektbeschreibung field not present');
    expect(find.text('Vernetzungsprojekt starten'), findsOneWidget,
      reason: 'Vernetzungsprojekt button is not present');
  });
}