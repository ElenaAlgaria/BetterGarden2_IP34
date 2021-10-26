import 'package:biodiversity/screens/login_page/register_email_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../environment/mock_provider_environment.dart';

void main() {
  testWidgets('test if all fields are present', (tester) async {
    await setUpBiodiversityEnvironment(
        tester: tester, widget: RegisterEmailPage());
    expect(find.widgetWithText(TextFormField, 'Nickname'), findsOneWidget,
        reason: 'Nickname field not present');
    expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget,
        reason: 'Name field not present');
    expect(find.widgetWithText(TextFormField, 'Nachname'), findsOneWidget,
        reason: 'Nachname field not present');
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget,
        reason: 'Email field not present');
    expect(find.widgetWithText(TextFormField, 'Passwort'), findsOneWidget,
        reason: 'Passwort field not present');
    expect(find.widgetWithText(TextFormField, 'Passwort wiederholen'),
        findsOneWidget,
        reason: 'Passwort wiederholen field not present');
    expect(find.widgetWithText(ElevatedButton, 'Registrieren'), findsOneWidget,
        reason: 'Registrieren field not present');
  });
}
