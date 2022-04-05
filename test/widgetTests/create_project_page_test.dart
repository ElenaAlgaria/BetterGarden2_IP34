import 'package:biodiversity/main.dart';
import 'package:biodiversity/screens/login_page/login_page.dart';
import 'package:biodiversity/screens/login_page/register_email_page.dart';
import 'package:biodiversity/screens/project_page/create_project_page.dart';
import 'package:biodiversity/screens/project_page/projects_overview_page.dart';
import 'package:firebase_core/firebase_core.dart';
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